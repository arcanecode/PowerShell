<#--------------------------------------------------------------------
  Get-Azure
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          https://arcanecode.com | https://github.com/arcanecode
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights 
  reserved. No warranty or guarentee is implied or expressly granted. 

  All information was accurate at the time of the demo creation. Note
  that things are changing very rapidly in the world of Azure in 
  general and Azure's PowerShell modules in particular, so be sure
  to check Microsoft online documentation for the latest information.
  
  The purpose of this module is to demonstrate the installation of
  the Azure PowerShell module.

  Note that there are actuall two methods of accessing Azure, 
  ASM (Azure Service Management) and ARM (Azure Resource Manager). 
  ASM is going to be retired, replaced by ARM. Thus for all demos
  we'll be using the ARM version of modules and cmdlets. 
--------------------------------------------------------------------#>

# Getting Azure
$PSVersionTable # Confirm on version 5

<#
   PowerShell 5 implemented a new module called Package Mangement 
   (Formerly known as OneGet). This makes it easy to download updates
   of various PowerShell modules, most notably Pester
#>
Import-Module PackageManagement

# Display the commands in PackageManagement
Get-Command -Module PackageManagement

# Shows the package in the repository 
# (If prompted to install nuget, say yes)
Find-Package AzureRM

# See if a version is already installed
Get-Module AzureRM -ListAvailable 

<#
   If you have installed PowerShell Azure Module previously via the 
   Microsoft Web Installer, consider removeing it using the
   Windows Add / Remove programs feature. If installed via PowerShell,
   use Uninstall-Module Azure.

   While it is possible to have both, you can get into some side 
   effects from time to time.
   
   If you decide to remove the original Azure module, after removing 
   it, then return here to install AzureRM from the PSGallery.
#>

<# 
  Installing Azure is a two step process. First you need to install
  the module itself. Once the module is installed, you need to run
  the Install-AzureRM cmdlet to install of the various components.

  If you have the older Azure module installed, there are some 
  overlapping names. You need to append -AllowClobber in order to
  get AzureRM installed, so it may "clobber" and take precedence
  over the older module. 
#>
Install-Module AzureRM -Force -AllowClobber

# Once you have installed the latest, hereafter you can 
# use Update-Module to keep it up to date. 
Update-Module AzureRM -Force

# Show stats about AzureRM
Get-Module AzureRM