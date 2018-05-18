#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Functions for performing common SSIS tasks for SQL Server with PowerShell

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This sample is part of the Zero To Hero with PowerShell and SQL Server
  pre-con. 

  This code is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

Import-Module SqlServer

#region ConvertTo-ACSqlDateString
#-----------------------------------------------------------------------------#
# ConvertTo-ACSqlDateString - Takes a passed in date time and reformats it
# for use in a SQL Query.
#-----------------------------------------------------------------------------#
function ConvertTo-ACSqlDateString ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Date to be converted'
                   )
         ]
         [datetime]$SourceDateTime
       )

  $sqlDateString = $(date $SourceDateTime -Format 'yyyy-MM-dd') `
                   + 'T' + `
                   $(date $SourceDateTime -Format 'HH:mm:ss')

  return $sqlDateString  

}
#endregion ConvertTo-ACSqlDateString

#region Execute-ACPackage
#------------------------------------------------------------------------------
# Execute-ACPackage - Executes the specified package in the SSIS catalog
#------------------------------------------------------------------------------
function Execute-ACPackage()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Folder with the SSIS Package'
                   )
         ]
         [string]$FolderName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SSIS Project'
                   )
         ]
         [string]$ProjectName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SSIS Package'
                   )
         ]
         [string]$PackageName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The Server\Instance with the IS catalog'
                   )
         ]
         [string]$ServerInstance
       )

  $fn = "Execute-ACPackage:"

  if ($ServerInstance -eq $null)
  { $ServerInstance = $env:COMPUTERNAME }

  $sql = @"
    -- Create a variable to hold the execution id
    Declare @execution_id bigint

    -- This will create a new execution, basically a spot in memory where
    -- we can build up everything we need to execute the package
    EXEC [SSISDB].[catalog].[create_execution] @package_name=N'$($PackageName)'
                                             , @execution_id=@execution_id OUTPUT
                                             , @folder_name=N'$($FolderName)'
                                             , @project_name=N'$($ProjectName)'
                                             , @use32bitruntime=False
                                             , @reference_id=Null
    
    -- By selecting our execution ID, it will return it to the Invoke-SQLCmd
    SELECT @execution_id AS ExecutionID
    
    -- Tell SSIS we will use the default logging level
    DECLARE @var0 smallint = 1
    EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
                                                          , @object_type=50
                                                          , @parameter_name=N'LOGGING_LEVEL'
                                                          , @parameter_value=@var0
    
    -- Tell SSIS to run in syncronous mode, i.e. don't return from the
    -- start-execution stored proc until after the pacakge finishes execution
    EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
                                                          ,  @object_type=50
                                                          , @parameter_name=N'SYNCHRONIZED'
                                                          , @parameter_value=1

    -- Finally, go tell SSIS to execute the package
    EXEC [SSISDB].[catalog].[start_execution] @execution_id  
"@

  # Note the query timeout below is important, 0 basically says not to
  # timeout. If we don't include it, the query will timeout after 30
  # seconds (the default) which may not be enough time
  $connectionString = "Server = $serverInstance; Database = SSISDB; Integrated Security = True;"

  $execution = Invoke-Sqlcmd -Query $sql `
                             -ConnectionString $connectionString `
                             -QueryTimeout 0

  # Return the execution object to the caller
  return $execution

}
#endregion Execute-ACPackage

#region Get-ACExecutionStatus
#-----------------------------------------------------------------------------#
# Get-ACExecutionStatus - Gets the status of the execution ID that is 
# passed in. 
#-----------------------------------------------------------------------------#
function Get-ACExecutionStatus ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The Execution ID'
                   )
         ]
         [int]$ExecutionID
       , [Parameter( Mandatory=$true
                   , HelpMessage='The Server\Instance with the IS catalog'
                   )
         ]
         [string]$ServerInstance
       )

  $fn = "Get-ACExecutionStatus:"

  $sql = @"
SELECT CASE [status]
       WHEN 1 THEN 'Created'
       WHEN 2 THEN 'Running'
       WHEN 3 THEN 'Canceled'
       WHEN 4 THEN 'Failed'
       WHEN 5 THEN 'Pending'
       WHEN 6 THEN 'Ended unexpectedly'
       WHEN 7 THEN 'Succeeded'
       WHEN 8 THEN 'Stopping' 
       WHEN 9 THEN 'Completed'
       ELSE 'Unknown'
       END AS ExecutionStatus
  FROM [SSISDB].[catalog].[executions]
  WHERE execution_id = $ExecutionID
"@

  $connectionString = "Server = $serverInstance; Database = SSISDB; Integrated Security = True;"

  $results = Invoke-Sqlcmd -Query $sql `
                           -ConnectionString $connectionString `
                           -QueryTimeout 0

  return $results.ExecutionStatus
  
}
#endregion Get-ACExecutionStatus

#region Get-ACExecutionData
#-----------------------------------------------------------------------------#
# Get-ACExecutionData - Gets detailed execution data from package executions
#-----------------------------------------------------------------------------#
function Get-ACExecutionData ()
{
  [cmdletbinding()]
  param( [Parameter( Mandatory=$true
                   , HelpMessage='The Server\Instance with the IS catalog'
                   )
         ]
         [string]$ServerInstance
       , [int]$ExecutionID = -1
       , [datetime]$StartDate
       , [datetime]$EndDate
       , [switch]$Brief
       )

  $fn = "Get-ACExecutionStatus:"
  $hasWhere = $false

  $sql = @"
    SELECT [execution_id] AS ExecutionID
         , [machine_name] AS MachineName
         , [server_name]  AS ServerName
         , [folder_name]  AS FolderName
         , [project_name] AS ProjectName
         , [package_name] AS PackageName
         , [folder_name]  + '\' 
           + [project_name] + '\'
           + [package_name] AS PackagePath
         , CASE [object_type]
             WHEN 20 THEN 'Project'
             WHEN 30 THEN 'Package'
             ELSE 'Unknown Object Type - Value ' + CAST([object_type] AS VARCHAR)
           END AS ExecutionTarget
         , CASE [status]
             WHEN 1 THEN 'Created'
             WHEN 2 THEN 'Running'
             WHEN 3 THEN 'Canceled'
             WHEN 4 THEN 'Failed'
             WHEN 5 THEN 'Pending'
             WHEN 6 THEN 'Ended unexpectedly'
             WHEN 7 THEN 'Succeeded'
             WHEN 8 THEN 'Stopping' 
             WHEN 9 THEN 'Completed'
             ELSE 'Unknown Status - Value ' + CAST([status] AS VARCHAR)
           END AS ExecutionStatus     
         , [start_time] AS StartTime
         , [end_time] AS EndTime
         , DATEDIFF(ss, [start_time], [end_time]) AS DurationInSeconds
      FROM [SSISDB].[catalog].[executions]
"@

  if ($ExecutionID -gt -1)
  {
    if ($hasWhere -eq $false)
    {
      $sql += "`r`n WHERE [execution_id] = $ExecutionID "
      $hasWhere = $true
    }
  }

  if ($StartDate -ne $null)
  {
    $startDateString = ConvertTo-ACSqlDateString -SourceDateTime $StartDate

    if ($hasWhere -eq $false)
    { 
      $sql += "`r`n WHERE [end_time] >= '$startDateString' " 
      $hasWhere = $true
    }
    else
    { $sql += "`r`n   AND [end_time] >= '$startDateString' " }
  }

  if ($EndDate -ne $null)
  {
    $endDateString = ConvertTo-ACSqlDateString -SourceDateTime $EndDate

    if ($hasWhere -eq $false)
    { 
      $sql += "`r`n WHERE [end_time] <= '$endDateString' " 
      $hasWhere = $true
    }
    else
    { $sql += "`r`n   AND [end_time] <= '$endDateString' " }
  }

  $sql += "`r`n ORDER BY [end_time] DESC"

  Write-Verbose "$fn `r`n $sql"

  $connectionString = "Server = $serverInstance; Database = SSISDB; Integrated Security = True;"

  $results = Invoke-Sqlcmd -Query $sql `
                           -ConnectionString $connectionString `
                           -QueryTimeout 0
  if ($Brief -eq $true)
  {
    $results = $results |
      Select-Object -Property ExecutionID, ServerName, PackagePath, `
                              ExecutionStatus, StartTime, EndTime, `
                              DurationInSeconds
  }

  return $results
  
}
#endregion Get-ACExecutionData

#region Invoke-ACSimulatedPackageExecution
#-----------------------------------------------------------------------------#
# Invoke-ACSimulatedPackageExecution - Executes packages and changes the
# clock to simulate execution over time.
#-----------------------------------------------------------------------------#
function Invoke-ACSimulatedPackageExecution ()
{
  [cmdletbinding()]
  param( [Parameter( Mandatory=$true
                   , HelpMessage='The Server\Instance with the IS catalog'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='Folder with the SSIS Package'
                   )
         ]
         [string]$FolderName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SSIS Project'
                   )
         ]
         [string]$ProjectName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SSIS Package'
                   )
         ]
         [string]$PackageName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The start date to begin running the package'
                   )
         ]
         [string]$StartDate
       , [Parameter( Mandatory=$true
                   , HelpMessage='The start time to begin running the package'
                   )
         ]
         [string]$StartTime
       , [Parameter( Mandatory=$true
                   , HelpMessage='The end date to stop running the package'
                   )
         ]
         [string]$EndDate
       , [Parameter( Mandatory=$true
                   , HelpMessage='The end time to stop running the package'
                   )
         ]
         [string]$EndTime
       , [Parameter( Mandatory=$true
                   , HelpMessage='The amount of time to increment. d=days h=hours m=minutes'
                   )
         ]
         [string]$IncrementUnit
       , [Parameter( Mandatory=$true
                   , HelpMessage='The amount of IncrementUnits to add after each run'
                   )
         ]
         [string]$IncrementAmount
       )
  
  # Time to kick off the packages. The idea is to simulate a SQL Agent Job that
  # kicks off the package at the same time everday.
  $executionTime = $StartTime

  [DateTime]$runDateTime = "$($StartDate) $($StartTime)"
  [DateTime]$runToDateTime = "$($EndDate) $($EndTime)"

  do  # Loop for each date in the date range
  {
    # Reset the clock for the current run
    Set-Date -date $runDateTime | Out-Null
    
    # Give a warm fuzzy we're doing something  
    Write-Verbose "Executing $($packageName) : $($runDateTime) "    
  
    # Execute the package 
    $execution = Execute-ACPackage -ServerInstance $ServerInstance `
                                   -FolderName $FolderName `
                                   -ProjectName $ProjectName `
                                   -PackageName $PackageName     
   
    $status = Get-ACExecutionStatus -ServerInstance $ServerInstance `
                                    -ExecutionID $execution.ExecutionID    

    # Let user know this one is done
    Write-Verbose "Completed $($packageName) : $($runDateTime) Status:$status ID: $($execution.ExecutionID) " 
  
    # Give a slight pause for the execution logs to finish writing. 
    # Found a few cases where the time changed before the logs finished updating and
    # it was causing it to look like we had execution times of 23 hours. :-/
    Start-Sleep -Seconds 15 
  
    # Advance date/time for next run
    switch ($IncrementUnit)
    {
      'd' { $runDateTime = $runDateTime.AddDays($IncrementAmount); break }
      'h' { $runDateTime = $runDateTime.Hours($IncrementAmount); break }
      'm' { $runDateTime = $runDateTime.AddMinutes($IncrementAmount); break }   
      default { $runDateTime = $runDateTime.AddMinutes(15); break }
    }
    
  } while ($runDateTime -lt $runToDateTime)

}
#endregion Invoke-ACSimulatedPackageExecution
