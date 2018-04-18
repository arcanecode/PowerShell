<#-----------------------------------------------------------------------------
  Create-ProfileContext.ps1

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 

  Notes
  This script will create a context file which can then be used to login
  to Azure automatically.
-----------------------------------------------------------------------------#>

# Path to demos - Set this to where you want to store your code
$dir = "C:\PowerShell\PSAzure-Module\PSAzure-Examples"
Set-Location $dir

# First login manually
Connect-AzureRmAccount

# Now save your context locally (Force will overwrite if there)
$path = "$dir\ProfileContext.ctx"
Save-AzureRmContext -Path $path -Force

# Show it is there
Get-Childitem $path

# Note: The Connect-PSToAzure will look for the context file if you do
# not pass in a path. See the help text for the Connect-PSToAzure function
# in the PSAzure-Login.ps1 script for more information.