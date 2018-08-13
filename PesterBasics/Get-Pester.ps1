<#-----------------------------------------------------------------------------
  PowerShell Testing with Pester

  This sample code is part of a series of articles entitled 
  
  "Pester the Tester - Testing PowerShell Code"
  
  located on RedGate's SimpleTalk website. You can find all of the authors 
  articles at: http://arcanecode.red

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.me
 
  This code module is Copyright (c) 2018 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 

  This code may not be reproduced in whole or in part without the express
  written consent of the author. You may use it within your own projects.

  The code in this file shows how to install Pester from the PSGallery when
  running on PowerShell 5.x. If you are on a different version of PowerShell,
  see the installation instructions on the Pester github repository at:
  https://github.com/pester/Pester/wiki/Installation-and-Update 
-----------------------------------------------------------------------------#>

# Getting Pester. First, confirm we are on version 5.x
$PSVersionTable 

# If you are on a version prior to 5, you will need to manually install it
# using the instructions on Pester's GitHub site.
# https://github.com/pester/Pester

<#
  PowerShell 5 implemented a new module called Package Mangement (Formerly known
  as OneGet). This makes it easy to download updates of various PowerShell 
  modules, most notably Pester. (Note, you don't have to explicitly import in 
  your projects, PowerShell will autoload a module. For demo purposes thogh 
  it just documents it well.)
#>
Import-Module PackageManagement

# Display the commands in PackageManagement
Get-Command -Module PackageManagement

# Shows the package in the repository (If prompted to install nuget, say yes)
Find-Package Pester

# See the version you have installed, if any
Get-Module Pester -ListAvailable

<# 
  Installing Pester
  First, make sure you are running PowerShell as an admin!
  By default 3.3.x ships with Windows 10. To install the latest 
  you have to use the -Force switch. (If it's not installed, using
  -Force won't have a negative impact)

  Also, we need the SkipPublisherCheck, as the preinstalled version
  is was signed using a different certificate than the one in the
  PowerShell Gallery, thus it'll error unless we include the switch.
  (If it's not installed using the switch won't raise an issue.)
#>
Install-Module Pester -Force -SkipPublisherCheck

# Verify what you now have installed
Get-Module Pester -ListAvailable

# Once you have installed the latest, hereafter you can 
# use Update-Module to keep it up to date. 
Update-Module Pester -Force

