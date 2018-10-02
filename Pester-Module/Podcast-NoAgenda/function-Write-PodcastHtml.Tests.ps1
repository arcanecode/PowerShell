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

Describe 'Write-PodcastHtml Unit Tests' -Tags 'Unit' {

  InModuleScope Podcast-NoAgenda { 

    Mock -ModuleName Podcast-NoAgenda ConvertTo-PodcastHtml {
      # Doesn't really matter what we put in here, as it's just going to get
      # output to the file and not used for anything
      return @'
    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
    </head>
    <body>
    
    <div data-role="page" id="pageone">
      <div data-role="header">
        <h1>PodcastSight - The home for the best podcast in the universe</h1>
      </div>
    
      <div data-role="main" class="ui-content">
        <h1>No Agenda Show</h1>        <div data-role="collapsible">
          <h2><img src="20160306210600_na-805-art-sm.jpg" 
               alt="No Agenda Episode Image" align="left" border="0" vspace="0" 
               width="64" height="64" hspace="15"
               >
               <p/>
               805: Mono Nuptials
          </h2>
          <ul data-role="listview">
            <li>
              <p>
No Agenda Episode 805 - "Mono Nuptials"</p>
              <p>
<b>Mono Nuptials</b></p>
              <p>
<audio src="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3" controls></audio></p>
              <p>
<a href="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3"><img src="http://adam.curry.com/enc/20160306204340_na-805-art-sm.jpg" alt="A picture named NA-805-Art-SM" align="middle" border="0" vspace="5" width="256" height="256" hspace="15"></a></p>
              <p>
Direct [<a href="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3">link</a>] to the mp3 file</p>
              <p>
ShowNotes Archive of links and Assets (clips etc) <a href="http://805.noagendanotes.com/"> 805.noagendanotes.com</a></p>
              <p>
<b>Sign Up</b> for the <a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/">newsletter</a></p>
              <p>
New: Directory Archive of Shownotes (includes all audio and video assets used) <a href="http://archive.noagendanotes.com">archive.noagendanotes.com</a></p>
              <p>
The No Agenda News Network- <a href="http://noagendanewsnetwork.com/">noagendanewsnetwork.com</a></p>
              <p>
RSS Podcast<a href="http://feed.nashownotes.com/rss.xml"> Feed</a> </p>
              <p>
Get the <a href="http://nanewsapp.com/">No Agenda News App</a> for your iPhone and iPad</p>
              <p>
Get the <a href="http://www.noagendroid.com/">NoAgendDroid app</a> for your Android Phone</p>
              <p>
<a href="http://bitlove.org/adamc1999/noagenda">Torrents</a> of each episode via BitLove</p>
              <p>
IPFS Hash for the mp3: QmQPd2KRqQab3qXF3ZdNonBDGRKVPQtfN67GWna2fKFfsa </p>
              <p>
BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I</p>
              <p>
<font size= -1><script>document.write("Last Modified " + document.lastModified)</script></font><br><a href="http://freedomcontroller.com"><font size= -2>This page created with the FreedomController</font></a></p>
              <p>
Credits</p>
              <p>
<b>Mono Nuptials</b></p>
              <p>
Executive Producer: Sir Bruce Willke</p>
              <p>
Associate Executive Producers: Mark Hall, Burton Rosenberger, Dame Sam Menner, Christopher Gray, Ben Smith, Black Knight Ara Derderian, Sir Dr. Sharkey, Sir Philip Meason-Baron of Wales, Mark Klein</p>
              <p>
Become a member of the 806 Club, support the show <a href="http://dvorak.org/na">here</a></p>
              <p>
<b>Sign Up</b> for the <a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/">newsletter</a></p>
              <p>
Titles: Sir Chad Biederman -> Baron of Guam</p>
              <p>
Art By: <a href="http://noagendaartgenerator.com/artist/412">sub7zero</a></p>
              <p>
ShowNotes Archive of links and Assets (clips etc) <a href="http://805.noagendanotes.com/"> 805.noagendanotes.com</a></p>
              <p>
New: Directory Archive of Shownotes (includes all audio and video assets used) <a href="http://archive.noagendanotes.com/">archive.noagendanotes.com</a></p>
              <p>
The No Agenda News Network- <a href="http://noagendanewsnetwork.com/">noagendanewsnetwork.com</a></p>
              <p>
RSS Podcast<a href="http://feed.nashownotes.com/rss.xml"> Feed</a> </p>
              <p>
Get the <a href="http://nanewsapp.com/">No Agenda News App</a> for your iPhone and iPad</p>
              <p>
Get the <a href="http://www.noagendroid.com/">NoAgendDroid app</a> for your Android Phone</p>
              <p>
<a href="http://bitlove.org/adamc1999/noagenda">Torrents</a> of each episode via BitLove</p>
              <p>
IPSH: QmQPd2KRqQab3qXF3ZdNonBDGRKVPQtfN67GWna2fKFfsa </p>
              <p>
<b>New!</b> <a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/">BitTorrent Sync</a> the No Agenda Show</p>
              <p>
<font size= -1><script>document.write("Last Modified " + document.lastModified)</script></font><br><a href="http://freedomcontroller.com"><font size= -2>This page created with the FreedomController</font></a></p>
              <p>
Keywords</p>
              
            </li>
          </ul>
        </div>
  
  </div>

  <div data-role="footer">
    <h3><a href="http://noagendashow.com">http://noagendashow.com</a></h3>
  </div>
</div> 

</body>
</html>

'@
    } # Mock ConvertTo-PodcastXml 

    # Since we're mocking, no need to have any real rssData to pass in
    $rssData = '' 

    # Pretend to get the XML data from the ConvertTo-PodcastXml function
    $htmlData = ConvertTo-PodcastHtml -PodcastData $rssData

    Write-PodcastHtml -HtmlData $htmlData `
                      -HtmlPathFile "$($TestPath)$('NoAgendaTest.html')"
    
    It 'should have created NoAgenda.html' {
      "$($TestPath)$('NoAgendaTest.html')" | Should -Exist
    }

  } # InModuleScope Podcast-NoAgenda 

} # Describe 'Write-PodcastHtml Unit Tests' -Tags 'Unit'

Describe 'Write-PodcastHtml Acceptance Tests' -Tags 'Acceptance' {

  InModuleScope Podcast-NoAgenda { 

    # Get rss data
    $rssData = Get-PodcastData

    # Convert it to Html
    $htmlData = ConvertTo-PodcastHtml -PodcastData $rssData

    # Unfortunately, to be able to test the default OutputPathFolder from the
    # function, we have to hard code it here    
    $defaultOutputPathFolder = 'C:\PowerShell\Podcast-Data\'
    
    # Put default path file in a variable for clarity
    $defaultHtmlPathFile = "$($defaultOutputPathFolder)$('NoAgenda.html')"

    # Delete the file if it was leftover from a previous test. The
    # silently continue will suppress any errors in case the file isn't there
    Remove-Item $defaultHtmlPathFile -ErrorAction SilentlyContinue
    
    # Use the default output path
    Write-PodcastHtml -HtmlData $htmlData 

    It 'should have created NoAgenda.html in the default output path' {
      $defaultHtmlPathFile | Should -Exist
    }

    # Test with non-default path
    $nonDefaultHtmlPathFile = "$($defaultOutputPathFolder)$('NoAgendaTest.html')"

    Remove-Item $nonDefaultHtmlPathFile -ErrorAction SilentlyContinue

    Write-PodcastHtml -HtmlData $htmlData `
                      -HtmlPathFile $nonDefaultHtmlPathFile

    It "should have created $nonDefaultHtmlPathFile" {
      $nonDefaultHtmlPathFile | Should -Exist
    }

    # Cleanup after ourselves
    Remove-Item $nonDefaultHtmlPathFile -ErrorAction SilentlyContinue

  } # InModuleScope Podcast-NoAgenda 

} # Describe 'Write-PodcastHtml Acceptance Tests' 
