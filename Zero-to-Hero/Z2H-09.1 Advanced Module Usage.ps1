<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Using the Advanced Module

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# Here is the path to the demo folder, and the name of the module manifest
# (update for your computer as needed)
$modulePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\'
$moduleName = 'Z2H-09.2 Module Advanced Module'

# We will import the module manifest file using the full path
$module = "$($modulePath)$($moduleName).psd1"

# To use a module, you first need to import it
Import-Module -Force $module
Get-Module

# Now the functions are available
Write-A
Write-B
Write-M

# Write-APrivate wasn't exported and hence isn't visible, causes error
Write-APrivate

# You can manually unload the module, or when your session ends it will
# be automatically be unloaded.
Remove-Module $moduleName

# Verify it is unloaded
Get-Module

# More help on modules
Get-Help about_modules

# Other about topics
Get-Help about*






#-----------------------------------------------------------------------------#
# Module Path
#-----------------------------------------------------------------------------#

# You can import modules without including the path if you store it
# in one of the default locations. To see this, look at the 
# environment variable PSModulePath
$env:PSModulePath

# We will use the 'User' location for modules. Note if you've not used
# modules before, the WindowsPowerShell\Modules\ folder may not exist, 
# so check first to see if you need to manually create. 

# Here is the path to the user folder of modules for this machine
# (if you are running on your own computer, you'll need to update for
# your computer)
$userModulePath = 'C:\Users\Arcane\Documents\WindowsPowerShell\Modules\'

# Reminder here's the original path for the demos
$modulePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\'

# Name of our module
$moduleName = 'Z2H-09.2 Module Advanced Module'

# First, we'll setup the new path for our module in the user folder,
# then create that folder
$userModulePath = "$($userModulePath)$($moduleName)" 
New-Item -ItemType directory -Force $userModulePath

# Note if you have made a lot of changes to the files (i.e. removing files 
# from the module) you may wish to clean out the directory prior to copying
Remove-Item "$($userModulePath)\*.*"

# Copy our module to the users module folder (force will overwrite if there)
Copy-Item "$($modulePath)Z2H-09*.*" `
          $userModulePath `
          -Force

# Validate the files are there
Get-ChildItem $userModulePath 

# It's not loaded into memory yet! 
Get-Module

# Now you can import the module without the path
Import-Module -Force $moduleName

# Verify it is loaded
Get-Module

# Test
Write-A
Write-B
Write-M

# Unload the module
Remove-Module $moduleName

# Verify it is unloaded
Get-Module


