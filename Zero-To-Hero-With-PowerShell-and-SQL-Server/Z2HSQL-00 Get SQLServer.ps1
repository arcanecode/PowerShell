#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Get the SqlServer Module

  Demonstrates how to install the SqlServer module in PowerShell 5.x

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This sample is part of the Zero To Hero with PowerShell and SQL Server
  pre-con. 

  This code is Copyright (c) 2017 - 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

if (1 -eq 1) { exit }  # In case I hit F5 by accident

# Shows the package in the repository 
# (If prompted to install nuget, say yes)
Find-Package SQLServer

# See if a version is already installed
Get-Module SQLServer -ListAvailable 

# If you don't have it, you can install it
Install-Module SQLServer -Force -AllowClobber

# If you do have it, you can do an update
Update-Module SQLServer -Force

# Either way confirm what we have
Get-Module SQLServer -ListAvailable 
