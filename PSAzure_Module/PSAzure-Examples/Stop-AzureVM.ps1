<#-----------------------------------------------------------------------------
  Stop (deallocate) a running Azure Virtual Machine

  Author
    Robert C. Cain | @ArcaneCode | info@arcanetc.com | http://arcanecode.me
 
  Details
    This example walks you through the steps involved to stop a virtual
    machine in Azure, using the module PSAzure. You can find the complete
    code at:
    https://github.com/arcanecode/PowerShell/tree/master/PSAzure_Module
    
    This is a pretty simple script, it just demonstrates the use of the
    Stop-PSAzureVM function. Be aware this function actually takes the
    VM and brings it to a deallocated state. This means you won't be
    paying for it, but it will take a little longer to start back up.

    This will be useful for VM's you occasionally use, such as at month
    end. Or perhaps you are in an environment that is strictly a 9-5
    type of operation. At the end of the day you could auto-run a script
    to stop a VM, then before everyone arrives at the office have
    a second script start the VMs back up. 

  Notices
    This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights
    reserved. The code herein is for demonstration purposes. No warranty
    or guarentee is implied or expressly granted. 
    
    This code may be used in your projects. 
    
    This code may NOT be reproduced in whole or in part, in print, video, or
    on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

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
Connect-PSToAzure

# Variable Declaration
$resourceGroup = 'AzurePSTestRG'
$vmName = 'AzurePSTestVM'

# Stop the VM
Stop-PSAzureVM -ResourceGroupName $resourceGroup `
               -VMName $vmName `
               -Verbose

# Get its current status
Get-PSAzureVMStatus -ResourceGroupName $resourceGroup `
                    -VMName $vmName `
                    -Verbose
