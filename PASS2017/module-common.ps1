<#-----------------------------------------------------------------------------
  Powering Azure SQL With PowerShell

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 
 -----------------------------------------------------------------------------#>

<#---------------------------------------------------------------------------#>
<# Common Functions used across all sample scripts.                          #>
<#---------------------------------------------------------------------------#>


<#---------------------------------------------------------------------------#>
<# Connect-PSToAzure                                                         #>
<#---------------------------------------------------------------------------#>
function Connect-PSToAzure ()
{ 
<#
  .SYNOPSIS
  Connects the current PowerShell session to Azure, if it is not already 
  connected.
  
  .DESCRIPTION
  If a path/file is passed in, will attempt to copy the contents to the
  clipboard with the assumption it is your password. It will then call the
  cmdlet to connect to Azure. You just key in your user ID, then can paste
  in your password. 

  WARNING: Of course it is dangerous to leave your password laying around
  in a text file. Be sure your machine is secure, or optionally omit the
  file and just key it in each time. 

  .PARAMETER Path
  The directory where your password file is stored

  .PARAMETER PasswordFile
  The file holding your password.

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE
  Connect-PSToAzure 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test' -PasswordFile 'mypw.txt'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [string]$Path
       , [string]$PasswordFile = 'azpw.txt'
       )

  # Login if we need to
  if ( $(Get-AzureRmContext).Account -eq $null )
  {
    # Copy your password to the clipboard
    if ($Path -ne $null)
    {
      $pwPathFile = "$Path\$passwordFile"
      if ($(Test-Path $pwPathFile))
      {
        Set-Clipboard $(Get-Content $pwPathFile )
      }
    }
    
    # Begin the login process
    Add-AzureRMAccount  # Login
  }

}

<#---------------------------------------------------------------------------#>
<# Set-PSSubscription                                                        #>
<#---------------------------------------------------------------------------#>
function Set-PSSubscription ()
{
<#
  .SYNOPSIS
  Sets the current Azure subscription.

  .DESCRIPTION
  When you have multiple Azure subscriptions, this function provides an easy
  way to change between them. The function will check to see what your current
  subscription is, and if different from the one passed in it will change it.

  .PARAMETER Subscription
  The name of the subscription to change to
  
  .INPUTS
  System.String

  .OUTPUTS
  n/a

  .EXAMPLE
  Set-PSSubscription -Subscription 'Visual Studio Ultimate with MSDN'

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
                   , HelpMessage='The subscription name to change to'
                   )
         ]
         [string]$Subscription
       )

  # Get the current context we're running under. From that we can
  # derive the current subscription name
  $currentAzureContext = Get-AzureRmContext
  $currentSubscriptionName = $currentAzureContext.Subscription.Name

  if ($currentSubscriptionName -eq $Subscription)
  {
    # If we're already running under it, do nothing
    Write-Verbose "Current Subscription is already set to $Subscription"  
  }
  else
  {
    # Change to the new subscription
    Write-Verbose "Current Subscription: $currentSubscriptionName"
    Write-Verbose "Changing Subscription to $Subscription "

    # Set the subscription to use
    Set-AzureRmContext -SubscriptionName $Subscription
  }
  
}

<#---------------------------------------------------------------------------#>
<# New-PSResoruceGroup                                                       #>
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
  
  # Check to see if the resource group already exists
  Write-Verbose "Checking for Resource Group $ResourceGroupName"
  $rgExists = Get-AzureRmResourceGroup -Name $ResourceGroupName `
                                       -ErrorAction SilentlyContinue
  
  # If not, create it.
  if ( $rgExists -eq $null )
  {
    Write-Verbose "Creating Resource Group $ResourceGroupName"
    New-AzureRmResourceGroup -Name $ResourceGroupName `
                             -Location $Location
  }
}

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

  # Check to see if the storage account exists
  Write-Verbose "Checking Storage Account $StorageAccountName"
  $saExists = Get-AzureRMStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $StorageAccountName `
                -ErrorAction SilentlyContinue

  # If not, create it.
  if ($saExists -eq $null)
  { 
    Write-Verbose "Creating Storage Account $StorageAccountName"
    New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
                              -Name $StorageAccountName `
                              -Location $Location `
                              -Type Standard_LRS
  }
}

<#---------------------------------------------------------------------------#>
<# Get-PSStorageAccountKey                                                   #>
<#---------------------------------------------------------------------------#>
function Get-PSStorageAccountKey()
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

  $storageAccountKey = $(Get-AzureRmStorageAccountKey `
                           -ResourceGroupName $ResourceGroupName `
                           -Name $StorageAccountName `
                        ).Value[0]

  return $storageAccountKey
}

<#---------------------------------------------------------------------------#>
<# Get-PSStorageContext                                                      #>
<#---------------------------------------------------------------------------#>
function Get-PSStorageContext()
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
  
  # This uses the custom cmdlet declared earlier in this file
  $storageAccountKey = Get-PSStorageAccountKey `
                         -ResourceGroupName $ResourceGroupName `
                         -StorageAccountName $StorageAccountName
  

  # Now that we have the key, we can get the context
  Write-Verbose "Getting Storage Context for account $StorageAccountName"
  $context = New-AzureStorageContext `
               -StorageAccountName $StorageAccountName `
               -StorageAccountKey $storageAccountKey

  return $context
}

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
  
  Write-Verbose "Checking Storage Container $ContainerName"

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
    Write-Verbose "Creating Storage Container $containerName"
    New-AzureStorageContainer -Name $containerName `
                              -Context $context `
                              -Permission Blob
  }
  
  # Whether it already existed or we just created it, we'll grab a reference
  # to it and return it from the function
  $container = Get-AzureStorageContainer -Name $containerName `
                                         -Context $context
  return $container
}

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

  Write-Verbose "Checking for $filePathName on the server"

  # We need the storage account key based on the account name
  $storageAccountKey = $(Get-AzureRmStorageAccountKey `
                          -ResourceGroupName $resourceGroupName `
                          -Name $storageAccountName `
                        ).Value[0]
  
  # With the account key we can get the storage context
  $context = New-AzureStorageContext `
               -StorageAccountName $storageAccountName `
               -StorageAccountKey $storageAccountKey
  
  # Get a file object from the path/file name
  $localFile = Get-ChildItem -Path $filePathName
  
  # Set a flag that assumes we'll need to upload
  $upload = $true

  # See if the file exists on the server and if so what size
  $azureFile = Get-AzureStorageBlob -Container $containerName -Context $context |
                    Where-Object Name -eq $localFile.Name
  
  # If it found the file...
  if ($azureFile -ne $null)
  {
    # ...and sizes are the same, no need to upload
    if ($azureFile.Length -eq $localFile.Length)
    { $upload = $false }
  }

  # If user inculded the Force switch, always upload even if
  # the file is already there and the same size
  if ($Force)
  { $upload = $true }
  
  # Time outs are the biggest issue here, so going to catch the error
  # and stop the script if one occurs
  if ($upload -eq $true)
  { 
    Write-Verbose "Uploading $localFile"
    
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
