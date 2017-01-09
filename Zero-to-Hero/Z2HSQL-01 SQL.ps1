<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server
  Demo 2 - SQL Provider
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2014 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 
  Note
  The code herein was written against SQL Server 2012. It was run on the same
  machine with SQL Server 2012 installed. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# Load the SQLPS Module
#-----------------------------------------------------------------------------#
#region Load the SQLPS Module

# First we need to see if the SQLPS module is loaded
Get-Module

# If not loaded, see if it is available
# This will list all available modules on the system. It may take a minute.
$sqlpsModules = Get-Module -ListAvailable | Where-Object Name -eq "SQLPS"
$sqlpsModules 

if ($sqlpsModules.Count -eq 0)
  { "SQLPS is not installed on this computer.  :-(" }
else
  { "Hurray! SQLPS is installed.  :-)" }


# For normal operations you can just import the sqlps module
Push-Location
Import-Module SQLPS
Pop-Location

# Note the above will get the most recent version. If you need to get a 
# specific version, follow the steps below to uncover its location

# We now know it is installed. Which versions are here?
Get-Module -ListAvailable SQLPS | Format-List -Property Name, Path

# The output from the command above looks like this on a system with 
# both SQL 2012 and 2014 installed

<# 
Name : SQLPS
Path : C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS\SQLPS.psd1

Name : SQLPS
Path : C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS\SQLPS.psd1
#>

# In order to load the appropriate SQLPS we have to get a reference to 
# the right path.
$ver = "*Microsoft SQL Server\110\*" 
$sqlps2012Path = $(Get-Module -ListAvailable SQLPS |
                    Where-Object { $_.Path -like $ver }).Path

$sqlps2012Path # Display the path

<#
  Breaking down the command above:
  $ver = "*Microsoft SQL Server\110\*" 
      Will hold the version number and part of the path to the version
      of SQL Server we want. 
      SQL2012 = 110
      SQL2014 = 120

  Get-Module -ListAvailable SQLPS    
      Returns a collection of module objects installed on this system where 
      the module name is SQLPS
 
  Where-Object { $_.Path -like $ver }
      Filters out the collection of modules to only return the single 
      module object whose path property contains the version we want
  
  $()
      Forces PowerShell to execute the code inside the () and return a 
      new object out of it (which is based on the module object)
 
  .Path 
      Return the Path property of the new object 
#>

<#
  Now that we have the reference to the right version of SQLPS, we can load it

  Note that the SQLPS module includes some commands that do not use the set
  of verbs approved for us in PowerShell. We can ignore the warnings that
  Import-Module would produce by using -DisableNameChecking.

  Also note the load will warn us if certain instances (say SSAS for example)
  are installed but not running. We can ignore those for our purposes by 
  using -WarningAction SilentlyContinue

  Finally we will suppress any other unneccesary messages by sending the
  output to the Out-Null cmdlet 

#>
Import-Module $sqlps2012Path `
              -DisableNameChecking `
              -WarningAction SilentlyContinue | 
              Out-Null

<#
  Note that if the module is already loaded, Import-Module won't try and
  load it a second time. If you want to force it to reload, use the 
  -Force switch

Import-Module $sqlps2012Path `
              -DisableNameChecking `
              -Force `
              -WarningAction SilentlyContinue | 
              Out-Null
#>


# Regardless of using the more generic SQLPS or importing a specific
# version, you will now be able to see SQLPS as a loaded module
Get-Module

# To see the list of new commands we have:
Get-Command -Module SQLPS

<# IMPORTANT!
  Note that loading the SQLPS module in versions of SQL Server prior to
  SQL Server 2016 Service Pack 1 automatically changes the current
  location to the SQL Provider. Your prompt would now look like:

  PS SQLSERVER:\

  If you have scripts you wish to execute, you will need to either
  change back to the folder with the scripts, i.e.

  Set-Location C:\PS

  or explicitly include the path

  . "C:\PS\RunThisScript.ps1"

  You can also use Push-Location before and Pop-Location after
  loading the module. Note that if you are on SQL Server 2016 SP1
  this isn't necessary but won't hurt anything to include, if you 
  wish to make your script compatible across multiple versions of
  SQL Server.

#>

#endregion Load the SQLPS Module


#-----------------------------------------------------------------------------#
# A quick tour around the SQL Provider
#-----------------------------------------------------------------------------#
#region Provider Tour

Clear-Host
  
# Navigate to the provider
Set-Location SQLSERVER:\
Get-ChildItem

# Move to the SQL folder to see the Machine  
Set-Location SQLSERVER:\SQL
Get-ChildItem

# Move down to the Machine to see the installed instances
Set-Location SQLSERVER:\SQL\ACSRV
Get-ChildItem

# Move down to the instance to see server level objects
Set-Location SQLSERVER:\SQL\ACSrv\default
Get-ChildItem

# Providers are variable friendly
$machine = "ACSrv"
$instance = "SQLSERVER:\SQL\$machine\default"
"The path to the instance is $instance"

# Move down to databases to see them
Set-Location $instance\Databases
Get-ChildItem

# Note by default system databases are hidden. To see them use the Force switch
Get-ChildItem -Force

# Move down to a specific databases to see its objects
Set-Location $instance\Databases\AdventureWorksDW2015
Get-ChildItem

# Move to the table collection to see all the tables
Set-Location $instance\Databases\AdventureWorksDW2015\Tables
Get-ChildItem

# Show the table objects for the product table
Set-Location $instance\Databases\AdventureWorksDW2015\Tables\dbo.DimProduct
Get-ChildItem

# Show the columns for the table
Set-Location $instance\Databases\AdventureWorksDW2015\Tables\dbo.DimProduct\Columns
Get-ChildItem

# and so on!  

# Reset location back to root of the provider
Set-Location SQLServer:\

#endregion Provider Tour

#-----------------------------------------------------------------------------#
# Common DBA Tasks with PowerShell
#-----------------------------------------------------------------------------#
#region DBA Tasks

# Backup database ------------------------------------------------------------

# Just for demo purposes, remove any backups from previous runs
### DO NOT DO THIS IN PRODUCTION!!!!
$bakPath = "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup"
Remove-Item "$($bakPath)\*.bak"
Get-ChildItem -Path $bakPath  # Nothing there! :-)

# Generate the name of the server and instance, in Server\Instance format
# Note if the instance is DEFAULT you have to omit it
$serverInstance = "ACSrv"

# Dynamicaly load an array with the list of database names to backup
$dataBases = Get-ChildItem "SQLSERVER:\SQL\ACSrv\default\Databases" |
               Where-Object Name -Like "*WideWorld*"

$dataBases  # Show the databases it found

# Backup each item
foreach($db in $dataBases)
{
  Backup-SqlDatabase -ServerInstance $serverInstance `
                     -Database $db.Name `
                     -BackupAction Database
}

# Show the backups
Get-ChildItem -Path $bakPath


# Review error logs ----------------------------------------------------------

<#
  Thanks to Ed Wilson, aka "The Scripting Guy", for his post at
  http://blogs.technet.com/b/heyscriptingguy/archive/2012/10/22/use-powershell-to-parse-sql-server-2012-error-logs.aspx
  Where more detailed explanations of querying the logs can be found
#>

# Firse we need to get a reference to the server, to access the server
# methods and properties
$server = Get-Item "SQLSERVER:\SQL\ACSrv\default"

# Examine the server object
$server.GetType() | Format-List
$server | Get-Member

# Use the ReadErrorLog Method to retrieve log data
$server.ReadErrorLog()

# Review for backup status
$server.ReadErrorLog() |
  Where-Object ProcessInfo -eq "Backup" |
  Format-List

# Create a backup that fails to show the error
Backup-SqlDatabase -ServerInstance "ACSrv" `
                   -Database "NoSuchDatabaseNameExists" `
                   -BackupAction Database

# Show the backups, including the new failure
$server.ReadErrorLog() |
  Where-Object ProcessInfo -eq "Backup" |
  Format-List

# Filter for only backup failures (Note text compare is case insensitive)
$backupFailures = $server.ReadErrorLog() |
  Where-Object {$_.ProcessInfo -eq "Backup" -and `
                               $_.Text -like 'Backup failed*' -and `
                               $_.LogDate -ge $(Get-Date).ToShortDateString() `
               } 
if($backupFailures -ne $null)
{
  "There were errors backup up the databases"
  $backupFailures
}


# Comb the logs for errors
$server.ReadErrorLog() |
 Where-Object {$_.text -match 'error' -OR $_.text -match 'failed' } |
 Sort-Object logdate |
 Format-Table logdate, text -AutoSize -Wrap


# Review SQL Agent Jobs ------------------------------------------------------

<#
  Thanks to Max Trinidad, for his post at
  http://maxt2posh.wordpress.com/2009/12/23/powershell-working-with-sql-server-agent-jobs/
  Where more detailed explanations of querying SQL Agent Jobs can be found
#>

$serverInstance = "ACSrv\default"
$jobPath = "SQLSERVER:\SQL\$serverInstance\jobserver\jobs\"
Set-Location $jobPath
$SQLjob = Get-ChildItem

$SQLjob # Show the jobs

# Get the status of the last run of a job
$jobHist = @()   # reset from any previous runs
foreach($job in $SQLjob)
{
  $jobHist += $job | Select-Object Parent, name, lastRunDate, lastRunOutcome 
}
 
$jobHist | Format-Table

# Get the status of each step of the last run of a job 
$jobStepHist = @()   # reset from any previous runs
foreach($job in $SQLjob)
{
  if ($job.CategoryID -eq 0)
  {
    foreach($jobName in $job)
    {
      Set-Location "$($jobPath)$($jobName).$($job.CategoryID)\Jobsteps"
      $jobStepHist += Get-ChildItem |
        Select-Object SubSystem, Parent, Name, LastRunDate, LastRunOutcome, Command
    }
  }
}

$jobHist | Format-Table -AutoSize 

Set-Location $jobPath
Get-ChildItem 
# add -Wrap if you want to see the full command, or use Format-List instead

#endregion DBA Tasks


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

# Let's put the output into a variable we can use
Clear-Host
$myOutput = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -SuppressProviderContextWarning `


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
$dbcmd = @"
  SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
    FROM dbo.SqlSaturday
   ORDER BY EventDate
"@
Clear-Host
$myOutput = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -SuppressProviderContextWarning `

$myOutput | Format-Table -AutoSize

# Getting to certain rows
$myOutput.Count   # How many rows we have
$myOutput[6].Location   # Remember arrays are 0 based!

# Iterating over the collection of rows
foreach($row in $myOutput)
{
  Write-Host $row.Organizer
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
Invoke-Sqlcmd -Query $dbcmd `
              -ServerInstance $env:COMPUTERNAME `
              -SuppressProviderContextWarning `
 
# After that runs check to make sure it's gone
Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\default\databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize

# At this point you get the idea. You can use T-SQL to do anything to the server or database

#endregion Dev Tasks
