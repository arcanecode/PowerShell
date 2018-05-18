#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Demonstrate common DBA tasks for SQL Server with PowerShell

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

# Set default folder
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"
$dirBackupDefault = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup'

# Load credentails
$pwFile = "$dir\pw.txt"
$passwordSecure = Get-Content $pwFile |
  ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object PSCredential ('sa', $passwordSecure)

#-----------------------------------------------------------------------------#
# Backup
#-----------------------------------------------------------------------------#

# For demo purposes, we will delete all of our existing backups. 
# DO NOT DO THIS IN YOUR PRODUCTION ENVIRONMENT OR ELSE HAVE YOUR RESUME READY
Get-ChildItem $dirBackupDefault |
  Remove-Item -Force -ErrorAction SilentlyContinue

Get-ChildItem $dirBackupDefault 

# Simple backup to default location, Full backup by default
$serverInstance = "ACDev"
Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "TutorialDB"
Get-ChildItem $dirBackupDefault 

# Can also do a log (incremental) backup on Full (non simple) recover model DBs
Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "TutorialDB" `
                   -BackupAction Log 
Get-ChildItem $dirBackupDefault 

# BackupAction can be Database (the default), Log, and Files

# You can backup to an alternate location
# Note, make sure the MSSQLSERVER 'user' has permissions to the target folder
Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "TeenyTinyDB" `
                   -Credential $cred `
                   -BackupFile "C:\Backups\TeenyTinyDB.bak"
Get-ChildItem 'C:\Backups'

# You can use a different set of credentials to do your backup
Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "WideWorldImportersDW" `
                   -Credential $cred 
Get-ChildItem $dirBackupDefault 

# You can turn backup compression on or off (or it'll use the server default)
# Note, if you backed up previously with a different compression setting,
# it will generate an error. Thus we'll remove any pre-existing backups 
# just to avoid this (probably not a good idea to do it in production)
Remove-Item "$dirBackupDefault\TeenyTinyDB.bak" `
            -Force `
            -ErrorAction SilentlyContinue
Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "TeenyTinyDB" `
                   -CompressionOption On 
Get-ChildItem $dirBackupDefault 


#-----------------------------------------------------------------------------#
# Backup to SQL Azure Blob Storage
#-----------------------------------------------------------------------------#

# This takes a bit of setup. First, you'll need a container in Azure blob
# storage. See the 'Z2HSQL-02.98 DBA - Setup Azure Storage.ps1' script for
# an example of how to create this.

# Second, you'll need to create a credential for Azure and store it in your
# local SQL Server. The end of the above mentioned script has more details
# on how to set this up

$sqlCredential = 'z2hstorageaccount'
$resourceGroupName = 'Z2HRG'
$storageAccountName = 'z2hstorageaccount'
$containerName = 'databasebackups'
$url = "https://$storageAccountName.blob.core.windows.net/$containerName"
$dbName = "TeenyTinyDB"
$backupFile = "$url/$dbName.bak"

Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "TeenyTinyDB" `
                   -BackupFile $backupFile `
                   -SqlCredential $sqlCredential

# Now see it's there.
# Login to Azure using the PSAzure module
Import-Module PSAzure -Force 
Connect-PSToAzure

# Get the storage context, again using the PSAzure module
$context = Get-PSStorageContext `
              -ResourceGroupName $resourceGroupName `
              -StorageAccountName $storageAccountName

# See what's in it
Get-AzureStorageBlob -Container $containerName -Context $context

# If you are just experimenting, don't forget to remove the storage
# container so you aren't charged for it. The script
# Z2HSQL-02.99 DBA - Remove Azure Storage.ps1 will show you how to remove 
# the storage account.


#-----------------------------------------------------------------------------#
# Restore
#-----------------------------------------------------------------------------#

# Do a simple backup first
Remove-Item "$dirBackupDefault\TeenyTinyDB.bak" `
            -Force `
            -ErrorAction SilentlyContinue
Backup-SqlDatabase -ServerInstance $serverInstance `
                   -Database "TeenyTinyDB"
Get-ChildItem $dirBackupDefault 


# Simple restore from the last backup that completely replaces the existing
# database
$serverInstance = "ACDev"
Restore-SqlDatabase -ServerInstance $serverInstance `
                    -Database 'TeenyTinyDB' `
                    -ReplaceDatabase

# You can also pass in a credential object
Restore-SqlDatabase -ServerInstance $serverInstance `
                    -Database 'TeenyTinyDB' `
                    -ReplaceDatabase `
                    -Credential $cred

# Restore from an alternate location
Restore-SqlDatabase -ServerInstance $serverInstance `
                    -Database 'TeenyTinyDB' `
                    -BackupFile 'C:\Backups\TeenyTinyDB.bak' `
                    -ReplaceDatabase

# Restore from Azure blob storage
$sqlCredential = 'z2hstorageaccount'
$resourceGroupName = 'Z2HRG'
$storageAccountName = 'z2hstorageaccount'
$containerName = 'databasebackups'
$url = "https://$storageAccountName.blob.core.windows.net/$containerName"
$dbName = "TeenyTinyDB"
$backupFile = "$url/$dbName.bak"

Restore-SqlDatabase -ServerInstance $serverInstance `
                    -Database 'TeenyTinyDB' `
                    -BackupFile $backupFile `
                    -SqlCredential $sqlCredential `
                    -ReplaceDatabase

