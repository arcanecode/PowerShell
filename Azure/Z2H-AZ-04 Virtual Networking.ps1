<#--------------------------------------------------------------------
  Z2H-AZ-04 Virtual Networking Demo
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          https://arcanecode.com | https://github.com/arcanecode
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights 
  reserved. No warranty or guarentee is implied or expressly granted. 

  All information was accurate at the time of the demo creation. Note
  that things are changing very rapidly in the world of Azure in 
  general and Azure's PowerShell modules in particular, so be sure
  to check Microsoft online documentation for the latest information.
  
  This demo shows how to create virtual networks in Azure.
--------------------------------------------------------------------#>

#region Login

# Set a variable with the path to the working directory as we'll
# use it over and over
$dir = "$($env:OneDrive)\Pluralsight\Azure\PS"

# Login to Azure if you've not done so
Add-AzureRmAccount 

#endregion Login

#region Create a Virtual Network
<#-------------------------------------------------------------------- 
   Creating a Virtual Network
--------------------------------------------------------------------#>

<#
   Before creating a virtual network, you should understand the 
   various types of networks. 

   No VNet - i.e. doing nothing establishes no Virtual Network. 
   VMs will run but won't be able to communicate with each other. 

   Cloud-only VNet - Creates a Virtual Network where all hosted 
   services can communicate with each other, but not external. 

   Cross-Premisis VNet - Allows your virtual network to communicate
   with other networks. Cross premisis supports these types of 
   gateways:

      Site to Site - Allows a local VPN device to communicate 
      directly with the Azure virtunal network gateway. Once setup
      resources on both networks can communicate as if they were all
      on the same network. 

      Point to Site - A point to site VPN allows an individual device
      on the scource network to communicate with the Azure network,
      similar to having your home computer start a VPN to communicate
      with your company network.

      Express Route - Allows for a dedicated connection to the Azure
      network, for example between your on premisis data center to
      the Azure data center. This removes the need from having to
      use the public internet network. Very fast, and expensive. 

   Before we can setup the network there are a few things we need
   to have. 

#>

<#
   First we need a resource group. See the notes in the sample
   Z2H-AZ-03 Storage.ps1 on how to create one. Here we'll use an
   already existing one.
#>
$resourceGroupName = 'PSDev'    # Need a Resource Group 

# Next we'll need the location to store the network. You can use
# the following cmdlet to get a list of valid locations
Get-AzureRMLocation | Sort-Object Location | Format-Table

# For our network we'll use East US
$location = 'southcentralus'

# Next we'll pick a name and put it in a variable
$netName = 'PSvNet'

<# 
   Now we need to set a  network address to use
   If you aren't familar with the / notation, it is CIDR. See the
   wikipedia article below for more information.
   https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
#>
$netAddress = '192.168.0.0/16'

# Now we can create our virtual network
New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName `
                          -Name $netName `
                          -AddressPrefix $netAddress `
                          -Location $location

# Verify it was created
Get-AzureRmVirtualNetwork |
  Select-Object Name, ResourceGroupName, ProvisioningState

#endregion Create a Virtual Network

#region Subnets
<#-------------------------------------------------------------------- 
   Subnets

   Now that our main network exists, we can create subnets
--------------------------------------------------------------------#>

# First, we need a reference to our main virtual network
$mainVNet = Get-AzureRmVirtualNetwork `
              -ResourceGroupName $resourceGroupName `
              -Name $netName

# Now we need a name and address for the subnet
$subnetName = 'PSvNetSubnet'
$subnetAddress = '192.168.1.0/24'

# Now we can add the subnet to our main network configuration
Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetName `
                                      -VirtualNetwork $mainVNet `
                                      -AddressPrefix $subnetAddress

<#
   Repeat above as needed for more than one.

   It is important to know that so far all you've done is add the
   subnets to the $mainVNet variable. To actually make the change
   in Azure, you'll need to use the following cmdlet.
#>
Set-AzureRmVirtualNetwork -VirtualNetwork $mainVNet

# We can verify by adding the subnets property to the output
Get-AzureRmVirtualNetwork |
  Select-Object Name, ResourceGroupName, ProvisioningState, Subnets

# You can find more information on networks at:
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-create-vnet-arm-ps
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/ps-common-network-ref

#endregion Subnets

#region Network Security Groups
<#-------------------------------------------------------------------- 
   Network Security Groups (NSG)

   Now that you have the networks setup, you should protect them.
   To do so, we'll setup Network Security Group.

   In our first example, we'll first create two rules, one to allow
   RDP, the second to allow access to the internet on port 80.

   Once the rules are created, we'll create the NSG and apply the
   rules all at the same time.

   Some notes about the parameters   
   Access -  can be Allow or Deny
   
   Protocol - can be TCP, UDP, or * (which will include TCP, UDP, 
              and ICMP)

   Port Ranges - Can be a single port, range of ports, or * for all

   AddressPrefix - Can be a single IP address, an IP Subnet, or *

   Direction - Inbound or Outbound

   Priority - A number between 100 and 4096, used to prioritize the
              order in which rules are applied

--------------------------------------------------------------------#>

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
$nsgName = 'PSvNetNSG'
$nsg = New-AzureRmNetworkSecurityGroup `
         -ResourceGroupName $resourceGroupName `
         -Location $location `
         -Name $nsgName `
         -SecurityRules $rdpRule, $httpRule

# You can see the rules by echoing the variable 
$nsg

# To review the list of NSGs
Get-AzureRmNetworkSecurityGroup | Select-Object Name

# To review the rules for an NSG
Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName `
                                -Name $nsgName |
  Select-Object SecurityRules -ExpandProperty SecurityRules |
  Format-Table

#endregion Network Security Groups

#region Managing NSGs - Adding Rules
<#-------------------------------------------------------------------- 
   Managing VNet NSG - Adding new rules

   You can add more rules to an existing NSG. First, get a reference
   to the security group you wish to add a rule to. Next, you will
   create a new rule, as  you saw in the previous example.
   Finally, you will set cmdlet to add the new rule.

--------------------------------------------------------------------#>
# Get the reference to our NSG
$nsg = Get-AzureRmNetworkSecurityGroup `
         -ResourceGroupName $resourceGroupName `
         -Name $nsgName

# Create a rule to allow https
Add-AzureRmNetworkSecurityRuleConfig `
  -NetworkSecurityGroup $nsg `
  -Name https-rule `
  -Description "Allow HTTPS" `
  -Access Allow `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 102 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 443

# Now add the new rule to our NSG
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg
#endregion Managing NSGs - Adding Rules

#region Managing NSGs - Altering Rules
<#-------------------------------------------------------------------- 
   Managing VNet NSG - Altering existing rules

   Just like you can add rules to an existing NSG, you can
   alter existing ones. The steps are essentially the same as
   the above, in reusing the same rule name you'll overwrite the
   existing rule. 
--------------------------------------------------------------------#>
# Get a reference to the NSG
$nsg = Get-AzureRmNetworkSecurityGroup `
         -ResourceGroupName $resourceGroupName `
         -Name $nsgName

# Update the rule. Note port ranges used to allow names like Internet
# to be used, this is no longer the case.
Set-AzureRmNetworkSecurityRuleConfig `
  -NetworkSecurityGroup $nsg `
  -Name https-rule `
  -Description "Allow HTTPS" `
  -Access Allow `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 102 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 443

# Save the changes
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg

#endregion Managing NSGs - Altering Rules

#region Managing NSGs - Removing Rules
<#-------------------------------------------------------------------- 
   Managing NSGs - Removing rules
--------------------------------------------------------------------#>
# Get a reference to the NSG
$nsg = Get-AzureRmNetworkSecurityGroup `
         -ResourceGroupName $resourceGroupName `
         -Name $nsgName

# Remove the rule
Remove-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
                                        -Name https-rule

# Now update the NSG
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg

Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName `
                                -Name $nsgName |
  Select-Object SecurityRules -ExpandProperty SecurityRules | 
  Format-Table

#endregion Managing NSGs - Removing Rules


#region Removing NSGs
<#-------------------------------------------------------------------- 
   Removing the entire NSG - This also acts as our cleanup section
   for the NSGs. 

   You can delete the entire NSG easily.
--------------------------------------------------------------------#>
# Before
Get-AzureRmNetworkSecurityGroup `
  -ResourceGroupName $resourceGroupName |
  Select-Object Name

# Remove it
Remove-AzureRmNetworkSecurityGroup `
  -ResourceGroupName $resourceGroupName `
  -Name $nsgName `
  -Force

# After
Get-AzureRmNetworkSecurityGroup `
  -ResourceGroupName $resourceGroupName |
  Select-Object Name

#endregion Removing NSGs

#region Cleanup
<#-------------------------------------------------------------------- 
   Cleanup

   At some point (such as the end of a demo) you will no longer need
   the virtual network. It's is very easy to remove.
--------------------------------------------------------------------#>

# Before
Get-AzureRmVirtualNetwork |
  Select-Object Name, ResourceGroupName, ProvisioningState

# Remove it
Remove-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName `
                             -Name $netName `
                             -Force

# After
Get-AzureRmVirtualNetwork |
  Select-Object Name, ResourceGroupName, ProvisioningState

#endregion Cleanup

<#-------------------------------------------------------------------- 
   Resources
   
   Network Security Groups
   https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-nsg

   Creating Network Security Groups
   https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-create-nsg-arm-ps

   Manage Network Security Groups
   https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-nsg-arm-ps

--------------------------------------------------------------------#>

