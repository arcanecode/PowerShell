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
  Tests to see if a specified database exists.

  .DESCRIPTION
  Takes the name of the passed in database and runs a query against the master
  database to see if the passed in database exists. 

  Note the user executing the query must have permissions to execute a read 
  only query against the master database.
  
  .INPUTS
  PodcastDatabaseName - The name of the database to create. If omitted, the
  company standard name of 'PodcastSight' is used.
  
  .OUTPUTS
  $true if the database exists, $false otherwise.
  
  .EXAMPLE
  $result = Test-PodcastDatabase 'PodcastSight'

  .EXAMPLE
  $result = Test-PodcastDatabase -PodcastDatabaseName 'PodcastSight'

  .EXAMPLE
  $result = Test-PodcastDatabase 
  
#>
function Test-PodcastDatabase()
{ 
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $PodcastDatabaseName = 'PodcastSight'
  )

  Write-Verbose "Test-PodcastDatabase..: Testing for database $PodcastDatabaseName"


  # Testing is done on the server running SQL Server

  <#
      Note you might think you could do something like:
       $machine = $env:COMPUTERNAME
       $path = "SQLServer:\SQL\$machine\default\databases\$PodcastDatabaseName"
       $return = Test-Path $path
     
      Unfortunately there can be a timing issue. If you do a New-PodcastDatabase (for example) and 
      immediately check the results using the above method, the SQL Provider may not have time to refresh 
      and thus report the database as not existing. 

      Therefore we need to query the server directly and see if it is there. 
  #>

  $dbcmd = @"
    SELECT COUNT(*) AS DbExists
      FROM [master].[sys].[databases]
     WHERE [name] = '$($PodcastDatabaseName)'  
"@

  # At PodcastSight, all SQL Servers are setup with default as the instance
  # Thus we can just use the computer name as the server instance, which will
  # use the default instance
  $result = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -Database 'master' `
                          -SuppressProviderContextWarning 
  
  # If the count of databases with that name is 0, it doesn't exist
  if ($($result.DbExists) -eq 0)
  { $return = $false }
  else
  { $return = $true }
     
  # Let user know
  Write-Verbose "Test-PodcastDatabase..: Database $PodcastDatabaseName exists: $return"

  # Return the result of the test
  return $return

} # function Test-PodcastDatabase
