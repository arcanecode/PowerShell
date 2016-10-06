<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server
  Speed test SQLPS vs SMO

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2014 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 -----------------------------------------------------------------------------#>

  # Before we begin, make sure both the SQLPS and SMO providers have been loaded as demonstrated
  # in the Z2H SQL.ps1 and Z2H SMO.ps1 demo files. 

  #-----------------------------------------------------------------------------------------------#
  # Real World Example:
  # Looking for columns of a certain data type using the SQL Provider
  #-----------------------------------------------------------------------------------------------#
    
  # SQLPS wants the instance even if it is default
  $serverInstance = $env:COMPUTERNAME + "\default"  
  $serverInstance = $env:COMPUTERNAME + "\SQL2014"  # Note the demo box uses a named instance SQL2014

  # Grab the start time so we can get some metrics on how long this runs
  $Start = Get-Date

  $matches = 0
  $dbCollection = (Get-Item SQLSERVER:\sql\$serverInstance\databases -Force).Collection
  
  foreach($db in $dbCollection)
  {
    $rootPath = "SQLSERVER:\sql\$serverInstance\databases\$($db.Name)\"
    $tablePath = "$rootPath\tables"
    $tableCollection = (Get-Item $tablePath -Force).Collection
    foreach($table in $tableCollection)
    {
      $tableName = "$($db.Name)\$($table.schema).$($table.name)"
      $columnPath = "$rootPath\tables\$($table.Schema).$($table.Name)\Columns"      
      $columnCollection = (Get-Item $columnPath).Collection
      foreach($column in $columnCollection)
      { 
        if($column.DataType.ToString() -eq 'bigint' ) 
        {
          "$tableName.$($column) is a BigInt"
          $matches++
        }  
      }
    }
  }

  $End = Get-Date  # Stop the timer
  "`n"
  "$matches Matches"
  
  # The end-start results in a date-time object, which you can get the 
  # various properties of, including total milliseonds or seconds
  $elapsed = $end - $start
  "Elapsed Time $($elapsed.TotalSeconds) Seconds ( $($elapsed.TotalMilliseconds) Milliseconds)"

# 147 Matches
# Elapsed Time 93.7865923 Seconds ( 93786.5923 Milliseconds)
##


  #-----------------------------------------------------------------------------------------------#
  # Real World Example:
  # Looking for columns of a certain data type using SMO
  #-----------------------------------------------------------------------------------------------#
   
  # If the instance is the default instance, SMO does NOT want it included
  $serverInstance = $env:COMPUTERNAME # + "\default"  
  $serverInstance = $env:COMPUTERNAME + "\SQL2012"  # Note the demo box uses a named instance SQL2012

  $Start = Get-Date

  $matches = 0
  $Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
  foreach($database in $Server.Databases)
  {
    foreach($table in $database.Tables)
    {
      $tableName = "$($database.Name)\$($table.schema).$($table.Name)"
      foreach($column in $table.Columns)
      { 
        if($column.DataType.ToString() -eq "bigint" )
        {
          "$tableName.$($column.Name) is a BigInt"
          $matches++
        }  
      }
    }
  }  

  $End = Get-Date
  "`n"
  "$matches Matches"
  $elapsed = $end - $start
  "Elapsed Time $($elapsed.TotalSeconds) Seconds ( $($elapsed.TotalMilliseconds) Milliseconds)"


  # My test on my system:
  # 147 Matches
  # Elapsed Time 17.1440635 Seconds ( 17144.0635 Milliseconds)  



###