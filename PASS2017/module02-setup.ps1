<#-----------------------------------------------------------------------------
  Powering Azure SQL With PowerShell

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 
 -----------------------------------------------------------------------------#>


<#---------------------------------------------------------------------------#>
<# Setup for Course 1 Module 2                                               #>
<#---------------------------------------------------------------------------#>

# Login to Azure --------------------------------------------------------------
$dir = "$($env:OneDrive)\Pluralsight\Azure\demos\course-01"
Set-Location $dir

# Run a script with functions used by multiple scripts in this course
. .\module-common.ps1

# Login if we need to
Connect-PSToAzure $dir

# Select the Azure account to use ---------------------------------------------
# You can use a framework such as this if you have multiple accounts
# PS=Pluralsight VS=Visual Studio MSDN FT=Azure Free Trial AC=ArcaneCode
$accountToUse = 'AC'
. .\module-set-common-vars.ps1 -AccountToUse $accountToUse

# Setup variables -------------------------------------------------------------
$location = 'southcentralus'
$dbName = 'WideWorldImporters'
$firewallRuleName = 'AllowSome' 
$queryTimeout = 500000
$pathCreateSQL = "$dir\WideWorldImportersAzureDWAdditions\WWI-DW-Additions\WWI-DW-Additions"

# Database Type
$edition = 'Premium'
$serviceObjectiveName = 'P1'
# $edition = 'Basic'
# $serviceObjectiveName = 'Basic'

# User Name for the SQL Server
$userName = 'ArcaneCode'
# Store the password to use in a text file (makes it easier to demo)
$pwFile = "$dir\pw.txt"
# PW is not encrypted for use with Invoke-SQLCmd
$password = Get-Content $pwFile 

# After the database is deployed, you may want to run additional scripts. 
# These are the SQL files we want to run.
$sqlScripts = @( 'DebugLog.sql'
               #, 'DB-AddUser.sql'
               )


# Set the session to use the correct subscription
Set-PSSubscription $useSub

# Create the resource group, if needed
New-PSResourceGroup $resourceGroupName $location

# Create the storage account, if needed
New-PSStorageAccount $storageAccountName $resourceGroupName $location

# Create the Storage Container, if needed
$container = New-PSStorageContainer $containerName $resourceGroupName $storageAccountName


<#---------------------------------------------------------------------------#>
<# Create and upload the local databases bacpac file to Azure                #>
<#---------------------------------------------------------------------------#>
#region Upload bacpac

# Creating a bacpac file can be time consuming, especially on a big database.
# If you are working with a static database, such as a development or test
# database, you may wish to create the bacpac file outside the script rather
# than regenerating it every time.

# Here I have four versions of the WideWorldImporters database, and just 
# uncomment the one I want to use for the current development session.

# This is the full version
#$bacpac = "$dir\wwi-bacpac-full\WideWorldImporters.bacpac"

# This is the smaller version
$bacpac = "$dir\wwi-bacpac-small\WideWorldImporters.bacpac"

# This is the empty version
#$bacpac = "$dir\wwi-bacpac-basic\WideWorldImporters.bacpac"

# This is the version for BASIC
#$bacpac = "$dir\wwi-bacpac-basic\WideWorldImporters.bacpac"

# For purposes of this demo, I still wanted to show how to generate a bacpac
# file. So I've created a tiny little databae that will run quickly. We'll
# use it to demonstrate, but you could replace with your own database name.
<#
$dbName = 'TeenyTinyDB'

# Out output file name
$targetFile = "$dir\$($dbName).bacpac"

# This uses the SQLPackage utility that ships with SQL Server. Note your
# location may change. In addition, the most recent versions of SQL Server
# (2017 and later) may have SQLPackage as a separate download. 
$sqlPackage = '"C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\sqlpackage.exe"'

# These are the parameters that are passed into the SQLPackage.exe
$params = '/Action:Export ' `
        + '/SourceServerName:localhost ' `
        + "/SourceDatabaseName:$($dbName) " `
        + "/targetfile:$($targetFile) " `
        + '/OverwriteFiles:True '

# Combine the sqlpackage.exe with the parameters
$cmd = "& $($sqlPackage) $($params)"

# Now execute it to create the bacpac
Invoke-Expression $cmd

# This is the end of the SQLPackage demo
#>

# Important, restore the database name so it won't try to use teenytinydb
# for the rest of the code. 
$dbName = 'WideWorldImporters'

# Finally, upload the bacpac file
Set-PSBlobContent -FilePathName $bacpac `
                  -ResourceGroupName $resourceGroupName `
                  -StorageAccountName $storageAccountName `
                  -ContainerName $containerName

#endregion Upload bacpac

<#---------------------------------------------------------------------------#>
<# Create the Azure SQL Server                                               #>
<#---------------------------------------------------------------------------#>
#region Create the SQL Server

# Generate a credential object for use with the server
$passwordSecure = Get-Content $pwFile |
                    ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object PSCredential ($username, $passwordSecure)

# Check to see if the server already exists
Write-Host "Checking the SQL Server $serverName" -ForegroundColor Yellow
$exists = Get-AzureRmSqlServer | Where-Object ServerName -eq $serverName

# If the server doesn't exist, create it.
if ($exists -eq $null)
{ 
  Write-Host "Creating the SQL Server $serverName" -ForegroundColor Cyan
  New-AzureRmSqlServer -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName `
                       -Location $location `
                       -SqlAdministratorCredentials $cred
}

# Now create a hole in the firewall of the SQL Server so we can use it
# First, see if the firewall rule already exists
Write-Host "Checking for Firewall Rule $firewallRuleName" -ForegroundColor Yellow
$exists = Get-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -FirewallRuleName $firewallRuleName `
            -ErrorAction SilentlyContinue


# Get the current IP Address
$x = Get-NetIPAddress -AddressFamily IPv4
$startIP = $x[0].IPAddress
$endIP = $x[0].IPAddress

# ... or set for a range
$startIP = '0.0.0.0'
$endIP = '255.255.255.255'


# If not found, create it
if ($exists -eq $null)
{ 
  # Note we're leaving the IP address range wide open, in a 
  # real world situation you should lock this down to a limited
  # range, if not a single IP address.
  Write-Host "Creating Firewall Rule $firewallRuleName" -ForegroundColor Cyan
  New-AzureRmSqlServerFirewallRule `
     -ResourceGroupName $resourceGroupName `
     -ServerName $servername `
     -FirewallRuleName $firewallRuleName `
     -StartIpAddress $startIP `
     -EndIpAddress $endIP
}
#endregion Create the SQL Server

<#---------------------------------------------------------------------------#>
<# Import the database, or more precisely the bacpac image of the database   #>
<#---------------------------------------------------------------------------#>
#region Import WideWorldImporters

# The import will fail if the db exists, so we need to check and delete it
# if it does
Write-Host "If needed removing database $dbName" -ForegroundColor Yellow
$exists = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                                 -ServerName $serverName |
          Where-Object DatabaseName -eq $dbName

if ($exists -ne $null)
{
  Write-Host "Removing database $dbName" -ForegroundColor Cyan
  Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                            -ServerName $serverName `
                            -DatabaseName $dbName `
                            -Force
}

# We now need the storage account key, and storage context
$storageAccountKey = Get-PSStorageAccountKey $resourceGroupName $storageAccountName
$context = Get-PSStorageContext $resourceGroupName $storageAccountName

# With the key and context, we can get the URI to the bacpac file
$storageUri = ( Get-AzureStorageBlob `
                  -blob "$($dbName).bacpac" `
                  -Container $containerName `
                  -Context $context `
              ).ICloudBlob.uri.AbsoluteUri

# Now we can begin the import process
Write-Host "Beginning Import of $dbName" -ForegroundColor Yellow
$request = New-AzureRmSqlDatabaseImport `
             -ResourceGroupName $resourceGroupName `
             -ServerName $serverName `
             -DatabaseName $dbName `
             -StorageKeyType StorageAccessKey `
             -StorageKey $storageAccountKey `
             -StorageUri $storageUri `
             -AdministratorLogin $cred.UserName `
             -AdministratorLoginPassword $cred.Password `
             -Edition $edition `
             -ServiceObjectiveName $serviceObjectiveName `
             -DatabasemaxSizeBytes 5000000

# After starting the import, Azure immediately returns control to PowerShell.
# We will need to call another cmdlet to check the status. Here we've created
# a loop to call it ever 10 seconds and check the status. The loop will end
# once we no longer get the InProgress message.
$keepGoing = $true
$processTimer = [System.Diagnostics.Stopwatch]::StartNew()
while ($keepGoing -eq $true)
{
  $status = Get-AzureRmSqlDatabaseImportExportStatus `
    -OperationStatusLink $request.OperationStatusLink
  if ($status.Status -eq 'InProgress')
  {
    Write-Host "$((Get-Date).ToLongTimeString()) - $($status.StatusMessage)" `
      -ForegroundColor DarkYellow
    Start-Sleep -Seconds 10
  }
  else
  {
    $processTimer.Stop()
    Write-Host "$($status.Status) - Elapsed Time $($processTimer.Elapsed.ToString())" `
      -ForegroundColor Yellow
    $keepGoing = $false
  }
}

# Show proof the DB now exists
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status


# Execute scripts to create tables and stored procs ---------------------------
foreach ($sqlScript in $sqlScripts)
{ 
  Write-Host "Executing $sqlScript" -ForegroundColor Yellow
  $sqlFile = "$pathCreateSQL\$sqlScript"
  $sql = Get-Content -Path $sqlFile -Raw
  Invoke-Sqlcmd -Query $sql `
                -ServerInstance "$serverName.database.windows.net" `
                -Database $dbName `
                -Username "$username@$serverName" `
                -Password $password `
                -QueryTimeout $queryTimeout
}

Write-Host "Done creating $dbName" -ForegroundColor Yellow

#endregion Import WideWorldImporters
