#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  SMO (SQL Management Objects) - Developer Tasks

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

# This module assumes you've already run the code found in the script
# Z2HSAL-04.01 SMO - Loading SMO.ps1 
# To load all the correct assemblies

# We'll also need these for a later demo
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"
Set-Location $dir

# Load credentails
$pwFile = "$dir\pw.txt"
$passwordSecure = Get-Content $pwFile |
  ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object PSCredential ('sa', $passwordSecure)


##-----------------------------------------------------------------------------#
# Common Dev Tasks with PowerShell
#-----------------------------------------------------------------------------#
#region Dev Tasks

# Create Database ------------------------------------------------------------

# Omit the instance if it is default
$serverInstance = $env:COMPUTERNAME #+ "\default"  

# Create a database the simple way -------------------------------------------
# Get a reference to the server
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInsta")

# Create a new database object in memory
$db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, "PSTest2")

# Take the database object in memory and write it out to SQL Server
$db.Create()   

# ...or the more complete way ------------------------------------------------
# Get a reference to the server
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")

# Create a new database object in memory
$db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, "PSTest3")

# Create a file group object, and add it to the in memory database object
$fg = New-Object Microsoft.SqlServer.Management.Smo.FileGroup ($db, 'PRIMARY')
$db.Filegroups.Add($fg)

# Create the data file object for the MDF file, add it to the file group for
# the in memory database object
$mdf = New-Object Microsoft.SqlServer.Management.Smo.DataFile($fg, "PSTest3_Data")                                        
$fg.Files.Add($mdf)   
$mdf.FileName = "C:\SQLdata\PSTest3_Data.mdf" 
$mdf.Size = 30.0 * 1KB    
$mdf.GrowthType = "Percent"  
$mdf.Growth = 10.0       
$mdf.IsPrimaryFile = "True" 

# Create the log file object for the MDF file, add it to the file group for
# the in memory database object
$ldf = New-Object Microsoft.SqlServer.Management.Smo.LogFile($db, "PSTest3_Log")
$db.LogFiles.Add($ldf)  
$ldf.FileName = "C:\SQLlog\PSTest3_Log.ldf"   
$ldf.Size = 20.0 * 1KB    
$ldf.GrowthType = "Percent"  
$ldf.Growth = 10.0   

# Finally, take the database object in memory and write it out to SQL Server
$db.Create()    

# Prove it exists
$server.Databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize


# Add the table via a script -------------------------------------------------
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")

$db = $Server.Databases["PSTest2"]
# This syntax is also valid:
#   $db = $Server.Databases.Item("PSTest2")

$sql = New-Object -Type System.Collections.Specialized.StringCollection 
$sql.Add("SET ANSI_NULLS On")  
$sql.Add("SET QUOTED_IDENTIFIER ON") 

$dbcmd = @"
  CREATE TABLE dbo.Sponsors
  (
      SponsorID     INT IDENTITY NOT NULL PRIMARY KEY
    , SqlSaturdayID INT NOT NULL 
    , SponsorName   NVARCHAR(100)
  )
"@

$sql.Add($dbcmd)     

# ExecuteNonQuery tells SQL to run the SQL but nothing will be returned
# This is similar to Invoke-SqlCmd
$db.ExecuteNonQuery($sql)

# Show its there by showing the tables collection for the database object
$db.Tables


# Add a table with pure SMO --------------------------------------------------
# Get references to the server and database into variables
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $server.Databases["PSTest2"]

# Create a new object in memory to hold our table
$table = New-Object Microsoft.SqlServer.Management.Smo.Table($db, "SqlSaturday")

# Create a column object for the first column
$col1 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "SqlSaturdayID")   
$col1.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::Int
$col1.Nullable = $false
# In this case we don't need the SqlSaturdayID col to be an identity type, but 
# if you did below is the code you'd need to use
# $col1.Identity = $true
# $col1.IdentitySeed = 1
# $col1.IdentityIncrement = 1
# Now add this column object to the in memory table object
$table.Columns.Add($col1) 

# Repeat for each column
# Organizer
$col2 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "Organizer")
$col2.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::NVarChar(100)
$col2.Nullable = $false
$table.Columns.Add($col2)  

# Location
$col3 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "Location")
$col3.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::NVarChar(100)
$col3.Nullable = $false
$table.Columns.Add($col3)  

# Event
$col4 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "EventDate")
$col4.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::DATETIME
$col4.Nullable = $false
$table.Columns.Add($col4)  

# Attendees
$col5 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "Attendees")   
$col5.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::Int
$col5.Nullable = $false
$table.Columns.Add($col5) 

# Now take the table object that is in memory write it to the SQL Server
$table.Create()   

# Show its there by showing the tables collection for the database object
$db.Tables
  

# Add a primary key to the SQL Saturday table --------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $server.Databases["PSTest2"]
$table = $db.Tables["SqlSaturday"] 

$pk = New-Object Microsoft.SqlServer.Management.Smo.Index($table, "PK_SqlSaturdayId")
$pk.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey

$ic = New-Object Microsoft.SqlServer.Management.Smo.IndexedColumn($pk, "SqlSaturdayID")  
$pk.IndexedColumns.Add($ic)

$table.Indexes.Add($pk)
$table.Alter() 

# Add a foriegn key from our sponsors to this new table ----------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $server.Databases["PSTest2"]
$table = $db.Tables["Sponsors"] 

$fk = New-Object `
  Microsoft.SqlServer.Management.Smo.ForeignKey($table, "FK_Sponsors_SqlSaturday")

$fkcol = New-Object `
  Microsoft.SqlServer.Management.Smo.ForeignKeyColumn($fk, "SqlSaturdayID", "SqlSaturdayID") 

$fk.Columns.Add($fkcol)
$fk.ReferencedTable = "SqlSaturday"  
$fk.Create()

# Add a unique index to the Sponsors table -----------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $server.Databases["PSTest2"]
$table = $db.Tables["Sponsors"] 

$uk = New-Object Microsoft.SqlServer.Management.Smo.Index($table, "UK_SponsorName")    
$uk.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriUniqueKey   

$ic = New-Object Microsoft.SqlServer.Management.Smo.IndexedColumn($uk, "SponsorName")   
$uk.IndexedColumns.Add($ic)  

$table.Indexes.Add($uk)  
$table.Alter() 


# Insert values into the SQL Saturday table ----------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $Server.Databases["PSTest2"]
$dbcmd = @"
  INSERT INTO dbo.SqlSaturday
    (SqlSaturdayID, Organizer, Location, EventDate, Attendees)
  VALUES
    (328, 'John Baldwin', 'Birmingham, AL', '2014/08/14', 150)
  , (999, 'Robert C. Cain', 'The Moon', '2014/08/30', 150)
  , (441, 'Arcane Code', 'Orange City, FL', '2015/06/16', 141)
  , (532, 'Aaron Nelson', 'Atlanta, GA', '2015/06/09', 132)
  , (555, 'Chrissy LeMaire', 'Paris, France', '2015/07/17', 182)
  , (650, 'Brent Ozar', 'Chicago, IL', '2015/08/04', 150)
  , (751, 'Adam Curry', 'Austin, TX', '2015/09/29', 151)
  , (844, 'John C. Dvorak', 'San Francisco, CA', '2015/10/13', 144)
"@

$db.ExecuteNonQuery($dbcmd)



# Now read that data back ----------------------------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $Server.Databases["PSTest2"]

$dbcmd = @"
  SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
    FROM dbo.SqlSaturday
   ORDER BY Attendees DESC
"@

# Returns a collection (array) of System.Data.DataSet objects
$data = $db.ExecuteWithResults($dbcmd)    
$data # Display the results

# Datasets can contain 1 or more DataTable objects in
# their Tables collection. Think of a Dataset as a special type of array,
# with extra properties for working with data
$data.GetType()

# How many tables did we get back
$data.Tables.Count

# Show the contents of the first table
$data.Tables[0]

# In this case we only have 1 dataset, so we can just grab it
# using the numerical array access technique. The data set would be 
# similar to the array of data row objects we saw in the SQL Provider
$dt = New-Object "System.Data.DataTable"  
$dt = $data.Tables[0]

# Show our rows
$dt | Format-Table -Autosize   

# The members of the data table
$dt | Get-Member

# Each $row is a System.Data.DataRow object  
foreach($row in $dt)
{
  $row.Organizer
}


# Update a row ---------------------------------------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$db = $Server.Databases["PSTest2"]

$dbcmd = @"
  UPDATE dbo.SqlSaturday
     SET Attendees = 999
   WHERE SqlSaturdayID = 328
"@

$db.ExecuteNonQuery($dbcmd)

# Read the row we updated
$dbcmd = @"
  SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
    FROM dbo.SqlSaturday
   WHERE SqlSaturdayID = 328
"@

$data = $db.ExecuteWithResults($dbcmd)    
$data.Tables[0] | Format-Table -Autosize   


# Drop the databases ---------------------------------------------------------
# DON'T DO THIS IN PRODUCTION UNLESS YOU REALLY REALLY REALLY MEAN IT!!!!!!!!!
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverInstance")
$Server.KillAllProcesses("PSTest2")
$Server.KillDatabase("PSTest2")

$Server.KillAllProcesses("PSTest3")
$Server.KillDatabase("PSTest3")

# Show it went bye-bye
$Server.Databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize

#endregion Dev Tasks
