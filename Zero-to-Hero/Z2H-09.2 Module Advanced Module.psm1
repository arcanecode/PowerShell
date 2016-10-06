<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Advanced Module (processed by the manifest)

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# You can declare functions directly in the PSM1 file
function Write-M()
{ Write-Host 'M' }

#-----------------------------------------------------------------------------#
# Most people though organize the functions into one or more PS1 files, 
# then execute them which in turn loads them into the module
# Note your execution policy must be set appropriately to be able to do this
#-----------------------------------------------------------------------------#

#region Import Scripts

# $PSScriptRoot is a shortcut to "the current folder where the script is being 
# run from". Also note the use of . sourcing

. "$PSScriptRoot\Z2H-09.3 Advanced Module Write-A.ps1"
. "$PSScriptRoot\Z2H-09.4 Advanced Module Write-B.ps1"

#endregion Import Scripts


#-----------------------------------------------------------------------------#
# If you don't explicitly export module members, all functions will be visible
# outside the module. 
#
# With Export-ModuleMember, only those functions listed will be visible. Any
# not included will be private to the function. 
#
# It is considered a best practice to explictly export the functions you want
# visible. 
#-----------------------------------------------------------------------------#

#region Export Module Members

Export-ModuleMember Write-A
Export-ModuleMember Write-B
Export-ModuleMember Write-M

# Note, because we don't export Write-APrivate 
# (from bpsd-m05-module-advanced-functions-A.ps1), 
# it won't be usable outside the module

#endregion Export Module Members
