<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server
  SMO (SQL Management Objects)
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 
  Note
  The code herein was written against SQL Server 2016. It was run on the same
  machine with SQL Server 2016 installed. 

  The SMO (SQL Management Object) is a .Net library for working with 
  SQL Server. The object model shows all the available objects, and how they 
  are related. All objects in SMO extend from the root node of "Server". Once 
  you create a server object, you can then drill down and work with the rest 
  of the objects on the server. 
  
  To see the object model for SMO, a diagram of everything in the library, visit:
  http://msdn.microsoft.com/en-us/library/ms162209.aspx
    or
  http://bit.ly/smodiagram

  To see the details about the namespace visit:
  http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo
    or
  http://bit.ly/smonamespace


-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# Load the SMO Assemblies
#-----------------------------------------------------------------------------#
#region Load SMO

# Indicate which version of SMO to load
$Version = "2016"

# Check to see if they are already loaded. 
# If not, add them to the current session
if( ([appdomain]::currentdomain.getassemblies() | Where {$_ -match "Microsoft.SqlServer.Smo"}) -eq $null)
{
  switch ($Version)
  {
    "2012"   { $assyPath = "C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\" }
    "2014"   { $assyPath = "C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\" }
    "2016"   { $assyPath = "C:\Program Files\Microsoft SQL Server\130\SDK\Assemblies\" }
    "2008R2" { $assyPath = "C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\" }
    default  { $assyPath = "C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\" }
  }

  
  $assemblylist = 
    "Microsoft.SqlServer.Smo", 
    "Microsoft.SqlServer.ConnectionInfo", 
    "Microsoft.SqlServer.SmoExtended", 
    "Microsoft.SqlServer.Dmf", 
    "Microsoft.SqlServer.SqlWmiManagement", 
    "Microsoft.SqlServer.Management.RegisteredServers", 
    "Microsoft.SqlServer.Management.Sdk.Sfc", 
    "Microsoft.SqlServer.SqlEnum", 
    "Microsoft.SqlServer.RegSvrEnum", 
    "Microsoft.SqlServer.WmiEnum", 
    "Microsoft.SqlServer.ServiceBrokerEnum", 
    "Microsoft.SqlServer.ConnectionInfoExtended", 
    "Microsoft.SqlServer.Management.Collector", 
    "Microsoft.SqlServer.Management.CollectorEnum"

  foreach ($asm in $assemblylist) 
  {
    if (Test-Path -Path "$($assyPath)$($asm).dll")
    {
      # Note you may see some online examples use Load Assembly with Partial Name
      # That is now depricated, use Add-Type instead
      Add-Type -Path "$($assyPath)$($asm).dll"
    }
  }
}

#endregion Load SMO


#-----------------------------------------------------------------------------#
# Common DBA Tasks with PowerShell and SMO
#-----------------------------------------------------------------------------#
#region DBA Tasks

# Backup database ------------------------------------------------------------

# Just for demo purposes, remove any previous backups
$bakPath = "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup"
Remove-Item "$($bakPath)\*.bak"
Get-ChildItem -Path $bakPath  # Nothing there! :-)

# If the instance is default, omit it
$machine = $env:COMPUTERNAME # + "\default"  

# Everything is driven from the Server object. Get a reference to it
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")

$bkup = New-Object Microsoft.SQLServer.Management.Smo.Backup 
$bkup.Database = "AdventureWorksDW2015"

$date = Get-Date   
$date = $date -replace "/", "-"     
$date = $date -replace ":", "-"  
$date = $date -replace " ", "_" 

$file = "$($bakPath)\AdventureWorksDW2015" + "_" + $date + ".bak"  

$bkup.Devices.AddDevice($file, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)  
$bkup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database  

$bkup.SqlBackup($server)

# Validate it is there
Get-ChildItem -Path $bakPath  # Nothing there! :-)

# Clean up after ourselves
Remove-Item "$($bakPath)\*.bak"


# Review error logs ----------------------------------------------------------

# If the instance is default, omit it
$machine = $env:COMPUTERNAME # + "\default"  

# Everything is driven from the Server object. Get a reference to it
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")

# Note, from here the code is exactly the same as the Provider

# Review for backup status
$server.ReadErrorLog() |
  Where-Object ProcessInfo -eq "Backup" |
  Format-List

# Create a backup that fails to show the error
Backup-SqlDatabase -ServerInstance "ArcaneCodePro3" `
                   -Database "NoSuchDatabaseNameExists" `
                   -BackupAction Database

# Show the backups, including the new failure
$server.ReadErrorLog() |
  Where-Object ProcessInfo -eq "Backup" |
  Format-List

# Filter for only backup failures
$backupFailures = $server.ReadErrorLog() |
  Where-Object {$_.ProcessInfo -eq "Backup" -and `
                               $_.Text -like 'Backup failed*' -and `
                               $_.LogDate -gt $(Get-Date).ToShortDateString() `
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



# Jobs -----------------------------------------------------------------------

# If the instance is default, omit it
$machine = $env:COMPUTERNAME # + "\default"  

# Everything is driven from the Server object. Get a reference to it
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")

$agent = $server.JobServer

$jobs = @()
foreach($job in $agent.Jobs)
{
  $aJob = [PSCustomObject]@{
          Parent = $job.Parent
          Name = $job.name
          LastRunDate = $job.lastRunDate
          LastRunOutcome = $job.lastRunOutcome 
          }
  $jobs += $aJob
}

$jobs | Format-Table -AutoSize

#endregion DBA Tasks

#-----------------------------------------------------------------------------#
# Common Dev Tasks with PowerShell
#-----------------------------------------------------------------------------#
#region Dev Tasks

# Create Database ------------------------------------------------------------

# Omit the instance if it is default
$machine = $env:COMPUTERNAME #+ "\default"  

# Create a database the simple way -------------------------------------------
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, "PSTest2")
$db.Create()   

# ...or the more complete way ------------------------------------------------
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, "PSTest2") 

$fg = New-Object Microsoft.SqlServer.Management.Smo.FileGroup ($db, 'PRIMARY')
$db.Filegroups.Add($fg)

$mdf = New-Object Microsoft.SqlServer.Management.Smo.DataFile($fg, "PSTest2_Data")                                        
$fg.Files.Add($mdf)   
$mdf.FileName = "C:\SQLdata\PSTest2_Data.mdf" 
$mdf.Size = 30.0 * 1KB    
$mdf.GrowthType = "Percent"  
$mdf.Growth = 10.0       
$mdf.IsPrimaryFile = "True" 

$ldf = New-Object Microsoft.SqlServer.Management.Smo.LogFile($db, "PSTest2_Log")
$db.LogFiles.Add($ldf)  
$ldf.FileName = "C:\SQLlog\PSTest2_Log.ldf"   
$ldf.Size = 20.0 * 1KB    
$ldf.GrowthType = "Percent"  
$ldf.Growth = 10.0   

$db.Create()    

# Prove it exists
$server.Databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize


# Add the table via a script -------------------------------------------------
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")

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

$db.ExecuteNonQuery($sql)

# Show its there by showing the tables collection for the database object
$db.Tables


# Add a table with pure SMO --------------------------------------------------
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = $server.Databases["PSTest2"]
$table = New-Object Microsoft.SqlServer.Management.Smo.Table($db, "SqlSaturday")

$col1 = New-Object Microsoft.SqlServer.Management.Smo.Column ($table, "SqlSaturdayID")   
$col1.DataType = [Microsoft.SqlServer.Management.Smo.Datatype]::Int
$col1.Nullable = $false
# In this case we don't need the SqlSaturdayID col to be an identity type, but 
# if you did below is the code you'd need to use
# $col1.Identity = $true
# $col1.IdentitySeed = 1
# $col1.IdentityIncrement = 1
$table.Columns.Add($col1) 

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

$table.Create()   

# Show its there by showing the tables collection for the database object
$db.Tables
  

# Add a primary key to the SQL Saturday table --------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = $server.Databases["PSTest2"]
$table = $db.Tables["SqlSaturday"] 

$pk = New-Object Microsoft.SqlServer.Management.Smo.Index($table, "PK_SqlSaturdayId")
$pk.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey

$ic = New-Object Microsoft.SqlServer.Management.Smo.IndexedColumn($pk, "SqlSaturdayID")  
$pk.IndexedColumns.Add($ic)

$table.Indexes.Add($pk)
$table.Alter() 

# Add a foriegn key from our sponsors to this new table ----------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
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
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = $server.Databases["PSTest2"]
$table = $db.Tables["Sponsors"] 

$uk = New-Object Microsoft.SqlServer.Management.Smo.Index($table, "UK_SponsorName")    
$uk.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriUniqueKey   

$ic = New-Object Microsoft.SqlServer.Management.Smo.IndexedColumn($uk, "SponsorName")   
$uk.IndexedColumns.Add($ic)  

$table.Indexes.Add($uk)  
$table.Alter() 


# Insert values into the SQL Saturday table ----------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = $Server.Databases["PSTest2"]
$dbcmd = @"
  INSERT INTO dbo.SqlSaturday
    (SqlSaturdayID, Organizer, Location, EventDate, Attendees)
  VALUES
    (328, 'John Baldwin', 'Birmingham, AL', '2014/08/14', 150)
  , (999, 'Robert C. Cain', 'The Moon', '2014/08/30', 150)
  , (441, 'Brian Knight', 'Orange City, FL', '2015/06/16', 141)
  , (532, 'Mike Davis', 'Jacksonville, FL', '2015/06/09', 132)
  , (650, 'Adam Jorgensen', 'Baton Rouge, LA', '2015/08/04', 150)
  , (751, 'Adam Curry', 'Austin, TX', '2015/09/29', 151)
  , (844, 'John C. Dvorak', 'San Francisco, CA', '2015/10/13', 144)
"@

$db.ExecuteNonQuery($dbcmd)



# Now read that data back ----------------------------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$db = $Server.Databases["PSTest2"]

$dbcmd = @"
  SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees
    FROM dbo.SqlSaturday
   ORDER BY Attendees DESC
"@

# Returns a System.Data.DataSet
$data = $db.ExecuteWithResults($dbcmd)    

# Datasets can contain 1 or more DataTable objects in
# their Tables collection. 
# In this case we only have 1, so we can just grab it
# using the numerical array access technique
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
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
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


# Drop the database ----------------------------------------------------------
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("$machine")
$Server.KillAllProcesses("PSTest2")
$Server.KillDatabase("PSTest2")

# Show it went bye-bye
$Server.Databases |
  Select-Object -Property Name, Status, RecoveryModel, Owner |
  Format-Table -Autosize

#endregion Dev Tasks
