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

# Get the path the script is executing from
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# If the module is already in memory, remove it
Get-Module Podcast-NoAgenda | Remove-Module -Force

# Import the module from the local path, not from the users Documents folder
Import-Module $here\Podcast-NoAgenda.psm1 -Force

Describe 'Get-PodcastData Tests' {

  $rssData = Get-PodcastData

  $rowNum = 0
  foreach ($podcast in $rssData)
  {
    $rowNum++
    Context "Podcast $rowNum has the correct properties" {
      # Load an array with the properties we need to look for
      $properties = ('Title', 'ShowUrl', 'EmbeddedHTML', 'Hosts', 
                     'PublicationDate', 'ImageUrl', 'AudioUrl', 'AudioLength')
      
      foreach ($property in $properties)
      { 
        It "Podcast $rowNum should have a property of $property" {
          [bool]($podcast.PSObject.Properties.Name -match $property) |
            Should -BeTrue
        }
      }
    
    } # Context 'Individual Podcast Properties' 
  } # foreach ($podcast in $rssData)

  Context 'Podcast Collection Values' {
    It 'should have at least 15 rows' {
      $rssData.Count | Should -BeGreaterOrEqual 15
    }

  } # Context 'Podcast Collection Values'

  $rowNum = 0
  foreach ($podcast in $rssData)
  {
    $rowNum++
    Context "Podcast Values for row $rowNum Episode $($podcast.Title)" {
      
      It 'ImageUrl should end with .jpg or .png' {
        $($podcast.ImageUrl.EndsWith('.jpg')) -or `
          $($podcast.ImageUrl.EndsWith('.png')) |
          Should -BeTrue
      }
    
      It 'AudioUrl should end with .mp3' {
        $podcast.AudioUrl.EndsWith('.mp3') | Should -BeTrue
      }
    
      It 'ShowUrl should contain noagendanotes' {
        $podcast.ShowUrl.Contains('noagendanotes') -or $podcast.ShowUrl.Contains('nashownotes') |
          Should -BeTrue
      }
    
      It 'Hosts should contain Adam Curry' {
        $podcast.Hosts.Contains('Adam Curry') | Should -BeTrue
      }
    
      It 'Hosts should contain John C. Dvorak' {
        $podcast.Hosts.Contains('John C. Dvorak') | Should -BeTrue
      }
    } # Context 'Podcast Values'
  } # foreach ($podcast in $rssData)

} #Describe 'Get-PodcastData' 

