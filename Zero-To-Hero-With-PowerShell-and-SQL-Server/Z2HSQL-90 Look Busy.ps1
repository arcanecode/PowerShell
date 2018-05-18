#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  This script is intended to keep SQL Server busy long enough to generate
  some statistics and other activity indicators. It is used as part of the
  monitoring section in Z2HSQL-02 DBA.ps1.

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


function Invoke-ACSqlCmd ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The sql statement to execute'
                   )
         ]
         [string]$SQL
       )

  $connectionString = "Server = $Computer; Database = $DatabaseName; Integrated Security = True;"
  
  # To use with credentials, instead use:
  # $connectionString = "Server = $sqlServer; Database = $dbName; User ID = $uid; Password = $pwd;"

  $data = Invoke-Sqlcmd -Query $SQL `
                        -ConnectionString $connectionString

  return $data
}

function Submit-ACSqlCmd ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The sql statement to execute'
                   )
         ]
         [string]$SQL
       )

  $connectionString = "Server = $Computer; Database = $DatabaseName; Integrated Security = True;"
  
  # To use with credentials, instead use:
  # $connectionString = "Server = $sqlServer; Database = $dbName; User ID = $uid; Password = $pwd;"

  Invoke-Sqlcmd -Query $SQL `
                -ConnectionString $connectionString

}


function ConvertTo-ACArray ()
{
  [cmdletbinding()]
  param(
         $DataRows
       , $ColumnName
       )

  $dataArray = @()
  foreach ($dataRow in $DataRows)
  {
    $dataArray += $dataRow.$ColumnName
  }
  
  return $dataArray

}

function Get-ACDatabaseNames ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       )

  $sql = @'
    SELECT [name] AS DatabaseName 
      FROM master.sys.databases 
     WHERE [name] 
       NOT IN ('master', 'tempdb', 'model', 'msdb')
'@
  
  $databases = Invoke-ACSqlCmd -ComputerName $ComputerName `
                               -DatabaseName 'master' `
                               -SQL $sql

  $databasesArray = ConvertTo-ACArray -DataRows $databases `
                                      -ColumnName 'DatabaseName'
  
  return $databasesArray 
}

function Get-TableNames ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       )

  $sql = @"
  SELECT '[' + TABLE_SCHEMA + '].[' + TABLE_NAME + ']' AS FullTableName 
    FROM [$DatabaseName].INFORMATION_SCHEMA.TABLES
   ORDER BY TABLE_SCHEMA, TABLE_NAME
"@
  
  $tables = Invoke-ACSqlCmd -ComputerName $ComputerName `
                            -DatabaseName $DatabaseName `
                            -SQL $sql

  $tableArray = ConvertTo-ACArray -DataRows $tables `
                                  -ColumnName 'FullTableName'

  return $tableArray 
}

function Get-ACRowCount ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table including schema'
                   )
         ]
         [string]$TableName
       )

  $sql = @"
  SELECT NumRows = COUNT(*)
    FROM $DatabaseName.$TableName
"@
  
  $rowCount = Invoke-ACSqlCmd -ComputerName $ComputerName `
                              -DatabaseName $DatabaseName `
                              -SQL $sql
  
  return $rowCount.NumRows
  
}

function Clear-ACTable ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , 
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table including schema'
                   )
         ]
         [string]$TableName
       )
  
  $sql = "TRUNCATE TABLE $TableName"

  Submit-ACSqlCmd -ComputerName $ComputerName `
                  -DatabaseName $DatabaseName `
                  -SQL $sql
}

function Save-ACRandomNumberOfRows ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       )

  $databaseName = 'InsertTest'
  Clear-ACTable -ComputerName $ComputerName `
                -DatabaseName $databaseName `
                -TableName 'dbo.InsertTestTable'

  $numRows = Get-Random -Minimum 500 -Maximum 10000

  for ($curRow = 1; $curRow -le $numRows; $curRow++)
  {
    $sql = @"
      INSERT INTO [dbo].[InsertTestTable] ([ABigNumber])
      VALUES ($curRow)
"@

    Submit-ACSqlCmd -ComputerName $ComputerName `
                    -DatabaseName $databaseName `
                    -SQL $sql
  }

}

$sqlServer = $env:COMPUTERNAME
$dataBases = Get-ACDatabaseNames -ComputerName $sqlServer

$passes = 20
for ($x = 1; $x -le $passes; $x++)
{
  Write-Host "Pass $x of $passes : Writing a random number of rows" -ForegroundColor Green
  Save-ACRandomNumberOfRows -ComputerName $sqlServer

  # Get a random database
  $randomDB = $dataBases | Get-Random
  
  #$randomDB = 'ReportServerTempDB'
  $tables = Get-TableNames -ComputerName $sqlServer -DatabaseName $randomDB
  $randomTable = $tables | Get-Random
  
  $dbTable = "$randomDB.$randomTable"
  
  $numRows = Get-ACRowCount -ComputerName $sqlServer `
                            -DatabaseName $randomDB `
                            -Table $randomTable

  if ($numRows -gt 1)
  {
    $getRows = Get-Random -Minimum 1 -Maximum $numRows
    $sql = @"
    SELECT TOP $getRows *
      FROM $dbTable
"@
  
  $connectionString = "Server = $sqlServer; Database = $randomDB; Integrated Security = True;"
  
  Write-Host "Pass $x of $passes : Getting $getRows rows from $dbTable" -ForegroundColor Yellow
  $someData =  Invoke-Sqlcmd -Query $sql `
                             -ConnectionString $connectionString `
                             -ErrorAction SilentlyContinue
 }
 
}
