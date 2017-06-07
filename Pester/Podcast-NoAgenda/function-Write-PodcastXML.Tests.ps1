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

Get-Module Podcast-NoAgenda | Remove-Module -Force
Import-Module $here\Podcast-NoAgenda.psm1 -Force

Describe 'Write-PodcastXML Unit Tests' -Tags 'Unit' {

  InModuleScope Podcast-NoAgenda { 

    # Mocking will let us replace the ConvertTo-PodcastXml function in the
    # module with the Mock below
    Mock -ModuleName Podcast-NoAgenda ConvertTo-PodcastXml {
      # Create an empty array then add each line to it, just as 
      # the real function would
      $retVal = @() 

      $retVal += @'
<Shows>
'@
      $retVal += @'
    <Show>
      <Title>805: Mono Nuptials</Title>
      <Link>http://805.noagendanotes.com</Link>
      <Hosts>Adam Curry & John C. Dvorak</Hosts>
      <PublicationDate>Sun, 06 Mar 2016 21:07:27 GMT</PublicationDate>
      <ImageURL>http://adam.curry.com/enc/20160306210600_na-805-art-sm.jpg</ImageURL>
      <ImageFileName>20160306210600_na-805-art-sm.jpg</ImageFileName>
      <AudioURL>http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3</AudioURL>
      <AudioFileName>NA-805-2016-03-06-Final.mp3</AudioFileName>
      <AudioFileLength>135988781</AudioFileLength>
    </Show>
'@
      $retVal += @'
    <Show>
      <Title>804: Evidence Free Zone</Title>
      <Link>http://804.noagendanotes.com/</Link>
      <Hosts>Adam Curry & John C. Dvorak</Hosts>
      <PublicationDate>Thu, 03 Mar 2016 21:01:33 GMT</PublicationDate>
      <ImageURL>http://adam.curry.com/enc/20160303210009_na-804-art-sm.jpg</ImageURL>
      <ImageFileName>20160303210009_na-804-art-sm.jpg</ImageFileName>
      <AudioURL>http://mp3s.nashownotes.com/NA-804-2016-03-03-Final.mp3</AudioURL>
      <AudioFileName>NA-804-2016-03-03-Final.mp3</AudioFileName>
      <AudioFileLength>120827149</AudioFileLength>
    </Show>
'@
      $retVal += @'
</Shows>
'@
      return $retVal
    } # Mock ConvertTo-PodcastXml 

    # Since we're mocking, no need to have any rssData (real or fake) to pass in
    $rssData = '' 

    # Pretend to get the XML data from the ConvertTo-PodcastXml function
    # Instead of calling the real function, it will call our mock one
    $xmlData = ConvertTo-PodcastXml -PodcastData $rssData

    # Write it out using a parameter
    Write-PodcastXML -XMLData $xmlData `
                     -XMLFilePath "$($TestPath)$('NoAgendaParameter.xml')"
    
    It 'Unit Test should have created NoAgendaParameter.xml from a parameter' {
      "$($TestPath)$('NoAgendaParameter.xml')" | Should Exist
    }

    # Write it out using pipelining   
    It 'Unit Test should have created NoAgendaPipeline.xml from the pipeline' {
      $xmlData | Write-PodcastXML -XMLFilePath "$($TestPath)$('NoAgendaPipeline.xml')"
      "$($TestPath)$('NoAgendaPipeline.xml')" | Should Exist
    }
  } # InModuleScope Podcast-NoAgenda 

} # Describe 'Write-PodcastXML Unit Tests' -Tags 'Unit'

Describe 'Write-PodcastXML Acceptance Tests' -Tags 'Acceptance' {

  InModuleScope Podcast-NoAgenda { 

    $rssData = Get-PodcastData

    # Get the XML data from the ConvertTo-PodcastXml function
    $xmlData = ConvertTo-PodcastXml -PodcastData $rssData

    # Unfortunately, to be able to test the default OutputPathFolder from the
    # function, we have to hard code it here    
    $defaultOutputPathFolder = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Data\'

    # Remove the default if it was out there from a previous run
    # (use SilentlyContinue to suppress any errors if it doesn't already exit)
    $defaultXmlFilePath = "$($defaultOutputPathFolder)NoAgenda.xml"
    
    Remove-Item $defaultXmlFilePath `
                -ErrorAction SilentlyContinue

    Context 'Write-PodcastXML Acceptance Tests Validate files written' { 
      Write-PodcastXML -XMLData $xmlData
      It 'Acceptance Test should have created NoAgenda.xml using the default output file name' {
        $defaultXmlFilePath | Should Exist
      }
      
      Write-PodcastXML -XMLData $xmlData `
                       -XMLFilePath "$($defaultOutputPathFolder)$('NoAgendaParameter.xml')"    
      It 'Acceptance Test should have created NoAgendaParameter.xml from a parameter' {
        "$($defaultOutputPathFolder)$('NoAgendaParameter.xml')" | Should Exist
      }
      
      $xmlData | Write-PodcastXML -XMLFilePath "$($defaultOutputPathFolder)$('NoAgendaPipeline.xml')"    
      It 'Acceptance Test should have created NoAgendaPipeline.xml from the pipeline' {
        "$($defaultOutputPathFolder)$('NoAgendaPipeline.xml')" | Should Exist
      }
    } # Context 'Write-PodcastXML Acceptance Tests Validate files written'

    # Now read in the XML file that was written and ensure it has everything
    [xml]$xmlNA = Get-Content $defaultXmlFilePath
    
    foreach($show in $xmlNA.Shows.Show)
    {
      Context "Testing XML Values for Show $($show.Title)" { 
        foreach($podcast in $rssData)
        {
          if ($podcast.Title -eq $show.Title)
          {
            It "Podcast Title $($podcast.Title) should equal XML Title $($show.Title)" {
              $podcast.Title.Contains($show.Title) | Should Be $true
            }

            It "Podcast ShowUrl $($podcast.ShowUrl) should equal XML ShowUrl $($show.ShowUrl)" {
              $podcast.ShowUrl.Contains($show.ShowUrl) | Should Be $true
            }

            It "Podcast Hosts $($podcast.Hosts) should equal XML Hosts $($show.Hosts)" {
              $podcast.Hosts.Contains($show.Hosts) | Should Be $true
            }

            It "Podcast PublicationDate $($podcast.PublicationDate) should equal XML PublicationDate $($show.PublicationDate)" {
              $podcast.PublicationDate.Contains($show.PublicationDate) | Should Be $true
            }

            It "Podcast ImageUrl $($podcast.ImageURL) should equal XML ImageUrl $($show.ImageURL)" { 
              $podcast.ImageURL.Contains($show.ImageURL) | Should Be $true
            }

            It "Podcast AudioUrl $($podcast.AudioURL) should equal XML ImageUrl $($show.AudioURL)" {
              $podcast.AudioURL.Contains($show.AudioURL) | Should Be $true
            }
            
            It "Podcast AudioLength $($podcast.AudioLength) should equal XML AudioFileLength $($show.AudioFileLength)" {
              $($podcast.AudioLength) -eq $($show.AudioFileLength) | Should Be $true
            }
          
          }
        } # foreach($podcast in $rssData)
      } # Context "Testing XML Values for Show $($xmlNA.Shows.Show)"
    } #foreach($show in $xmlNA.Shows.Show)


  } # InModuleScope Podcast-NoAgenda 

} # Describe 'Write-PodcastXML Acceptance Tests' 

