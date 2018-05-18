#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  The code in this module cleans up the Azure Storage account, as well as 
  the created Credentials stored in your on-premesis database, created in
  the script Z2HSQL-02.98 DBA - Setup Azure Storage.ps1. This script
  was created to support backing up a database to Azure, as demonstrated
  in the script Z2HSQL-02.05 DBA - Backup Restore.ps1.

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

Import-Module PSAzure
Import-Module SqlServer

# Connect to Azure and drop the resource group and everything in it
Connect-PSToAzure
$resourceGroup = 'Z2HRG'
Remove-PsAzureResourceGroup -ResourceGroupName $resourceGroup

# Remove the credential object from the local SQL Server

# Note this uses the SQL Provider to handle the pathing. 
# Additionally if this is the default instance, here you'll have to include it
# (unlike in other cmdlets we've used)
$serverInstanceDefault = 'ACDev\default'
$storageAccountName = 'z2hstorageaccount'
$path = "SQLSERVER:\SQL\$serverInstanceDefault\Credentials\$storageAccountName"

# The command also assumes you are running this on the SQL Server that has
# the credential to be removed and you have the appropriate rights
Remove-SqlCredential -Path $path

