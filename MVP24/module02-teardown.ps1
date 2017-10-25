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
<# Teardown for Course 1 Module 2                                            #>
<#---------------------------------------------------------------------------#>

$dir = "$($env:OneDrive)\Pluralsight\Azure\demos\course-01"
Set-Location $dir

# Run a script with functions used by multiple scripts in this course
. .\module-common.ps1

# This section sets some variables as to what to remove.
# For a daily teardown we'll only remove the database since it
# incurrs premium storage. When you are done, you can set 
# all three to true in order to remove everything. 
$dropDB = $true
$dropSQLServer = $false
$dropFirewall = $false

$dbName = "WideWorldImporters"

# Login if we need to
Connect-PSToAzure $dir

# Select the Azure account to use ---------------------------------------------
# You can use a framework such as this if you have multiple accounts
# PS=Pluralsight VS=Visual Studio MSDN FT=Azure Free Trial
$accountToUse = 'PS'
switch ($accountToUse)
{
  'PS' { 
         $useSub = 'Pluralsight Azure Content'
         $resourceGroupName = 'PSAZDemo'
         $storageAccountName = 'psazstoragedemo'
         $containerName = 'psazstoragecontainer'
         $serverName = 'psazsqlserver'
         break
       }
  'VS' { 
         $useSub = 'Visual Studio Ultimate with MSDN'
         $resourceGroupName = 'PSDemo'
         $storageAccountName = 'psstoragedemo'
         $containerName = 'psstoragecontainer'
         $serverName = 'pssqlserver'
         break
       }
  'FT' {
         $useSub = 'Azure Free Trial'
         $resourceGroupName = 'PSFTDemo'
         $storageAccountName = 'psftstoragedemo'
         $containerName = 'psftstoragecontainer'
         $serverName = 'psftsqlserver'
         break
       }
  default      
       { 
         $useSub = 'Visual Studio Ultimate with MSDN'
         $resourceGroupName = 'PSDemo'
         $storageAccountName = 'psstoragedemo'
         $containerName = 'psstoragecontainer'
         $serverName = 'pssqlserver'
         break
       }
}

# Set the session to use the correct subscription
Set-PSSubscription $useSub

#region Drop Database ---------------------------------------------------------
if ($dropDB -eq $true)
{ 
  Write-Host "Checking for the existance of $dbName" -ForegroundColor Yellow
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
  } # if ($exists -ne $null)
} #if ($dropDB -eq $true)

#endregion Drop Database

#region Drop Firewall

# Now drop the firewall -------------------------------------------------------
$firewallRuleName = 'AllowSome' 
if ($dropFirewall -eq $true)
{ 
  Write-Host "Checking for the existance of a firewall on the server $servername" -ForegroundColor Yellow
  $exists = Get-AzureRmSqlServerFirewallRule `
              -ResourceGroupName $resourceGroupName `
              -ServerName $servername `
              -FirewallRuleName $firewallRuleName `
              -ErrorAction SilentlyContinue


  if ($exists -ne $null)
  { 
     Write-Host "Removing the firewall from the server $servername" -ForegroundColor Cyan
     Remove-AzureRmSqlServerFirewallRule `
       -ResourceGroupName $resourceGroupName `
       -ServerName $servername `
       -FirewallRuleName 'AllowSome' `
       -Force
  } # if ($exists -ne $null)
} # if ($dropFirewall -eq $true)

#endregion Drop Firewall

#region Drop SQL Server -------------------------------------------------------

if ($dropSQLServer -eq $true)
{ 
  Write-Host "Checking for the existance of the SQL Server $serverName" -ForegroundColor Yellow
  $exists = Get-AzureRmSqlServer | Where-Object ServerName -eq $serverName
  if ($exists -ne $null)
  { 
    Write-Host "Removing the SQL Server $serverName" -ForegroundColor Cyan
    Remove-AzureRmSqlServer -ResourceGroupName $resourceGroupName `
                            -ServerName $serverName `
                            -Force
  } # if ($exists -ne $null)
} # if ($dropSQLServer -eq $true)

#endregion Drop SQL Server



