#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  SMO (SQL Management Objects) - DBA Tasks

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

# Execute the code in the helper functions script, as we'll reuse a bit
# here to make things easy
. "$dir\Z2HSQL-03.01 DEV - Helper Functions.ps1"

# Some helper functions
function New-ZombieDB ()
{
  # First we need to create a db to delete. We'll reuse some code from the
  # Z2HSQL-03.02 DEV - Create Database.ps1 script
  
  $serverInstance = $env:COMPUTERNAME  # Omitting default
  $databaseName = 'ZombieDB'
  New-ACDatabase -Credentials $cred `
                 -ServerInstance $serverInstance `
                 -DatabaseName $databaseName `
                 -Verbose
  
  Get-SqlDatabase -ServerInstance $serverInstance `
                  -Credential $cred
}

#region Backup
#-----------------------------------------------------------------------------#
# Backup database
#-----------------------------------------------------------------------------#

# Just for demo purposes, remove any previous backups. 
# *************************** BIG SCARY WARNING! *****************************
# ********************* DO NOT RUN THIS IN PRODUCTION!!!!!! ******************
# *************************** YOU"VE BEEN WARNED *****************************
$bakPath = "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup"
Remove-Item "$($bakPath)\*.bak"
Remove-Item "$($bakPath)\*.log"
Get-ChildItem -Path $bakPath  # Nothing there! :-)

# If the instance is default, omit it
$serverName = $env:COMPUTERNAME # + "\default"  
$databaseName = 'TeenyTinyDB'

# Everything is driven from the Server object. Get a reference to it
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverName")

$bkup = New-Object Microsoft.SQLServer.Management.Smo.Backup 
$bkup.Database = $databaseName

$date = Get-Date   
$date = $date -replace "/", "-"     
$date = $date -replace ":", "-"  
$date = $date -replace " ", "_" 

$file = "$($bakPath)\$databaseName" + "_" + $date + ".bak"  

$bkup.Devices.AddDevice($file, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)  
$bkup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database  

$bkup.SqlBackup($server)

# Validate it is there
Get-ChildItem -Path $bakPath  

# Clean up after ourselves
Remove-Item "$($bakPath)\*.bak"

#endregion Backup

#region Error Logs
#-----------------------------------------------------------------------------#
# Review error logs 
#-----------------------------------------------------------------------------#

# If the instance is default, omit it
$serverName = $env:COMPUTERNAME # + "\default"  

# Everything is driven from the Server object. Get a reference to it
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverName")

# Review for backup status
$server.ReadErrorLog() |
  Where-Object ProcessInfo -eq "Backup" |
  Format-List

# Create a backup that fails to show the error
Backup-SqlDatabase -ServerInstance $serverName `
                   -Database "NoSuchDatabaseNameExists" `
                   -BackupAction Database

# Show the backups, including the new failure
$server.ReadErrorLog() |
  Where-Object ProcessInfo -eq "Backup" |
  Format-List

# Filter for only backup failures
$backupFailures = $server.ReadErrorLog() |
  Where-Object { $_.ProcessInfo -eq "Backup" -and `
                 $_.Text -like 'Backup failed*' -and `
                 $_.LogDate -gt $(Get-Date).ToShortDateString() `
               } 
if($backupFailures -ne $null)
{
  "There were errors backup up the databases"
  $backupFailures
}
else
{
  "Here are the errors as of $(Get-Date)"
  $backupFailures
}

# Comb the logs for errors
$server.ReadErrorLog() |
  Where-Object {$_.text -match 'error' -OR $_.text -match 'failed' } |
  Sort-Object logdate |
  Format-Table logdate, text -AutoSize -Wrap

#endregion Error Logs

#region Jobs
#-----------------------------------------------------------------------------#
# Jobs
#-----------------------------------------------------------------------------#

# If the instance is default, omit it
$serverName = $env:COMPUTERNAME # + "\default"  

# Everything is driven from the Server object. Get a reference to it
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverName")

$agent = $server.JobServer

$jobs = @()   # Create an empty array

foreach($job in $agent.Jobs)
{
  # Create a custom PS Object and copy over the properties we
  # want from the job into our new object
  $aJob = [PSCustomObject]@{
          Parent = $job.Parent
          Name = $job.name
          LastRunDate = $job.lastRunDate
          LastRunOutcome = $job.lastRunOutcome 
          }
  # Add the new object to our @jobs array
  $jobs += $aJob
}

# Display the conents of our jobs
$jobs | Format-Table -AutoSize

#endregion Jobs

#region Delete a database fast and easy
#-----------------------------------------------------------------------------#
# Delete a database fast and easy
#-----------------------------------------------------------------------------#

# First we need to create a db to delete. Use the little helper function
# to create it
New-ZombieDB
$databaseName = 'ZombieDB'

# Get a reference to the server
$serverName = $env:COMPUTERNAME # + "\default"  
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverName")

$server.KillAllProcesses($databaseName)
$server.KillDatabase($databaseName)
$server.KillProcess(52)

Get-SqlDatabase -ServerInstance $serverName `
                -Credential $cred

#endregion Delete a database fast and easy

#region Scripting the db
#-----------------------------------------------------------------------------#
# Scripting the server
#-----------------------------------------------------------------------------#
# Get a reference to the server
$serverName = $env:COMPUTERNAME # + "\default"  
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$serverName")

$server.Script()

#endregion Scripting the db


