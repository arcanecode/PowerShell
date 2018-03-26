<#-----------------------------------------------------------------------------
  Defines helper functions for working with Azure Resource Groups

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    New-PSResourceGroup
    Remove-PsAzureResourceGroup

-----------------------------------------------------------------------------#>

#region New-PSResourceGroup
<#---------------------------------------------------------------------------#>
<# New-PSResourceGroup                                                       #>
<#---------------------------------------------------------------------------#>
function New-PSResourceGroup ()
{ 
<#
  .SYNOPSIS
  Create a new resource group.

  .DESCRIPTION
  Checks to see if the passed in resource group name exists, if not it will 
  create it in the location that matches the location parameter.
  
  .PARAMETER ResourceGroupName
  The name of the resource group to create

  .PARAMETER Location
  The Azure geographic location to store the resource group in.

  .INPUTS
  System.String

  .OUTPUTS
  n/a

  .EXAMPLE
  New-PSResourceGroup -ResourceGroupName 'ArcaneRG' -Location 'southcentralus'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the resource group to create'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The geo location to store the Resource Group in'
                   )
         ]
         [string]$Location
       )
  
  $fn = 'New-PSResourceGroup:'
  # Check to see if the resource group already exists
  Write-Verbose "$fn Checking for Resource Group $ResourceGroupName"

  # Method 1 - Ignores errors
  # $rgExists = Get-AzureRmResourceGroup -Name $ResourceGroupName `
  #                                      -ErrorAction SilentlyContinue

  # Method 2 - Filters on this end
  $rgExists = Get-AzureRmResourceGroup |
     Where-Object {$_.ResourceGroupName -eq $ResourceGroupName}

  
  # If not, create it.
  if ( $rgExists -eq $null )
  {
    Write-Verbose "$fn Creating Resource Group $ResourceGroupName"
    New-AzureRmResourceGroup -Name $ResourceGroupName `
                             -Location $Location
  }
}
#endregion New-PSResourceGroup

#region Remove-PsAzureResourceGroup
<#---------------------------------------------------------------------------#>
<# Remove-PsAzureResourceGroup                                               #>
<#---------------------------------------------------------------------------#>
function Remove-PsAzureResourceGroup ()
{
<#
  .SYNOPSIS
  Removes an Azure Resource Group

  .DESCRIPTION
  Removes an Azure Resource Group and everything it contains, if that group
  exists. Be warned, it does not provide warnings, confirmations, and the like.

  .PARAMETER ResourceGroupName
  The name of the resource group to remove.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PsAzureResourceGroup -ResourceGroupName 'resourcegrouptoremove'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to delete'
                   )
         ]
         [string]$ResourceGroupName
       )

  $fn = 'Remove-PsAzureResourceGroup:'

  Write-Verbose "$fn Checking for resource group $ResourceGroupName"
  $exists = Get-AzureRmResourceGroup | 
    Where-Object -Property 'ResourceGroupName' -eq $ResourceGroupName
  
  if ($exists -ne $null)
  {
    Write-Verbose "$fn Removing resource group $ResourceGroupName"
    Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
  }

}
#endregion Remove-PsAzureResourceGroup