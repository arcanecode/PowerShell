#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  This code creates the necessary Azure Storage components for use in
  backing up your SQL Server, as demonstrated in the script
  Z2HSQL-02.05 DBA - Backup Restore.ps1

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

# Path to demos - Set this to where you want to store your code
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"
Set-Location $dir

# Load our module, or force a reload in case it's already loaded
# Assumes you have already installed the module.
Import-Module PSAzure -Force 

Connect-PSToAzure

# WARNING: Storage account names must be unique across Azure. If
# you've downloaded this as a sample, you must change the name of
# the storage account! Use something like "yournameherestorageaccount"
$storageAccountName = 'z2hstorageaccount'
$resourceGroupName = 'Z2HRG'
$location = 'southcentralus'
$containerName = 'databasebackups'

$saAvailable = Test-PSStorageAccountNameAvailability `
                   -StorageAccountName $storageAccountName 
if ($saAvailable -eq $true)
{
  # Create a resource group for our test
  New-PSResourceGroup -ResourceGroupName $resourceGroupName `
                      -Location $location 
  
  # Create a storage account to keep the VM in
  New-PSStorageAccount -StorageAccountName $storageAccountName `
                       -ResourceGroupName $resourceGroupName `
                       -Location $location
}
else
{
  Write-Host "The name $storageAccountName was not available"
}

# Create a storage container
New-PSStorageContainer -ContainerName $containerName `
                       -ResourceGroupName $resourceGroupName `
                       -StorageAccountName $storageAccountName

# See what's in it
$context = Get-PSStorageContext `
              -ResourceGroupName $resourceGroupName `
              -StorageAccountName $storageAccountName

Get-AzureStorageBlob -Container $containerName -Context $context



<#-----------------------------------------------------------------------------
  Prior to being able to backup to Azure, you will need to setup a credential
  on your local SQL Server that stores the account key info for your storage
  account.
  
  For step by step instructions, see: 
  https://msdn.microsoft.com/library/64f8805c-1ddc-4c96-a47c-22917d12e1ab 
  
  The SQL Command is at the bottom, it needs these parameters:
 
  Identity - this is the name of the storage account you specified when 
             creating a storage account. Here, the value in the 
             $storageAccountName variable
 
  Secret   - this should be either the Primary or Secondary Access Key
             for the storage account. Using the PSAzure module, you can
             get this value with the followign command:
 
             Get-PSStorageAccountKey `
               -ResourceGroupName $resourceGroupName `
               -StorageAccountName $storageAccountName
 
  Now, could open up ssms, connect to the db engine, and run
  the following command. 
 
CREATE CREDENTIAL z2hstorageaccount 
  WITH IDENTITY= 'z2hstorageaccount'
     , SECRET = '<storage account access key>' 

  To remove it later:
DROP CREDENTIAL z2hstorageaccount

  BUT! There's a better way, we can do this all in PowerShell!
#>

# Get the key
$resourceGroupName = 'Z2HRG'
$storageAccountName = 'z2hstorageaccount'
$storageAccountKey = Get-PSStorageAccountKey `
                         -ResourceGroupName $resourceGroupName `
                         -StorageAccountName $storageAccountName

# Now we have to convert the key to a secure string
$secureStorageAccountKey = ConvertTo-SecureString $storageAccountKey -AsPlainText -Force

# The new credential needs the path to the server. The path is using the
# SQL Provider pathing. Here if the instance is the default, we'll need 
# to include default for the instance name
$serverInstanceDefault = 'ACDev\default'
$path = "SQLSERVER:\SQL\$serverInstanceDefault"

# Create the new credential. For simplicity we'll use the storage account
# name in Azure (the Identity property) for the Name property of the 
# credential inside your local SQL Server 
New-SqlCredential -Name $storageAccountName `
                  -Identity $storageAccountName `
                  -Secret $secureStorageAccountKey `
                  -Path $path

