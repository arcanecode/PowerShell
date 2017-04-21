<#--------------------------------------------------------------------
  Z2H-AZ-03 Storage
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          https://arcanecode.com | https://github.com/arcanecode
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights 
  reserved. No warranty or guarentee is implied or expressly granted. 

  All information was accurate at the time of the demo creation. Note
  that things are changing very rapidly in the world of Azure in 
  general and Azure's PowerShell modules in particular, so be sure
  to check Microsoft online documentation for the latest information.
  
  In this demo you'll see how to create and use storage accounts
  in Azure.
--------------------------------------------------------------------#>

#region Login

# Set a variable with the path to the working directory as we'll
# use it over and over
$dir = "$($env:OneDrive)\Pluralsight\Azure\PS"

# Login to Azure
Add-AzureRmAccount 

# OR
$path = "$dir\ProfileContext.ctx"
Import-AzureRmContext -Path $path

# Make sure we are using the correct subscription
Select-AzureRMSubscription `
  -SubscriptionName 'Visual Studio Ultimate with MSDN'
#endregion Login

#region Get Storage Account Info
<#-------------------------------------------------------------------- 
   Getting information on current storage accounts
--------------------------------------------------------------------#>

# Get a list of storage accounts associated with this subscription
Get-AzureRMStorageAccount

# Get storage account info for a specific resource group
Get-AzureRMStorageAccount -ResourceGroupName psdev

# Get info for a specific account
Get-AzureRmStorageAccount |
  Where-Object StorageAccountName -eq 'acstoretest1'

# Create some output that's easier to read
Get-AzureRmStorageAccount | 
  Select-Object ResourceGroupName, StorageAccountName

# Remove our test storage account
Remove-AzureRmStorageAccount -ResourceGroupName 'PSDev' `
                             -Name 'acstoretest1' `
                             -Force

Get-AzureRmStorageAccount | 
  Select-Object ResourceGroupName, StorageAccountName
#endregion Get Storage Account Info

#region Setting up Storage Accounts
<#-------------------------------------------------------------------- 
   Setting up storage accounts
--------------------------------------------------------------------#>

<#
   To create a new storage account, we'll need a few things.
   First, we'll need to know the location to put in. To get the 
   list of valid locations, we'll use the Get-AzureRmLocation cmdlet.
   The Sort and Format are just used to make the output readable.
#>
Get-AzureRMLocation | Sort-Object Location | Format-Table

<#
   Next you'll need to know what type of storage to use. It will be
   one of the values below.

   Standard_LRS - Locally Redundent Storage
                  Cheapest, creates 3 copies in the same datacenter. 
                  If a catastrophic event occurs at the data center, 
                  the data could be unavailable or even lost. Only 
                  suggested for demos or where loss of data would 
                  not have an impact.

   Standard_ZRS - Zone Redundant Storage 
                  Replicates data from local storage to other data 
                  centers in the same geographic zone. Affordable, 
                  but there is a delay in sync. Thus, if a failover 
                  occurs not all data may have made it over. In 
                  addition, data may not become available until MS 
                  initiates the failover to the secondary.

   Standard_GRS - Geo-Redundant Storage 
                  Replicates data to a secondary region hundreds of 
                  miles from primary region. Similar rules to ZRS, 
                  there is a sync delay and MS has to initiate 
                  failover.

   Standard_RAGRS - Read-Access Geo-Redundant Storage 
                    In addition to GRS makes the secondary available 
                    as a Read-Only site. Good for scalability, 
                    expensive, same issues with sync-delay. While 
                    data will be available for read, it won’t be 
                    available to write until MS initiates failover.

   Premium_LRS - LRS but on solid state drives

#>

# Next you need to know what resource group to use. This will list
# the ones available
Get-AzureRmResourceGroup

<#
   If you want to place it in a new resource group, you can use
   the New-AzureRMResourceGroup cmdlet. You just need to know
   the name you want to call it, and the storage location
   (from the list returned by Get-AzureRMLocation)
#>
New-AzureRmResourceGroup -Name 'MyNewRG' `
                         -Location 'southcentralus'
Get-AzureRmResourceGroup

<#
 You can remove a Resource Group it if you don't need it. 
 If you don't want it to prompt for confirmation, use the
 -Force switch.

 WARNING 1: If you remove a resource group, it will remove
            everything associated with that resource group.
 WARNING 2: If you don't pass in a name it will remove ALL 
            resource groups.
#>
Remove-AzureRmResourceGroup -Name 'MyNewRG' -Force
Get-AzureRmResourceGroup

<#
   Storage Account names must (annoyingly) be unique across all of
   Azure. To determine if your name is in use, you can use the 
   following cmdlet
#>
Get-AzureRmStorageAccountNameAvailability -Name 'acpstest1'


# Now we can create our group
New-AzureRmStorageAccount -ResourceGroupName 'PSDev' `
                          -Name 'acpstest1' `
                          -Location 'southcentralus' `
                          -Type Standard_LRS

# Confirm it is there
Get-AzureRMStorageAccount -ResourceGroupName psdev

# To see how many resource accounts you've used, and how many you
# have left, use this cmdlet
Get-AzureRmStorageUsage

#endregion Setting up Storage Accounts

#region Uploading files
<#--------------------------------------------------------------------
   Next we want to setup our storage container to hold files, then
   upload files to it. 
   First, we'll see if the storage exists, if not we'll create it.
--------------------------------------------------------------------#>

$resourceGroupName = 'PSDev'
$storageAccountName = 'acpsdemo1'

$exists = Get-AzureRmStorageAccountNameAvailability `
            -Name $storageAccountName
if($exists.NameAvailable -eq $true)
{
  New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                            -Name $storageAccountName `
                            -Location 'southcentralus' `
                            -Type Standard_LRS
    
}

# Next we'll need the key for the storage account
Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName `
                             -Name $storageAccountName

<# 
   Note this is returning multiple keys. One is the primary, the 
   other is the secondary, and are named key1 and key2. Since 
   we only need one, we'll use the primary (the first one) 
   and use this code to get that first key.

   Also note you can regenerate the keys if needed using the 
   New-​Azure​Rm​Storage​Account​Key and specifying which key.
#>
$storageAccountKey = $(Get-AzureRmStorageAccountKey `
                         -ResourceGroupName $resourceGroupName `
                         -Name $storageAccountName `
                      ).Value[0]

<#
   Now we need to create a context variable to encapsulate our
   storage access info. Note this only creates an in memory object,
   it won't alter your Azure instance.
#>
$context = New-AzureStorageContext `
             -StorageAccountName $storageAccountName `
             -StorageAccountKey $storageAccountKey

# Now we'll set a name for the container we'll be creating
# Note it must start and end with lowercase letters
$containerName = 'podcastimages'

# Create a new storage container that will hold our images
New-AzureStorageContainer -Name $containerName `
                          -Context $context `
                          -Permission Blob

# Now grab a reference to it
$container = Get-AzureStorageContainer -Name $containerName `
                                       -Context $context


# Now specify where to get the images from locally
$path = "$($env:OneDrive)\Pluralsight\Azure\Images\"

# Get a list of files to upload
$files = Get-ChildItem $path

# Now upload those suckers
foreach ($file in $files)
{
  "Uploading $($file.Name)" # Just a friendly progress message

  Set-AzureStorageBlobContent -File $file.FullName `
                              -Container $containerName `
                              -Blob $file.Name `
                              -Context $context

}

# Now see the results
Get-AzureStorageBlob -Container $containerName -Context $context

# To see something smaller, use select
Get-AzureStorageBlob -Container $containerName -Context $context |
  Select-Object Name

# To remove everything we just uploaded
Get-AzureStorageBlob -Container $containerName -Context $context |
  Remove-AzureStorageBlob 

# Confirm it is gone
Get-AzureStorageBlob -Container $containerName -Context $context

# We could also upload using the pipeline. Use -Force to overwrite
# without confirmation.
Get-ChildItem -Path "$($path)*" -File |
  Set-AzureStorageBlobContent -Container $containerName `
                              -Context $context `
                              -Force

Get-AzureStorageBlob -Container $containerName -Context $context |
  Select-Object Name

#endregion Uploading files

#region Downloading files
<#-------------------------------------------------------------------- 
   Downloading content from Azure Storage

   To download files you will need to have a context object, and 
   to get that, we'll need the storage account key.
--------------------------------------------------------------------#>
$resourceGroupName = 'PSDev'
$storageAccountName = 'acpsdemo1'
$storageAccountKey = $(Get-AzureRmStorageAccountKey `
                         -ResourceGroupName $resourceGroupName `
                         -Name $storageAccountName `
                      ).Value[0]

$context = New-AzureStorageContext `
             -StorageAccountName $storageAccountName `
             -StorageAccountKey $storageAccountKey

# Set the name of the container with what we want to download
$containerName = 'podcastimages'

# Set the path for our download
$destinationPath = "$($env:OneDrive)\Pluralsight\Azure\downloads\"

# For demo purposes, clean out the downloadfolder and show it empty
Remove-Item "$destinationPath\*"
Get-Item "$destinationPath\*"

# Load an array of blob objects
$blobs = Get-AzureStorageBlob -Container $containerName `
                              -Context $context 

# Loop over each blob in the array and downlaod it. 
# Use -Force to automatically overwrite all files, otherwise it will
# prompt you for each one.
foreach ($blob in $blobs)
{
  "Downloading $($blob.Name)"
  Get-AzureStorageBlobContent -Blob $blob.Name `
                              -Container $ContainerName `
                              -Destination $destinationPath `
                              -Context $context `
                              -Force
}

# Show the downloaded files
Get-Item "$destinationPath\*"

# Did you know you can open explorer from PowerShell?
Explorer $destinationPath

#endregion Downloading files

#region Copying files betwen containers
<#-------------------------------------------------------------------- 
   We can also copy from one container to another. Let's setup a 
   second containter in the same storage account as our target
--------------------------------------------------------------------#>
$containerName = 'podcastimages'
$containerNameStaging = 'podcastimagesstaging'

# If the container doesn't exist, create it
$containerStaging = Get-AzureStorageContainer `
                      -Name $containerNameStaging `
                      -Context $context `
                      -ErrorAction SilentlyContinue
if ($containerStaging -eq $null)
{
  New-AzureStorageContainer -Name $containerNameStaging `
                            -Context $context `
                            -Permission Blob
}

# Get the key to the staging area
$storageAccountKeyStaging = $(Get-AzureRmStorageAccountKey `
                                -ResourceGroupName $resourceGroupName `
                                -Name $storageAccountName `
                             ).Value[0]
 
# Get the context for our source
$srcContext = New-AzureStorageContext  `
                –StorageAccountName $storageAccountName `
                -StorageAccountKey $storageAccountKey  
 
# Get the context for our destination
$destContext = New-AzureStorageContext  `
                 –StorageAccountName $storageAccountName `
                 -StorageAccountKey $storageAccountKeyStaging 

# Grab a list of the available blobs
$sourceBlobs = Get-AzureStorageBlob -Container $containerName `
                                    -Context $srcContext

# We'll get the name of the first one for this next example
$srcBlobName = $sourceBlobs[0].Name
 
Start-AzureStorageBlobCopy -SrcBlob $srcBlobName `
                           -SrcContainer $containerName `
                           -Context $srcContext `
                           -DestContainer $containerNameStaging `
                           -DestContext $destContext `
                           -Force

<#
   Start-AzureStorageBlobCopy is an asynchronus opertion. It will
   go off and do it in the background. If you want to monitor the
   progress, you can return the result into a variable, then
   pass it to Get-AzureStorageBlobCopyState
#>

# We'll get the name of the second blob for this next example
$srcBlobName = $sourceBlobs[1].Name
 
$blobState = Start-AzureStorageBlobCopy `
               -SrcBlob $srcBlobName `
               -SrcContainer $containerName `
               -Context $srcContext `
               -DestContainer $containerNameStaging `
               -DestContext $destContext `
               -Force

$blobState | Get-AzureStorageBlobCopyState

<#
   Now let's copy all of the blobs from our source to the destination
#>
$sourceBlobs = Get-AzureStorageBlob -Container $containerName `
                                    -Context $context

# Declare an empty array to store the copy status
$copyStatus = @()

# Now copy each file, capturing it's copy status into an array
foreach ($blob in $sourceBlobs)
{
  "Copying $($blob.Name) to $containerNameStaging"

  $copyStatus += Start-AzureStorageBlobCopy `
                   -SrcBlob $blob.Name `
                   -SrcContainer $containerName `
                   -Context $srcContext `
                   -DestContainer $containerNameStaging `
                   -DestContext $destContext `
                   -Force

}

# Now display the copy status of each file
foreach ($status in $copyStatus)
{
  $fileName = $status.Name
  $state = $status | Get-AzureStorageBlobCopyState
  "$fileName Copy Status: $($state.Status)"
}

# Prove it is all there
Get-AzureStorageBlob -Container $containerNameStaging `
                     -Context $context |
  Select-Object Name

#endregion Copying files betwen containers

#region Cleanup
<#-------------------------------------------------------------------- 
   Now we can cleanup so we're not taking up storage
--------------------------------------------------------------------#>

# Remove just the containers
Remove-AzureStorageContainer -Name 'podcastimagesstaging' `
                             -Context $context

Remove-AzureStorageContainer -Name 'podcastimages' `
                             -Context $context `
                             -Force   # Suppress the confirmation

# Remove the whole storage Account
Remove-AzureRmStorageAccount -ResourceGroupName 'PSDev' `
                             -Name 'acpsdemo1' `
                             -Force

# Show it's gone
Get-AzureRMStorageAccount -ResourceGroupName psdev |
  Select-Object ResourceGroupName, StorageAccountName

#endregion Cleanup