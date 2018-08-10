<#-----------------------------------------------------------------------------
  PowerShell 201 - Simple script that will just 'Do Something' for
  demonstrating security rules.
 
  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2018 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 

  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# This very simple script is used to demonstrate being able
# to run scripts, work with execution policies, and the like.
#-----------------------------------------------------------------------------#

Set-Location 'C:\PowerShell\PS201'

Get-ChildItem |
  Out-GridView -Wait
