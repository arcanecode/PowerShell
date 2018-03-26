<#-----------------------------------------------------------------------------
  Defines helper functions for working with Azure Storage

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    New-PSStorageAccount
    Get-PSStorageAccountKey
    Get-PSStorageContext
    New-PSStorageContainer
    Set-PSBlobContent
    Remove-PSAzureStorageContainer
    Remove-PSAzureStorageAccount

-----------------------------------------------------------------------------#>

#region New-PSStorageAccount
<#---------------------------------------------------------------------------#>
<# New-PSStorageAccount                                                      #>
<#---------------------------------------------------------------------------#>
function New-PSStorageAccount ()
{ 
<#
  .SYNOPSIS
  Create a new storage account

  .DESCRIPTION
  Checks to see if an Azure storage account exists in a particular resource
  group. If not, it will create it. 

  .PARAMETER StorageAccountName
  The name of the storage account to create.

  .PARAMETER ResourceGroupName
  The resource group to put the storage account in.

  .Parameter Location
  The Azure geographic location to put the storage account in.

  .INPUTS
  System.String

  .OUTPUTS
  A new storage account

  .EXAMPLE
  New-PSStorageAccount -StorageAccountName 'ArcaneStorageAcct' `
                       -ResourceGroupName 'ArcaneRG' `
                       -Location 'southcentralus'

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
                   , HelpMessage='The name of the storage account to create'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to put the storage account in'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The geo location to put the storage account in'
                   )
         ]
         [string]$Location
       )

  $fn = 'New-PSStorageAccount:'

  # Check to see if the storage account exists
  Write-Verbose "$fn Checking Storage Account $StorageAccountName"
  $saExists = Get-AzureRMStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $StorageAccountName `
                -ErrorAction SilentlyContinue

  # If not, create it.
  if ($saExists -eq $null)
  { 
    Write-Verbose "$fn Creating Storage Account $StorageAccountName"
    New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
                              -Name $StorageAccountName `
                              -Location $Location `
                              -Type Standard_LRS
  }
}
#endregion New-PSStorageAccount

#region Get-PSStorageAccountKey
<#---------------------------------------------------------------------------#>
<# Get-PSStorageAccountKey                                                   #>
<#---------------------------------------------------------------------------#>
function Get-PSStorageAccountKey ()
{
<#
  .SYNOPSIS
  Gets the key associated with a storage account

  .DESCRIPTION
  Every storage account has a special key assoicated with it. This key unlocks
  the storage vault to get data in or out of it. This cmdlet will get the key
  for the passed storage account.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the storage account

  .PARAMETER StorageAccountName
  The name of the storage account you need the key for

  .INPUTS
  System.String

  .OUTPUTS
  Storage Account Key

  .EXAMPLE
  Get-PSStorageAccountKey -ResourceGroupName 'ArcaneRG' `
                          -StorageAccountName 'ArcaneStorageAcct'

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
                   , HelpMessage='The resource group containing the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to get the key for'
                   )
         ]
         [string]$StorageAccountName
       )

  $fn = 'Get-PSStorageAccountKey:'

  Write-Verbose "$fn Getting storage account key for storage account $StorageAccountName"
  $storageAccountKey = $(Get-AzureRmStorageAccountKey `
                           -ResourceGroupName $ResourceGroupName `
                           -Name $StorageAccountName `
                        ).Value[0]

  return $storageAccountKey
}
#endregion Get-PSStorageAccountKey

#region Get-PSStorageContext
<#---------------------------------------------------------------------------#>
<# Get-PSStorageContext                                                      #>
<#---------------------------------------------------------------------------#>
function Get-PSStorageContext ()
{
<#
  .SYNOPSIS
  Get the context for a storage account.

  .DESCRIPTION
  To fully access a storage account you use its context. The context is based
  on a combination of the account name and key. This cmdlet will retrieve the
  context so you can use it in subsequent storage operations.

  .PARAMETER ResourceGroupName
  The resource group containing the storage account.

  .PARAMETER StorageAccountName
  The name of the storage account. 

  .INPUTS
  System.String

  .OUTPUTS
  Context

  .EXAMPLE
  Get-PSStorageContext -ResourceGroupName 'ArcaneRG' `
                       -StorageAccountName 'ArcaneStorageAcct'


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
                   , HelpMessage='The resource group containing the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to get the context for'
                   )
         ]
         [string]$StorageAccountName
       )
  
  $fn = 'Get-PSStorageContext:'
  # This uses the custom cmdlet declared earlier in this file
  $storageAccountKey = Get-PSStorageAccountKey `
                         -ResourceGroupName $ResourceGroupName `
                         -StorageAccountName $StorageAccountName
  

  # Now that we have the key, we can get the context
  Write-Verbose "$fn Getting Storage Context for account $StorageAccountName"
  $context = New-AzureStorageContext `
               -StorageAccountName $StorageAccountName `
               -StorageAccountKey $storageAccountKey

  return $context
}
#endregion Get-PSStorageContext

#region New-PSStorageContainer
<#---------------------------------------------------------------------------#>
<# New-PSStorageContainer                                                    #>
<#---------------------------------------------------------------------------#>
function New-PSStorageContainer ()
{ 
<#
  .SYNOPSIS
  Create a new Azure Blob Storage Container.

  .DESCRIPTION
  Checks to see if a storage container already exists for the name passed in.
  If not, it will create a new Blob Storage Container. 

  .PARAMETER ContainerName
  The name of the container to create.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the storage account

  .PARAMETER StorageAccountName
  The name of the storage account you want to create a container in

  .INPUTS
  System.String

  .OUTPUTS
  A new Azure Blob Storage Container

  .EXAMPLE
  New-PSStorageContainer -ContainerName 'ArcaneContainer' `
                         -ResourceGroupName 'ArcaneRG' `
                         -StorageAccountName 'ArcaneStorageAcct'

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
                   , HelpMessage='The name of the container to create'
                   )
         ]
         [string]$ContainerName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to create the container in'
                   )
         ]
         [string]$StorageAccountName
       )
  
  $fn = 'New-PSStorageContainer:'
  Write-Verbose "$fn Checking for Storage Container $ContainerName"

  # First we have to have the storage context
  $context = Get-PSStorageContext `
               -ResourceGroupName $ResourceGroupName `
               -StorageAccountName $StorageAccountName
  
  # Now we can check to see if it exists
  $exists = Get-AzureStorageContainer -Name $ContainerName `
                                      -Context $context `
                                      -ErrorAction SilentlyContinue

  # If it doesn't exist, we'll create it                            
  if ($exists -eq $null)
  { 
    Write-Verbose "$fn Creating Storage Container $ContainerName"
    New-AzureStorageContainer -Name $ContainerName `
                              -Context $context `
                              -Permission Blob
  }
  
  # Whether it already existed or we just created it, we'll grab a reference
  # to it and return it from the function
  Write-Verbose "$fn Retrieving container $ContainerName information"
  $container = Get-AzureStorageContainer -Name $ContainerName `
                                         -Context $context
  return $container
}
#endregion New-PSStorageContainer

#region Set-PSBlobContent
<#---------------------------------------------------------------------------#>
<# Set-PSBlobContent                                                         #>
<#---------------------------------------------------------------------------#>
function Set-PSBlobContent ()
{
<#
  .SYNOPSIS
  Uploads a local file to a storage container.

  .DESCRIPTION
  This will upload a local file to an Azure storage container. First though,
  it checks to see if the file already exists, and if so is it the same size
  in Azure storage as it is on the local drive. If they match, then it skips
  the upload unless the -Force switch is used. 

  .PARAMETER FilePathName
  The path and file name to the local file to be uploaded.

  .PARAMETER ResourceGroupName
  The Resource Group holding the storage account.

  .PARAMETER StorageAccountName
  The storage account holding the container.

  .PARAMETER ContainerName
  The name of the container to upload to.

  .PARAMETER TimeOut
  Optional. The timeout period before the upload fails. Defaults to 500000 seconds.

  .PARAMETER Force
  A Switch that when present will always upload the file even if it already
  exists and is the same size locally as it is in the container.

  .INPUTS
  System.String

  .OUTPUTS
  A new file in the container.

  .EXAMPLE
  Set-PSBlobContent -FilePathName 'C:\Temp\myfile.txt' `
                    -ResourceGroupName 'ArcaneRG' `
                    -StorageAccountName 'ArcaneStorageAcct' `
                    -ContainerName 'ArcaneContainer'

  .EXAMPLE
  Set-PSBlobContent -FilePathName 'C:\Temp\myfile.txt' `
                    -ResourceGroupName 'ArcaneRG' `
                    -StorageAccountName 'ArcaneStorageAcct' `
                    -ContainerName 'ArcaneContainer' `
                    -TimeOut 900000 `
                    -Force

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
                   , HelpMessage='The directory / file name of the file to upload'
                   )
         ]
         [string]$FilePathName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The storage account name holding the container'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the container to upload to'
                   )
         ]
         [string]$ContainerName
       , [int]$TimeOut = 500000
       , [switch]$Force
       )

  $fn = 'Set-PSBlobContent:'


  # We need the storage account key based on the account name
  Write-Verbose "$fn Getting key for account $StorageAccountName"
  $storageAccountKey = $(Get-AzureRmStorageAccountKey `
                          -ResourceGroupName $ResourceGroupName `
                          -Name $StorageAccountName `
                        ).Value[0]
  
  # With the account key we can get the storage context
  Write-Verbose "$fn Getting context for account $StorageAccountName"
  $context = New-AzureStorageContext `
               -StorageAccountName $storageAccountName `
               -StorageAccountKey $storageAccountKey
  
  # Get a file object from the path/file name
  Write-Verbose "$fn Getting a reference to $FilePathName"
  $localFile = Get-ChildItem -Path $FilePathName
  
  # Set a flag that assumes we'll need to upload
  $upload = $true

  # See if the file exists on the server and if so what size
  Write-Verbose "$fn Checking to see if $FilePathName already exists on the server"
  $azureFile = Get-AzureStorageBlob -Container $containerName -Context $context |
                    Where-Object Name -eq $localFile.Name
  
  # If it found the file...
  if ($azureFile -ne $null)
  {
    # ...and sizes are the same, no need to upload
    if ($azureFile.Length -eq $localFile.Length)
    { 
      $upload = $false 

      # As long as the user didn't include the force switch, let
      # them know the upload will be skipped
      if ($Force -eq $false)
      { Write-Verbose "$fn File already exists, upload will be skipped" }
    }
  }

  # If user inculded the Force switch, always upload even if
  # the file is already there and the same size
  if ($Force)
  { 
    Write-Verbose "$fn Force switched used, upload will occur"
    $upload = $true 
  }
  
  # Time outs are the biggest issue here, so going to catch the error
  # and stop the script if one occurs
  if ($upload -eq $true)
  { 
    Write-Verbose "$fn Uploading $localFile"
    
    try 
    { 
      Set-AzureStorageBlobContent -File $localFile.FullName `
                                  -Container $containerName `
                                  -Blob $localFile.Name `
                                  -Context $context `
                                  -ServerTimeoutPerRequest $TimeOut `
                                  -ClientTimeoutPerRequest $TimeOut `
                                  -Force
    }
    catch
    {
      throw $_  # Display the error
      break     # Halt the script
    }
  } # if ($upload -eq $true)
}
#endregion Set-PSBlobContent

#region Remove-PSAzureStorageContainer
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureStorageContainer                                            #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureStorageContainer ()
{
<#
  .SYNOPSIS
  Removes an Azure storage container from a storage account.

  .DESCRIPTION
  Removes an Azure storage container, and everything it contains, if that
  container exists. Be warned, it does not provide warnings, confirmations, 
  and the like.

  .PARAMETER ResourceGroupName
  The name of the resource group holding the storage container to remove.

  .PARAMETER StorageAccountName
  The name of the storage account holding the container to remove.

  .PARAMETER ContainerName
  The name of the container to be removed

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PsAzureStorageContainer -ResourceGroupName 'resourcegroupname' `
                                 -StorageAccountName 'storageaccount' `
                                 -ContainerName 'containertoremove'

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
                   , HelpMessage='The resource group holding the storage account'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account holding the container'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the container to remove'
                   )
         ]
         [string]$ContainerName
       )

  $fn = 'Remove-PSAzureStorageContainer:'

  Write-Verbose "$fn Get context for storage account $StorageAccountName"
  $context = Get-PSStorageContext -ResourceGroupName $ResourceGroupName `
                                  -StorageAccountName $StorageAccountName `
                                  -Verbose

  Write-Verbose "$fn Checking for Container $ContainerName"
  $exists = Get-AzureStorageContainer -Name $ContainerName `
                                      -Context $context `
                                      -ErrorAction SilentlyContinue

  # If it exists, we'll remove it                            
  if ($exists -ne $null)
  { 
    Write-Verbose "$fn Removing Container $ContainerName"
    Remove-AzureStorageContainer -Name $containerName `
                                 -Context $context `
                                 -Force 
  }
}
#endregion Remove-PSAzureStorageContainer

#region Remove-PSAzureStorageAccount
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureStorageAccount                                              #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureStorageAccount ()
{
<#
  .SYNOPSIS
  Removes an Azure storage account.

  .DESCRIPTION
  Removes an Azure storage account, and everything it contains, if that account
  exists. Be warned, it does not provide warnings, confirmations, and the like.

  .PARAMETER ResourceGroupName
  The name of the resource group holding the storage account to remove.

  .PARAMETER StorageAccountName
  The name of the storage account to remove.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PsAzureStorageAccount -ResourceGroupName 'resourcegroupname' `
                               -StorageAccountName 'accounttoremove'

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
                   , HelpMessage='The resource group to put the storage account in'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to create'
                   )
         ]
         [string]$StorageAccountName
       )

  $fn = 'Remove-PSAzureStorageAccount:'

  Write-Verbose "$fn Checking for account $StorageAccountName in group $ResourceGroupName"
  $saExists = Get-AzureRMStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $StorageAccountName `
                -ErrorAction SilentlyContinue

  if ($saExists -ne $null)
  {
    Write-Verbose "$fn Removing account $StorageAccountName from group $ResourceGroupName"
    Remove-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
                                 -AccountName $StorageAccountName `
                                 -Force
  }
}
#endregion Remove-PSAzureStorageAccount
