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

#-----------------------------------------------------------------------------#
# Common Dev Tasks with PowerShell
#-----------------------------------------------------------------------------#
#region Dev Tasks

# Create a database with the Provider ----------------------------------------

# First get a list of exising databases
Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\default\databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize

# Create the database -- Can go simple:
$dbcmd = "Create Database PSTest1"

# ...or more complex
$sqlPath = "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\"

$dbcmd = @"
  CREATE DATABASE [PSTest1] CONTAINMENT = NONE ON  PRIMARY 
    ( NAME = N'PSTest1'
    , FILENAME = N'$($sqlPath)PSTest1.mdf' 
    , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB 
    )
    LOG ON 
    ( NAME = N'PSTest1_log'
    , FILENAME = N'$($sqlPath)PSTest1_log.ldf' 
    , SIZE = 784KB , MAXSIZE = 2048GB , FILEGROWTH = 10%
    )
"@

Invoke-Sqlcmd -Query $dbcmd -ServerInstance $env:COMPUTERNAME 
Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\default\databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize

# Move to the database folder
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1
Get-ChildItem 

# Now shift to the tables and list them
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1\Tables
Get-ChildItem # Of course there aren't any (yet!)

# If working with a particular database a lot, consider
# setting up a new alias to it
New-PSDrive -Name PST1 `
            -PSProvider SQLSERVER `
            -Root SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1

Set-Location PST1:
Get-ChildItem

Set-Location PST1:\Tables
Get-ChildItem

# When done, either use the remove cmdlet below, otherwise
# when this session ends so does the lifespan of the PSDrive
# Make sure to set your location outside the PSDrive first
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1
Remove-PSDrive PST1

# Create a table -------------------------------------------------------------
$dbloc = "SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1"
Set-Location $dbloc

$dbcmd = @"
  CREATE TABLE dbo.SqlSaturday
  (
      SqlSaturdayID INT NOT NULL 
    , Organizer     NVARCHAR(100)
    , Location      NVARCHAR(100)
    , EventDate     DATE
    , Attendees     INT
  )
"@

# We can invoke like this since our current location is in a database
Invoke-Sqlcmd -Query $dbcmd -ServerInstance $env:COMPUTERNAME
Get-ChildItem $dbloc\Tables

<#
  Sidebar - Invoke-SqlCmd and the default instance
  
  Note that for most cmdlets, such as Set-Location, if the instance is
  default (aka localhost) you still include it in the cmdlet. 

  Invoke-SqlCmd is different, if the instance is default, you must omit
  it when passing it into the -ServerInstance parameter. 

  If you were calling a specific instance, perhaps you have one called 
  SQL2014, the text would look like

  Invoke-Sqlcmd -Query $dbcmd -ServerInstance "ACSrv\SQL2014"

#>


# Insert data into a table ---------------------------------------------------

# Construct a standard INSERT statement
$dbcmd = @"
  INSERT INTO dbo.SqlSaturday
    (SqlSaturdayID, Organizer, Location, EventDate, Attendees)
  VALUES
    (328, 'John Baldwin', 'Birmingham, AL', '2014/08/14', 150)
"@
  
# Move the current folder to somewhere other than the current database
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default

# You can use the -Database parameter so you can be elsewhere in the provider
Invoke-Sqlcmd -Query $dbcmd `
              -ServerInstance $env:COMPUTERNAME `
              -Database "PSTEST1" 


# Add a second record
$dbcmd = @"
  INSERT INTO dbo.SqlSaturday
    (SqlSaturdayID, Organizer, Location, EventDate, Attendees)
  VALUES
    (999, 'Robert C. Cain', 'The Moon', '2014/08/30', 150)
"@

# Reset location to database so we get proper context for the provider
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1

# Without passing in a database, SQLPS will use the database the provider
# is currently in. However it will provide us a warning to that effect.
# You can use the supress switch to prevent that warnings from appearing
Invoke-Sqlcmd -Query $dbcmd `
              -ServerInstance $env:COMPUTERNAME `
              -SuppressProviderContextWarning 


# Get data out of the table --------------------------------------------------

# You might think you can set the current location to the table and see it's data
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1\Tables\dbo.SqlSaturday
Get-ChildItem 

# Nope. Instead query the data
$dbcmd = @"
  SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
    FROM dbo.SqlSaturday
   WHERE SqlSaturdayID = 328
"@
Clear-Host
Invoke-Sqlcmd -Query $dbcmd `
              -ServerInstance $env:COMPUTERNAME `
              -SuppressProviderContextWarning `

# Even easier! Read-SqlTableData is context aware. If the provider is located
# in a table, it will read the rows in that table
Read-SqlTableData

# Let's put the output into a variable we can use
Clear-Host
$myOutput = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -SuppressProviderContextWarning `

# This will also work of the provider is in the right spot. Use Where-Object
# to emulate the WHERE clause of a SQL query.
$myOutput = Read-SqlTableData |
              Where-Object -Property SqlSaturdayID -eq 328

# See the result
$myOutput                            # As the default table
$myOutput | Format-Table -AutoSize   # As a list
$myOutput.Organizer                  # Get one element of it

# System.Data.DataRow datatype
$myOutput.GetType()

# Get-Member will give you a full type name in addition to other info
$myOutput | Get-Member


# Dealing with sets of data --------------------------------------------------
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases\PSTest1\Tables\dbo.SqlSaturday

# Let's load in a bit more data
$dbcmd = @"
  INSERT INTO dbo.SqlSaturday
    (SqlSaturdayID, Organizer, Location, EventDate, Attendees)
  VALUES
    (441, 'Arcane Code', 'Orange City, FL', '2015/06/16', 141)
  , (532, 'Aaron Nelson', 'Atlanta, GA', '2015/06/09', 132)
  , (555, 'Chrissy LeMaire', 'Paris, France', '2015/07/17', 182)
  , (650, 'Brent Ozar', 'Chicago, IL', '2015/08/04', 150)
  , (751, 'Adam Curry', 'Austin, TX', '2015/09/29', 151)
  , (844, 'John C. Dvorak', 'San Francisco, CA', '2015/10/13', 144)
"@

Invoke-Sqlcmd -Query $dbcmd `
              -ServerInstance $env:COMPUTERNAME `
              -SuppressProviderContextWarning `

# Query the data to see our new rows
$myOutput = Read-SqlTableData

$myOutput | Format-Table -AutoSize

# Getting to certain rows
$myOutput.Count   # How many rows we have
$myOutput[6].Location   # Remember arrays are 0 based!

# You can actually get a whole list by just referencing the property
$myOutput.Organizer

# Or iterating over the collection of rows
foreach($row in $myOutput)
{
  Write-Host "The event organizer was $($row.Organizer)"
}

# Note myOutput is now an array datatype
$myOutput.GetType()

# It's an array of System.Data.DataRow objects
$myOutput[0] | Get-Member


# Drop the database now that we're done --------------------------------------

# All done let's drop the db

# Move our current location so it doesn't interfere with the drop
Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\default\databases

# Create the drop command
$dbcmd = @"
  USE master;
  GO
  ALTER DATABASE [PSTest1]
  SET SINGLE_USER 
  WITH ROLLBACK IMMEDIATE;
  GO
 DROP DATABASE [PSTest1]
"@

# Run the drop
# Warning, sometimes thie drop will break the connection from
# PowerShell to the server, and you have to restart the 
# PowerShell session. 
Invoke-Sqlcmd -Query $dbcmd `
              -ServerInstance $env:COMPUTERNAME `
              -SuppressProviderContextWarning `
 
# After that runs check to make sure it's gone
Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\default\databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize

# At this point you get the idea. You can use T-SQL to do anything to the server or database

#endregion Dev Tasks
