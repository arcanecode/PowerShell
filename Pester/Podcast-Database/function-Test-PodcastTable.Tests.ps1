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

Describe 'Test-PodcastTable Tests' {

  InModuleScope Podcast-Database {

    $podcastSightExists = Confirm-PodcastDbExists 
    It 'PodcastSight should exist in order to do this test' {
      $podcastSightExists | Should Be $true
    }
    
    # Only do the rest of the tests if the db exists, otherwise fail them all 
    if ($podcastSightExists -eq $true)
    { 
      $stagingExists = Confirm-PodcastTableExists -DatabaseName 'PodcastSight' `
                                                  -TableName 'Staging'
      It 'independant confirmation that staging exists' {
        $stagingExists | Should Be $true
      }
  
      It 'default database name, Staging should be present' {
        $(Test-PodcastTable -PodcastTableName 'Staging') | Should Be $true
      }

      It 'default database name, dbo.Staging should be present' {
        $(Test-PodcastTable -PodcastTableName 'dbo.Staging') | Should Be $true
      }

      It 'named database name, Staging should be present' {
        $(Test-PodcastTable -PodcastDatabaseName 'PodcastSight' `
                            -PodcastTableName 'Staging') |
          Should Be $true
      }

      It 'named database name, dbo.Staging should be present' {
        $(Test-PodcastTable -PodcastDatabaseName 'PodcastSight' `
                            -PodcastTableName 'dbo.Staging') |
          Should Be $true
      }

      # Get a table name that doesn't exist
      $rootTableName = 'DontExist'
      $testTableName = ''
      for($i=1; $i -le 100; $i++)
      {
        $testTableName = $rootTableName + $i.ToString()
        $exists = Confirm-PodcastTableExists -DatabaseName 'PodcastSight' `
                                             -TableName $testTableName
        if ($exists -eq $false)
        { break }      
      } # for($i=1; $i -le 100; $i++)

      It "table name $testTableName should not exist" {
        $(Test-PodcastTable 'PodcastSight' $testTableName) | Should Be $false
      }

    } # if ($podcastSightExists -eq $true)

  } # InModuleScope Podcast-Database 

}
