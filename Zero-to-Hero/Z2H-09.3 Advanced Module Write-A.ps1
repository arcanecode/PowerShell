<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Sample module to import into the advanced module demo

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# Module doesn't really do much, just used to show the module process
function Write-A()
{
  Write-Host 'A'
}

# Note this function will only be usable inside the module, because we
# don't explicitly export it in the modules main psm1 file. 
function Write-APrivate()
{
  Write-Host 'APrivate'
}



