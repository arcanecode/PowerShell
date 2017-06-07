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
  .SYNOPSIS
  Tests for the existance of the specified table.

  .DESCRIPTION
  Tests to see if the table name passed into the function exists. 
  
  .INPUTS
  PodcastDatabaseName - The name of the database to look in. By default if
  no name is passed in the company standard of PodcastSight is used. 

  PodcastTableName - The name of the table to look for. 
  
  .OUTPUTS
  $true if the table is found, $false if it is not.
  
  .EXAMPLE
  $result = Test-PodcastTable -PodcastDatabaseName 'PodcastSight' -PodcastTableName 'NoAgenda'

  .EXAMPLE
  $result = Test-PodcastTable 'PodcastSight' 'NoAgenda'

  .EXAMPLE
  $result = Test-PodcastTable -PodcastTableName 'NoAgenda'

  .EXAMPLE
  $result = Test-PodcastTable 'NoAgenda'

#>
function Test-PodcastTable()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $PodcastDatabaseName = 'PodcastSight'
    ,
    [parameter (Mandatory = $true) ]
    $PodcastTableName 
  )

  # Check to see if they included a schema, if not use dbo
  if ($PodcastTableName.Contains('.'))
  {
    $tbl = $PodcastTableName
  }
  else
  {
    $tbl = "dbo.$PodcastTableName"
  }

  Write-Verbose "Test-PodcastTable.....: Checking for Table $tbl in $PodcastDatabaseName "

  $dbcmd = @"
    SELECT COUNT(*) AS TableExists
      FROM [INFORMATION_SCHEMA].[TABLES]
     WHERE [TABLE_SCHEMA] + '.' + [TABLE_NAME] = '$tbl'
"@

  $result = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -Database $PodcastDatabaseName `
                          -SuppressProviderContextWarning 
 
  if ($($result.TableExists) -eq 0)
  { $return = $false }
  else
  { $return = $true }

  # Let user know
  Write-Verbose "Test-PodcastTable.....: Table $tbl exists: $return"

  # Return the result of the test
  return $return

} # function Test-PodcastTable
