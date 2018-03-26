#PSAzure-VirtualNetwork


#region Test-PSAzureVirtualNetwork
<#---------------------------------------------------------------------------#>
<# Test-PSAzureVirtualNetwork                                                #>
<#---------------------------------------------------------------------------#>
function Test-PSAzureVirtualNetwork ()
{
<#
  .SYNOPSIS
  Tests to see if the Azure Virtual Network exists

  .DESCRIPTION
  Checks to see if the name of the virtual network exists in the passed in 
  resource group. Returns true if it does, or false if not. 

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter Name
  The name of the virtual network

  .INPUTS
  System.String

  .OUTPUTS
  Boolean

  .EXAMPLE
  Test-AzureVM -ResourceGroupName 'ArcaneRG' `
               -Name 'MyVirtualNetworkName'

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
                   , HelpMessage='The name of the virtual network'
                   )
         ]
         [string]$Name

       )
  
  $fn = 'Test-PSAzureVirtualNetwork:'
  Write-Verbose "$fn Checking for existance of $Name in resource group $ResourceGroupName"
  
  $exists = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName |
             Where-Object Name -eq $Name

  if ($exists -ne $null)
  {
    $result = $true
    Write-Verbose "$fn Virtual Network $Name exists."
  }
  else
  {
    $result = $false
    Write-Verbose "$fn Virtual Network $Name does not exist."
  }

  return $result
}
#endregion Test-PSAzureVirtualNetwork

#region Get-PSAzureVirtualNetworkList
<#---------------------------------------------------------------------------#>
<# Get-PSAzureVirtualNetworkList                                             #>
<#---------------------------------------------------------------------------#>
function Get-PSAzureVirtualNetworkList ()
{
<#
  .SYNOPSIS
  Return a list of virtual networks

  .DESCRIPTION
  Return a formatted list of virtual networks. List includes the name of
  the network, the resource group, and its current provision state.

  .INPUTS
  System.String

  .OUTPUTS
  Custom list of virtual networks

  .EXAMPLE
  Get-PSAzureVirtualNetworkList

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>
  $fn = 'Get-PSAzureVirtualNetworkList:'
  Write-Verbose "$fn Getting virtual network list"

  $list = Get-AzureRmVirtualNetwork |
            Select-Object Name, ResourceGroupName, ProvisioningState

  return $list 

}
#endregion Get-PSAzureVirtualNetworkList

#region New-PSAzureVirtualNetwork
<#---------------------------------------------------------------------------#>
<# New-PSAzureVirtualNetwork                                                 #>
<#---------------------------------------------------------------------------#>
function New-PSAzureVirtualNetwork ()
{
<#
  .SYNOPSIS
  Create a new virtual network

  .DESCRIPTION
  Create a new virtual network on Azure in the specified resource group. 

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .PARAMETER VirtualNetworkName
  The name of the virtual network  
  
  .PARAMETER VirtualSubnetName
  The name of the virtual subnet 
   
  .PARAMETER VirtualNetworkAddress
  The IP Address of the virtual network  
  
  .PARAMETER VirtualSubnetAddress  
  The IP Address of the virtual subnet  
  
  .PARAMETER Location
  The geographic location for the virtual network

  .INPUTS
  System.String

  .OUTPUTS
  Creates a virtual network

  .EXAMPLE
  New-PSAzureVirtualNetwork -ResourceGroupName 'myResourceGroupName' `
                            -VirtualNetworkName 'myNetworkName' `
                            -VirtualSubnetName 'mySubnetName' `
                            -VirtualNetworkAddress '192.168.0.0/16' `
                            -VirtualSubnetAddress '192.168.1.0/24' `
                            -Location 'southeasternus' `
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
                   , HelpMessage='The name of the virtual network'
                   )
         ]
         [string]$VirtualNetworkName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual subnet'
                   )
         ]
         [string]$VirtualSubnetName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The IP Address of the virtual network'
                   )
         ]
         [string]$VirtualNetworkAddress
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The IP Address of the virtual subnet'
                   )
         ]
         [string]$VirtualSubnetAddress
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The geographic location for the virtual network'
                   )
         ]
         [string]$Location
       )
  
  $fn = 'New-PSAzureVirtualNetwork:'

  $vNetExists = Test-PSAzureVirtualNetwork `
                    -ResourceGroupName $ResourceGroupName `
                    -Name $VirtualNetworkName 
  
  if ($vNetExists -eq $false)
  { 
    # Note in this example we'll create the subnet, then create the 
    # new vNet and add the subnet all in one step
    Write-Verbose "$fn Creating subnet $VirtualSubnetName for network $VirtualNetworkName"
  
    # Create the subnet
    $subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
                      -Name $VirtualSubnetName `
                      -AddressPrefix $VirtualSubnetAddress
    
    # Create the vNet attaching the subnet to it
    Write-Verbose "$fn Creating network $VirtualNetworkName"
    New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName `
                              -Name $VirtualNetworkName `
                              -AddressPrefix $VirtualNetworkAddress `
                              -Subnet $subnetConfig `
                              -Location $Location
  }
  else
  {
    Write-Verbose "$fn virtual network $VirtualNetworkName already exists"
  }
  
}
#endregion New-PSAzureVirtualNetwork

#region Remove-PSAzureVirtualNetwork
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureVirtualNetwork                                              #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureVirtualNetwork ()
{
<#
  .SYNOPSIS
  Removes (deletes) an Azure Virtual Network
  
  .DESCRIPTION
  Deletes the virtual network named in the VirtualNetworkName parameter

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .PARAMETER VirtualNetworkName
  The name of the virtual network  
  
  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureVirtualNetwork -ResourceGroupName 'myResourceGroupName' `
                               -VirtualNetworkName 'myNetworkName' `
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
                   , HelpMessage='The name of the virtual network'
                   )
         ]
         [string]$VirtualNetworkName
       )

  $fn = 'Remove-PSAzureVirtualNetwork:'
  Write-Verbose "$fn Preparing to remove virtual network $VirtualNetworkName"
  $exists = Test-PSAzureVirtualNetwork -ResourceGroupName $ResourceGroupName `
                                       -Name $VirtualNetworkName
  
  if ($exists -eq $true)
  {
    Write-Verbose "$fn Removing virtual network $VirtualNetworkName"
    Remove-AzureRmVirtualNetwork `
      -Name $VirtualNetworkName `
      -ResourceGroupName $ResourceGroupName `
      -Force
  }
  
}
#endregion Remove-PSAzureVirtualNetwork

#region Test-PSAzureNetworkSecurityGroup
<#---------------------------------------------------------------------------#>
<# Test-PSAzureNetworkSecurityGroup                                          #>
<#---------------------------------------------------------------------------#>
function Test-PSAzureNetworkSecurityGroup ()
{
<#
  .SYNOPSIS
  Tests to see if a network security group exists

  .DESCRIPTION
  Checks to see if the specified network security group exists within the
  specified resource group

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .Parameter NetworkSecurityGroupName
  The name of the network security group

  .INPUTS
  System.String

  .OUTPUTS
  Boolean. True if it exists, False if not.

  .EXAMPLE
  $exists = Test-PSAzureNetworkSecurityGroup `
                -ResourceGroupName 'myResourceGroupName' `
                -NetworkSecurityGroupName 'myNetworkSecurityGroupName'

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
                   , HelpMessage='The resource group containing the network security group'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the network security group to see if it exists'
                   )
         ]
         [string]$NetworkSecurityGroupName
       )
  
  $fn = 'Test-PSAzureNetworkSecurityGroup:'

  Write-Verbose "$fn Testing for security group $NetworkSecurityGroupName"
  $exists = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName |
              Where-Object Name -eq $NetworkSecurityGroupName

  if ($exists -eq $null)
  {
    Write-Verbose "$fn Network Security Group $NetworkSecurityGroupName does not exist"
    $result = $false
  }
  else
  {
    Write-Verbose "$fn Network Security Group $NetworkSecurityGroupName exists"
    $result = $true
  }
  
  return $result

}
#endregion Test-PSAzureNetworkSecurityGroup

#region New-PSAzureSecurityRule
<#---------------------------------------------------------------------------#>
<# New-PSAzureSecurityRule                                                   #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSecurityRule ()
{
<#
  .SYNOPSIS
  Create a new security rule

  .DESCRIPTION
  Create a new network security rule. Security rules are required by the
  New-PSAzureNetworkSecurityGroup function.

  .PARAMETER RuleName 
  The name to give this new rule
  
  .PARAMETER RuleDescription
  The description for this rule
  
  .PARAMETER Priority
  Priority for the rule
  
  .PARAMETER Port
  The network port for the rule
  
  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  $newRule = New-PSAzureSecurityRule -RuleName 'rdp-rule' `
                                     -RuleDescription 'Allow RDP' `
                                     -Priority 100 `
                                     -Port 3389

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
                   , HelpMessage='The name to give this new rule'
                   )
         ]
         [string]$RuleName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The description for this rule'
                   )
         ]
         [string]$RuleDescription
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='Priority for the rule'
                   )
         ]
         [string]$Priority
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The network port for the rule'
                   )
         ]
         [string]$Port
       )
  
  $fn = 'New-PSAzureSecurityRule:'
  Write-Verbose "$fn Creating rule $RuleName" 
  
  $newRule = New-AzureRmNetworkSecurityRuleConfig `
               -Name $RuleName `
               -Description $RuleDescription `
               -Access Allow `
               -Protocol Tcp `
               -Direction Inbound `
               -Priority $Priority `
               -SourceAddressPrefix Internet `
               -SourcePortRange * `
               -DestinationAddressPrefix * `
               -DestinationPortRange $Port

  return $newRule
  
}
#endregion New-PSAzureSecurityRule

#region New-PSAzureRdpSecurityRule
<#---------------------------------------------------------------------------#>
<# New-PSAzureRdpSecurityRule                                                #>
<#---------------------------------------------------------------------------#>
function New-PSAzureRdpSecurityRule ()
{
<#
  .SYNOPSIS
  Create a specific security rule to allow RDP traffic.

  .DESCRIPTION
  Calls New-PSAzureSecurityRule with the specific set of parameters needed
  in order to allow RDP traffic through the network.

  .INPUTS
  System.String

  .OUTPUTS
  Returns an network rule object.

  .EXAMPLE
  $rdpRule = New-PSAzureRdpSecurityRule 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  $rdpRule = New-PSAzureSecurityRule -RuleName 'rdp-rule' `
                                     -RuleDescription 'Allow RDP' `
                                     -Priority 100 `
                                     -Port 3389

  return $rdpRule

}
#endregion New-PSAzureRdpSecurityRule

#region New-PSAzureHttpSecurityRule
<#---------------------------------------------------------------------------#>
<# New-PSAzureHttpSecurityRule                                               #>
<#---------------------------------------------------------------------------#>
function New-PSAzureHttpSecurityRule ()
{
<#
  .SYNOPSIS
  Create a specific security rule to allow HTTP traffic.

  .DESCRIPTION
  Calls New-PSAzureSecurityRule with the specific set of parameters needed
  in order to allow HTTP traffic through the network.

  .INPUTS
  System.String

  .OUTPUTS
  Returns an network rule object.

  .EXAMPLE
  $httpRule = New-PSAzureHttpSecurityRule 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017,2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  $httpRule = New-PSAzureSecurityRule -RuleName 'web-rule' `
                                      -RuleDescription 'Allow HTTP' `
                                      -Priority 101 `
                                      -Port 80

  return $httpRule

}
#endregion New-PSAzureHttpSecurityRule

#region New-PSAzureNetworkSecurityGroup
<#---------------------------------------------------------------------------#>
<# New-PSAzureNetworkSecurityGroup                                           #>
<#---------------------------------------------------------------------------#>
function New-PSAzureNetworkSecurityGroup ()
{
<#
  .SYNOPSIS
  Create a new network security group.

  .DESCRIPTION
  Creates a new network security group in the resource group specified.

  .PARAMETER ResourceGroupName
  The resource group holding the virtual machine

  .PARAMETER NetworkSecurityGroupName
  The name of the network security group

  .PARAMETER Location
  The geographic location for the network security group

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  New-PSAzureNetworkSecurityGroup -ResourceGroupName 'myResourceGroupName' `
                                  -NetworkSecurityGroupName 'myNetworkSecurityGroup' `
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
                   , HelpMessage='The resource group to hold the network security group'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the network security group'
                   )
         ]
         [string]$NetworkSecurityGroupName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The geographic location for the network security group'
                   )
         ]
         [string]$Location
       )
  
  $fn = 'New-PSAzureNetworkSecurityGroup:'
  Write-Verbose "$fn Creating $NetworkSecurityGroupName" 

  $exists = Test-PSAzureNetworkSecurityGroup `
                -ResourceGroupName $ResourceGroupName `
                -NetworkSecurityGroupName $NetworkSecurityGroupName

  if ($exists -eq $false)
  {
    Write-Verbose "$fn Creating security rules"
    $rdpRule = New-PSAzureRdpSecurityRule 
    $httpRule = New-PSAzureHttpSecurityRule
    
    Write-Verbose "$fn Creating Security Group $NetworkSecurityGroupName in resource group $ResourceGroupName"  
    New-AzureRmNetworkSecurityGroup `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location `
           -Name $NetworkSecurityGroupName `
           -SecurityRules $rdpRule, $httpRule
  }
  else
  {
    Write-Verbose "$fn Security Group $NetworkSecurityGroupName already exists"  
  }
  
}
#endregion New-PSAzureNetworkSecurityGroup

#region Remove-PSAzureNetworkSecurityGroup
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureNetworkSecurityGroup                                        #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureNetworkSecurityGroup ()
{
<#
  .SYNOPSIS
  Remove (delete) the specified network security group.

  .DESCRIPTION
  Removes the specified network security group located in the passed in
  resource group.

  .PARAMETER ResourceGroupName
  The resource group holding the network security group

  .PARAMETER NetworkSecurityGroupName
  The name of the network security group to remove'
  
  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureNetworkSecurityGroup -ResourceGroupName 'myResourceGroupName' `
                                     -NetworkSecurityGroupName 'myNsgName' `
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
                   , HelpMessage='The resource group containing the network security group'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the network security group to remove'
                   )
         ]
         [string]$NetworkSecurityGroupName
       )
  
  $fn = 'Remove-PSAzureNetworkSecurityGroup:'

  Write-Verbose "$fn Preparing to remove security group $NetworkSecurityGroupName"

  $exists = Test-PSAzureNetworkSecurityGroup `
                -ResourceGroupName $resourceGroupName `
                -NetworkSecurityGroupName $NetworkSecurityGroupName
  
  if ($exists -eq $true)
  { 
    Write-Verbose "$fn Removing security group $NetworkSecurityGroupName"
    Remove-AzureRmNetworkSecurityGroup `
          -Name $NetworkSecurityGroupName `
          -ResourceGroupName $ResourceGroupName `
          -Force
  }

}
#endregion Remove-PSAzureNetworkSecurityGroup

#region Test-PSAzureVirtualNIC
<#---------------------------------------------------------------------------#>
<# Test-PSAzureVirtualNIC                                                    #>
<#---------------------------------------------------------------------------#>
function Test-PSAzureVirtualNIC ()
{
<#
  .SYNOPSIS
  Tests to see if the virtual NIC exits.

  .DESCRIPTION
  Tests to see if the virtual network interface card exists. Returns true 
  if it does, false if it does not.

  .PARAMETER ResourceGroupName
  The resource group holding the virtual NIC

  .PARAMETER NICName
  The name of the virtual NIC

  .INPUTS
  System.String

  .OUTPUTS
  Boolean

  .EXAMPLE
  $exists = Test-PSAzureVirtualNIC -ResourceGroupName $ResourceGroupName `
                                   -NICName $NICName

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
                   , HelpMessage='The name of the virtual NIC'
                   )
         ]
         [string]$NICName
       )
  
  $fn = 'Test-PSAzureVirtualNIC:'
  Write-Verbose "$fn Testing NIC $NICName"

  $exists = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName |
              Where-Object Name -eq $NICName

  if ($exists -eq $null)
  {
    Write-Verbose "$fn NIC $NICName does not exist"
    $result = $false
  }
  else
  {
    Write-Verbose "$fn NIC $NICName exists"
    $result = $true
  }

  return $result
}
#endregion Test-PSAzureVirtualNIC

#region Get-PSAzureVirtualNIC
<#---------------------------------------------------------------------------#>
<# Get-PSAzureVirtualNIC                                                     #>
<#---------------------------------------------------------------------------#>
function Get-PSAzureVirtualNIC ()
{
<#
  .SYNOPSIS
  Returns an object with the virtual NIC.

  .DESCRIPTION

  .PARAMETER ResourceGroupName
  The resource group holding the virtual NIC

  .PARAMETER NICName
  The name of the virtual NIC

  .INPUTS
  System.String

  .OUTPUTS
  A reference to the virtual NIC

  .EXAMPLE


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
                   , HelpMessage='The name of the virtual NIC'
                   )
         ]
         [string]$NICName
       )
  
  $fn = 'Get-PSAzureVirtualNIC:'

  Write-Verbose "$fn Checking for NIC $NICName"
  $exists = Test-PSAzureVirtualNIC -ResourceGroupName $ResourceGroupName `
                                   -NICName $NICName

  if ($exists -eq $true)
  {
    Write-Verbose "$fn Getting data for NIC $NICName"
    $result = Get-AzureRmNetworkInterface `
                 -ResourceGroupName $ResourceGroupName `
                 -Name $NICName
  }
  else
  {
    Write-Verbose "$fn NIC $NICName does not exist"
    $result = $null
  }

  return $result
}
#endregion Get-PSAzureVirtualNIC

#region New-PSAzureVirtualNIC
<#---------------------------------------------------------------------------#>
<# New-PSAzureVirtualNIC                                                     #>
<#---------------------------------------------------------------------------#>
function New-PSAzureVirtualNIC ()
{
<#
  .SYNOPSIS
  Create a new virtual NIC.

  .DESCRIPTION
  Creates a new virtual network interface card (NIC) in the specified
  Resource Group.

  .PARAMETER ResourceGroupName
  The resource group holding the virtual NIC

  .PARAMETER NICName
  The name of the virtual NIC

  .PARAMETER VirtualNetworkName
  The name of the virtual network

  .PARAMETER NetworkSecurityGroupName
  The name of the network security group

  .PARAMETER Location
  The geographic location for the virtual NIC

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  New-PSAzureVirtualNIC -ResourceGroupName 'myResourceGroupName' `
                        -NICName 'myNicName' `
                        -VirtualNetworkName 'myNetworkName' `
                        -NetworkSecurityGroupName 'myNsgName' `
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
                   , HelpMessage='The resource group to hold the virtual NIC'
                   )
         ]
         [string]$ResourceGroupName 
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual NIC'
                   )
         ]
         [string]$NICName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the virtual network'
                   )
         ]
         [string]$VirtualNetworkName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the network security group'
                   )
         ]
         [string]$NetworkSecurityGroupName
         ,
         [Parameter( Mandatory=$true
                   , HelpMessage='The geographic location for the virtual NIC'
                   )
         ]
         [string]$Location
       )

  $fn = 'New-PSAzureVirtualNIC:'
  Write-Verbose "$fn Checking for NIC $NICName"

  $exists = Test-PSAzureVirtualNIC -ResourceGroupName $ResourceGroupName `
                                   -NICName $NICName

  if ($exists -eq $false)
  {
    # Get a reference to our existing virtual network
    Write-Verbose "$fn Getting reference to virtual network $VirtualNetworkName"
    $vNet = Get-AzureRmVirtualNetwork `
              -ResourceGroupName $ResourceGroupName `
              -Name $VirtualNetworkName
    
    # Get a reference to the existing NSG
    Write-Verbose "$fn Getting reference to security group $NetworkSecurityGroupName"
    $nsg = Get-AzureRmNetworkSecurityGroup `
             -ResourceGroupName $ResourceGroupName `
             -Name $NetworkSecurityGroupName
      
    # Create a public IP address and specify a DNS name
    Write-Verbose "$fn Creating pubic IP Address"
    $pip = New-AzureRmPublicIpAddress `
             -ResourceGroupName $ResourceGroupName `
             -Location $Location `
             -AllocationMethod Static `
             -IdleTimeoutInMinutes 4 `
             -Name "mypublicdns$(Get-Random)"
    
    Write-Verbose "$fn Creating NIC $NICName"
    $nic = New-AzureRmNetworkInterface `
             -Name $NICName `
             -ResourceGroupName $resourceGroupName `
             -Location $location `
             -SubnetId $vNet.Subnets[0].Id `
             -PublicIpAddressId $pip.Id `
             -NetworkSecurityGroupId $nsg.Id
  }
  
}
#endregion New-PSAzureVirtualNIC

#region Remove-PSAzureVirtualNIC
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureVirtualNIC                                                  #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureVirtualNIC ()
{
<#
  .SYNOPSIS
  Removes (deletes) a NIC.

  .DESCRIPTION
  Removes (deletes) a virtual network interface card (NIC).

  .PARAMETER ResourceGroupName
  The resource group holding the virtual NIC

  .PARAMETER NICName
  The name of the virtual NIC

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureVirtualNIC -ResourceGroupName 'myResourceGroupName' `
                           -NICName 'myNicName' `
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
                   , HelpMessage='The name of the virtual NIC'
                   )
         ]
         [string]$NICName
       )

  $fn = 'Remove-PSAzureVirtualNIC:'
  Write-Verbose "$fn Checking for NIC $NICName"

  $exist = Test-PSAzureVirtualNIC -ResourceGroupName $ResourceGroupName `
                                  -NICName $NICName
  if ($exist -eq $true)
  {
    Write-Verbose "$fn Removing Virtual NIC $NICName"
    Remove-AzureRmNetworkInterface `
          -Name $NICName `
          -ResourceGroupName $ResourceGroupName `
          -Force
  }

}
#endregion Remove-PSAzureVirtualNIC
