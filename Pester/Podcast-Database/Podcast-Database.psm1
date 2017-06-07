<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

Push-Location
Import-Module SQLPS -DisableNameChecking -WarningAction SilentlyContinue | Out-Null
Pop-Location

. $PSScriptRoot\function-Test-PodcastDatabase.ps1
. $PSScriptRoot\function-New-PodcastDatabase.ps1
. $PSScriptRoot\function-Test-PodcastTable.ps1
. $PSScriptRoot\function-New-PodcastTable.ps1
. $PSScriptRoot\function-Update-PodcastTable.ps1

Export-ModuleMember Test-PodcastDatabase
Export-ModuleMember New-PodcastDatabase
Export-ModuleMember Test-PodcastTable
Export-ModuleMember New-PodcastTable
Export-ModuleMember Update-PodcastTable


