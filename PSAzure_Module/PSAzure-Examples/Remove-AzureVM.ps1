<#-----------------------------------------------------------------------------
  Start stopped Azure Virtual Machine

  Author
    Robert C. Cain | @ArcaneCode | info@arcanetc.com | http://arcanecode.me
 
  Details
    This example walks you through the steps involved to remove a virtual
    machine in Azure, using the module PSAzure. You can find the complete
    code at:
    https://github.com/arcanecode/PowerShell/tree/master/PSAzure_Module
    
    When you no longer need a virtual machine, you will want to get rid of
    it. Perhaps you are following along with these examples, and are just
    experimenting. Alternatively you are creating your VMs brand new each
    time you need them and no longer want the old ones. 

  Notices
    This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights
    reserved. The code herein is for demonstration purposes. No warranty
    or guarentee is implied or expressly granted. 
    
    This code may be used in your projects. 
    
    This code may NOT be reproduced in whole or in part, in print, video, or
    on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

# Path to demos - Set this to where you want to store your code
$dir = "C:\PowerShell\PSAzure-Module\PSAzure-Examples"
Set-Location $dir

# Load our module, or force a reload in case it's already loaded
# Assumes you have already installed the module.
Import-Module PSAzure -Force 

# Login. To make login quicker, this uses function looks to 
# see if a profile context file (named, by default, ProfileContext.ctx)
# exists. If so, it uses that info to make logging in easier.
# See the script Create-ProfileContext.ps1 on how to create this file.
Connect-PSToAzure

# Variable Declaration
$resourceGroup = 'AzurePSTestRG'
$vmName = 'AzurePSTestVM'
$networkName = 'AzurePSTestNetwork'
$nicName = 'ArcanePSTestNIC'

# Storage account name must be between 3 and 24 characters 
# and use numbers and lower-case letters only.
$storageAccount = 'azurepsteststorageacct'

# This will check to see if the VM is running, and if so stop it.
# It then removes the VM. Note there are no "are you sure" prompts,
# this script assumes you know what you are doing. 
Remove-PSAzureVM -ResourceGroupName $resourceGroup `
                 -VMName $vmName `
                 -Verbose

# Next, we will need to remove the NIC
Remove-PSAzureVirtualNIC -ResourceGroupName $resourceGroup `
                         -NICName $nicName `
                         -Verbose

# Having removed the NIC it is now safe to remove the Virtual Network
# WARNING! It should be pretty obvious but if you have other VMs that 
# also use this virtual network you are going to have issues.
Remove-PSAzureVirtualNetwork -ResourceGroupName $resourceGroup `
                             -VirtualNetworkName $networkName `
                             -Verbose

# Remove the storage account
# WARNING! If you have other stuff here besides the VM, those
# items will get deleted too! 
Remove-PsAzureStorageAccount -ResourceGroupName $resourceGroup `
                             -StorageAccountName $storageAccount `
                             -Verbose

# Remove the resource group

# ********************* SUPER HUGE DIRE WARNING! ********************* 

# If you remove the resource group, it removes EVERYTHING associated
# with that resource group. Everything. So be very very very very
# careful with this. 

# Also, if you prefer, you can just remove the resource group.
# As long as the VM isn't running, it will remove the RG and EVERYTHING
# in it including the VM.
Remove-PsAzureResourceGroup -ResourceGroupName $resourceGroup

