#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Demonstrate common Developer tasks for SQL Server with PowerShell

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

function Test-ACDatabase ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance for the new database'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to create'
                   )
         ]
         [string]$DatabaseName
       )

  $fn = "Test-ACDatabase:"

  Write-Verbose "$fn Checking to see if $DatabaseName exists on $ServerInstance"
  $exists = Get-SqlDatabase -ServerInstance $ServerInstance `
                            -Credential $Credentials |
              Where-Object Name -eq $DatabaseName

  if ($exists -eq $null)
  { 
    Write-Verbose "$fn $DatabaseName does not exist on $ServerInstance"
    $retVal = $false 
  }
  else
  { 
    Write-Verbose "$fn $DatabaseName exists on $ServerInstance"
    $retVal = $true 
  }

  return $retVal  

}

function New-ACDatabase ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
          , HelpMessage='The name of the database to create'
          )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
          , HelpMessage='The name of the server/instance for the new database'
          )
         ]
         [string]$DatabaseName
       )

  $fn = "New-ACDatabase:"
  # First make sure if it exists or not
  $exists = Test-ACDatabase -Credentials $Credentials `
                            -ServerInstance $ServerInstance `
                            -DatabaseName $DatabaseName

  if ($exists -eq $false)
  {
    Write-Verbose "$fn Creating database $DatabaseName on $ServerInstance"
    $connectionString = "Server = $serverInstance; Database = master; Integrated Security = True;"

    $sql = @"
      CREATE DATABASE $DatabaseName
"@
    
    Invoke-Sqlcmd -Query $sql -ConnectionString $connectionString
  }
  else
  {
    Write-Verbose "$fn Database $DatabaseName on $ServerInstance already exists, no action taken"
  }
}

function Remove-ACDatabase ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
          , HelpMessage='The name of the database to create'
          )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
          , HelpMessage='The name of the server/instance for the new database'
          )
         ]
         [string]$DatabaseName
       )

  $fn = "Remove-ACDatabase:"
  # First make sure if it exists or not
  $exists = Test-ACDatabase -Credentials $Credentials `
                            -ServerInstance $ServerInstance `
                            -DatabaseName $DatabaseName

  if ($exists -eq $true)
  {
    Write-Verbose "$fn Removing database $DatabaseName on $ServerInstance"
    $connectionString = "Server = $serverInstance; Database = master; Integrated Security = True;"
    
    # First force the db into single user mode to close connections
    $sql = @"
      ALTER DATABASE $DatabaseName SET single_user WITH ROLLBACK immediate
"@
    Invoke-Sqlcmd -Query $sql -ConnectionString $connectionString

    # Now drop it.
    $sql = @"
      DROP DATABASE $DatabaseName
"@
    Invoke-Sqlcmd -Query $sql -ConnectionString $connectionString
  }
  else
  {
    Write-Verbose "$fn Database $DatabaseName on $ServerInstance did not exist, not action taken"
  }

}

function Test-ACSchema ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the schema'
                   )
         ]
         [string]$SchemaName
       )

  $fn = "Test-ACSchema:"

  Write-Verbose "$fn Checking to see if $SchemaName exists in $DatabaseName "
  $sql = @"
    SELECT [SCHEMA_NAME]
      FROM [INFORMATION_SCHEMA].[SCHEMATA]
     WHERE [SCHEMA_NAME] = '$SchemaName'
"@

  $results = Invoke-Sqlcmd -Query $sql `
                           -Database $DatabaseName `
                           -ServerInstance $ServerInstance `
                           -Credential $Credentials

  if ($results.SCHEMA_NAME -eq $null)
  { 
    Write-Verbose "$fn $SchemaName does not exist in $DatabaseName"
    $retVal = $false 
  }
  else
  { 
    Write-Verbose "$fn $SchemaName exists in $DatabaseName"
    $retVal = $true 
  }

  return $retVal  

}

function New-ACSchema ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the schema'
                   )
         ]
         [string]$SchemaName
       )

  $fn = "New-ACSchema:"

  Write-Verbose "$fn Checking to see if $SchemaName exists in $DatabaseName "
  $exists = Test-ACSchema -Credentials $Credentials `
                          -ServerInstance $serverInstance `
                          -DatabaseName $databaseName `
                          -SchemaName $schemaName 

  if ($exists -eq $false)
  {
    Write-Verbose "$fn Creating Schema $SchemaName in $DatabaseName"
    $sql = "CREATE SCHEMA [$SchemaName]"

    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials
  }
  else
  {
    Write-Verbose "$fn Schema $SchemaName in $DatabaseName already exists, no action taken"
  }
}

function Remove-ACSchema ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the schema'
                   )
         ]
         [string]$SchemaName
       )

  $fn = "Remove-ACSchema:"

  Write-Verbose "$fn Checking to see if $SchemaName exists in $DatabaseName "
  $exists = Test-ACSchema -Credentials $Credentials `
                          -ServerInstance $serverInstance `
                          -DatabaseName $databaseName `
                          -SchemaName $schemaName 

  if ($exists -eq $true)
  {
    Write-Verbose "$fn Dropping Schema $SchemaName in $DatabaseName"
    $sql = "DROP SCHEMA [$SchemaName]"

    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials
  }
  else
  {
    Write-Verbose "$fn Schema $SchemaName in $DatabaseName did not exist, no action taken"
  }
}

function Test-ACTable ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table excluding schema'
                   )
         ]
         [string]$TableName
       )

  $fn = "Test-ACTable:"

  Write-Verbose "$fn Checking to see if $SchemaName.$TableName exists in $DatabaseName "
  $sql = @"
    SELECT [TABLE_SCHEMA] + '.' + [TABLE_NAME] AS SchemaTable
      FROM [INFORMATION_SCHEMA].[TABLES]
     WHERE [TABLE_SCHEMA] = '$SchemaName'
       AND [TABLE_NAME] = '$TableName'
"@

  $results = Invoke-Sqlcmd -Query $sql `
                           -Database $DatabaseName `
                           -ServerInstance $ServerInstance `
                           -Credential $Credentials

  if ($results.SchemaTable -eq $null)
  { 
    Write-Verbose "$fn $SchemaName.$TableName does not exist in $DatabaseName"
    $retVal = $false 
  }
  else
  { 
    Write-Verbose "$fn $SchemaName.$TableName exists in $DatabaseName"
    $retVal = $true 
  }

  return $retVal  

}

function New-ACTable ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table excluding schema'
                   )
         ]
         [string]$TableName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The definition of the table, basically the stuff inside the () of a create table statement'
                   )
         ]
         [string]$TableDefinition
       )

  $fn = "New-ACTable:"

  Write-Verbose "$fn Checking to see if $SchemaName.$TableName exists in $DatabaseName "
  $exists = Test-ACTable -Credentials $Credentials `
                          -ServerInstance $serverInstance `
                          -DatabaseName $DatabaseName `
                          -SchemaName $SchemaName `
                          -TableName $TableName

  if ($exists -eq $false)  
  {
    Write-Verbose "$fn Creating Table $SchemaName.$TableName"
    $sql = @"
      CREATE TABLE $SchemaName.$TableName
      (
        $TableDefinition
      )
"@

    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials
    
  }
  else
  {
    Write-Verbose "$fn Table $SchemaName.$TableName already exists, no action taken"
  }
}

function Remove-ACTable ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table excluding schema'
                   )
         ]
         [string]$TableName
       )

  $fn = "Remove-ACTable:"
  $ftn = "$SchemaName.$TableName" # Full Table Name

  Write-Verbose "$fn Checking to see if $ftn exists in $DatabaseName "
  $exists = Test-ACTable -Credentials $Credentials `
                          -ServerInstance $serverInstance `
                          -DatabaseName $DatabaseName `
                          -SchemaName $SchemaName `
                          -TableName $TableName
  if ($exists -eq $true)  
  {
    Write-Verbose "$fn Removing Table $ftn"
    $sql = @"
      DROP TABLE $ftn
"@

    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials    
  }
  else
  {
    Write-Verbose "$fn Table $ftn didn't exist, no action taken"
  }

}

function Clear-ACTable ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table excluding schema'
                   )
         ]
         [string]$TableName
       )

  $fn = "Remove-ACTable:"
  $ftn = "$SchemaName.$TableName" # Full Table Name

  Write-Verbose "$fn Checking to see if $ftn exists in $DatabaseName "
  $exists = Test-ACTable -Credentials $Credentials `
                          -ServerInstance $serverInstance `
                          -DatabaseName $DatabaseName `
                          -SchemaName $SchemaName `
                          -TableName $TableName
  if ($exists -eq $true)  
  {
    Write-Verbose "$fn Truncating Table $SchemaName.$TableName"
    $sql = @"
      TRUNCATE TABLE $ftn
"@

    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials    
  }
  else
  {
    Write-Verbose "$fn Table $ftn does not exist, no action taken"
  }

}

function Get-ACTableRowCount ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the table excluding schema'
                   )
         ]
         [string]$TableName
       )

  $fn = "Get-ACTableRowCount:"
  $ftn = "$SchemaName.$TableName" # Full Table Name

  Write-Verbose "$fn Checking to see if $ftn exists in $DatabaseName "
  $exists = Test-ACTable -Credentials $Credentials `
                         -ServerInstance $serverInstance `
                         -DatabaseName $DatabaseName `
                         -SchemaName $SchemaName `
                         -TableName $TableName
  
  if ($exists -eq $true)  
  {
    Write-Verbose "$fn Getting row count for $ftn"
    $sql = @"
      SELECT COUNT(*) AS NumRows FROM $ftn
"@

    $results = Invoke-Sqlcmd -Query $sql `
                             -Database $DatabaseName `
                             -ServerInstance $ServerInstance `
                             -Credential $Credentials    
    $retVal = $results.NumRows
  }
  else
  {
    Write-Verbose "$fn Table $ftn does not exist, no action taken"
    $retVal = -1   # Set to -1 to indicate we had an issue
  }

  return $retVal

}

function Test-ACView ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the view excluding schema'
                   )
         ]
         [string]$ViewName
       )

  $fn = "Test-ACView:"
  $fvn = "$SchemaName.$ViewName" # Full View Name

  Write-Verbose "$fn Checking to see if $fvn exists in $DatabaseName "
  $sql = @"
    SELECT [TABLE_SCHEMA] + '.' + [TABLE_NAME] AS SchemaView
      FROM [INFORMATION_SCHEMA].[VIEWS]
     WHERE [TABLE_SCHEMA] = '$SchemaName'
       AND [TABLE_NAME] = '$ViewName'
"@

  $results = Invoke-Sqlcmd -Query $sql `
                           -Database $DatabaseName `
                           -ServerInstance $ServerInstance `
                           -Credential $Credentials

  if ($results.SchemaView -eq $null)
  { 
    Write-Verbose "$fn $fvn does not exist in $DatabaseName"
    $retVal = $false 
  }
  else
  { 
    Write-Verbose "$fn $fvn exists in $DatabaseName"
    $retVal = $true 
  }

  return $retVal  

}

function New-ACView ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the view excluding schema'
                   )
         ]
         [string]$ViewName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The definition of the View, basically the stuff after the create view statement'
                   )
         ]
         [string]$ViewDefinition
       , [switch]$Update
       )

  $fn = "New-ACView:"
  $fvn = "$SchemaName.$ViewName"  # Full View Name

  $sql = @"
    CREATE OR ALTER VIEW $fvn AS
      $ViewDefinition
"@
  Write-Verbose "$fn Checking to see if $fvn exists in $DatabaseName "
  $exists = Test-ACView -Credentials $Credentials `
                          -ServerInstance $serverInstance `
                          -DatabaseName $DatabaseName `
                          -SchemaName $SchemaName `
                          -ViewName $ViewName

  # If the view doesn't exist, or if they said update, do it!
  if ( $exists -eq $false ) 
  {
    Write-Verbose "$fn Creating View $fvn on $DatabaseName"
    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials
  }
  else
  {
    if ( $Update -eq $true )
    {
      Write-Verbose "$fn Updating View $fvn on $DatabaseName"
      Invoke-Sqlcmd -Query $sql `
                    -Database $DatabaseName `
                    -ServerInstance $ServerInstance `
                    -Credential $Credentials
    }
    else
    {
      Write-Verbose "$fn Table $fvn already exists, to update use the -Update switch. No action taken"
    }
  }
}

function Remove-ACView ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Credential object with access to the server'
                   )
         ]
         [PSCredential]$Credentials
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the server/instance'
                   )
         ]
         [string]$ServerInstance
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database'
                   )
         ]
         [string]$DatabaseName
       , [string]$SchemaName = 'dbo'
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the view excluding schema'
                   )
         ]
         [string]$ViewName
       )

  $fn = "Remove-ACView:"
  $fvn = "$SchemaName.$ViewName" # Full View Name

  Write-Verbose "$fn Checking to see if $fvn exists in $DatabaseName "
  $exists = Test-ACView -Credentials $Credentials `
                        -ServerInstance $serverInstance `
                        -DatabaseName $DatabaseName `
                        -SchemaName $SchemaName `
                        -ViewName $ViewName
  if ($exists -eq $true)  
  {
    Write-Verbose "$fn Removing View $fvn"
    $sql = @"
      DROP VIEW $fvn
"@

    Invoke-Sqlcmd -Query $sql `
                  -Database $DatabaseName `
                  -ServerInstance $ServerInstance `
                  -Credential $Credentials    
  }
  else
  {
    Write-Verbose "$fn View $fvn didn't exist, no action taken"
  }

}
