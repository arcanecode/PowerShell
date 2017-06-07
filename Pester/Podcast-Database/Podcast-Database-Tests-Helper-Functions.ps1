<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

<#
    This script contains functions that will be useful within the tests, and useful in more
    than one test file. 

    For all of the functions, we will add the scope specifier of 'global' before the name. 
    This is due to the behavoir of Pesters InModuleScope. Once that line is invoked the 
    scope localizes to that of the module, and thus functions and variables created prior 
    to the InModuleScope line won't be visible within it, unless a global scope is declared 
    when creating a function or variable. 
  
#>


function global:Find-NonexistantPodcastDbName ()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $RootDatabaseName = 'PodcastDatabaseTest'
  )
  
  # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
  Push-Location
  Import-Module SqlPS -DisableNameChecking
  Pop-Location

  $testDbName = '' # Initialize variable for looping
  
  $retDbName = ''  # This will hold the value to return
  
  for($i=1; $i -le 100; $i++)
  {
    $testDbName = $RootDatabaseName + $i.ToString()
    $dbcmd = @"
      SELECT COUNT(*) AS DbExists
        FROM [master].[sys].[databases]
       WHERE [name] = '$($testDbName)'  
"@
    $result = Invoke-Sqlcmd -Query $dbcmd `
    -ServerInstance $env:COMPUTERNAME `
    -Database 'master' `
    -SuppressProviderContextWarning 
     
    if ($($result.DbExists) -eq 0)
    { 
      $retDbName = $testDbName
      break 
    }
  
  } # for($i=1; $i -le 100; $i++)
      
  # It's highly unlikely we won't be able to find a db name that doesn't exist, but just in case...
  if ($retDbName -eq '')
  {
    throw "Could not find an available database using the root of $RootDatabaseName "
  }

  Write-Verbose "global:Find-NonexistantPodcastDbName Found that database $retDbName does not exist"
  return $retDbName

} # function Find-NonexistantPodcastDbName



function global:Find-ExistingPodcastDbName ()
{
  
  # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
  Push-Location
  Import-Module SqlPS -DisableNameChecking
  Pop-Location

  $dbcmd = 'SELECT TOP 1 [Name] AS DbName FROM [master].[sys].[databases]'
  $result = Invoke-Sqlcmd -Query $dbcmd `
  -ServerInstance $env:COMPUTERNAME `
  -Database 'master' `
  -SuppressProviderContextWarning 
   
  Write-Verbose "global:Find-ExistingPodcastDbName: Found a database that exists: $($result.DbName)"
  return $result.DbName

} # function Find-ExistingPodcastDbName

function global:Confirm-PodcastDbExists 
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $DatabaseName = 'PodcastSight'
  )

  # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
  Push-Location
  Import-Module SqlPS -DisableNameChecking
  Pop-Location

  $retVal = $false # This will hold the value to return
  
  $dbcmd = @"
    SELECT [Name] AS DbName 
      FROM [master].[sys].[databases] 
     WHERE [Name] = '$($DatabaseName)'
"@
  $result = Invoke-Sqlcmd -Query $dbcmd `
  -ServerInstance $env:COMPUTERNAME `
  -Database 'master' `
  -SuppressProviderContextWarning 
   
  if ($result.DbName -eq $DatabaseName)
  {
    Write-Verbose "global:Confirm-PodcastDbExists: The $DatabaseName database exists"
    $retVal = $true
  }
  else
  {
    Write-Verbose "global:Confirm-PodcastDbExists: The $DatabaseName database does not exist"
    $retVal = $false
  }
  
  return $retVal 

} # global:Confirm-PodcastDbExists 

function global:Confirm-PodcastTableExists 
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $DatabaseName = 'PodcastSight'
    ,
    [parameter (Mandatory = $false) ]
    $TableName = 'Staging'
  )

  # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
  Push-Location
  Import-Module SqlPS -DisableNameChecking
  Pop-Location

  $retVal = $false # This will hold the value to return
  
  $dbcmd = @"
    SELECT [Name] AS TableName 
      FROM [$($DatabaseName)].[sys].[tables] 
     WHERE [Name] = '$($TableName)'
"@
  $result = Invoke-Sqlcmd -Query $dbcmd `
  -ServerInstance $env:COMPUTERNAME `
  -Database 'master' `
  -SuppressProviderContextWarning 
   
  if ($result.TableName -eq $TableName)
  {
    Write-Verbose "global:Confirm-PodcastTableExists: The $TableName table exists"
    $retVal = $true
  }
  else
  {
    Write-Verbose "global:Confirm-PodcastTableExists: The $TableName table does not exist"
    $retVal = $false
  }
  
  return $retVal 

} # global:Confirm-PodcastTableExists 

function global:Confirm-PodcastProcedureExists 
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $DatabaseName = 'PodcastSight'
    ,
    [parameter (Mandatory = $false) ]
    $ProcedureName = 'InsertStagingData'
  )

  # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
  Push-Location
  Import-Module SqlPS -DisableNameChecking
  Pop-Location

  $retVal = $false # This will hold the value to return
  
  $dbcmd = @"
    SELECT [Name] AS ProcedureName 
      FROM [$($DatabaseName)].[sys].[procedures] 
     WHERE [Name] = '$($ProcedureName)'
"@
  $result = Invoke-Sqlcmd -Query $dbcmd `
  -ServerInstance $env:COMPUTERNAME `
  -Database 'master' `
  -SuppressProviderContextWarning 
   
  if ($result.ProcedureName -eq $ProcedureName)
  {
    Write-Verbose "global:Confirm-PodcastProcedureExists: The $ProcedureName stored procedure exists"
    $retVal = $true
  }
  else
  {
    Write-Verbose "global:Confirm-PodcastProcedureExists: The $ProcedureName stored procedure does not exist"
    $retVal = $false
  }
  
  return $retVal 

} # global:Confirm-PodcastProcedureExists 

# Create a function to get a list of column names from the staging table
function global:Get-PodcastColumnNames 
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $DatabaseName = 'PodcastSight'
    ,
    [parameter (Mandatory = $false) ]
    $TableName = 'Staging'
  )

  # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
  Push-Location
  Import-Module SqlPS -DisableNameChecking
  Pop-Location

  $dbcmd = @"
    SELECT c.[name] as ColumnName
      FROM [sys].[columns] c JOIN [sys].[tables] t ON c.[object_id] = t.[object_id]
     WHERE t.[name] = '$($TableName)'
"@
  $result = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -Database $DatabaseName `
                          -SuppressProviderContextWarning 

  # Returns a result where you can test $result.ColumnName.Contains($colName)
  return $result    
}

