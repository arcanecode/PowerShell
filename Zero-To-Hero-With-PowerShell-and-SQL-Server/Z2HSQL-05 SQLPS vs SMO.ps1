#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Speed test SqlServer module vs SMO

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


# Before we begin, make sure both the SQLPS and SMO providers have been loaded as demonstrated
# in the Z2H SQL.ps1 and Z2H SMO.ps1 demo files. 

#-----------------------------------------------------------------------------------------------#
# Real World Example:
# Looking for columns of a certain data type using the SQL Provider
#-----------------------------------------------------------------------------------------------#
  
# SqlServer wants the instance even if it is default
$serverInstance = $env:COMPUTERNAME + "\default"  
# $serverInstance = $env:COMPUTERNAME + "\N4IXT"  

# Grab the start time so we can get some metrics on how long this runs
$Start = Get-Date

# Set the number of matches to 0
$matches = 0

# Load a list of database objects into a variable
# -Force ensures we get the system databases as well
$dbCollection = (Get-Item SQLSERVER:\sql\$serverInstance\databases -Force).Collection

# For each database on the server
foreach($db in $dbCollection)
{
  # Create a string to hold the path to the database
  $rootPath = "SQLSERVER:\sql\$serverInstance\databases\$($db.Name)\"
  # Now create a second string to path to the tables in the database
  $tablePath = "$rootPath\tables"
  # Load the table objects for the database into a variable
  $tableCollection = (Get-Item $tablePath -Force).Collection
  # Loop over each table in the current database
  foreach($table in $tableCollection)
  {
    # Use the object properties to buld the full database.schema.table name
    $tableName = "$($db.Name)\$($table.schema).$($table.name)"
    # Create a path to the columns
    $columnPath = "$rootPath\tables\$($table.Schema).$($table.Name)\Columns"
    # Now load the column objects into a variable
    $columnCollection = (Get-Item $columnPath).Collection
    # For each column in the table's column collection
    foreach($column in $columnCollection)
    { 
      # if that column is a big int, display the name
      # and increment the counter
      if($column.DataType.ToString() -eq 'bigint' ) 
      {
        "$tableName.$($column) is a BigInt"
        $matches++
      }  
    }
  }
}

$End = Get-Date     # Stop the timer
"`n"                # output a line feed to give a blank line
"$matches Matches"  # Display number of matches

# The end-start results in a date-time object, which you can get the 
# various properties of, including total milliseonds or seconds
$elapsed = $end - $start
"Elapsed Time $($elapsed.TotalSeconds) Seconds ( $($elapsed.TotalMilliseconds) Milliseconds)"

# 136 Matches
# Elapsed Time 30.2542171 Seconds ( 30254.2171 Milliseconds)
##


#-----------------------------------------------------------------------------------------------#
# Real World Example:
# Looking for columns of a certain data type using SMO
#-----------------------------------------------------------------------------------------------#
 
# If the instance is the default instance, SMO does NOT want it included
$serverInstance = $env:COMPUTERNAME # + "\default"  
# $serverInstance = $env:COMPUTERNAME + "\N4IXT"  

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
# 136 Matches
# Elapsed Time 14.0312818 Seconds ( 14031.2818 Milliseconds)

###