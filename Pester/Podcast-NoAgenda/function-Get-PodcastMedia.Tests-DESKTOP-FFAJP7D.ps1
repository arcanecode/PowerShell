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

Describe 'Get-PodcastMedia Unit Tests' -Tags 'Unit' {

  InModuleScope Podcast-NoAgenda { 

    # See the notes in function-GetPodcastImage.Tests for how the mock data works  
    # Also note, due to the size of the podcast files for unit testing the mocked data
    # has been reduced to just two podcasts in order to save download bandwidth and time
    $mockRssData = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>PodcastSight.Podcast</T>
      <T>System.Management.Automation.PSCustomObject</T>
      <T>System.Object</T>
    </TN>
    <MS>
      <S N="Title">814: Produce &amp; Pipelines</S>
      <S N="ShowUrl">http://814.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 814 - "Produce &amp; Pipelines"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Produce &amp; Pipelines&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-814-2016-04-07-final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-814-2016-04-07-final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160407193233_na-814-art-sm.jpg" alt="A picture named NA-814-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-814-2016-04-07-final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://814.noagendanotes.com/"&gt; 814.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmXYDEQwC6gikA9enYxkQ21HtUua2bs1ziE2chW5g7pm4i &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Produce &amp; Pipelines&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Thor Odelsting, Sir Henry P. Biglin, Jing Yu, Sir Smilesalot Ryan Merritt, Craig Lucca, Daniel J Franco&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Sander Hoksbergen Baron of the Alps, JQ, Ron Nooren, Sean Regalado&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 814 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Paul Webb -&gt; Sir Paul of Twickenham&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/4"&gt;Patrick Buijs&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://814.noagendanotes.com/"&gt; 814.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmXYDEQwC6gikA9enYxkQ21HtUua2bs1ziE2chW5g7pm4i &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 07 Apr 2016 19:59:48 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160407195815_na-814-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-814-2016-04-07-final.mp3</S>
      <S N="AudioLength">123349429</S>
    </MS>
  </Obj>
  <Obj RefId="1">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">813: Clinton Condign</S>
      <S N="ShowUrl">http://813.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 813 - "Clinton Condign"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Clinton Condign&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-813-2016-04-03-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-813-2016-04-03-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160403181111_na-813-art-sm.jpg" alt="A picture named NA-813-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-813-2016-04-03-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://813.noagendanotes.com/"&gt; 813.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmYTHCRUrbmaqC1v7buGT25W8Mn2UFvmvsFugaHeRctCMA &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Clinton Condign&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Dam Astrid Duchess of Tokyo&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 814 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Lu the Shoe -&gt; Sir Lu The Shoe&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/668"&gt;Sir_Sluf&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://813.noagendanotes.com/"&gt; 813.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmYTHCRUrbmaqC1v7buGT25W8Mn2UFvmvsFugaHeRctCMA &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 03 Apr 2016 18:31:43 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160403183034_na-813-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-813-2016-04-03-Final.mp3</S>
      <S N="AudioLength">112311070</S>
    </MS>
  </Obj>
</Objs>
'@
  
    $rssData = [System.Management.Automation.PSSerializer]::DeserializeAsList($mockRssData)
    
    <#--------------------------------------------------------------------------------------------------- 
       For the first set of tests, we will call the function using an empty folder. The first will test 
       calling using the parameter, the second using a parameter. 
      
       Since these are virtually identical, we'll use a simple loop and call the tests, just altering 
       the call and the folder name
    ---------------------------------------------------------------------------------------------------#>
    $loops = 'parameter', 'pipeline'
    foreach ($loop in $loops)
    { 
      Context "Get-PodcastMedia Unit Test using the $loop" { 
        $testDriveFolder = "$($TestDrive)\$($loop)\"
        New-Item $testDriveFolder -ItemType directory
        
        # The function calls Test-Path, we should Mock it
        # Since this is an empty folder, Test-Path should always return false
        Mock Test-Path { return $false }

        if ($loop -eq 'parameter')                             # Execute the function using a parameter
          { 
            $downloadedMedia = Get-PodcastMedia -rssData $rssData `
                                                -OutputPathFolder $testDriveFolder `
                                                -Verbose 
          }
        else                                                   # Execute the function using the pipeline
          { 
            $downloadedMedia = $rssData |
              Get-PodcastMedia -OutputPathFolder $testDriveFolder -Verbose 
          }

        foreach ($podcast in $rssData)
        {
          $audioFileName = $podcast.AudioUrl.Split('/')[-1]
          $outFileName = "$($testDriveFolder)$($audioFileName)"
        
          It "should have downloaded podcast $audioFileName " {
            $outFileName | Should Exist
          }
        
          It "$audioFileName should have a length of $($podcast.AudioLength)" {
            $mp3File = Get-ChildItem $outFileName
            $mp3File.Length.ToString() | Should Match $podcast.AudioLength
          }
        } # foreach ($podcast in $rssData)
      } # Context "Get-PodcastMedia Unit Test using the $loop"
    } #     foreach ($loop in $loops)

    <#--------------------------------------------------------------------------------------------------- 
       In the second set of tests, we will fake an existing file, so that it will trigger the do not 
       download flag within the function. This will let us know it is correctly skipping over files 
       to preserve our bandwidth
    ---------------------------------------------------------------------------------------------------#>
    $loops = 'parameter', 'pipeline'
    foreach ($loop in $loops)
    { 
      Context "Unit Test Get-PodcastMedia $loop test with existing files" {
        # Because the TestDrive won't get cleared out between context calls we'll
        # just create a subfolder for each test and put the files there
        $testDriveFolder = "$($TestDrive)\$($loop)Exist\"
        New-Item $testDriveFolder -ItemType directory

        # Since we only have two podcasts in the mock data, use the first one as our 'existing' one
        $existingFiles = @()
        $existingFiles += $($rssData[0].AudioURL.Split('/')[-1])
        
        # If you want to use the full mocked data array, after you copy the mockdata assignment from
        # the podcast images test remove the line above and uncomment the next two lines
        #for ($x = 0; $x -lt 7; $x += 1) 
        #  { $existingFiles += $($rssData[$x].ImageURL.Split('/')[-1]) }
        
        <#
            Next we need to mock Test-Path, to fake the existance of one or more files. This triggers the
            functions do not d/l me logic so we can test it. 
           
            Note we don't want to actually create files, we just need to have our fake Test-Path tell 
            the Get-PodcastImage function they exist so it will not download them. We'll use the 
            non-existance of the file in one of our tests.
        #>
        Mock Test-Path {
          # Note the Mock automatically adds the $path variable based on the
          # signature of Test-Path, i.e. its -Path parameter
          $fileName = $path.Split('\')[-1]
          if ($fileName -in $existingFiles)
          { $retValue = $true }
          else
          { $retValue = $false }
          return $retValue 
        }

        if ($loop -eq 'parameter')                             # Execute the function using a parameter
        { 
          $downloadedMedia = Get-PodcastMedia -rssData $rssData `
          -OutputPathFolder $testDriveFolder `
          -Verbose 
        }
        else                                                   # Execute the function using the pipeline
        { 
          $downloadedMedia = $rssData |
          Get-PodcastMedia -OutputPathFolder $testDriveFolder -Verbose 
        }
        
        # In this test ensure the files that it reported as downloaded were in fact downloaded
        foreach ($audioFile in $downloadedMedia)
        {
          $outFileName = "$($testDriveFolder)$($audioFile)"
        
          It "should have downloaded podcast $audioFile " {
            $outFileName | Should Exist
          }        
        } # foreach ($podcast in $rssData)

        # For the files that are supposed to already exist, we'll do two tests
        foreach ($audioFile in $existingFiles)
        {
          # First, we'll make sure the supposedly existing file was not reported as downloaded
          It "$audioFile should not exist in the list of downloaded media" {
            [bool]($audioFile -in $downloadedImages) | Should Be $false
          }
     
          # Next, we will make sure the file DOESN'T exist. In otherwords,
          # since it wasn't supposed to download, we'll make sure it didn't
          $outFileName = "$($testDriveFolder)$($audioFile)"
          It "$audioFile should not have been downloaded, and thus should not exist" {
            $outFileName | Should Not Exist
          }
        } # foreach ($audioFile in $existingFiles)

      } # Context "Unit Test Get-PodcastMedia $loop test with existing files" {
    } # foreach ($loop in $loops)

  } # InModuleScope Podcast-NoAgenda

} # Describe 'Get-PodcastMedia Unit Tests' 



Describe 'Get-PodcastMedia Acceptance Tests' -Tags 'Acceptance' {

  InModuleScope Podcast-NoAgenda { 

    # For acceptance we call the real function
    $rssData = Get-PodcastData
    
    <#
       The only difference in our tests is:
         1. The path to which things are downloaded to and
         2. The way in which Get-PodcastImage is called. 
       To keep from having a lot of repetitive code, the output folders are placed into a hash table, 
       which is iterated over. The name is used in a switch to control which method to call 
       Get-PodcastImage. The value is used for the folder to test in
    #>

    $root = 'C:\PS\Pester-course\demo\completed-final-module\'
    $tests = @{ 'default parameter' = "$($root)Podcast-Data\";
                'default pipeline'  = "$($root)Podcast-Data\";
                'nondefault parameter' = "$($root)Podcast-Test\";
                'nondefault pipeline'  = "$($root)Podcast-Test\";
              }

    <#
       Note to iterate over a hash table, you have to use GetEnumerator to pop off each individual 
       entry in the hash table. Each entry will have two values, the Name (left side of =), 
       and the Value (right side of =)
    #>
    foreach($test in $tests.GetEnumerator())
    {
      $folder = $test.Value 

      # Get a list of images already present
      $existingMedia = Get-ChildItem "$($folder)*" -Include *.mp3 | Select-Object Name
      
      # Call Get-PodcastImage based on which test we are running for
      switch ($test.Name)
      {
        'default parameter'    
          { $downloadedMedia = Get-PodcastMedia -rssData $rssData }
        'default pipeline'     
          { $downloadedMedia = $rssData | Get-PodcastMedia }
        'nondefault parameter' 
          { $downloadedMedia = Get-PodcastMedia -rssData $rssData -OutputPathFolder $folder }
        'nondefault pipeline'  
          { $downloadedMedia = $rssData | Get-PodcastMedia -OutputPathFolder $folder }
      } # switch ($test.Name)
      
      # Use split to reduce the test name to either default or nondefault and parameter or pipeline.
      # We'll use them in the context and test names to reduce their length
      $dlFolder = $test.Name.Split(' ')[0]
      $pipeParam = $test.Name.Split(' ')[1]

      Context "Acceptance Test Get-PodcastMedia $pipeParam test to $dlFolder folder" { 
        foreach ($podcast in $rssData)
        {
          $audioFileName = $podcast.AudioUrl.Split('/')[-1]
          $outFileName = "$($folder)$($audioFileName)"
        
          It "File $audioFileName should exist in the $dlFolder" {
            $outFileName | Should Exist
          }
        
          It "$audioFileName should have a length of $($podcast.AudioLength)" {
            $mp3File = Get-ChildItem $outFileName
            $mp3File.Length.ToString() | Should Match $podcast.AudioLength
          }
        } # foreach ($podcast in $rssData)
      
        # Make sure downloaded media wasn't in the list of existing ones
        foreach ($mp3 in $downloadedMedia)
        {
          It "should have downloaded $mp3" {
            [bool]($mp3 -in $existingMedia) | Should Be $false
          }
        }

      } # Context 'Get-PodcastMedia Acceptance Test pipeline'

      # Remove the podcasts that were just downloaded so we can reset for next test
      foreach ($mp3 in $downloadedMedia)
      {
        Remove-Item "$($folder)$($mp3)" -ErrorAction SilentlyContinue
      }

    } # foreach($test in $tests.GetEnumerator())

  } # InModuleScope Podcast-NoAgenda

} # Describe 'Get-PodcastMedia Acceptance Tests' 
