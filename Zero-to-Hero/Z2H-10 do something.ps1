<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Simple script that will just 'Do Something'

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# This very simple script is used to demonstrate being able
# to run scripts, work with execution policies, and the like.
#-----------------------------------------------------------------------------#

Set-Location 'C:\Users\Arcane\OneDrive\PS\Z2H'

Get-ChildItem |
  Out-GridView -Wait
