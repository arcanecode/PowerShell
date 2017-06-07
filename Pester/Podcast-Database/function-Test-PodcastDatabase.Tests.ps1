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

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module Podcast-Database| Remove-Module -Force
Import-Module $here\Podcast-Database.psm1 -Force

# Import the test helper functions
. "$here\Podcast-Database-Tests-Helper-Functions.ps1"
    

Describe 'Test-PodcastDatabase Tests' {

  InModuleScope Podcast-Database {
   
    $nonexistantPodcastDbName = Find-NonexistantPodcastDbName
    It "should not find database $nonexistantPodcastDbName passed in as a parameter" {
      $(Test-PodcastDatabase $nonexistantPodcastDbName ) | Should Be $false
    }

    $existingPodcastDbName = Find-ExistingPodcastDbName    
    It "should find database $existingPodcastDbName passed in as a parameter" {
      $(Test-PodcastDatabase $existingPodcastDbName) | Should Be $true
    }

    It 'the PodcastSight database must exist to be able to test using default parameter' {
      Confirm-PodcastDbExists | Should Be $true
    }
  
    It 'should find database PodcastSight using the default parameter' {
      Test-PodcastDatabase | Should Be $true
    }

    It 'Test-PodcastDatabase should equal the result of Confirm-DatabaseExists' {
      ((Test-PodcastDatabase) -eq (Confirm-PodcastDbExists)) | Should Be $true
    }
        
  } # InModuleScope Podcast-Database

}
