<#--------------------------------------------------------------------
  Z2H-AZ-06 SQL
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          https://arcanecode.com | https://github.com/arcanecode
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights 
  reserved. No warranty or guarentee is implied or expressly granted. 

  All information was accurate at the time of the demo creation. Note
  that things are changing very rapidly in the world of Azure in 
  general and Azure's PowerShell modules in particular, so be sure
  to check Microsoft online documentation for the latest information.
  
  In this demo you'll see how to interact with AzureSQL. 
--------------------------------------------------------------------#>

#region Login

# Set a variable with the path to the working directory as we'll
# use it over and over
$dir = "$($env:OneDrive)\Pluralsight\Azure\PS"

# Login to Azure
Add-AzureRmAccount 

# OR
$path = "$dir\ProfileContext.ctx"
Import-AzureRmContext -Path $path

#endregion Login

#region Create SQL Server DB
<#-------------------------------------------------------------------- 
   Create the virtual SQL Server a database
--------------------------------------------------------------------#>

# First you need a resource group to put the Server in
$resourceGroupName = 'AzureSqlRG'
$location = 'southcentralus'
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Now we need to create our logical SQL Server. First we'll need
# credentials for our server admin.
$userName = 'ArcaneCode'
$pwFile = "$dir\vmpw.txt"
$password = Get-Content $pwFile |
   ConvertTo-SecureString -AsPlainText -Force

$cred = New-Object PSCredential ($username, $password)

# Alternatively you could use the following to prompt the user 
# (we won't be using this alternate credential, it is just here to 
#  illustrate)
$credAlternate = Get-Credential

# Now we can create our server
$serverName = 'arcanesql'
New-AzureRmSqlServer -ResourceGroupName $resourceGroupName `
                     -ServerName $serverName `
                     -Location $location `
                     -SqlAdministratorCredentials $cred

<#
   Next, we need to create a firewall rule to allow us to access
   the server from outside of Azure. In this example we're going
   to open it up to all IP addresses, which can be risky. When
   possible, isolate it to a specific range.
#>

New-AzureRmSqlServerFirewallRule `
  -ResourceGroupName $resourceGroupName `
  -ServerName $servername `
  -FirewallRuleName 'AllowSome' `
  -StartIpAddress '0.0.0.0' `
  -EndIpAddress '255.255.255.255'

# Now that we have our Server, let's create an empty database
$dbName = 'ArcaneDB'
New-AzureRmSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $servername `
    -DatabaseName $dbName `
    -RequestedServiceObjectiveName 'Basic'

<#
   To connect to the server in SSMS, just open and connect to
   <servername>.database.windows.net, where <servername> is the name
   of the server you just created. 

   Change the login to SQL Server, and use the user id and password
   you created in the credential step above. 
#>

#endregion Create SQL Server DB

#region Export/Import Databases
<#-------------------------------------------------------------------- 
   Exporting and Importing Databases
--------------------------------------------------------------------#>

# Before we can start exporting/importing, we need a storage area 
# to put our backup file in. Let's create one.
$saName = 'arcanestorageaccount'
$exists = Get-AzureRmStorageAccountNameAvailability -Name $saName
if($exists.NameAvailable -eq $true)
{
  New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                            -Name $saName `
                            -Location $location `
                            -Type Standard_LRS
}

$saKey = $(Get-AzureRmStorageAccountKey `
             -ResourceGroupName $resourceGroupName `
             -Name $saName).Value[0]

<#
   Now we need to create a context variable to encapsulate our
   storage access info. Note this only creates an in memory object,
   it won't alter your Azure instance.
#>
$context = New-AzureStorageContext -StorageAccountName $saName `
                                   -StorageAccountKey $saKey
# Create a new storage container that will hold our images
$containerName = 'arcanesqlstorage'

New-AzureStorageContainer -Name $containerName `
                          -Context $context `
                          -Permission Blob

# Now grab a reference to it
$container = Get-AzureStorageContainer -Name $containerName `
                                       -Context $context

# From the container we can determine the root URI where our blob  
# will ultimately reside
$rootUri = $container.CloudBlobContainer.Uri.AbsoluteUri

# Now we need to append the blob name to the root URI
$storageUri = "$rootUri/$dbName.bacpac"

# Finally, we need to remove the blob if it is there already, or 
# else we'll get an error
$blobExists = Get-AzureStorageBlob -Container $containerName `
                        -Context $context `
                        -Blob "$dbName.bacpac" `
                        -ErrorAction SilentlyContinue
if ($blobExists -ne $null)
{ 
  Remove-AzureStorageBlob -Container $containerName `
                          -Context $context `
                          -Blob "$dbName.bacpac"
}


# Now we can start the export. We'll return a variable which we 
# can use to check the status of the export.
$export = New-AzureRmSqlDatabaseExport `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $dbName `
            -StorageKeyType StorageAccessKey `
            -StorageKey $saKey `
            -StorageUri $storageUri `
            -AdministratorLogin $cred.UserName `
            -AdministratorLoginPassword $cred.Password 

# To get the status of your export
Get-AzureRmSqlDatabaseImportExportStatus `
  -OperationStatusLink $export.OperationStatusLink

# Show it is there
Get-AzureStorageBlob -Container $containerName `
                     -Blob $blobName `
                     -Context $context

# Once you have the export, importing is quite simple
$importDbName = $dbName + 'Import'

<#
   One new parameter is Edition. Valid values are:
   Premium
   PremimumRS
   Basic
   Standard
   DataWarehouse
   Free
   Stretch
   None

   The other is ServiceObjectiveName. Check out
   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers
   For an article and list of SO's. We'll use Basic as this is a demo
#>
$import = New-AzureRmSqlDatabaseImport `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $importDbName `
            -DatabaseMaxSize 5000000 `
            -Edition Basic `
            -ServiceObjectiveName Basic `
            -StorageKeyType StorageAccessKey `
            -StorageKey $saKey `
            -StorageUri $storageUri `
            -AdministratorLogin $cred.UserName `
            -AdministratorLoginPassword $cred.Password 

# Once the import starts use this to check the status
Get-AzureRmSqlDatabaseImportExportStatus `
  -OperationStatusLink $import.OperationStatusLink


# Get a compact list of databases and their status
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status

# Drop it if we don't need it
Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                          -ServerName $serverName `
                          -DatabaseName $importDbName `
                          -Force

# And get the list again to show it is gone
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status


#endregion Export/Import Databases

#region Migrating to Cloud
<#-------------------------------------------------------------------- 
   Moving on premisis to the cloud
--------------------------------------------------------------------#>
# First export the database as a bacpac. You can use SqlPackage, or
# in SSMS right click on the database, pick Tasks, then
# Export Data-Tier Application
#$dbName = 'wwi-ssdt'
$dbName = 'AdventureWorksDW2014'
$targetFile = "$dir\$($dbName).bacpac"
$sqlPackage = '"C:\Program Files (x86)\Microsoft Visual Studio 15.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\sqlpackage.exe"'
$params = '/Action:Export ' `
        + '/SourceServerName:localhost ' `
        + "/SourceDatabaseName:$($dbName) " `
        + "/targetfile:$($targetFile) " `
        + '/OverwriteFiles:True '
$cmd = "& $($sqlPackage) $($params)"
Invoke-Expression $cmd

# Next copy it up to the cloud. Start by getting the storage context
$saName = 'arcanestorageaccount'
$saKey = $(Get-AzureRmStorageAccountKey `
             -ResourceGroupName $resourceGroupName `
             -Name $saName).Value[0]
$context = New-AzureStorageContext -StorageAccountName $saName `
                                   -StorageAccountKey $saKey

# Now copy it up to storage
$containerName = 'arcanesqlstorage'
Set-AzureStorageBlobContent -File $targetFile `
                            -Container $containerName `
                            -Context $context `
                            -Blob "$($dbName).bacpac" `
                            -ServerTimeoutPerRequest 1200 `
                            -ClientTimeoutPerRequest 1200

# One last thing, we need to get the URI to the blob we want to import
$storageUri = ( Get-AzureStorageBlob `
                  -blob "$($dbName).bacpac" `
                  -Container $containerName `
                  -Context $context `
              ).ICloudBlob.uri.AbsoluteUri

# Now start the import of the database. 
# Note that Start-AzureSqlDatabaseImport no longer seems to work
$request = New-AzureRmSqlDatabaseImport `
             -ResourceGroupName $resourceGroupName `
             -ServerName $serverName `
             -DatabaseName $dbName `
             -StorageKeyType StorageAccessKey `
             -StorageKey $saKey `
             -StorageUri $storageUri `
             -AdministratorLogin $cred.UserName `
             -AdministratorLoginPassword $cred.Password `
             -Edition Basic `
             -ServiceObjectiveName Basic `
             -DatabasemaxSizeBytes 5000000

# Monitor the import process by using the following cmdlet
Get-AzureRmSqlDatabaseImportExportStatus `
  -OperationStatusLink $request.OperationStatusLink 

# Show it is there
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status

#endregion Migrating to Cloud


#region Cleanup
<#-------------------------------------------------------------------- 
   Cleanup after the demos are run
--------------------------------------------------------------------#>
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status

# You could remove individual parts.
Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                          -ServerName $serverName `
                          -DatabaseName $dbName `
                          -Force

Remove-AzureStorageContainer -Name $containerName `
                             -Context $context `
                             -Force   # Suppress the confirmation

# Or just remove the whole Resource Group
Remove-AzureRmResourceGroup -Name $resourceGroupName -Force
Get-AzureRmResourceGroup

#endregion Cleanup


<#-------------------------------------------------------------------- 
   Resources

   List of AzureRmSQL Cmdlets
   https://docs.microsoft.com/en-us/powershell/module/azurerm.sql/?view=azurermps-3.8.0

   List of Service Tiers
   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers

   Resolving T-SQL differences during migration to Azure SQL Database
   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-transact-sql-information

--------------------------------------------------------------------#>

























<#-------------------------------------------------------------------- 
   Ignore this area, stuff that is in progress for the future
--------------------------------------------------------------------#>
Get-AzureRmSqlServerServiceObjective -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName 'ArcaneDB'
