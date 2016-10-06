<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Using the Simple Module

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# It is common to assemble module names into variables, makes it easier
# to move
$modulePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\'
$moduleName = 'Z2H-08-Simple-Module'

$module = "$($modulePath)$($moduleName).psm1"

# To use a module, you first need to import it
Import-Module $module

# Show list of modules in memory
Get-Module 

# Now the functions in the module are ready for your use. 
Write-One

Write-Two

# Note, if you go to the module and make a change, and reimport, it doesn't
# actually reload since it is already in memory

# Go to the Write-One function and change the return then run this code
Import-Module $module
Write-One                 # Still returns original data

# Because the module is already loaded, by default PS won't reload
# To force it to reload, you have to use the -Force switch
Import-Module -Force $module
Write-One

# Note variables in the module won't appear here
# Try to display a variable declared in the module, won't show anything
Import-Module -Force $module
"Module Variable = $scopedToModuleOnly "

# They are scoped to the module.
# To create a public variable, use "Global"
$Global:scopedGlobal 

# Globals can cause all kinds of issues. Much better to use functions
Get-ITM

Write-ITM 'Arcane Code'
Get-ITM

# Note the variable isn't available outside the module
$Script:scopedToScript 

# You can unload a module from memory
Remove-Module $moduleName
Write-One               # Now gives error

