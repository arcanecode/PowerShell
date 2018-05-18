<#-----------------------------------------------------------------------------
  Demonstrates how to get options for configuring an Azure VM

  Author
    Robert C. Cain | @ArcaneCode | info@arcanetc.com | http://arcanecode.me
 
  Details
    When creating a virtual machine in Azure, there are several pieces of
    information you have to gather. First, you need the publisher, the 
    company or organization that created the virtual machine image that 
    is used in the creation of the Azure VM.

    Each publisher has multiple images it offers. For example, Microsoft
    offers SQL Server, SharePoint, and more. So determining which image
    is the next step.

    With the basic image selected, you then need to be more specific. 
    If you had selected SQL Server for example, you need to indicate 
    SQL Server 2012, 2014, 2016, 2017, and so on. This is the offer.

    So now you have the publisher, image, and offer. Next is the SKU. 
    Let's say you selected SQL Server 2017. Do you want the Enterprise,
    Standard, Developer, or another option. This specific version of
    the offer is the SKU.

    Another option to determine is the version. You may wish to create
    a specific version of your SKU.

    Once you have determined the specific image you want, you then have
    to determine the size of the VM. Number of cores, memory etc. 

    This script demonstrates how to gather these pieces of information
    so they can be passed into the New-PSAzureVM function that is
    part of the PSAzure module. 

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

# To get a list of available VM images, we first need to supply some
# parameters to narrow things down. First is location.
$location = 'southcentralus'

# Next we need to determine the publisher.
Get-AzureRmVMImagePublisher -Location $location 

# As you can see, there's a lot! Let's limit the list down 
# to just Microsoft
Get-AzureRmVMImagePublisher -Location $location |
  Select-Object PublisherName |
  Where-Object PublisherName -Like 'Microsoft*'

# Looking at the list above, we decide we want to create a 
# Microsoft SQL Server, and hence set the publisher. 
$publisher = 'MicrosoftSQLServer'

# With that set, we now need an offer. Use this cmdlet to see what
# is available
Get-AzureRmVMImageOffer -Location $location -PublisherName $publisher

# Looking over the list, we decide SQL Server 2016 Service Pack 1
# running on Windows Server 2016 is what we need. This gives us the
# offer.
$offer = 'SQL2016SP1-WS2016'

# Each offer has different SKUs. Let's see what SKUs are available
# for this offer.
Get-AzureRmVMImageSku -Location $location `
                      -PublisherName $publisher `
                      -Offer $offer

# Now we've seen the SKUs for this image, let's use the SQL Dev one
$sku = 'SQLDEV'

# With the SKU picked, we can get a list of the specific 
# versions for the selected SKU
Get-AzureRmVMImage -Location $location `
                   -PublisherName $publisher `
                   -Offer $offer `
                   -Sku $sku

# We can capture a specific version of the SKU.
$version = '13.0.500110'

# Note, you can  use a specific version number, or in the creation
# use 'latest' to get the latest version of the VM
$version = 'latest'

# OK, so at this point we've determined what image to be used
# in creating the virtual machine. Now we need to specify what
# hardware characteristics should be used in the virtual macine.
# Things like CPU, RAM, etc. 

# Virtual machine sizes can vary by location, so we need to let
# it know where we will be creating the VM. Use the following
# cmdlet to get a list of available sizes.
Get-AzureRmVMSize -Location $location 

# You can further limit the list, for example let's just look
# at the basic machine sizes. 
Get-AzureRmVmSize -Location $location |
  Where-Object Name -like 'Basic*'

# We'll use a small one for our simple needs
$vmSize = 'Basic_A3' 

# Using the cmdlets above you've now been able to gather the
# parameters needed to create a virtual machine. To recap:
$location = 'southcentralus'
$publisher = 'MicrosoftSQLServer'
$offer = 'SQL2016SP1-WS2016'
$sku = 'SQLDEV'
$version = '13.0.500110'
$vmSize = 'Basic_A3' 
