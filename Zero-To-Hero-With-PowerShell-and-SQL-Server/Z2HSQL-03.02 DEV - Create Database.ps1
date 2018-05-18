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

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

Import-Module SqlServer

# Set a reference to the local execution folder
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"
Set-Location $dir

# Execute the code in the helper functions script
. "$dir\Z2HSQL-03.01 DEV - Helper Functions.ps1"

# Load credentails
$pwFile = "$dir\pw.txt"
$passwordSecure = Get-Content $pwFile |
  ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object PSCredential ('sa', $passwordSecure)

#region Create Database
#-----------------------------------------------------------------------------#
# Create the database
#-----------------------------------------------------------------------------#

# Get a list of database
$serverInstance = $env:COMPUTERNAME
Get-SqlDatabase -ServerInstance $serverInstance `
                -Credential $cred

# Create a new database
$databaseName = 'SQLSaturday'
New-ACDatabase -Credentials $cred `
               -ServerInstance $serverInstance `
               -DatabaseName $databaseName `
               -Verbose

Get-SqlDatabase -ServerInstance $serverInstance `
                            -Credential $cred

# There is also a function to drop a database
Remove-ACDatabase -Credentials $cred `
                  -ServerInstance $serverInstance `
                  -DatabaseName $databaseName `
                  -Verbose
#endregion Create Database

#region Schemas
#-----------------------------------------------------------------------------#
# Working with schemas
#-----------------------------------------------------------------------------#
$schemaName = 'People'
New-ACSchema -Credentials $cred `
             -ServerInstance $serverInstance `
             -DatabaseName $databaseName `
             -SchemaName $schemaName `
             -Verbose

# You can also remove it (but don't do it right now)
Remove-ACSchema -Credentials $cred `
                -ServerInstance $serverInstance `
                -DatabaseName $databaseName `
                -SchemaName $schemaName `
                -Verbose
#endregion Schemas

#region Create Tables
#-----------------------------------------------------------------------------#
# Creating Tables
#-----------------------------------------------------------------------------#
$schemaName = 'People'
$tableName = 'Organizers'
$TableDefinition = @"   
    SqlSaturdayID     INT IDENTITY NOT NULL 
  , SqlSaturdayNumber INT NOT NULL
  , OrganizerName     NVARCHAR(100)
  , OrganizerEmail    NVARCHAR(256)
  , Location          NVARCHAR(100)
  , EventDate         DATE
"@

New-ACTable -Credentials $cred `
            -ServerInstance $serverInstance `
            -DatabaseName $databaseName `
            -SchemaName $SchemaName `
            -TableName $tableName `
            -TableDefinition $TableDefinition `
            -Verbose

# You can also remove the table (although don't do it now)
Remove-ACTable -Credentials $cred `
               -ServerInstance $serverInstance `
               -DatabaseName $databaseName `
               -SchemaName $SchemaName `
               -TableName $tableName `
               -Verbose

#endregion Create Tables

#region Loading Data Method 1 - Write-SqlTableData from variables
#-----------------------------------------------------------------------------#
# Loading Data in to Tables - Method 1 - Write-SqlTableData from variables
#
# Shoutout to Jerris Heaton for deciphering the .Net to SQL mapping types,
# and for figuring out you need to convert hash tables to PSCustomObjects
# to use them with Write-SQLTableData
#
# https://stackoverflow.com/questions/45248147/write-sqltabledata-the-given-value-of-type-string-from-the-data-source-cannot-b
# System.String                             DataType.NVarCharMax
# System.Int64                              DataType.BigInt
# System.Byte[]                             DataType.VarBinaryMax
# System.Boolean                            DataType.Bit
# System.Char                               DataType.NChar(1)
# System.DateTime                           DataType.DateTime2(7)
# System.DateTimeOffset                     DataType.DateTimeOffset(7)
# System.Decimal                            DataType.Decimal(14, 0x1c)
# System.Double                             DataType.Float
# System.Int32                              DataType.Int
# System.Char[]                             DataType.NVarCharMax
# System.Single                             DataType.Real
# System.Int16                              DataType.SmallInt
# System.Object                             DataType.Variant
# System.TimeSpan                           DataType.Timestamp
# System.Byte                               DataType.TinyInt
# System.Guid                               DataType.UniqueIdentifier
# System.UInt64                             DataType.Numeric(0, 20)
# System.UInt32                             DataType.BigInt
# System.UInt16                             DataType.Int
# System.SByte                              DataType.SmallInt
# Microsoft.SqlServer.Types.SqlHierarchyId  DataType.HierarchyId
# Microsoft.SqlServer.Types.SqlGeography    DataType.Geography
# Microsoft.SqlServer.Types.SqlGeometry     DataType.Geometry
# 
#-----------------------------------------------------------------------------#

# Method one, load from an array of key/value pairs
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$tableName = 'Organizers'

# If you have an identity column, you must include the column name in the 
# list, but leave it's value empty. 
$inputData = [PSCustomObject] @{
    SqlSaturdayID = ''
    SqlSaturdayNumber = 111
    OrganizerName = 'Adam Curry'
    OrganizerEmail = 'adam@email.com'
    Location = 'San Antonio, TX'
    EventDate = '2018-02-01'
  }

Write-SqlTableData -ServerInstance $serverInstance `
                   -Credential $cred `
                   -DatabaseName $databaseName `
                   -SchemaName $schemaName `
                   -TableName $tableName `
                   -InputData $inputData 


# Show the results
$sql = "SELECT * FROM People.Organizers"
Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred |
  Format-Table

# To load multiple rows, place the individual objects into an array
$inputData = @() # Create an empty array

# Row 1
$inputDataRow = [PSCustomObject] @{
    SqlSaturdayID = ''; SqlSaturdayNumber = 222; 
    OrganizerName = 'John C Dvorak'; OrganizerEmail = 'john@email.com'; 
    Location = 'San Francisco, CA'; EventDate = '2018-03-01'
  }
$inputData += $inputDataRow

# Row 2
$inputDataRow = [PSCustomObject] @{
    SqlSaturdayID = ''; SqlSaturdayNumber = 333;
    OrganizerName = 'Hortence Hollywoger'; OrganizerEmail = 'hoho@email.com';
    Location = 'Boston, MA'; EventDate = '2018-03-01'
  }
$inputData += $inputDataRow

# Row 3
$inputDataRow = [PSCustomObject] @{
    SqlSaturdayID = ''; SqlSaturdayNumber = 444;
    OrganizerName = 'Thomas Jefferson'; OrganizerEmail = 'bigjeff@email.com';
    Location = 'Richmond, VA'; EventDate = '2018-04-01'
  }
$inputData += $inputDataRow

# Write the multiple rows of data
Write-SqlTableData -ServerInstance $serverInstance `
                   -Credential $cred `
                   -DatabaseName $databaseName `
                   -SchemaName $schemaName `
                   -TableName $tableName `
                   -InputData $inputData

# Show the results
$sql = "SELECT * FROM People.Organizers"
Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred |
  Format-Table


#endregion Loading Data Method 1 - Write-SqlTableData from variables

#region Loading Data Method 2 - Write-SqlTableData from CSV file
#-----------------------------------------------------------------------------#
# Loading Data in to Tables - Method 2 - Write-SqlTableData from CSV file
#-----------------------------------------------------------------------------#

# Truncate the table for the next round of fun
Clear-ACTable -Credentials $cred `
              -ServerInstance $serverInstance `
              -DatabaseName $databaseName `
              -SchemaName $SchemaName `
              -TableName $tableName `
              -Verbose

# Get a row count just to show the table is now empty
Get-ACTableRowCount -Credentials $cred `
                    -ServerInstance $serverInstance `
                    -DatabaseName $databaseName `
                    -SchemaName $SchemaName `
                    -TableName $tableName `
                    -Verbose

# Setup some variables
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$tableName = 'Organizers'
$databaseName = 'SQLSaturday'
$csvPath = "$dir\SqlSaturday.People.Organizers.csv"
$header = "SqlSaturdayID", "SqlSaturdayNumber",	"OrganizerName",	`
                   "OrganizerEmail",	"Location",	"EventDate"

# Show the contents of the CSV for illustration purposes
psedit $csvPath

# Import the data
Import-Csv -Path $csvPath -Header $header |
Write-SqlTableData -ServerInstance $serverInstance `
                   -Credential $cred `
                   -DatabaseName $databaseName `
                   -SchemaName $schemaName `
                   -TableName $tableName

# Show the loaded data
$sql = "SELECT * FROM People.Organizers"
Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred |
  Format-Table

#endregion Loading Data Method 2 - Write-SqlTableData from CSV file

#region Loading Data Method 3 - Creating a new table from the pipeline
#-----------------------------------------------------------------------------#
# Create a new table from the pipeline
#-----------------------------------------------------------------------------#
# Setup some variables
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'dbo'
$tableName = 'TaskManagerDump'
$databaseName = 'SQLSaturday'

# Using -Force will create the table if it doesn't exist. 
# If it does exist, new rows are appended to the table
$propertyNames = 'Id','ProcessName','StartTime','UserProcessorTime',
                 'WorkingSet','Description'
(Get-Process | Select-Object -Property $propertyNames ) | 
 Write-SqlTableData -ServerInstance $serverInstance `
                    -DatabaseName $databaseName `
                    -SchemaName $schemaName `
                    -TableName $tableName `
                    -Force 

# Show the results
$sql = "SELECT * FROM $schemaName.$tableName"
Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred |
  Format-Table

#endregion Loading Data Method 3 - Creating a new table from the pipeline

#region Loading Data Method 4 - Good old fashioned T-SQL
#-----------------------------------------------------------------------------#
# Loading Data using good old fashioned T-SQL
#-----------------------------------------------------------------------------#
# Setup some variables
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$tableName = 'Organizers'
$databaseName = 'SQLSaturday'

# Truncate the table for the next round of fun
Clear-ACTable -Credentials $cred `
              -ServerInstance $serverInstance `
              -DatabaseName $databaseName `
              -SchemaName $SchemaName `
              -TableName $tableName `
              -Verbose

# Get a row count just to show the table is now empty
Get-ACTableRowCount -Credentials $cred `
                    -ServerInstance $serverInstance `
                    -DatabaseName $databaseName `
                    -SchemaName $SchemaName `
                    -TableName $tableName `
                    -Verbose

$sql = @"
INSERT INTO [People].[Organizers]
  ( [SqlSaturdayNumber]
  , [OrganizerName]
  , [OrganizerEmail]
  , [Location]
  , [EventDate]
  )
VALUES
    ( 111, 'Adam Curry','adam@email.com','San Antonio TX','2018-01-01 00:00:00' )
  , ( 222, 'John C Dvorak','john@email.com','San Francisco CA','2018-02-01 00:00:00')
  , ( 333, 'Thomas Jefferson','tjeff@email.com','Boston, MA','2018-03-01 00:00:00')
  , ( 444, 'Hortence Hollywoger','hoho@email.com','Alpharetta, GA','2018-04-01 00:00:00')

"@

Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred

$sql = "SELECT * FROM People.Organizers"
Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred |
  Format-Table

#endregion Loading Data Method 3 - Good old fashioned T-SQL

#region Reading Data Method 1 - Read-SqlTableData
#-----------------------------------------------------------------------------#
# Reading data from a table - Method 1 - Read-SqlTableData
#-----------------------------------------------------------------------------#

# Setup some variables
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$tableName = 'Organizers'

# Simple read that gets all rows and columns
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName

# Use with Format-Table to get easier to read results
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName |
  Format-Table

# Or Out-GridView for something easy to review
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName |
  Out-GridView

# Select a subset of columns, and set their sort order
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName `
                  -ColumnName 'SqlSaturdayNumber', 'OrganizerName', 'OrganizerEmail' `
                  -ColumnOrder 'OrganizerName', 'OrganizerEmail' |
  Format-Table

# If you want to change from asc to desc, add the columnordertype
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName `
                  -ColumnName 'SqlSaturdayNumber', 'OrganizerName', 'OrganizerEmail' `
                  -ColumnOrder 'OrganizerName', 'OrganizerEmail' `
                  -ColumnOrderType DESC,DESC  |
  Format-Table


# You can also select the top N rows. In addition, the column names can be
# placed in a variable
$colNames = 'SqlSaturdayNumber', 'OrganizerName', 'OrganizerEmail', 'EventDate'
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName `
                  -ColumnName $colNames `
                  -ColumnOrder 'EventDate' `
                  -ColumnOrderType DESC  `
                  -TopN 2 |
  Format-Table


# If you are using the provider it's even easier
$serverInstanceDefault = "$($env:COMPUTERNAME)\default"
$ftn = "$schemaName.$tableName"  # Full Table Name
Set-Location "SQLSERVER:\SQL\$serverInstanceDefault\databases\$databaseName\tables\$ftn"
Read-SqlTableData | Format-Table

# Reset our location
Set-Location $dir

# Note that Read-SqlTableData doesn't have the equivalent of a WHERE clause.
# Use a Where-Object after the return to simulate
Read-SqlTableData -ServerInstance $serverInstance `
                  -Credential $cred `
                  -DatabaseName $databaseName `
                  -SchemaName $schemaName `
                  -TableName $tableName `
                  -ColumnName $colNames |
  Where-Object SqlSaturdayNumber -eq 111

# You can return the data into a variable and work with it.
$organizerData = Read-SqlTableData -ServerInstance $serverInstance `
                                   -Credential $cred `
                                   -DatabaseName $databaseName `
                                   -SchemaName $schemaName `
                                   -TableName $tableName `
                                   -ColumnName $colNames

# Each column name is converted to a property
# Here's our columns SqlSaturdayNumber, OrganizerName, OrganizerEmail, EventDate
foreach ($row in $organizerData)
{
  "SQL Saturday $($row.SqlSaturdayNumber) was organized by $($row.OrganizerName) on $($row.EventDate)"
}

#endregion Reading Data Method 1 - Read-SqlTableData

#region Reading Data Method 2 - Using SQL
#-----------------------------------------------------------------------------#
# Reading data from a table - Method 2 - Using SQL
#-----------------------------------------------------------------------------#

# Setup some variables
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$tableName = 'Organizers'
$databaseName = 'SQLSaturday'

# Using T-SQL is basically writing a traditional T-SQL SELECT query
$sql = @"
  SELECT [SqlSaturdayNumber]
       , [OrganizerName]
       , [EventDate]
    FROM [People].[Organizers]
   ORDER BY [EventDate] DESC
"@

Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred

# Invoke-Sqlcmd also supports using a connection string 
$connectionString = "Server = $serverInstance; Database = $databaseName; Integrated Security = True;"
Invoke-Sqlcmd -Query $sql -ConnectionString $connectionString

# You can load the data into a variable and work with it. This will
# create an array of DataRow type objects
$organizerData = Invoke-Sqlcmd -Query $sql `
                               -Database $databaseName `
                               -ServerInstance $ServerInstance `
                               -Credential $cred

foreach ($row in $organizerData)
{
  "SQL Saturday $($row.SqlSaturdayNumber) was organized by $($row.OrganizerName) on $($row.EventDate)"
}

# If you have a query that returns one row, you can address that data directly
# This is because PowerShell senses there is only one row, so instead of 
# creating an array of DataRows, it only returns the single DataRow
$sql = @"
  SELECT [SqlSaturdayNumber]
       , [OrganizerName]
       , [EventDate]
    FROM [People].[Organizers]
   WHERE [SqlSaturdayNumber] = 222
"@

$organizerRow = Invoke-Sqlcmd -Query $sql `
                              -Database $databaseName `
                              -ServerInstance $ServerInstance `
                              -Credential $cred

"SQL Saturday $($organizerRow.SqlSaturdayNumber) was organized by $($organizerRow.OrganizerName) on $($organizerRow.EventDate)"


#endregion Reading Data Method 2 - Using SQL

#region Views
#-----------------------------------------------------------------------------#
# Working with Views
#-----------------------------------------------------------------------------#
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$viewName = 'OrganizersList'
$databaseName = 'SQLSaturday'
$viewDefinition = @"
  SELECT DISTINCT 
         [OrganizerName]
       , [OrganizerEmail]
    FROM [People].[Organizers]
"@

# Create a new view using the View helper function
New-ACView -Credentials $Cred `
           -ServerInstance $serverInstance `
           -DatabaseName $databaseName `
           -SchemaName $SchemaName `
           -ViewName $viewName `
           -ViewDefinition $ViewDefinition `
           -Verbose 

# The New-ACView can also update a view with the -Update switch
New-ACView -Credentials $Cred `
           -ServerInstance $serverInstance `
           -DatabaseName $databaseName `
           -SchemaName $SchemaName `
           -ViewName $viewName `
           -ViewDefinition $ViewDefinition `
           -Update `
           -Verbose 

# You can read a view using T-SQL and Invoke-Sqlcmd. But there is also a 
# built-in cmdlet to do it for you
$colNames = 'OrganizerName', 'OrganizerEmail'
Read-SqlViewData -ServerInstance $serverInstance `
                 -Credential $cred `
                 -DatabaseName $databaseName `
                 -SchemaName $schemaName `
                 -ViewName $viewName `
                 -ColumnName $colNames

# Read-SqlViewData also supports the other options similar to Read-SqlTableData
# like ColumnOrderType and TopN

# Finally, there is a helper function to drop the view (don't do it now)
Remove-ACView -Credentials $Cred `
              -ServerInstance $serverInstance `
              -DatabaseName $databaseName `
              -SchemaName $SchemaName `
              -ViewName $viewName `
              -Verbose 

#endregion Views

#region Updating Data
#-----------------------------------------------------------------------------#
# Updating Data
#-----------------------------------------------------------------------------#
$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'
$schemaName = 'People'
$tableName = 'Organizers'
$databaseName = 'SQLSaturday'

# Currently, to update data you have to use T-SQL
$sql = @"
  UPDATE People.Organizers
    SET OrganizerEmail = 'hoho@hohomail.com'
  WHERE OrganizerName = 'Hortence Hollywoger'
"@

# Issue the update
Invoke-Sqlcmd -Query $sql `
              -Database $databaseName `
              -ServerInstance $ServerInstance `
              -Credential $cred

# Show the results
$colNames = 'OrganizerName', 'OrganizerEmail'
Read-SqlViewData -ServerInstance $serverInstance `
                 -Credential $cred `
                 -DatabaseName $databaseName `
                 -SchemaName $schemaName `
                 -ViewName $viewName `
                 -ColumnName $colNames

#endregion Updating Data

#region Other Objects
#-----------------------------------------------------------------------------#
# Working with other SQL Server objects
#-----------------------------------------------------------------------------#
<#
  For working with other object types in SQL Server, such as stored procedures,
  functions, and the like, follow the same pattern outlined in the Update
  section. Create the t-sql, and use Invoke-Sqlcmd to run it.

  Note that the SqlServer module does include cmdlets for working with 
  always on, encryption, and availability groups. However these are beyond
  the scope of an introductory course. 

  For a complete list of cmdlets in the SqlServer module, see the online 
  reference at:
  https://docs.microsoft.com/en-us/powershell/module/sqlserver/?view=sqlserver-ps

#>

#endregion Other Objects

#region Cleanup
#-----------------------------------------------------------------------------#
# This section just removes the local database we've been playing with. 
# Makes cleaning up after yourself easy
#-----------------------------------------------------------------------------#

$serverInstance = $env:COMPUTERNAME
$databaseName = 'SQLSaturday'

Remove-ACDatabase -Credentials $cred `
                  -ServerInstance $serverInstance `
                  -DatabaseName $databaseName `
                  -Verbose

#endregion Cleanup

