<#-----------------------------------------------------------------------------
  PSAzure module contains helper functions for working with Azure. 
  This file runs the scripts and defines the public functions

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>


. $PSScriptRoot\PSAzure-AzureSQL.ps1
. $PSScriptRoot\PSAzure-Hive.ps1
. $PSScriptRoot\PSAzure-Login.ps1
. $PSScriptRoot\PSAzure-ResourceGroups.ps1
. $PSScriptRoot\PSAzure-Storage.ps1
. $PSScriptRoot\PSAzure-Text.ps1
. $PSScriptRoot\PSAzure-VM.ps1
. $PSScriptRoot\PSAzure-VirtualNetwork.ps1


# Export Members
#region Export Members

# PSAzure-AzureSQL
  Export-ModuleMember New-PSAzureSQLServer
  Export-ModuleMember New-PSAzureSQLServerFirewallRule
  Export-ModuleMember New-PSBacPacFile
  Export-ModuleMember Remove-PSAzureSQLDatabase
  Export-ModuleMember New-PSAzureSQLDatabaseImport
  Export-ModuleMember Remove-PSAzureSqlDatabase
  Export-ModuleMember Remove-PSAzureSqlServerFirewallRule
  Export-ModuleMember Remove-PSAzureSqlServer

# PSAzure-Hive
  Export-ModuleMember Limit-PSHqlResults
  Export-ModuleMember Invoke-PSHqlCmd
  Export-ModuleMember Get-PSHiveTables
  Export-ModuleMember Test-PSHiveTable

# PSAzure-Login
  Export-ModuleMember Connect-PSToAzure
  Export-ModuleMember Set-PSSubscription

# PSAzure-ResourceGroups
  Export-ModuleMember New-PSResourceGroup
  Export-ModuleMember Remove-PsAzureResourceGroup

# PSAzure-Storage
  Export-ModuleMember Test-PSAzureValidStorageAccountName
  Export-ModuleMember Test-PSStorageAccountNameAvailability
  Export-ModuleMember Test-PSStorageAccount
  Export-ModuleMember New-PSStorageAccount
  Export-ModuleMember Get-PSStorageAccountKey
  Export-ModuleMember Get-PSStorageContext
  Export-ModuleMember New-PSStorageContainer
  Export-ModuleMember Set-PSBlobContent
  Export-ModuleMember Remove-PSAzureStorageContainer
  Export-ModuleMember Remove-PSAzureStorageAccount

# PSAzure-Text
  Export-ModuleMember Find-PSCharactersInFile
  Export-ModuleMember Write-PSArrayToFile
  Export-ModuleMember Add-RightPadding

# PSAzure-VM
  Export-ModuleMember Test-PSAzureVM
  Export-ModuleMember Get-PSAzureVMStatus
  Export-ModuleMember Stop-PSAzureVM
  Export-ModuleMember Start-PSAzureVM
  Export-ModuleMember New-PSAzureVM
  Export-ModuleMember New-PSAzureVMRDP
  Export-ModuleMember Remove-PSAzureVM

# PSAzure-VirtualNetwork
  Export-ModuleMember Test-PSAzureVirtualNetwork 
  Export-ModuleMember Get-PSAzureVirtualNetworkList
  Export-ModuleMember New-PSAzureVirtualNetwork
  Export-ModuleMember Remove-PSAzureVirtualNetwork
  
  Export-ModuleMember Test-PSAzureNetworkSecurityGroup
  Export-ModuleMember New-PSAzureSecurityRule
  Export-ModuleMember New-PSAzureRdpSecurityRule
  Export-ModuleMember New-PSAzureHttpSecurityRule
  Export-ModuleMember New-PSAzureNetworkSecurityGroup
  Export-ModuleMember Remove-PSAzureNetworkSecurityGroup

  Export-ModuleMember Test-PSAzureVirtualNIC
  Export-ModuleMember Get-PSAzureVirtualNIC
  Export-ModuleMember New-PSAzureVirtualNIC
  Export-ModuleMember Remove-PSAzureVirtualNIC

#endregion Export Members