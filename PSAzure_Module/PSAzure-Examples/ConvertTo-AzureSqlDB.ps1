<#-----------------------------------------------------------------------------
  Powering Azure SQL With PowerShell

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017/2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 
 -----------------------------------------------------------------------------#>
 
#region Module - Introduction
<#---------------------------------------------------------------------------#>
<# Module - Introduction                                                     #>
<#                                                                           #>
<# This section is just a few basic steps. First, we setup a reference to    #>
<# the directory with the code samples. I store my demos in OneDrive, in a   #>
<# folder for this course. But if you download these you can place them      #>
<# anywhere, just update the $dir variable to the spot where you saved it.   #>
<#                                                                           #>
<# Next we call the script with all our functions, after which we call one   #>
<# our custom functions ot connect to Azure and set our current subscription #>
<# (useful if you have more than one subscription). Note these are not       #>
<# covered in the video associated with these samples, as logging into Azure #>
<# is covered in another course. However the code is there should you wish   #>
<# to review it.                                                             #>
<#---------------------------------------------------------------------------#>

# Path to demos - Set this to where you want to store your code
#$dir = "C:\PowerShell\PSAzure-Module\PSAzure-Examples"
$dir = "$($env:ONEDRIVE)\Pluralsight\PSAzure-Module\PSAzure-Examples"
Set-Location $dir

# Load our module, or force a reload in case it's already loaded
# Assumes you have already installed the module.
Import-Module PSAzure -Force 

# Login. To make login quicker, this uses function looks to 
# see if a profile context file (named, by default, ProfileContext.ctx)
# exists. If so, it uses that info to make logging in easier.
# See the script Create-ProfileContext.ps1 on how to create this file.
# See the help for Connect-PSToAzure for a list of locations where it will
# automatically look for the file, or pass in the location using the -Path
# parameter.
Connect-PSToAzure -Verbose

# Create a shorter path to display
New-PSDrive -Name Demo `
            -PSProvider FileSystem `
            -Root $dir

Set-Location Demo:

# Set the session to use the correct subscription
$useSub = 'Visual Studio Ultimate with MSDN'
Set-PSSubscription $useSub

#endregion Module - Introduction

#region Module - Resource Groups and Storage Accounts
<#---------------------------------------------------------------------------#>
<# Module - Resource Groups and Storage Accounts                             #>
<#                                                                           #>
<# Before we do anything, we need to have a resource group. Resource groups  #>
<# are an organizational mechanism. We place objects that are related to     #>
<# each other, such as a web server and the SQL Server it uses, into the     #>
<# same resource group.                                                      #>
<#                                                                           #>
<# To import data into AzureSQL, we use a bacpac as the source. Thus we need #>
<# a place on Azure to store that bacpac. In this section, after creating    #>
<# the resource group, we'll create our storage space.                       #>
<#                                                                           #>
<# Storage in Azure consists of two parts. First, you create the storage     #>
<# account. After creating the account, you create a container within the    #>
<# account. A single storage account can contain multiple containers, of     #>
<# different types. for this module though, we only need a single container, #>
<# and it will be a blob type of container which can hold pretty much        #>
<# anything.                                                                 #>
<#---------------------------------------------------------------------------#>
$resourceGroupName = 'PSAzSQLPlaybookDemo'
$location = 'southcentralus'          # Geographic location to store everything
$storageAccountName = 'pbstoragedemo' # Name of the storage account
$containerName = 'pbstoragecontainer' # Name of container inside storage account

# Create the resource group, if needed
New-PSResourceGroup -ResourceGroupName $resourceGroupName `
                    -Location $location `
                    -Verbose

# Create the storage account, if needed
New-PSStorageAccount -StorageAccountName $storageAccountName `
                     -ResourceGroupName $resourceGroupName `
                     -Location $location `
                     -Verbose

# Create the Storage Container, if needed
$container = New-PSStorageContainer -ContainerName $containerName `
                                    -ResourceGroupName $resourceGroupName `
                                    -StorageAccountName $storageAccountName `
                                    -Verbose

#endregion Module - Resource Groups and Storage Accounts

#region Module - Create an Azure SQL Server
<#---------------------------------------------------------------------------#>
<# Module - Create an Azure SQL Server                                       #>
<#                                                                           #>
<# Creating an Azure SQL Server is a two step process. First, we need to     #>
<# create the server itself. After the server is created though, there is no #>
<# way to communicate with it outside Azure. As a result we need to create   #>
<# a firewall rule to allow specific IP addresses to access the server.      #>
<#                                                                           #>
<# One important note. To make this easy to demo, I store my password in a   #>
<# plain text file, and just read it in. This password is only used for      #>
<# these simple demos. In the real world, this is a very poor practice.      #>
<# There are numerous blog posts and methods out on the internet on how to   #>
<# properly store an encrypted password, however I did not want to           #>
<# complicate the code demos provided with this module, and kept it very     #>
<# simple. The point about storing plain text passwords in text files is:    #>
<#                                                                           #>
<#   ******************** DO NOT DO THIS IN YOUR CODE! ********************  #>
<#                                                                           #>
<# If I find you doing this in your code, I will grab my latest book, the    #>
<# SQL Serve 2016 Reporting Services Cookbook, available at fine retailers   #>
<# everywhere, and smack you upside the head with it. Repeatedly.            #>
<#---------------------------------------------------------------------------#>

# Setup variables
$resourceGroupName = 'PSAzSQLPlaybookDemo'
$location = 'southcentralus'          # Geographic location to store everything
$serverName = 'psplaybooksqlserver'   # Name for our new SQL Server
$userName = 'ArcaneCode'              # Admin User Name for the SQL Server

# Read the password to use from a text file 
# (evil practice but makes it easy to demo)
$pwFile = "$dir\pw.txt"
$password = Get-Content $pwFile 

New-PSAzureSQLServer -ServerName $serverName `
                     -ResourceGroupName $resourceGroupName `
                     -Location $location `
                     -UserName $userName `
                     -Password $password `
                     -Verbose

$firewallRuleName = 'ArcaneCodesFirewallRule' 

# There are two ways to get the IP address for the firewall.
# First, you can get the IP Address of the computer running this script
$x = Get-NetIPAddress -AddressFamily IPv4
$startIP = $x[0].IPAddress
$endIP = $x[0].IPAddress

# Alternatively, you can manually enter a range of IPs. Here it's just
# been opened to the entire internet, in reality you'd limit it to just 
# the range needed by your company
$startIP = '0.0.0.0'
$endIP = '255.255.255.255'

# Now we can call our helper function to create the new firewall rule
New-PSAzureSQLServerFirewallRule -ServerName $serverName `
                                 -ResourceGroupName $resourceGroupName `
                                 -FirewallRuleName $firewallRuleName `
                                 -StartIpAddress $startIP `
                                 -EndIpAddress $endIP `
                                 -Verbose
#endregion Module - Create an Azure SQL Server

#region Module - Migrate a Local Database to AzureSQL
<#---------------------------------------------------------------------------#>
<# Module - Migrate a Local Database to AzureSQL                             #>
<#                                                                           #>
<# In this module, we'll first take a database from a SQL Server and         #>
<# convert it to a bacpac file.                                              #>
<#                                                                           #>
<# Next, we'l upload that bacpac to the storage container we created in      #>
<# the module 'Resource Groups and Storage Accounts.                         #>
<#                                                                           #>
<# In the third step, we'll start the database import process.               #>
<#                                                                           #>
<# The database import is an asyncronous process, as soon as you issue the   #>
<# import command control returns to PowerShell. So in the fourth step we    #>
<# will see some code that will allow you to monitor the import progress.    #>
<#                                                                           #>
<# Notes                                                                     #>
<# Creating a bacpac file can be time consuming, especially on a big         #>
<# database. If you are working with a static database, such as a            #>
<# development or test database, you may wish to create the bacpac file      #>
<# once, outside your main script, rather than regenerating it every time.   #>
<#                                                                           #>
<# For purposes of this demo, we're using a tiny little database that will   #>
<# run very quickly. Be warned that if you have a huge database the bacpac   #>
<# creation could take a considerable time.                                  #>
<#---------------------------------------------------------------------------#>

# Setup variables
$storageAccountName = 'pbstoragedemo' # Name of the storage account
$containerName = 'pbstoragecontainer' # Name of container inside storage account
$serverName = 'psplaybooksqlserver'   # Name for our new SQL Server
$userName = 'ArcaneCode'              # Admin User Name for the SQL Server
$resourceGroupName = 'PSAzSQLPlaybookDemo'

# Read the password to use from a text file 
# (evil practice but makes it easy to demo)
$pwFile = "$dir\pw.txt"
$password = Get-Content $pwFile 

# Create the bacpac
$dbName = 'TeenyTinyDB'
New-PSBacPacFile -DatabaseName $dbName `
                 -Path $dir `
                 -SourceServer 'localhost' `
                 -Verbose

# Upload the bacpac file to storage
$bacPacFile = "$dir\$($dbName).bacpac"
Set-PSBlobContent -FilePathName $bacPacFile `
                  -ResourceGroupName $resourceGroupName `
                  -StorageAccountName $storageAccountName `
                  -ContainerName $containerName `
                  -Verbose

# The import will fail if the db exists, so we need to check and delete it
# if it does
Remove-PSAzureSQLDatabase -ResourceGroupName $resourceGroupName `
                          -ServerName $serverName `
                          -DatabaseName $dbName `
                          -Verbose

# Database Type
$dbEdition = 'Basic'
$serviceObjectiveName = 'Basic'

# Now we can start the import process
$request = New-PSAzureSqlDatabaseImport `
              -ResourceGroupName $resourceGroupName `
              -ServerName $serverName `
              -DatabaseName $dbName `
              -StorageAccountName $storageAccountName `
              -StorageContainerName $containerName `
              -UserName $userName `
              -Password $password `
              -DbEdition $dbEdition `
              -ServiceObjectiveName $serviceObjectiveName `
              -Verbose

# After starting the import, Azure immediately returns control to PowerShell.
# We will need to call another cmdlet to check the status. Here we've created
# a loop to call it ever 10 seconds and check the status. For a large database
# you will likely want to up the time to minutes or maybe even hours. The loop
# will end once we no longer get the InProgress message.

# Just a flag to keep the while loop going
$keepGoing = $true

# It can be useful to know how long loads take. Using a stopwatch can
# make this easy.
$processTimer = [System.Diagnostics.Stopwatch]::StartNew()

# Keep looping until we find out it is done. 
while ($keepGoing -eq $true)
{
  # This will tell us the status, but we will need the request object
  # returned by our function New-PSAzureSQLDatabaseImport
  $status = Get-AzureRmSqlDatabaseImportExportStatus `
               -OperationStatusLink $request.OperationStatusLink
  
  if ($status.Status -eq 'InProgress') # Display a progress message
  {
    Write-Host "$((Get-Date).ToLongTimeString()) - $($status.StatusMessage)" `
      -ForegroundColor DarkYellow
    Start-Sleep -Seconds 10
  }
  else                                 # Let user know we're done
  {
    $processTimer.Stop()
    Write-Host "$($status.Status) - Elapsed Time $($processTimer.Elapsed.ToString())" `
      -ForegroundColor Yellow
    $keepGoing = $false
  }
}

# Just to wrap this up, show proof the DB now exists
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status

#endregion Module - Migrate a Local Database to AzureSQL

#region Module - Apply Additional SQL Scripts Against the Azure SQL Database
<#---------------------------------------------------------------------------#>
<# Module - Apply Additional SQL Scripts Against the Azure SQL Database      #>
<#                                                                           #>
<# At times you may wish to execute scripts against your AzureSQL database.  #>
<# This may be to add to or alter the database you have just deployed, in a  #>
<# post deployment scenario. Or just as part of regular maintenance.         #>
<#                                                                           #>
<# In this section we will load an array of of script file names into an     #>
<# array. Then each script will be run against the AzureSQL database.        #>
<#---------------------------------------------------------------------------#>

$queryTimeout = 500000

# This array holds the SQL files we want to run.
$sqlScripts = @( 'DebugLog.sql'
               #, 'DB-AddUser.sql'
               )

# Just a simple array that reads each file into memory. The -Raw is very 
# important, without it the script will be loaded as an array. With -Raw,
# the file is loaded as one big text string into the $sql variable.
foreach ($sqlScript in $sqlScripts)
{ 
  # Show a nice little message letting user know what we're doing
  Write-Host "Executing $sqlScript" -ForegroundColor Yellow

  # Create a variable with the full path\file to load
  $sqlFile = "$dir\$sqlScript"

  # Read in the contents of the file into a variable
  $sql = Get-Content -Path $sqlFile -Raw

  # Invoke-Sqlcmd is use to run SQL scripts against SQL databases,
  # whether local or AzureSQL. For AzureSQL, the full server name will be
  # the name of the server followed by .database.windows.net

  # The username will be the user name followed by @ and the server name
  # (without the database.windows.net)
  
  # The password should be the unencrypted, plain text password

  Invoke-Sqlcmd -Query $sql `
                -ServerInstance "$serverName.database.windows.net" `
                -Database $dbName `
                -Username "$username@$serverName" `
                -Password $password `
                -QueryTimeout $queryTimeout
}

Write-Host "Done updating $dbName" -ForegroundColor Yellow

#endregion Module - Apply Additional SQL Scripts Against the Azure SQL Database

#region Module - Removing AzureSQL
<#---------------------------------------------------------------------------#>
<# Module - Removing AzureSQL                                                #>
<#---------------------------------------------------------------------------#>
$resourceGroupName = 'PSAzSQLPlaybookDemo'
$serverName = 'psplaybooksqlserver'   
$dbName = 'TeenyTinyDB'
$firewallRuleName = 'ArcaneCodesFirewallRule' 
$storageAccountName = 'pbstoragedemo' 
$containerName = 'pbstoragecontainer' 

Remove-PSAzureSQLDatabase -ResourceGroupName $resourceGroupName `
                          -ServerName $serverName `
                          -DatabaseName $dbName `
                          -Verbose

Remove-PSAzureSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
                                    -ServerName $serverName `
                                    -FirewallRuleName $firewallRuleName `
                                    -Verbose

Remove-PSAzureSqlServer -ResourceGroupName $resourceGroupName `
                        -ServerName $serverName `
                        -Verbose

Remove-PsAzureStorageContainer -ResourceGroupName $resourceGroupName `
                               -StorageAccountName $storageAccountName `
                               -ContainerName $containerName `
                               -Verbose

Remove-PSAzureStorageAccount -StorageAccountName $storageAccountName `
                             -ResourceGroupName $resourceGroupName `
                             -Verbose

Remove-PsAzureResourceGroup -ResourceGroupName $resourceGroupName `
                            -Verbose

Get-AzureRmResourceGroup

# Cleanup the short cut we created at the beginning
Set-Location $dir
Remove-PSDrive -Name Demo

#endregion Module - Removing AzureSQL


