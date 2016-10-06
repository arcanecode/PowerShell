<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Example of a Simple Module

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# At its simplest, a module can be just a ps1 file renamed to psm1
# with functions defined

function Write-One()
{
  Write-Output 'OneThree'
}

function Write-Two()
{
  Write-Output 'Two'
}


# Note if you declare a variable its scope is limited to the module
$scopedToModuleOnly = 'In The Morning'

# To make it everywhere you could make it global
$Global:scopedGlobal = 'In The Global Morning'

# A better solution is to us a script level variable and wrap in a function
$Script:scopedToScript = 'In The Morning!'

function Get-ITM()
{
  return $Script:scopedToScript 
}

function Write-ITM($itm)
{
  $Script:scopedToScript = $itm
}
