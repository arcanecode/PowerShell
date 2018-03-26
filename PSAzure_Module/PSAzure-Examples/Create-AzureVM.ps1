<#-----------------------------------------------------------------------------
  Create a new Azure Virtual Machine

  Author
    Robert C. Cain | @ArcaneCode | info@arcanetc.com | http://arcanecode.me
 
  Details
    This example walks you through the steps involved to create a virtual
    machine in Azure, using the module PSAzure. You can find the complete
    code at:
    https://github.com/arcanecode/PowerShell/tree/master/PSAzure_Module
    
    You'll start by creating a resource group, then a storage account to 
    hold the VM.

    Next you will need to create a virtual network, and along with it
    a virtual network security group that holds the firewall rules to allow
    traffic in and out of your new virtual machine.
    
    After that you create a virtual NIC (Network Interface Card) that 
    the VM will use to talk to the virtual network. 

    Finally, you are ready to create the VM! To do so, you will need
    to gather certain parameteres ahead of time, such as what image to
    use to create the machine, and how big the machine should be. 
    The script 'Get-AzureVMOptions.ps1', located in these samples,
    walks you through the steps needed to get this information. 

    As a final step the script creates an RDP file to login to your
    VM remotely, then launches it. 

  Notices
    This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights
    reserved. The code herein is for demonstration purposes. No warranty
    or guarentee is implied or expressly granted. 
    
    This code may be used in your projects. 
    
    This code may NOT be reproduced in whole or in part, in print, video, or
    on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

# Path to demos - Set this to where you want to store your code
$dir = "$($env:OneDrive)\Pluralsight\PSAzure-Module\PSAzure-Examples"
Set-Location $dir

# Load our module, or force a reload in case it's already loaded
# Assumes you have already installed the module.
Import-Module PSAzure -Force 

# Login. To make login quicker, this uses function looks to 
# see if a profile context file (named, by default, ProfileContext.ctx)
# exists. If so, it uses that info to make logging in easier.
# See the script Create-ProfileContext.ps1 on how to create this file.
Connect-PSToAzure -Path $dir


#------------------------------------------------------------------------------
# Set the foundation. 
#------------------------------------------------------------------------------

# Start with Variable Declaration. This keeps them together for 
# easy copy to other projects.
$resourceGroup = 'AzurePSTestRG'
$location = 'southcentralus'

# Storage account name must be between 3 and 24 characters 
# and use numbers and lower-case letters only.
$storageAccount = 'azurepsteststorageacct'

# Create a resource group for our test
New-PSResourceGroup -ResourceGroupName $resourceGroup -Location $location

# Create a storage account to keep the VM in
New-PSStorageAccount -StorageAccountName $storageAccount `
                     -ResourceGroupName $resourceGroup `
                     -Location $location `
                     -Verbose

#------------------------------------------------------------------------------
# Create the virtual networking components
#------------------------------------------------------------------------------

# Network related variables
$networkSecurityGroup = 'AzurePSTestSecurityGroup'
$networkName = 'AzurePSTestNetwork'
$networkAddress = '192.168.0.0/16'
$subnetName = 'AzurePSTestNetworkSubnet'
$subnetAddress = '192.168.1.0/24'
$nicName = 'ArcanePSTestNIC'

# Create an Azure Virtual Network
New-PSAzureVirtualNetwork -ResourceGroupName $resourceGroup `
                          -VirtualNetworkName $networkName `
                          -VirtualSubnetName $subnetName `
                          -VirtualNetworkAddress $networkAddress `
                          -VirtualSubnetAddress $subnetAddress `
                          -Location $location `
                          -Verbose

# Now to create a security group that will configure the 
# firewall for the virtual network
New-PSAzureNetworkSecurityGroup -ResourceGroupName $resourceGroup `
                                -NetworkSecurityGroupName $networkSecurityGroup `
                                -Location $location `
                                -Verbose

# Finally create the NIC the VM will use to connect to the network
New-PSAzureVirtualNIC -ResourceGroupName $resourceGroup `
                      -NICName $nicName `
                      -VirtualNetworkName $networkName `
                      -NetworkSecurityGroupName $networkSecurityGroup `
                      -Location $location `
                      -Verbose

#------------------------------------------------------------------------------
# Now you can create the VM
#------------------------------------------------------------------------------

# VM Related Variables
$vmName = 'AzurePSTestVM'
$adminName = 'ArcaneCode'
$diskName = 'AzurePSTestDisk'

# The supplied password must be between 8-123 characters long and must 
# satisfy at least 3 of password complexity requirements from the following: 
# 1) Contains an uppercase character
# 2) Contains a lowercase character
# 3) Contains a numeric digit
# 4) Contains a special character
# 5) Control characters are not allowed
$adminPW = 'mySuperStr0ngP@ssword'

# Note these values were derived using the examples in the script
# Get-AzureVMOptions.ps1
$vmSize = 'Basic_A3'
$vmPublisher = 'MicrosoftSQLServer' 
$vmOffer = 'SQL2016SP1-WS2016' 
$vmSKU = 'SQLDEV' 
# By default it uses the latest version for a SKU

# Now we can create our VM! This might take a while depending
# on the options we selected and how busy Azure happens to be.
# Be patient if nothing is returned for several minutes. (Your
# humble author has seen it take as long as 20 minutes to create
# a VM.)
New-PSAzureVM `
   -ResourceGroupName $resourceGroup `
   -VMName $vmName `
   -VMAdminName $adminName `
   -VMAdminPassword $adminPW `
   -VMSize $vmSize `
   -Publisher $vmPublisher `
   -Offer $vmOffer `
   -SKU $vmSKU `
   -StorageAccountName $storageAccount `
   -DiskName $diskName `
   -NICName $nicName `
   -Location $location `
   -Verbose

# Get its current status, just to show it is running
Get-PSAzureVMStatus -ResourceGroupName $resourceGroup `
                    -VMName $vmName

# Create an RDP for the new VM and open it
$rdpFile = "$($dir)\$($vmName).rdp"
New-PSAzureVMRDP -ResourceGroupName $resourceGroup `
                 -VMName $vmName `
                 -Path $rdpFile `
                 -Verbose

# Run the RDP to connect to the new VM
# When the connection pops up, be sure to use "More Choices"
# Enter the user name and password specified in the
# variables.
Invoke-Item $rdpFile

