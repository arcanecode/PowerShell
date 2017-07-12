<#--------------------------------------------------------------------
  Z2H-AZ-05 Virtual Machines
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          https://arcanecode.com | https://github.com/arcanecode
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights 
  reserved. No warranty or guarentee is implied or expressly granted. 

  All information was accurate at the time of the demo creation. Note
  that things are changing very rapidly in the world of Azure in 
  general and Azure's PowerShell modules in particular, so be sure
  to check Microsoft online documentation for the latest information.
  
  This script will demonstrate the creation of virtual machines 
  in Azure using PowerShell. Be aware it will be using both 
  storage and virtual networks created in previous demo scripts.
--------------------------------------------------------------------#>

#region Login 

# Set a variable with the path to the working directory as we'll
# use it over and over
$dir = "$($env:OneDrive)\Pluralsight\Azure\PS"

# Login to Azure if you've not done so already
Add-AzureRmAccount 

#endregion Login

<#-------------------------------------------------------------------- 
   Prerequisites

   First, using techniques we've already seen we'll setup some basics
   that are needed.
--------------------------------------------------------------------#>

#region Prerequisite Resource Group

# First create a resource group
$location = 'southcentralus'
$resourceGroupName = 'ArcaneVMRG'

$rgExists = Get-AzureRmResourceGroup -Name $resourceGroupName `
                                     -ErrorAction SilentlyContinue
if ( $rgExists -eq $null )
{
  New-AzureRmResourceGroup -Name $resourceGroupName `
                           -Location $location
}
#endregion Prerequisite Resource Group

#region Prerequisite Create Storage Account

$storageAccountName = 'arcanevmstorage'

$saExists = Get-AzureRMStorageAccount `
              -ResourceGroupName $resourceGroupName `
              -Name $storageAccountName `
              -ErrorAction SilentlyContinue
if ($saExists -eq $null)
{ 
  New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                            -Name $storageAccountName `
                            -Location $location `
                            -Type Standard_LRS
}

#endregion Prerequisite Create Storage Account

#region Prerequisite Virtual Network
# Next the virtual network
$netName = 'ArcaneVMvNet'
$netAddress = '192.168.0.0/16'
$subnetName = 'ArcanevNetSubnet'
$subnetAddress = '192.168.1.0/24'

$vNetExists = Get-AzureRmVirtualNetwork `
                -ResourceGroupName $resourceGroupName `
                -Name $netName -ErrorAction SilentlyContinue
if ($vNetExists -eq $null)
{ 
  # Note in this example we'll create the subnet, then create the 
  # new vNet and add the subnet all in one step

  # Create the subnet
  $subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
                    -Name $subnetName `
                    -AddressPrefix $subnetAddress
  
  # Create the vNet attaching the subnet to it
  New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName `
                            -Name $netName `
                            -AddressPrefix $netAddress `
                            -Subnet $subnetConfig `
                            -Location $location
}

# Verify it was created
Get-AzureRmVirtualNetwork |
  Select-Object Name, ResourceGroupName, ProvisioningState
#endregion Prerequisite Virtual Network

#region Prerequisite Network Security Groups
# Allow RDP
$rdpRule = New-AzureRmNetworkSecurityRuleConfig `
             -Name 'rdp-rule' `
             -Description "Allow RDP" `
             -Access Allow `
             -Protocol Tcp `
             -Direction Inbound `
             -Priority 100 `
             -SourceAddressPrefix Internet `
             -SourcePortRange * `
             -DestinationAddressPrefix * `
             -DestinationPortRange 3389  

# Allow Internet (Http) Access on Port 80
$httpRule = New-AzureRmNetworkSecurityRuleConfig `
              -Name web-rule `
              -Description "Allow HTTP" `
              -Access Allow `
              -Protocol Tcp `
              -Direction Inbound `
              -Priority 101 `
              -SourceAddressPrefix Internet `
              -SourcePortRange * `
              -DestinationAddressPrefix * `
              -DestinationPortRange 80

# Now that the rules have been created, let's create the NSG
$nsgName = 'ArcanevNetNSG'
$nsg = New-AzureRmNetworkSecurityGroup `
         -ResourceGroupName $resourceGroupName `
         -Location $location `
         -Name $nsgName `
         -SecurityRules $rdpRule, $httpRule
#endregion Prerequisite Network Security Groups

#region Create NIC
<#-------------------------------------------------------------------- 
   Create a NIC (Network Interface Card)

   The VM will need a NIC which will connect the subnet, NSG, and 
   IP Address
--------------------------------------------------------------------#>
# Get a reference to our existing virtual network
$vNet = Get-AzureRmVirtualNetwork `
          -ResourceGroupName $resourceGroupName `
          -Name $netName

# Get a reference to the existing NSG
$nsg = Get-AzureRmNetworkSecurityGroup `
         -ResourceGroupName $resourceGroupName `
         -Name $nsgName


# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress `
         -ResourceGroupName $resourceGroupName `
         -Location $location `
         -AllocationMethod Static `
         -IdleTimeoutInMinutes 4 `
         -Name "mypublicdns$(Get-Random)"

$nicName = 'ArcaneNIC'
$nic = New-AzureRmNetworkInterface `
         -Name $nicName `
         -ResourceGroupName $resourceGroupName `
         -Location $location `
         -SubnetId $vNet.Subnets[0].Id `
         -PublicIpAddressId $pip.Id `
         -NetworkSecurityGroupId $nsg.Id

#endregion Create NIC

#region Gather VM Info
<#-------------------------------------------------------------------- 
   Now we gather information needed to get the VM
--------------------------------------------------------------------#>

# To get a list of available VM images, we first need to supply some
# parameters to narrow things down. First is location.
$location = 'southcentralus'

# Next we need to determine the publisher
Get-AzureRmVMImagePublisher -Location $location 

# There's a lot, let's limit to Microsoft
Get-AzureRmVMImagePublisher -Location $location |
  Select-Object PublisherName |
  Where-Object PublisherName -Like 'Microsoft*'

# Next we need an offer. Use this cmdlet to see what is available
$publisher = 'MicrosoftSQLServer'
Get-AzureRmVMImageOffer -Location $location -PublisherName $publisher

# So now we've picked out SQL2016SP1-WS2016. Now we need the sku
$offer = 'SQL2016SP1-WS2016'
Get-AzureRmVMImageSku -Location $location `
                      -PublisherName $publisher `
                      -Offer $offer

# Now we've seen the skus, so let's use the SQL Dev one
$sku = 'SQLDEV'

# Get specific information for the selected image
Get-AzureRmVMImage -Location $location `
                   -PublisherName $publisher `
                   -Offer $offer `
                   -Sku $sku

# Let's capture the version
$version = '13.0.500110'

# Note, you can  use a specific version number, or in the creation
# use 'latest' to get the latest version of the VM

# We'll need to know the size to use. You can get a list from:
Get-AzureRmVMSize -Location $location 

# Something simple and basic will work for us
Get-AzureRmVmSize -Location $location |
  Where-Object Name -like 'Basic*'

# We'll use a small one for our simple needs
$vmSize = 'Basic_A3' 

#endregion Gather VM Info

#region Create the VM
<#-------------------------------------------------------------------- 
   Now we can begin creating the VM
--------------------------------------------------------------------#>

# Give our VM a name
$vmName = 'ArcaneSQLDev'

# Create a PSCredential object
$userName = 'ArcaneCode'
$pwFile = "$dir\vmpw.txt"
$password = Get-Content $pwFile |
   ConvertTo-SecureString -AsPlainText -Force

$cred = New-Object PSCredential ($username, $password)

# Now create a new VM Configuration, the first step toward our VM
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm = Set-AzureRmVMOperatingSystem -VM $vm `
                                   -Windows `
                                   -ComputerName $vmName `
                                   -Credential $cred `
                                   -ProvisionVMAgent `
                                   -EnableAutoUpdate

$vm = Set-AzureRmVMSourceImage -VM $vm `
                               -PublisherName $publisher `
                               -Offer $offer `
                               -Skus $sku `
                               -Version 'latest'

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

# Get a reference to the storage account
$storageAccount = Get-AzureRMStorageAccount `
                    -ResourceGroupName $resourceGroupName `
                    -Name $storageAccountName `

$diskName = 'ArcaneVMOS'
$diskURI = $storageAccount.PrimaryEndpoints.Blob.ToString() `
             + 'vhds/' + $diskName + '.vhd'

$vm = Set-AzureRmVMOSDisk -VM $vm `
                          -Name $diskName `
                          -VhdUri $diskURI `
                          -CreateOption FromImage

# Add a data disk
$dataDiskSize = 20 # 20 GB
$dataDiskLabel = 'ArcaneVMData'
$dataDiskName = 'ArcaneVM-DataDisk'
$dataDiskURI = $storageAccount.PrimaryEndpoints.Blob.ToString() `
                 + 'vhds/' + $dataDiskName + '.vhd'
Add-AzureRmVmDataDisk -VM $vm `
                      -Name $dataDiskLabel `
                      -DiskSizeInGB $dataDiskSize `
                      -VhdUri $dataDiskURI `
                      -Lun 0 `
                      -CreateOption Empty

# Finally! Now we'll issue the command that actually creates the VM
New-AzureRmVm -ResourceGroupName $resourceGroupName `
              -Location $location `
              -VM $vm

# Get info about a VM
Get-AzureRmVm -ResourceGroupName $resourceGroupName `
              -Name $vmName | Format-List

# Use the -Status to get detailed info, including if the VM is running
Get-AzureRmVm -ResourceGroupName $resourceGroupName `
              -Name $vmName `
              -Status

# If you only need to know if the VM is running...
Get-AzureRmVm -ResourceGroupName $resourceGroupName `
              -Name $vmName `
              -Status |
              Select-Object ResourceGroupName, Name -ExpandProperty Statuses |
              Where-Object Code -Match 'PowerState' |
              Select-Object ResourceGroupName, Name, DisplayStatus


# Get an RDP for it
$localPath = "$dir\AzureACVM.rdp"
Get-AzureRmRemoteDesktopFile -ResourceGroupName $resourceGroupName `
                             -Name $vmName `
                             -LocalPath $localPath
Invoke-Item $localPath

#endregion Create the VM

#region Manage a VM
<#-------------------------------------------------------------------- 
   Managing your VM

   There are two ways to stop a VM. When StayProvisioned is used,
   the VM stays allocated in the Azure fabric. This means the VM
   is still using resources, and will keep it's IP address and
   other similar resources. Billing continues under this method.

   Without StayProvisioned, the machine is deallocated. It's public
   IP address is lost, the next time a machine boots Azure will
   add a new network adapter then allocate a new address for it.
--------------------------------------------------------------------#>

# Stop and Deallocate VM - Is shutdown and resources are deallocated, 
# no billing occurs
Stop-AzureRmVM -ResourceGroupName $resourceGroupName `
               -Name $vmName `
               -Force

# Stop but leave allocated - leaves it provisioned 
# billing still occurs
Stop-AzureRmVM -ResourceGroupName $resourceGroupName `
               -Name $vmName `
               -StayProvisioned `
               -Force

# Start a VM, if it is stopped
Start-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName 

# Restart a VM
Restart-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName 

#endregion Manage a VM

#region Cleanup
<#-------------------------------------------------------------------- 
   Cleanup - Removing the Resource Group will remove the VM, 
   virtual network, and storage account
--------------------------------------------------------------------#>
Remove-AzureRmResourceGroup -Name $resourceGroupName -Force
Get-AzureRmResourceGroup

#endregion Cleanup