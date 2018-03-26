<#-----------------------------------------------------------------------------
  Defines helper functions for working with Azure VMs 

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    Test-PSAzureVM
    Get-PSAzureVMStatus
    Stop-PSAzureVM
    Start-PSAzureVM

-----------------------------------------------------------------------------#>

#region Test-PSAzureVM
<#---------------------------------------------------------------------------#>
<# Test-PSAzureVM                                                              #>
<#---------------------------------------------------------------------------#>
function Test-PSAzureVM ()
{
<#
  .SYNOPSIS
  Tests to see if the Azure Virtual Machine exists

  .DESCRIPTION
  Checks to see if the name of the virtual machine exists in the passed in 
  resource group. Returns true if it does, or false if not. 

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter VMName
  The name of the virtual machine

  .INPUTS
  System.String

  .OUTPUTS
  Boolean

  .EXAMPLE
  Test-AzureVM -ResourceGroupName 'ArcaneRG' `
               -VMName 'MyVirtualMachine'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the VM'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName

       )
  
  $fn = 'Test-PSAzureVM:'
  Write-Verbose "$fn Checking for existance of $VMName in resource group $ResourceGroupName"
  $exists = Get-AzureRmVm -ResourceGroupName $ResourceGroupName |
             Where-Object Name -eq $VMName

  if ($exists -ne $null)
  {
    $result = $true
    Write-Verbose "$fn VM $vmName exists."
  }
  else
  {
    $result = $false
    Write-Verbose "$fn VM $vmName does not exist."
  }

  return $result
}
#endregion Test-PSAzureVM

#region Get-PSAzureVMStatus
<#---------------------------------------------------------------------------#>
<# Get-PSAzureVMStatus                                                       #>
<#---------------------------------------------------------------------------#>
function Get-PSAzureVMStatus ()
{
<#
  .SYNOPSIS
  Gets the running status of an Azure Virtual Machine

  .DESCRIPTION
  Checks the current state of an Azure Virtual Machine, will return a status
  such as running, deallocated, or stopped. 

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter VMName
  The name of the virtual machine

  .INPUTS
  System.String

  .OUTPUTS
  A string with the current state of the VM

  .EXAMPLE
  Get-PSAzureVMStatus -ResourceGroupName 'ArcaneRG' `
                      -VMName 'MyVirtualMachine'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the VM'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName

       )
  
  $fn = "Get-PSAzureVMStatus:"
  $exists = Test-PSAzureVM -ResourceGroupName $ResourceGroupName `
                         -VMName $VMName
  
  if ($exists -eq $true)
  {
    Write-Verbose "$fn Getting status of $VMName in resource group $ResourceGroupName"
    $vmStatus = Get-AzureRmVm -ResourceGroupName $ResourceGroupName `
                  -Name $VMName `
                  -Status |
                  Select-Object ResourceGroupName, Name -ExpandProperty Statuses |
                  Where-Object Code -Match 'PowerState' |
                  Select-Object DisplayStatus

    $status = $vmStatus.DisplayStatus
    Write-Verbose "$fn $VMName status is $status"
  }
  else
  {
    $status = "Error - The virtual machine $VMName does not exist."
    Write-Verbose "$fn $status"
  }

  return $status
}
#endregion Get-PSAzureVMStatus

#region Stop-PSAzureVM
<#---------------------------------------------------------------------------#>
<# Stop-AzureVM                                                              #>
<#---------------------------------------------------------------------------#>
function Stop-PSAzureVM ()
{
<#
  .SYNOPSIS
  Turns off (puts in a deallocated state) an Azure Virtual Machine

  .DESCRIPTION
  Checks to see if the name of the virtual machine exists in the passed in 
  resource group. If it exists, it then checks to see if it is in a running
  state (status = 'VM running'). If so, it will then attempt to stop it,
  placing it in a state of VM deallocated.

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter VMName
  The name of the virtual machine

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Stop-AzureVM -ResourceGroupName 'ArcaneRG' `
               -VMName 'MyVirtualMachine'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the VM'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName

       )

  $fn = 'Stop-PSAzureVM:'
  $exists = Test-PSAzureVM -ResourceGroupName $ResourceGroupName -VMName $VMName

  if ($exists -eq $true)
  {
    $status = Get-PSAzureVMStatus `
                 -ResourceGroupName $resourceGroupName `
                 -VMName $vmName

    if ($status -eq 'VM running')
    {
      Write-Verbose "$fn Stopping VM $vmName in resource group $ResourceGroupName"
      Stop-AzureRmVM -ResourceGroupName $ResourceGroupName `
                     -Name $VMName `
                     -Force

    }
    else
    {
      Write-Verbose "$fn $VMName is not running, it's current state is $status"
    }
  }
  else
  {
    Write-Verbose "$fn Cannot stop VM $VMName, it does not exist."
  }

}
#endregion Stop-PSAzureVM

#region Start-PSAzureVM
<#---------------------------------------------------------------------------#>
<# Start-PSAzureVM                                                           #>
<#---------------------------------------------------------------------------#>
function Start-PSAzureVM ()
{
<#
  .SYNOPSIS
  Turns on (puts in a state of VM running) an Azure Virtual Machine

  .DESCRIPTION
  Checks to see if the name of the virtual machine exists in the passed in 
  resource group. If it exists, it then checks to see if it is in a running
  state (status = 'VM running'). If not, it will then attempt to start it,
  placing it in a state of VM running.

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter VMName
  The name of the virtual machine

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Start-AzureVM -ResourceGroupName 'ArcaneRG' `
                -VMName 'MyVirtualMachine'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the VM'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName

       )

  $fn = 'Start-PSAzureVM:'
  $exists = Test-PSAzureVM -ResourceGroupName $ResourceGroupName -VMName $VMName

  if ($exists -eq $true)
  {
    $status = Get-PSAzureVMStatus `
                 -ResourceGroupName $resourceGroupName `
                 -VMName $vmName

    if ($status -ne 'VM running')
    {
      Write-Verbose "$fn Starting VM $vmName in resource group $ResourceGroupName"
      Start-AzureRmVM -ResourceGroupName $ResourceGroupName `
                      -Name $VMName 

    }
    else
    {
      Write-Verbose "$fn $VMName is already running, it's current state is $status"
    }
  }
  else
  {
    Write-Verbose "$fn Cannot stop VM $VMName, it does not exist."
  }

}
#endregion Start-PSAzureVM

#region New-PSAzureVM
<#---------------------------------------------------------------------------#>
<# New-PSAzureVM                                                             #>
<#---------------------------------------------------------------------------#>
function New-PSAzureVM ()
{
<#
  .SYNOPSIS
  Create a new Azure Virtual Machine

  .DESCRIPTION
  Creates a new Azure Virtual Machine. Prior to creating the VM, there are
  some prerequisites. A storage account must exist to hold the virtual hard
  drive. A virtual network, including security group and NIC, must exist. You
  must know the size of the VM, along with the publisher, offer, and sku. 

  .PARAMETER ResourceGroupName
  The resource group to create the virtual machine in

  .PARAMETER VMName
  The name of the virtual machine

  .PARAMETER VMAdminName
  The name of the admin user for the virtual machine

  .PARAMETER VMAdminPassword
  The admin users secure string password  

  .PARAMETER VMSize
  The size of the virtual machine  

  .PARAMETER Publisher
  The publisher for the software for this VM  

  .PARAMETER Offer
  The offer (SQL Server, etc) for this VM  

  .PARAMETER SKU
  The specific version, or SKU, for the offer of this VM  

  .PARAMETER Version
  The version number of the offer, defaults to 'latest'

  .PARAMETER StorageAccountName
  The storage account to hold the drives for the VM  

  .PARAMETER DiskName
  The name of the disk drive (VHD) for the VM  

  .PARAMETER NICName
  The Virtual NIC (Network Interface Card) for the VM  

  .PARAMETER Location
  The geographic location for the VM

  .INPUTS
  System.String

  .OUTPUTS
  Creates a new Azure VM

  .EXAMPLE
  New-PSAzureVM `
     -ResourceGroupName $resourceGroupName `
     -VMName $vmName `
     -VMAdminName 'ArcaneCode' `
     -VMAdminPassword 'mysuperstrongpasswordhere' `
     -VMSize 'Basic_A3' `
     -Publisher 'MicrosoftSQLServer' `
     -Offer 'SQL2016SP1-WS2016' `
     -SKU 'SQLDEV' `
     -StorageAccountName 'myStorageAccount' `
     -DiskName 'myDiskName' `
     -NICName 'myNicName' `
     -Location 'southcentralus' `
     -Verbose
     
  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the VM'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the admin user for the virtual machine'
                   )
         ]
         [string]$VMAdminName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The admin users secure string password'
                   )
         ]
         [string]$VMAdminPassword
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The size of the virtual machine'
                   )
         ]
         [string]$VMSize
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The publisher for the software for this VM'
                   )
         ]
         [string]$Publisher
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The offer (SQL Server, etc) for this VM'
                   )
         ]
         [string]$Offer
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The specific version, or SKU, for the offer of this VM'
                   )
         ]
         [string]$SKU
         ,
         [string]$Version = 'latest'
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The storage account to hold the drives for the VM'
                   )
         ]
         [string]$StorageAccountName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the disk drive (VHD) for the VM'
                   )
         ]
         [string]$DiskName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The Virtual NIC (Network Interface Card) for the VM'
                   )
         ]
         [string]$NICName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The geographic location for the VM'
                   )
         ]
         [string]$Location
       )

  $fn = 'New-PSAzureVM:'
  Write-Verbose "$fn Checking for AzureVM $VMName"
  $exists = Test-PSAzureVM -ResourceGroupName $ResourceGroupName -VMName $VMName

  if ($exists -eq $false)
  {
    Write-Verbose "$fn Creating Credentails for admin $VMAdminName"
    $password = $VMAdminPassword |
      ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object PSCredential ($VMAdminName, $password)

    Write-Verbose "$fn Setting $VMName size to $VMSize"
    $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

    Write-Verbose "$fn Setting $VMName operating system to Windows"
    $vm = Set-AzureRmVMOperatingSystem -VM $vm `
                                       -Windows `
                                       -ComputerName $VMName `
                                       -Credential $cred `
                                       -ProvisionVMAgent `
                                       -EnableAutoUpdate

    Write-Verbose "$fn Setting $VMName source image to:"
    Write-Verbose "$fn      Publisher: $Publisher"
    Write-Verbose "$fn      Offer....: $Offer"
    Write-Verbose "$fn      SKU......: $SKU"
    Write-Verbose "$fn      Version..: $Version"
    $vm = Set-AzureRmVMSourceImage -VM $vm `
                                   -PublisherName $Publisher `
                                   -Offer $Offer `
                                   -Skus $SKU `
                                   -Version $Version
    
    Write-Verbose "$fn Getting NIC data for $NICName"
    $nic = Get-PSAzureVirtualNIC -ResourceGroupName $ResourceGroupName `
                                 -NICName $NICName

    Write-Verbose "$fn Adding the NIC $NICName to the VM $VMName"
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

    # Get a reference to the storage account
    Write-Verbose "$fn Getting storage account info for account $StorageAccountName"
    $storageAccount = Get-AzureRMStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $StorageAccountName 
    
    Write-Verbose "$fn Getting URI for disk $DiskName"
    $diskURI = $storageAccount.PrimaryEndpoints.Blob.ToString() `
                 + 'vhds/' + $DiskName + '.vhd'
    
    Write-Verbose "$fn Setting $VMName disk"
    $vm = Set-AzureRmVMOSDisk -VM $vm `
                              -Name $DiskName `
                              -VhdUri $diskURI `
                              -CreateOption FromImage
    
    # Finally! Now we'll issue the command that actually creates the VM
    Write-Verbose "$fn Creating the VM $VMName"
    New-AzureRmVm -ResourceGroupName $ResourceGroupName `
                  -Location $Location `
                  -VM $vm
        
  }

}
#endregion New-PSAzureVM

#region New-PSAzureVMRDP
<#---------------------------------------------------------------------------#>
<# New-PSAzureVMRDP                                                          #>
<#---------------------------------------------------------------------------#>
function New-PSAzureVMRDP ()
{
<#
  .SYNOPSIS
  Creates an RDP file.

  .DESCRIPTION
  Creates a remote desktop protocol (RDP) file by which a user may access
  the virtual machine that exists in Azure. 

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .PARAMETER VMName
  The name of the virtual machine

  .PARAMETER Path
  The path (including file name) to store the RDP file

  .PARAMETER Force
  Will force the overwrite of the RDP file if it already exists

  .INPUTS
  System.String

  .OUTPUTS
  Creates an RDP file

  .EXAMPLE
  New-PSAzureVMRDP -ResourceGroupName 'myResourceGroup' `
                   -VMName 'MyVirtualMachine' `
                   -Path 'C:\Temp\GetToMyVM.rdp' `
                   -Verbose

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to hold the virtual NIC'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The path (including file name) to store the VM'
                   )
         ]
         [string]$Path
         ,
         [switch]$Force
       )

  $fn = 'New-PSAzureVMRDP:'
  Write-Verbose "$fn Checking for RDP $Path"

  # Default the create flat to create the RDP
  $create = $true

  # See if the RDP is already there
  $exists = Test-Path $Path 

  # If it's there, set the create flag to false
  if ($exists -eq $true)
  { $create = $false }

  # ...unless the force flag was set, in which case force the create
  if ($Force -eq $true)
  { $create = $true }

  # Create the RDP File
  if ($create -eq $true)
  {
    Write-Verbose "$fn Creating RDP File $Path"
    Get-AzureRmRemoteDesktopFile `
      -ResourceGroupName $ResourceGroupName `
      -Name $VMName `
      -LocalPath $Path
  }
  else
  {
    Write-Verbose "$fn RDP File $Path already exists"
  }

}
#endregion New-PSAzureVMRDP

#region Remove-PSAzureVM
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureVM                                                          #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureVM ()
{
<#
  .SYNOPSIS
  Removes (deletes) a virtual machine.

  .DESCRIPTION
  Validates that a VM exists, if so it then checks the status. If that VM
  is running, it is shut down. Then it is deleted from Azure. 

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter VMName
  The name of the virtual machine

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureVM -ResourceGroupName 'myResourceGroup' `
                   -VMName 'myVMName' `
                   -Verbose

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to hold the virtual NIC'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual machine'
                   )
         ]
         [string]$VMName
       )
  $fn = "Remove-PSAzureVM:"
  Write-Verbose "$fn Removing VM $VMName"
  $exists = Test-PSAzureVM -ResourceGroupName $resourceGroupName `
                           -VMName $vmName
  
  if ($exists -eq $true)
  {   
    Stop-PSAzureVM -ResourceGroupName $resourceGroupName `
                   -VMName $vmName
  
    # Now delete it
    Write-Verbose "$fn Removing VM $VMName"
    Remove-AzureRmVm -Name $VMName `
                     -ResourceGroupName $ResourceGroupName `
                     -Force
  
}

}
#endregion Remove-PSAzureVM
