<#-----------------------------------------------------------------------------
  Install-PSAzureModule
  
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This script is Copyright (c) 2017 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 

  Notes
  This script can be used to deploy the PSAzure module to the users 
  WindowsPowershell Modules folder. 
-----------------------------------------------------------------------------#>

# This script assumes you have created a folder on your C: drive named
# PowerShell, i.e. C:\PowerShell.
# It then assumes you have placed the PSAzure-Module folder within the
# C:\PowerShell folder, and unzipped the contents into it. Thus you should
# have a folder structure of:
# C:\PowerShell
# C:\PowerShell\PSAzure-Module
# C:\PowerShell\PSAzure-Module\PSAzure
# C:\PowerShell\PSAzure-Module\PSAzure-Deploy
# C:\PowerShell\PSAzure-Module\PSAzure-Examples

# If you want to change the root location of your PowerShell scripts,
# change the $powershellScripts to match the root of your scripts folder.
# It's important you retain the PSAzure-Module structure. 

$powershellScripts = 'C:\PowerShell'

# This script assumes you have placed the module in a folder with
# the name in the $moduleFolder
$moduleFolder = 'PSAzure-Module'

# This is the name of your module, it should match the folder
# name containing the PSAzure module
$moduleName = 'PSAzure'

# Determine the location of the module. 
# Example: C:\PowerShell\PSAzure-Module
$rootLocation = "$powershellScripts\$moduleFolder"

# This sets the location of the root folder
# Example: C:\PowerShell\PSAzure-Module\PSAzure
$filesLocation = "$rootLocation\$moduleName"

# Save the current folder location
Push-Location

# Then set it to the root where the three folders from github
# were downloaded (or unzipped) to
Set-Location $rootLocation

# We assume you retained the module heirarchy as found in github
# (or the zip file). This script will load helper functions for
# installing a module
. .\PSAzure-Deploy\DeployModule.ps1

# Gets a list of files in the module folder
$files = Get-ChildItem $filesLocation

# Create an array with the full path and file name for each file
# in the modules folder
$moduleFiles = @()
foreach ($file in $files)
{
  $moduleFiles += $file.FullName  
}

# Now call the installer to copy the files into the users
# WindowsPowerShell folder inside their documents folder
# It uses a helper function from the DeployModule.ps1 script
Install-MyModule -ModuleName 'PSAzure' -Files $moduleFiles -Replace

# For verifcation, we'll call another fuction from DeployModule.ps1,
# which returns the path to the users WindowsPowerShell folder from
# inside their documents folder
$moduleLocation = Get-UserModulePath

# Now add on the folder for this specific module we're installing
$myModuleLocation = "$moduleLocation\$moduleName"

# Now just display the results of our work
Get-ChildItem $myModuleLocation

# Restore the directory the user had previously been in
Pop-Location