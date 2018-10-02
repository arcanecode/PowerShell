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

<#
Special Note: In order to mock the Get-PodastData, we have to create a data
block which emulates the RSS feed. To do so, we'll take the data returned
by the Get-PodcastData function and export it to a file.

  $data = Get-PodcastData
  $data | Export-clixml 'C:\Temp\NoAgendaCli.xml'

Now we just open the file and paste it's content into the $mockRssDat variable
in test below. This is a one time task done when this test was created. 

Within the test, we'll need to turn the data back into a string. To do so,
the PowerShell automation framework has a class called PSSerializer. Under the
hood this is what the Import- and Export- Clixml cmdlets use. 

Here, we'll use the DeserializeAsList method in order to turn our string back
into an array of objects, similar to what our modules Get-PodcastData function
returns. 
$rssData = [System.Management.Automation.PSSerializer]::DeserializeAsList($mockedSerializedData)

We could also have chosen to use Import-Clixml and read in the 
'C:\Temp\NoAgendaCli.xml' file:

$rssData = Import-Clixml 'C:\Temp\mockdataserialized.xml'

However it is generally best to keep your tests self contained, and not reliant
on external objects as much as possible. 

While this does seem like a lot of work, it's only needed once in order to
mock the return values from our Get-PodcastData cmdlet. 
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module Podcast-NoAgenda | Remove-Module -Force
Import-Module $here\Podcast-NoAgenda.psm1 -Force

InModuleScope Podcast-NoAgenda { 

  Describe 'Get-PodcastImage Unit Tests Parameter' -Tags 'Unit' {

  
    $mockRssData = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>PodcastSight.Podcast</T>
      <T>System.Management.Automation.PSCustomObject</T>
      <T>System.Object</T>
    </TN>
    <MS>
      <S N="Title">819: non-binary person</S>
      <S N="ShowUrl">http://819.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 819 - "non-binary person"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;non-binary person&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-819-2016-04-24-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-819-2016-04-24-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160424194430_na-819-art-sm.jpg" alt="A picture named NA-819-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-819-2016-04-24-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://819.noagendanotes.com/"&gt; 819.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmPCivKWXZnJUt6tfd4fN6JjzrUFhqyQemzih2sZGv1Z1M &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;non-binary person&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://wherethecstandsfor.com"&gt;Where The C Stands For&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: James Brown, Henry Cunningham&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Nick Johannes, Ben Smith&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 820 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Nick Raimondi -&gt; Sir Raimondi&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artwork/7260"&gt;Mark G&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://819.noagendanotes.com/"&gt; 819.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmPCivKWXZnJUt6tfd4fN6JjzrUFhqyQemzih2sZGv1Z1M &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 24 Apr 2016 20:08:15 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160424200416_na-819-art-feed.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-819-2016-04-24-Final.mp3</S>
      <S N="AudioLength">127171457</S>
    </MS>
  </Obj>
  <Obj RefId="1">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">818: Document 17</S>
      <S N="ShowUrl">http://818.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 818 - "Document 17"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Document 17&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-818-2016-04-21-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-818-2016-04-21-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160421192753_na-818-art-sm.jpg" alt="A picture named NA-818-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-818-2016-04-21-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://818.noagendanotes.com/"&gt; 818.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Document 17&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://wherethecstandsfor.com"&gt;Where The C Stands For&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Dwayne Melancon Arch Duke of the Pacific Northwest, Uncle Dave&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producer: Todd Troutman&lt;/p&gt;&lt;p&gt;_x000A_Club 818 Member: Sir Dwayne Melancon Arch Duke of the Pacific Northwest&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 819 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Tim Khaner -&gt; Sir Tim, Knight of the No Agenda Roundtable&lt;/p&gt;&lt;p&gt;_x000A_Art By: Nick The Rat&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://818.noagendanotes.com/"&gt; 818.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 21 Apr 2016 19:51:33 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160421195005_na-818-art-feed.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-818-2016-04-21-Final.mp3</S>
      <S N="AudioLength">122273266</S>
    </MS>
  </Obj>
  <Obj RefId="2">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">817: Sellout Politics</S>
      <S N="ShowUrl">http://817.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 817 - "Sellout Politics"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sellout Politics&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-817-2016-04-17-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-817-2016-04-17-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160417193253_na-817-art-sm.jpg" alt="A picture named NA-817-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-817-2016-04-17-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://817.noagendanotes.com/"&gt; 817.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmR8RgVXCLjcD8AN1xGjq7hVB5Qj2d7geEvyzR1pupiATe &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sellout Politics&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://wherethecstandsfor.com"&gt;Where The C Stands For&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Stone Harriman, Sir Sean Earl of Federal Reserve District 7, James Pyers,&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Kyle Ferencz, Timnonymous, Dame Sam Menner, Jesse Simonin&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 818 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Richard Henderson -&gt; Sir Richard, Black Knight of the Foot&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Herb Lamb -&gt; Baron of Buford Dam&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/560"&gt;Mark G&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://817.noagendanotes.com/"&gt; 817.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmR8RgVXCLjcD8AN1xGjq7hVB5Qj2d7geEvyzR1pupiATe &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 17 Apr 2016 20:03:34 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160420105437_na-817-art-feed.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-817-2016-04-17-Final.mp3</S>
      <S N="AudioLength">131632256</S>
    </MS>
  </Obj>
  <Obj RefId="3">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">816: Dehydrated in China</S>
      <S N="ShowUrl">http://816.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 816 - "Dehydrated in China"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dehydrated in China&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-816-2016-04-14-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-816-2016-04-14-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160414193051_na-816-art-sm.jpg" alt="A picture named NA-816-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-816-2016-04-14-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://816.noagendanotes.com/"&gt; 816.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmbbJBys5NzEuvD69woNRtg4H9NT7T7i8eyTwphVMBneyY &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dehydrated in China&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Snrkl, Sir K-Town&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Eric Olson, Sir Barislov Marinov, Bryan Mancuso-Sir Scheister Destroyer of Cones,  Anonymous, Jonathan Rowley, iAmsterdam&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 817 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Bryan Mancuso -&gt; Sir Scheister, Destroyer of Cones, Jarrod Wolf -&gt; Sir Long Wolf of Vidor, Erik Olson -&gt; Sir Warbacon&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir K-Town -&gt; Baronet, Sir Ben Naidus -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/109"&gt;20wattbulb&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://wherethecstandsfor.com"&gt;Where The C Stands For&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://816.noagendanotes.com/"&gt; 816.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmbbJBys5NzEuvD69woNRtg4H9NT7T7i8eyTwphVMBneyY &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 14 Apr 2016 20:00:58 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160414195932_na-816-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-816-2016-04-14-Final.mp3</S>
      <S N="AudioLength">126945217</S>
    </MS>
  </Obj>
  <Obj RefId="4">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">815: Political Perp Walk</S>
      <S N="ShowUrl">http://815.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 815 - "Political Perp Walk"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Political Perp Walk&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-815-2016-04-10-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-815-2016-04-10-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160410153026_na-815-art-sm.jpg" alt="A picture named NA-815-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-815-2016-04-10-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://815.noagendanotes.com/"&gt; 815.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmXBdPu9kkiBo718SFSj6unkUUkg32UfPfChpRhgqihykb &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Political Perp Walk&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Stephen Hutto, David Killian, Jan Leclerc-Sir Kwyjiboo&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Richard Henderson, Baronet Sir Chris Speers, Sir Nick of the Southside, Sir Stewart Morrison&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 816 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: "Bright Eyes" -&gt; Black Dame Bright Eyes, Jan Leclerc -&gt; Sir Kwyjiboo (pronunciation kweejeeboo), Stewart Morrison -&gt; Sir Morrison&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Chris Speers -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/10"&gt;Nick The Rat&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://815.noagendanotes.com/"&gt; 815.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmXBdPu9kkiBo718SFSj6unkUUkg32UfPfChpRhgqihykb &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 10 Apr 2016 19:42:44 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160410194121_na-815-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-815-2016-04-10-Final.mp3</S>
      <S N="AudioLength">122169537</S>
    </MS>
  </Obj>
  <Obj RefId="5">
    <TNRef RefId="0" />
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
  <Obj RefId="6">
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
  <Obj RefId="7">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">812: Non-Disabled</S>
      <S N="ShowUrl">http://812.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 812 - "Non-Disabled"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Non-Disabled&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-812-2016-03-31-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-812-2016-03-31-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160331200715_na-812-sm.png" alt="A picture named NA-812-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-812-2016-03-31-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://812.noagendanotes.com/"&gt; 812.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmNpFfgnFMmaxU37mywzh6fHjxUrDakiGcQCVAi79vpjuh &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Non-Disabled&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Philip Pfotenhauer-Baron of Bayern (Bavaria) and Österreich (Austria), Vicountess Dame Tanya, Sir Gregory Davis&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Barislav Marinov, Anonymous, Jeremiah Treibel, Ignacio Salome, Laura Hickman&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 813 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Gregory Davis -&gt; Sir Gregory Davis, Kevin McColpin -&gt; Sir K-Mac&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Philip Pfotenhauer  -&gt; Baron of Bayern (Bavaria) and Österreich (Austria), Baroness Tanya -&gt; Viscountess, Sir Phil Rodokanakis -&gt; Sir Forensicator&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/782"&gt;Chunjee&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://812.noagendanotes.com/"&gt; 812.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmNpFfgnFMmaxU37mywzh6fHjxUrDakiGcQCVAi79vpjuh &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 31 Mar 2016 20:35:48 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160331203420_na-812-big.png</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-812-2016-03-31-Final.mp3</S>
      <S N="AudioLength">121690246</S>
    </MS>
  </Obj>
  <Obj RefId="8">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">811: Dead Men Can't Sue</S>
      <S N="ShowUrl">http://811.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 811 - "Dead Men Can't Sue"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dead Men Can't Sue&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160327154435_na-811-art-sm.jpg" alt="A picture named NA-811-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://811.noagendanotes.com/"&gt; 811.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmdZCSsfgzfj5LPZK4XtAA4YME2hKQJBP9t5dccA1XwGo5 &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dead Men Can't Sue&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Jessie Lorenz Blind Dame of the SF Bay, Sir Phillip Rodokanakis &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Matt McVader,-Knight of Edgewater, Sir Hank Scorpio of the Electrical Grid&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 812 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Douglas Chick -&gt; Sir Hank Scorpio of the Electrical Grid, Matt McVader -&gt; Sir Matt McVader, Knight of Edgewater, Phillip Rodokanakis -&gt; Sir Rodokanakis, Jessie Lorenz -&gt; Blind Dame of the SF Bay&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/10"&gt;Nick the Rat&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://811.noagendanotes.com/"&gt; 811.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:QmdZCSsfgzfj5LPZK4XtAA4YME2hKQJBP9t5dccA1XwGo5 &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 27 Mar 2016 19:58:25 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160327195705_na-811-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3</S>
      <S N="AudioLength">127537831</S>
    </MS>
  </Obj>
  <Obj RefId="9">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">810: Karmonious</S>
      <S N="ShowUrl">http://810.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 810 - "Karmonious"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Karmonious&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-810-2016-03-24-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-810-2016-03-24-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160324194240_na-810-art-sm.jpg" alt="A picture named NA-810-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-810-2016-03-24-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://810.noagendanotes.com/"&gt; 810.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmRkdeGGX1VPqYY2PmqE1f87XwjvYtMn2haC1Anqfqp6J8 &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Karmonious&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Patrick Seymour, Duke Sir Thomas Nussbaum&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Gary Bachman,  Black Knight Baron of Royal Wootton Bassett Sir Bryan Barrow&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 811 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Joe Cool Design -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/560"&gt;Mark G.&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://810.noagendanotes.com/"&gt; 810.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmRkdeGGX1VPqYY2PmqE1f87XwjvYtMn2haC1Anqfqp6J8 &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 24 Mar 2016 20:08:00 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160324200620_na-810-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-810-2016-03-24-Final.mp3</S>
      <S N="AudioLength">129302880</S>
    </MS>
  </Obj>
  <Obj RefId="10">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">809: Velocity of Money</S>
      <S N="ShowUrl">http://809.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 809 - "Velocity of Money"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Velocity of Money&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-809-2016-03-20-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-809-2016-03-20-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160320193308_na-809-art-sm.jpg" alt="A picture named NA-809-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-809-2016-03-20-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://809.noagendanotes.com/"&gt; 809.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmQ3mP2928Btak8P879xM9MXHFh1fY5YPnZ5szyfyo6wwL &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Velocity of Money&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Robert Wieda, Sir K-Town&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sandra Langston, Oystein Berge&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 810 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Robert Wieda -&gt; Knight&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Beardmaster General​ -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/657"&gt;Melvin_Gibstein&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://809.noagendanotes.com/"&gt; 809.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:QmQ3mP2928Btak8P879xM9MXHFh1fY5YPnZ5szyfyo6wwL &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 20 Mar 2016 19:54:51 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160320195323_na-809-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-809-2016-03-20-Final.mp3</S>
      <S N="AudioLength">119565504</S>
    </MS>
  </Obj>
  <Obj RefId="11">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">808: Happy Countries</S>
      <S N="ShowUrl">http://808.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 808 - "Happy Countries"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Happy Countries&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-808-2016-03-17-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-808-2016-03-17-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160317195305_na-808-art-sm.jpg" alt="A picture named NA-808-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-808-2016-03-17-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://808.noagendanotes.com/"&gt; 808.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmcK41L4RJzhsoJiauPrmND1GmGWj87pjDUjkRXssi71Qg &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Happy Countries&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Erik A. Svendson, Sir Baz Sutton, Claudia Gerber,&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producer: John Dunn&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 809 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Barry Sutton -&gt; Sir Baz, Thomas Kilbride -&gt; Sir Thomas Kilbride&lt;/p&gt;&lt;p&gt;_x000A_Titles: Dame Janice Kang -&gt; Baroness Janice of the Mutton &amp; Mead&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artwork/7090"&gt;sub7zero&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://808.noagendanotes.com/"&gt; 808.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:QmcK41L4RJzhsoJiauPrmND1GmGWj87pjDUjkRXssi71Qg &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 17 Mar 2016 20:12:27 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160317201056_na-808-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-808-2016-03-17-Final.mp3</S>
      <S N="AudioLength">133101569</S>
    </MS>
  </Obj>
  <Obj RefId="12">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">807: Thanks Obama!</S>
      <S N="ShowUrl">http://807.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 807 - "Thanks Obama!"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Thanks Obama!&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-807-2016-03-13-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-807-2016-03-13-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160313193724_na-807-art-sm.jpg" alt="A picture named NA-807-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-807-2016-03-13-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://807.noagendanotes.com/"&gt; 807.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmWrDwfpQb12dWk3ZmLW2Uok2KdEyZoB9pbETnvbrFvRCc &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Thanks Obama!&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Roy Pearce of Ancona Baron of the Treasure Coast, Andrew Goodman, David Ellis, Sir Scott Spencer Baron of North Georgia, Sir Don Tomaso Di Toronto&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 808 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Jakub Wojciak -&gt; Sir Jacob of the Cloud&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Roy of Ancona -&gt; Baron of the Treasure Coast&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artwork/7061"&gt;Nick the Rat&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://807.noagendanotes.com/"&gt; 807.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:QmWrDwfpQb12dWk3ZmLW2Uok2KdEyZoB9pbETnvbrFvRCc &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 13 Mar 2016 19:54:22 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160313195016_na-807-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-807-2016-03-13-Final.mp3</S>
      <S N="AudioLength">128244383</S>
    </MS>
  </Obj>
  <Obj RefId="13">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">806: Babushkas of Chernobyl</S>
      <S N="ShowUrl">http://806.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 806 - "Babushkas of Chernobyl"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Babushkas of Chernobyl&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-806-2016-03-10-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-806-2016-03-10-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160310164103_na-806-art-sm.jpg" alt="A picture named NA-806-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-806-2016-03-10-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://806.noagendanotes.com/"&gt; 806.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmeHcwZjw7wYqd6TFVmuFcPtszxbtHCnfPFVh9efbz3WPd &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Babushkas of Chernobyl&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Andy Peelman-Peacekeeper of Flooding Flanders, John Franz&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Nick Principe, Peter Hawkins, Sir Norman McDonough, Sir Luke of London, Jeffrey Walso, Daniel Sheetz&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 807 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Andy Peelman -&gt; Sir Andy, Peacekeeper of Flooding Flanders, Jan van der Laan -&gt; The Bears Knight&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Beardmaster General -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/560"&gt;Mark G.&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://806.noagendanotes.com/"&gt; 806.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmeHcwZjw7wYqd6TFVmuFcPtszxbtHCnfPFVh9efbz3WPd &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Thu, 10 Mar 2016 21:16:35 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160310211434_na-806-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-806-2016-03-10-Final.mp3</S>
      <S N="AudioLength">136082833</S>
    </MS>
  </Obj>
  <Obj RefId="14">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">805: Mono Nuptials</S>
      <S N="ShowUrl">http://805.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 805 - "Mono Nuptials"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Mono Nuptials&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160306204340_na-805-art-sm.jpg" alt="A picture named NA-805-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://805.noagendanotes.com/"&gt; 805.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmQPd2KRqQab3qXF3ZdNonBDGRKVPQtfN67GWna2fKFfsa &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Mono Nuptials&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Sir Bruce Willke&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Mark Hall, Burton Rosenberger, Dame Sam Menner, Christopher Gray, Ben Smith, Black Knight Ara Derderian, Sir Dr. Sharkey, Sir Philip Meason-Baron of Wales, Mark Klein&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 806 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Chad Biederman -&gt; Baron of Guam&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/412"&gt;sub7zero&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://805.noagendanotes.com/"&gt; 805.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmQPd2KRqQab3qXF3ZdNonBDGRKVPQtfN67GWna2fKFfsa &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry and John C. Dvorak</S>
      <S N="PublicationDate">Sun, 06 Mar 2016 21:07:27 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160306210600_na-805-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3</S>
      <S N="AudioLength">135988781</S>
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
      Context "Unit Test Get-PodcastImage for each file using the $loop" {
        # Because the TestDrive won't get cleared out between context calls we'll
        # just create a subfolder for each test and put the files there
        $testDriveFolder = "$($TestDrive)\$($loop)\"
        New-Item $testDriveFolder -ItemType directory
        
        # The function calls Test-Path, we should Mock it
        # Since this is an empty folder, Test-Path should always return false
        Mock Test-Path { return $false }
        
        if ($loop -eq 'parameter')                             # Execute the function using a parameter
          { $downloadedImages = Get-PodcastImage -rssData $rssData -OutputPathFolder $testDriveFolder }
        else                                                   # Execute the function using the pipeline
          { $downloadedImages = $rssData | Get-PodcastImage -OutputPathFolder $testDriveFolder }
  
        foreach($podcast in $rssData)
        {
          $imgFileName = $podcast.ImageURL.Split('/')[-1]
          $outFileName = "$($testDriveFolder)$($imgFileName)"
          It "Image $imgFileName should exist" {      
            $outFileName | Should Exist
          }
  
          It "Image $imgFileName should exist in download list" {
            [bool]($imgFileName -in $downloadedImages) | Should -BeTrue
          }
        } # foreach($podcast in $rssData)
  
      } # Context "Unit Test Get-PodcastImage for each file using the $loop"
    } # foreach ($loop in $loops)


    <#--------------------------------------------------------------------------------------------------- 
       In the second set of tests, we will fake an existing file, so that it will trigger the do not 
       download flag within the function. This will let us know it is correctly skipping over files 
       to preserve our bandwidth
    ---------------------------------------------------------------------------------------------------#>
    $loops = 'parameter', 'pipeline'
    foreach ($loop in $loops)
    { 
      Context "Unit Test Get-PodcastImage $loop test with existing files" {
        # Because the TestDrive won't get cleared out between context calls we'll
        # just create a subfolder for each test and put the files there
        $testDriveFolder = "$($TestDrive)\$($loop)Exist\"
        New-Item $testDriveFolder -ItemType directory
     
        # For this test, we need to ensure it is not downloading files that
        # already exist. To do so, we'll begin by taking the first seven files
        # from our mock data and adding them to an array 
        $existingFiles = @()
        for ($x = 0; $x -lt 7; $x += 1) 
          { $existingFiles += $($rssData[$x].ImageURL.Split('/')[-1]) }
     
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
          { $downloadedImages = Get-PodcastImage -rssData $rssData -OutputPathFolder $testDriveFolder }
        else                                                   # Execute the function using the pipeline
          { $downloadedImages = $rssData | Get-PodcastImage -OutputPathFolder $testDriveFolder }
        
        # For the first test, ensure the files the function reported as downloaded actually were
        foreach($imageFile in $downloadedImages)
        {        
          $outFileName = "$($testDriveFolder)$($imageFile)"
          It "Image $imageFile have been downloaded, and thus should exist" {      
            $outFileName | Should -Exist
          }     
        } # foreach($podcast in $rssData)
        
        # For the files that are supposed to already exist, we'll do two tests
        foreach ($imageFile in $existingFiles)
        {
          # First, we'll make sure the supposedly existing file was not reported as downloaded
          It "$imageFile should not exist in the list of downloaded images" {
            [bool]($imageFile -in $downloadedImages) | Should -BeFalse
          }
     
          # Next, validate the file DOESN'T exist. In otherwords, since it wasn't supposed to download, 
          # we'll make sure it didn't
          $outFileName = "$($testDriveFolder)$($imageFile)"
          It "$imageFile should not have been downloaded, and thus should not exist" {
            $outFileName | Should -Not -Exist
          }
     
        }
     
      } # Context "Unit Test Get-PodcastImage $loop test with existing files"
    } # foreach ($loop in $loops)
    
  } # Describe 'Get-PodcastImage Unit Tests'

} # InModuleScope Podcast-NoAgenda

Describe 'Get-PodcastImage Acceptance Tests' -Tags 'Acceptance' {

  InModuleScope Podcast-NoAgenda { 
  
    $rssData = Get-PodcastData

    <#---------------------------------------------------------------------------------------------------
       The only difference in our tests is:
         1. The path to which things are downloaded to and
         2. The way in which Get-PodcastImage is called. 
       To keep from having a lot of repetitive code, the output folders are placed into a hash table, 
       which is iterated over. The name is used in a switch to control which method to call 
       Get-PodcastImage. The value is used for the folder to test in
    ---------------------------------------------------------------------------------------------------#>

    $root = 'C:\PowerShell\Pester-Module\'
    $tests = @{ 'default parameter' = "$($root)Podcast-Data\"
                'default pipeline'  = "$($root)Podcast-Data\"
                'nondefault parameter' = "$($root)Podcast-Test\"
                'nondefault pipeline'  = "$($root)Podcast-Test\"
              }

    # Note to iterate over a hash table, you have to use GetEnumerator to pop off each individual entry 
    # in the hash table. Each entry will have two values, the Name (left side of =), and the Value 
    # (right side of =)
    foreach($test in $tests.GetEnumerator())
    {
      $folder = $test.Value

      # Get a list of images already present
      $existingImages = Get-ChildItem "$($folder)*" -Include *.jpg, *.png | Select-Object Name

      # Call Get-PodcastImage based on which test we are running for
      switch ($test.Name)
      {
        'default parameter'    
           { $downloadedImages = Get-PodcastImage -rssData $rssData -Verbose }
        'default pipeline'     
           { $downloadedImages = $rssData | Get-PodcastImage -Verbose }
        'nondefault parameter' 
           { $downloadedImages = Get-PodcastImage -rssData $rssData -OutputPathFolder $folder -Verbose }
        'nondefault pipeline'  
           { $downloadedImages = $rssData | Get-PodcastImage -OutputPathFolder $folder -Verbose }
      } # switch ($test.Name)

      # Use split to reduce the test name to either default or nondefault and parameter or pipeline.
      # We'll use them in the context and test names to reduce their length
      $dlFolder = $test.Name.Split(' ')[0]
      $pipeParam = $test.Name.Split(' ')[1]

      Context "Acceptance Test Get-PodcastImage $pipeParam test to $dlFolder folder" {
        # Make sure all the files exist
        foreach($podcast in $rssData)
        {
          $imgFileName = $podcast.ImageURL.Split('/')[-1]
          $outFileName = "$($folder)$($imgFileName)"
          It "image $imgFileName should exist in the $dlFolder folder" {      
            $outFileName | Should -Exist
          }
        }
      
        # Make sure downloaded images weren't in the list of existing ones
        foreach ($img in $downloadedImages)
        {
          It "should have downloaded $img" {
            [bool]($img -in $existingImages) | Should -BeFalse
          }
        }
      
      } # Context 'Acceptance Test Get-PodcastImage 

      # Optional: Remove the images that were just downloaded so we can reset for next test
      # foreach ($img in $downloadedImages)
      # {
      #   Remove-Item "$($folder)$($img)" -ErrorAction SilentlyContinue
      # }
          
    } # foreach($test in $tests.GetEnumerator())

  } # InModuleScope Podcast-NoAgenda

} # Describe 'Get-PodcastImage Acceptance Tests'
