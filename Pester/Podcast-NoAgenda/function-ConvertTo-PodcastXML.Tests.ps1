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

Describe 'ConvertTo-PodcastXML Unit Tests' -Tags 'Unit' {

  InModuleScope Podcast-NoAgenda { 

    # See the notes in function-GetPodcastImage.Tests for how the mock data works  
    $mockRssData = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>Selected.System.Xml.XmlElement</T>
      <T>System.Management.Automation.PSCustomObject</T>
      <T>System.Object</T>
    </TN>
    <MS>
      <S N="Title">805: Mono Nuptials</S>
      <S N="ShowUrl">http://805.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 805 - "Mono Nuptials"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Mono Nuptials&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160306204340_na-805-art-sm.jpg" alt="A picture named NA-805-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://805.noagendanotes.com/"&gt; 805.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmQPd2KRqQab3qXF3ZdNonBDGRKVPQtfN67GWna2fKFfsa &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Mono Nuptials&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Sir Bruce Willke&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Mark Hall, Burton Rosenberger, Dame Sam Menner, Christopher Gray, Ben Smith, Black Knight Ara Derderian, Sir Dr. Sharkey, Sir Philip Meason-Baron of Wales, Mark Klein&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 806 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Chad Biederman -&gt; Baron of Guam&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/412"&gt;sub7zero&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://805.noagendanotes.com/"&gt; 805.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmQPd2KRqQab3qXF3ZdNonBDGRKVPQtfN67GWna2fKFfsa &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 06 Mar 2016 21:07:27 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160306210600_na-805-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-805-2016-03-06-Final.mp3</S>
      <S N="AudioLength">135988781</S>
    </MS>
  </Obj>
  <Obj RefId="1">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">804: Evidence Free Zone</S>
      <S N="ShowUrl">http://804.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 804 - "Evidence Free Zone"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Evidence Free Zone&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-804-2016-03-03-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-804-2016-03-03-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160303203627_na-804-art-sm.jpg" alt="A picture named NA-804-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-804-2016-03-03-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://804.noagendanotes.com/"&gt; 804.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmevDmqLLHaNWMBQucCRgnfwNGJHtnT5rJWuarGn99SzYa &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Evidence Free Zone&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Sir Edward of Bridgewater, Duke Thomas Nussbaum, Joseph Gilbert &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: John Glover&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 805 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Titles: Dame Francine Hardaway -&gt; Baroness &lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/560"&gt;Mark G.&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://804.noagendanotes.com/"&gt; 804.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmevDmqLLHaNWMBQucCRgnfwNGJHtnT5rJWuarGn99SzYa &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 03 Mar 2016 21:01:33 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160303210009_na-804-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-804-2016-03-03-Final.mp3</S>
      <S N="AudioLength">120827149</S>
    </MS>
  </Obj>
  <Obj RefId="2">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">803: Joe Hitler</S>
      <S N="ShowUrl">http://803.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 803 - "Joe Hitler"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Joe Hitler&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-803-2016-02-28-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-803-2016-02-28-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160228210431_na-803-art-sm.jpg" alt="A picture named NA-803-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-803-2016-02-28-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://803.noagendanotes.com/"&gt; 803.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmU2nkTGzMPXnVfn43JiMgRHJAyzx1MXJsMd9UZdnnC7L8 &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Joe Hitler&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Greg Davis &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: James C Reeves, Mark Pleger, Sir Jojo&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 804 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Guy Boazy -&gt; Black Baron&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/443"&gt;Baron Nussbaum&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://803.noagendanotes.com/"&gt; 803.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmU2nkTGzMPXnVfn43JiMgRHJAyzx1MXJsMd9UZdnnC7L8 &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 28 Feb 2016 21:31:44 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160228212927_na-803-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-803-2016-02-28-Final.mp3</S>
      <S N="AudioLength">140918521</S>
    </MS>
  </Obj>
  <Obj RefId="3">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">802: Warehouse of Souls</S>
      <S N="ShowUrl">http://802.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 802 - "Warehouse of Souls"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Warehouse of Souls&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-802-2016-02-25-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-802-2016-02-25-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160225203910_na-802-art-sm.jpg" alt="A picture named NA-802-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-802-2016-02-25-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://802.noagendanotes.com/"&gt; 802.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3:  QmS1iWtGNh7q3G9TQYm4CH6cwyBhcDXnUNHiW6stH6XHe6 &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Warehouse of Souls&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Anonymous Baron of Colfax CA, American Liberty, David Prince, John J Horner&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Chris Foster, Sir Cliff Howell, Eliezer Martinez, Sir Scott Thomson, Jacobus Boersma&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 803 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Raun (rhymes with phone) Kilgo -&gt; Sir Therblig of the Digital Domain, Colin Sloman -&gt; Sir Horatio of Wandsworth, Black Knight, John J Horner -&gt; Sir John the Brewer, Scott Thomson -&gt; Sir Roadwolf, Knight of the Tonawandas&lt;/p&gt;&lt;p&gt;_x000A_Titles: Anonymous Knight in Colfax, CA -&gt; Baron of Colfax CA&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/686"&gt;BohemianGroove&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://802.noagendanotes.com/"&gt; 802.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmS1iWtGNh7q3G9TQYm4CH6cwyBhcDXnUNHiW6stH6XHe6 &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 25 Feb 2016 21:09:20 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160225210800_na-802-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-802-2016-02-25-Final.mp3</S>
      <S N="AudioLength">132518611</S>
    </MS>
  </Obj>
  <Obj RefId="4">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">801: White Male Clerks</S>
      <S N="ShowUrl">http://801.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 801 - "White Male Clerks"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;White Male Clerks&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-801-2016-02-21-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-801-2016-02-21-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160221203409_na-801-art-sm.jpg" alt="A picture named NA-801-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-801-2016-02-21-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://801.noagendanotes.com/"&gt; 801.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmYR4tjrPmQUipfqthXFXnBgYJX8S8dXhEAzD5e4J3RU7F &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Male White Clercks&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Alyssa Karounos, AJ of the one tree hill, Adriaan Spronk &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir ReadyKilowatt, Sandra Ferreira, Sir Donald Winkler Knight of the Bohemian Forest and the Barghain realm, Dwight Chick, Jeroen Huttinga&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 802 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Kristina Caldwell -&gt; Dame Kristina, Donald Winkler -&gt; Sir Donald Winkler, Knight of the Bohemian Forest and the Berghain realm&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/10"&gt;Nick The Rat&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://801.noagendanotes.com/"&gt; 801.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmYR4tjrPmQUipfqthXFXnBgYJX8S8dXhEAzD5e4J3RU7F &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 21 Feb 2016 21:04:22 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160221210250_na-801-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-801-2016-02-21-Final.mp3</S>
      <S N="AudioLength">115889366</S>
    </MS>
  </Obj>
  <Obj RefId="5">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">800: Toilet Wars</S>
      <S N="ShowUrl">http://800.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 800 - "Toilet Wars"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Toilet Wars&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-800-2016-02-18-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-800-2016-02-18-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160218210449_na-800-art-sm.jpg" alt="A picture named NA-800-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-800-2016-02-18-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://800.noagendanotes.com/"&gt; 800.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmRzjWR2bPCnEHj5GvcyUV5vtssDNYCbbAu88um6UGV46P &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Toilet Wars&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Benjamin Naidus, Sir Bashir, Sir Trevor Mudge, Anonymous, Sir Jojo the Network Chimp, Stephen Vorhees, Michael Hinz &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: John Scales, Ron Gardner, Jack Smith, Ryan McCullough, Sir Adam Johnson Baron of the Bourbon Barrel Stout, Sir Robert Goshko Earl of Alberta, Ben Smith, Christine Bachman, Matthew Bellemare, Joshua Willis, John Robinette, Sir Kirk of the Happy Snowy Valley, Dennis Stephens, Baronet Sir Guy Boazy, Anonymous, Pnonymous&lt;/p&gt;&lt;p&gt;_x000A_Club 800 Members: Benjamin Naidus, Sir Bashir, Sir Trevor Mudge&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 801 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Douwe Andela -&gt; Sir D of Hollandsche Rading, Black Knight, Henry Reese -&gt; Sir Henry of Nagoya, Black Knight, Ben Smith -&gt; Sir Ben of Oakland, Order of The Economic Roundtable&lt;/p&gt;&lt;p&gt;_x000A_Titles: &lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/415"&gt;H@ssan M@ynard&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://800.noagendanotes.com/"&gt; 800.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH: QmRzjWR2bPCnEHj5GvcyUV5vtssDNYCbbAu88um6UGV46P &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 18 Feb 2016 21:32:05 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160218213050_na-800-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-800-2016-02-18-Final.mp3</S>
      <S N="AudioLength">139137487</S>
    </MS>
  </Obj>
  <Obj RefId="6">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">799: War on Serif</S>
      <S N="ShowUrl">http://799.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 799 - "War on Serif"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;War on Serif&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-799-2016-02-14-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-799-2016-02-14-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160214203115_na-790-art-sm.jpg" alt="A picture named NA-799-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-799-2016-02-14-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://799.noagendanotes.com/"&gt; 799.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmPeWDeVHJXc3aoZXgKyY6jJhXYKqzRfgqjb5NKJxws6Vi &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;War on Serif&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: Baronet Sir Coby Hung&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Ronald Gardner, Dame of Linz, Sir Mad Hatter Knight of the Fifth Column, Baron Sir DH Slammer, James 'Jamie' Richard, Symbio Agency Inc, Gerald Howard, Dame Astrid Klein Baronet of Tokyo, John Miller, Craig Dashnow, Sir Hank Viscount of Queens&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 800 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Lin -&gt; Lady Lin the Dame of Linz, Brian Warden -&gt; Sir Brian Warden&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Hung -&gt; Baronet, Sir Mad Hatter -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/654"&gt;Cesium137&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://799.noagendanotes.com/"&gt; 799.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:QmeXfSALyDLhENrmqJj8HrQtZbRainP9frXTtNRPFvUmMy &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 14 Feb 2016 20:57:52 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160214205642_na-790-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-799-2016-02-14-Final.mp3</S>
      <S N="AudioLength">128848405</S>
    </MS>
  </Obj>
  <Obj RefId="7">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">798: Dangerous Speech</S>
      <S N="ShowUrl">http://798.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 798 - "Dangerous Speech"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dangerous Speech&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-798-2016-02-11-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-798-2016-02-11-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160211204302_na-798-art-sm.jpg" alt="A picture named NA-798-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-798-2016-02-11-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://798.noagendanotes.com/"&gt; 798.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmPeWDeVHJXc3aoZXgKyY6jJhXYKqzRfgqjb5NKJxws6Vi &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dangerous Speech&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Frank Ajzensztat Baron of Stonnington, David Killian &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Vincent Farrell, Gregory McGregor, Sir Richard Moffatt,  Sir Nick of the SouthSide &lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 799 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights: Sarah Harris -&gt; Black Dame Sarah Harris, Nate Friedman -&gt; Sir Got Nate, Derbe Dike -&gt; Sir Derbe Dike&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/668"&gt;Sir Sluf&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://798.noagendanotes.com/"&gt; 798.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 11 Feb 2016 21:08:52 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160211210733_na-798-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-798-2016-02-11-Final.mp3</S>
      <S N="AudioLength">135279053</S>
    </MS>
  </Obj>
  <Obj RefId="8">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">797: Laptop Bomb</S>
      <S N="ShowUrl">http://797.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 797 - "Laptop Bomb"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Laptop Bomb&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-797-2016-02-07-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-797-2016-02-07-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160207211152_na-797-art-sm.jpg" alt="A picture named NA-797-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-797-2016-02-07-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://797.noagendanotes.com/"&gt; 797.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3:  QmZZ3XNdJz4QpFhm4HJJFNFLqMniehsrydtjouAZkynzxN &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Laptop Bomb&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Pnonymous, Sir Snozzages of Suwanee, Sir Anonymous of the ADF, Arch Duke Sir Dwayne Melancon&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Sheats Baronet of the Cuban Leaf, David Hoffman, Sir D00M-Liberator of the Hennepin Slaves, Black Knight Sir Dave Koss&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 798 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights: Michael Sosnin -&gt; Sir Snozzages of Suwanee, Donn O'Malley -&gt; Sir D00M, Liberator of the Hennepin Slaves, Anonymous -&gt; Sir Anonymous of the ADF&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Dave Koss -&gt; Baronet&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/109"&gt;20wattbulb&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://797.noagendanotes.com/"&gt; 797.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:  QmXgkK2Vax52V6HRt2pCo5pSvfPi2kWPghinzj7vXjCvuF &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 07 Feb 2016 21:50:17 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160207214856_na-797-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-797-2016-02-07-Final.mp3</S>
      <S N="AudioLength">135539686</S>
    </MS>
  </Obj>
  <Obj RefId="9">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">796: Bomb Denmark</S>
      <S N="ShowUrl">http://796.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 796 - "Bomb Denmark"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Bomb Denmark&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-796-2016-02-04-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-796-2016-02-04-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160204204826_na-796-art-sm.jpg" alt="A picture named NA-796-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-796-2016-02-04-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://796.noagendanotes.com/"&gt; 796.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3:  QmZZ3XNdJz4QpFhm4HJJFNFLqMniehsrydtjouAZkynzxN &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Bomb Denmark&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Dustin Marquess - Sir Jail Bird, Knight of the .45, Sir Denny Goad, Sir Ralf Nellessen, Sir Mike Rotch-Knight of the pseudonym, Phillip Rodokanakis, Sir Eric Halbritter, David Habidank, Douglas Kuhlman -&gt; Sir Would_E of the Dakota Territory, Matk Workman&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Loren Smudski, Michael Levin, Chris Perry, David Prince, Benjamin Vernooij, Desmond Lo, Sir Paul Schneider, Sir Brad Dougherty, Sir Jason Danierls, Sir Norman McDonough, Peter Scharmüller, John Robinette, Adam Barrett, Marv Santealla&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 797 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights: Sarah Harris -&gt; Dame, Sarah Harris, Sara Dornonville -&gt; Dame Sara Dornonville, Dustin Marquess -&gt; Sir Jail Bird, Knight of the .45, Denny Goad -&gt; Sir Denny, "Mike Rotch" -&gt; Sir Mike Rotch, Knight of the pseudonym, Douglas Kuhlman -&gt; Sir Would_E of the Dakota Territory, Bruce Hall -&gt; Sir Rhosis, Vincent Farrell -&gt; Sir Vince of Southern Silicon Valley&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/682"&gt;Spadez85&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://796.noagendanotes.com/"&gt; 796.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 04 Feb 2016 21:05:42 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160204210407_na-796-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-796-2016-02-04-Final.mp3</S>
      <S N="AudioLength">125171485</S>
    </MS>
  </Obj>
  <Obj RefId="10">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">795: Trump Head</S>
      <S N="ShowUrl">http://795.noagendanotes.com/</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 795 - "Trump Head"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Trump Head&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-795-2016-01-31-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-795-2016-01-31-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160131212123_na-795-art-sm.jpg" alt="A picture named NA-795-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-795-2016-01-31-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://795.noagendanotes.com/"&gt; 795.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3:  QmZZ3XNdJz4QpFhm4HJJFNFLqMniehsrydtjouAZkynzxN &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Trump Head&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sarah Harris, Sir James Mills-Knight of the Form 990, James Brown, American Liberty, Sir Chase McCarthy, Todd McGreevy, James Schmid, Scott Littler-The Knight to be Named Later, Daniel Woodlief, Sir Paul of Winooski, Frenzied Designs, Kevin Perdeek, David Booher, Sir Christopher Dolan, Robert Dodd, LDTeachers.net, Steven Baker, Sir Kent Zieser, David K&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Keith Bradshaw, Herbert Harms, Sean Connelly, Gerard Small, Richard Henderson, Mike Merva, Anonymous Douchebag,  Jennifer Loveberg, Dame Tanya Weiman, Patrick Sullivan, Eric Asbury, Sir Patrick Coble, Jeffrey Fitch, John White, Rollie Hawk, Brian Hinman, Dustin Marquess, Sir HMFIC Black Knight of the US Army, Sir Upper Decker, Marvin Brittain, Anonymous, Kris Johnson, Sir Steven Fettig, Sir Festus, John Monaro, Sir Atomic Rod Adams, Jonathan Doughtie, John Cox, Josh McComas, Sir Brian Lawson, Timothy Tillman&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 796 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights: Zack Gilbrech -&gt; Zachary Knight of the Bluff city, Scott Littler -&gt; The Knight to be Named Later, James Mills -&gt; Sir James of the Form 990&lt;/p&gt;&lt;p&gt;_x000A_Titles: Sir Thor Hanks -&gt; Baronet, Sir Jordan DeMoss -&gt; Baron of Pearl Harbor&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/654"&gt;Cesium137&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://795.noagendanotes.com/"&gt; 795.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 31 Jan 2016 21:44:12 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160131214250_na-795-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-795-2016-01-31-Final.mp3</S>
      <S N="AudioLength">151871945</S>
    </MS>
  </Obj>
  <Obj RefId="11">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">794: Party Boat</S>
      <S N="ShowUrl">http://794.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 794 - "Party Boat"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Party Boat&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-794-2016-01-28-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-794-2016-01-28-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160128210759_na-794-art-sm.jpg" alt="A picture named NA-794-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-794-2016-01-28-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3:&lt;i&gt;QmaXetonNkyBYKd4xbzyFYEvxkCLs7URDZDjkUKVW3xuJt&lt;/i&gt; &lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://794.noagendanotes.com/"&gt; 794.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Party Boat&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producer: TF Publishing BV&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producer: Sir Tim Saunders&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 795 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights: Allen Cavedo III -&gt; Sir Caved III, Colin Sloman -&gt; Sir Horatio of Wandsworth&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/723"&gt;NetworkDali&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://794.noagendanotes.com/"&gt; 794.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 28 Jan 2016 21:33:07 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160128213141_na-794-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-794-2016-01-28-Final.mp3</S>
      <S N="AudioLength">130128089</S>
    </MS>
  </Obj>
  <Obj RefId="12">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">793: Divide &amp; Ruin</S>
      <S N="ShowUrl">http://793.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 793 - "Divide &amp; Ruin"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Divide &amp; Ruin&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-793-2016-01-24-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-793-2016-01-24-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160124211600_na-793-art-sm.jpg" alt="A picture named NA-793-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-793-2016-01-24-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: &lt;i&gt;QmVvr6kWHNpPYTpkBxJis88YtWMti1AApdeSLkDeQKGXP5&lt;/i&gt; &lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://793.noagendanotes.com/"&gt; 793.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Divide &amp; Ruin&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir David Roberts Knight of the Yellow Rose, Derbe Dike, Sir Robert Goshkom Earl of Alberta&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Timnonymous&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 794 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/109"&gt;20wattbulb&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://793.noagendanotes.com/"&gt; 793.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 24 Jan 2016 21:43:52 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160124214236_na-793-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-793-2016-01-24-Final.mp3</S>
      <S N="AudioLength">122449160</S>
    </MS>
  </Obj>
  <Obj RefId="13">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">792: Buffoonery</S>
      <S N="ShowUrl">http://792.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 792 - "Buffoonery"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Buffoonery&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://feed.nashownotes.com.s3.amazonaws.com/NA-792-2016-01-21-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://feed.nashownotes.com.s3.amazonaws.com/NA-792-2016-01-21-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160121164446_na-792-art-sm.jpg" alt="A picture named NA-792-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://feed.nashownotes.com.s3.amazonaws.com/NA-792-2016-01-21-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://792.noagendanotes.com/"&gt; 792.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Buffoonery&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Blackballs of TWiT the Baron of Logan Square, Peter Gill, Sir Mad Hatter &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Subodh Pethe, Jayson Wall, Scott Schipper, JohnOverall.com&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 793 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/674"&gt;CaraP&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://792.noagendanotes.com/"&gt; 792.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Thu, 21 Jan 2016 21:09:56 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160121210832_na-792-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-792-2016-01-21-Final.mp3</S>
      <S N="AudioLength">125667997</S>
    </MS>
  </Obj>
  <Obj RefId="14">
    <TNRef RefId="0" />
    <MS>
      <S N="Title">791: Shunt Unit</S>
      <S N="ShowUrl">http://791.noagendanotes.com</S>
      <S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 791 - "Shunt Unit"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Shunt Unit&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;embed type="application/x-shockwave-flash" src="http://www.dvorak.org/blog/wp-content/uploads/2008/01/playersingle.swf" id="mymovie" name="mymovie" quality="high" flashvars="autoPlay=no&amp;amp;soundPath=http://mp3s.nashownotes.com/NA-791-2016-01-17-Final.mp3&amp;overColor=#ff0000" height="80" &gt;&lt;/embed&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-791-2016-01-17-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160117170152_na-791-art-sm.jpg" alt="A picture named NA-791-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-791-2016-01-17-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://791.noagendanotes.com/"&gt; 791.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Shunt Unit&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Sir Timothy Crow The Fiber Knight, Sir James Brown&lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir J-nonymous, Aaron, Sir Yael Ossowski Knight of the Non-Hipster Man Beard, Dimitry Rabinovich, Eric Shearer&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 792 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights: Timothy Crow -&gt; Sir Timothy Crow The Fiber Knight, Yael Ossowski -&gt; Sir Yael Ossowski Knight of the Non-Hipster man beard&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/109"&gt;20wattbulb&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://791.noagendanotes.com/"&gt; 791.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
      <S N="Hosts">Adam Curry &amp; John C. Dvorak</S>
      <S N="PublicationDate">Sun, 17 Jan 2016 22:26:37 GMT</S>
      <S N="ImageUrl">http://adam.curry.com/enc/20160117222511_na-791-art-sm.jpg</S>
      <S N="AudioUrl">http://mp3s.nashownotes.com/NA-791-2016-01-17-Final.mp3</S>
      <S N="AudioLength">127602591</S>
    </MS>
  </Obj>
</Objs>
'@
  
    $rssData = [System.Management.Automation.PSSerializer]::DeserializeAsList($mockRssData)

    # Test as Parameter
    $xmlData = (ConvertTo-PodcastXML -PodcastData $rssData) | Out-String

    foreach ($podcast in $rssData)
    {
      Context "Parameter Unit Test: Show $($podcast.Title) data is present and correct" { 
        
        It "should have <Title>$($podcast.Title)</Title>" {
          $xmlData.Contains("      <Title>$($podcast.Title)</Title>") |
            Should Be $true
        }
      
        It "should have <ShowUrl>$($podcast.ShowUrl)</ShowUrl>" {
          $xmlData.Contains("      <ShowUrl>$($podcast.ShowUrl)</ShowUrl>") |
            Should Be $true
        }
      
        It "should have <Hosts>$($podcast.Hosts)</Hosts>" {
          $xmlData.Contains("      <Hosts>$($podcast.Hosts)</Hosts>") |
            Should Be $true
        }
      
        It "should have <PublicationDate>$($podcast.PublicationDate)</PublicationDate>" {
          $xmlData.Contains("      <PublicationDate>$($podcast.PublicationDate)</PublicationDate>") |
            Should Be $true
        }
      
        It "should have <ImageURL>$($podcast.ImageURL)</ImageURL>" {
          $xmlData.Contains("      <ImageURL>$($podcast.ImageURL)</ImageURL>") |
            Should Be $true
        }
      
        It "should have <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>" {
          $xmlData.Contains("      <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>") |
            Should Be $true
        }
      
        It "should have <AudioURL>$($podcast.AudioURL)</AudioURL>" {
          $xmlData.Contains("      <AudioURL>$($podcast.AudioURL)</AudioURL>") |
            Should Be $true
        }
        
        $audioFileName = $podcast.AudioUrl.Split('/')[-1]      
        It "should have <AudioFileName>$($audioFileName)</AudioFileName>" {
          $xmlData.Contains("      <AudioFileName>$($audioFileName)</AudioFileName>") |
            Should Be $true
        }
      
        It "should have <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>" {
          $xmlData.Contains("      <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>") |
            Should Be $true
        }
      
      } # Context 'That each value in the feed is in the XML'
    } # foreach ($podcast in $rssData)

    # Test as Pipeline
    $xmlData = $rssData | ConvertTo-PodcastXML | Out-String

    # ConvertTo-PodcastXML returns a big string. Break into an array
    #$xmlData = $xmlData.Split("`r`n")

    foreach ($podcast in $rssData)
    {
      Context "Pipeline Unit Test: Show $($podcast.Title) data is present and correct" { 
        
        It "should have <Title>$($podcast.Title)</Title>" {
          $xmlData.Contains("      <Title>$($podcast.Title)</Title>") |
            Should Be $true
        }
      
        It "should have <ShowUrl>$($podcast.ShowUrl)</ShowUrl>" {
          $xmlData.Contains("      <ShowUrl>$($podcast.ShowUrl)</ShowUrl>") |
            Should Be $true
        }
      
        It "should have <Hosts>$($podcast.Hosts)</Hosts>" {
          $xmlData.Contains("      <Hosts>$($podcast.Hosts)</Hosts>") |
            Should Be $true
        }
      
        It "should have <PublicationDate>$($podcast.PublicationDate)</PublicationDate>" {
          $xmlData.Contains("      <PublicationDate>$($podcast.PublicationDate)</PublicationDate>") |
            Should Be $true
        }
      
        It "should have <ImageURL>$($podcast.ImageURL)</ImageURL>" {
          $xmlData.Contains("      <ImageURL>$($podcast.ImageURL)</ImageURL>") |
            Should Be $true
        }
      
        It "should have <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>" {
          $xmlData.Contains("      <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>") |
            Should Be $true
        }
      
        It "should have <AudioURL>$($podcast.AudioURL)</AudioURL>" {
          $xmlData.Contains("      <AudioURL>$($podcast.AudioURL)</AudioURL>") |
            Should Be $true
        }
        
        $audioFileName = $podcast.AudioUrl.Split('/')[-1]      
        It "should have <AudioFileName>$($audioFileName)</AudioFileName>" {
          $xmlData.Contains("      <AudioFileName>$($audioFileName)</AudioFileName>") |
            Should Be $true
        }
      
        It "should have <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>" {
          $xmlData.Contains("      <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>") |
            Should Be $true
        }
      
      } # Context 'That each value in the feed is in the XML'
    } # foreach ($podcast in $rssData)


  } # InModuleScope Podcast-NoAgenda

} # Describe 'ConvertTo-PodcastXML Unit Tests'

Describe 'ConvertTo-PodcastXML Acceptance Tests' -Tags 'Acceptance' {

  InModuleScope Podcast-NoAgenda { 
  
    $rssData = Get-PodcastData

    # Test as parameter
    $xmlData = (ConvertTo-PodcastXML -PodcastData $rssData) | Out-String

    foreach ($podcast in $rssData)
    {
      Context "Parameter Acceptance Test: Show $($podcast.Title) data is present and correct" { 
        
        It "should have <Title>$($podcast.Title)</Title>" {
          $xmlData.Contains("      <Title>$($podcast.Title)</Title>") |
            Should Be $true
        }
      
        It "should have <ShowUrl>$($podcast.ShowUrl)</ShowUrl>" {
          $xmlData.Contains("      <ShowUrl>$($podcast.ShowUrl)</ShowUrl>") |
            Should Be $true
        }
      
        It "should have <Hosts>$($podcast.Hosts)</Hosts>" {
          $xmlData.Contains("      <Hosts>$($podcast.Hosts)</Hosts>") |
            Should Be $true
        }
      
        It "should have <PublicationDate>$($podcast.PublicationDate)</PublicationDate>" {
          $xmlData.Contains("      <PublicationDate>$($podcast.PublicationDate)</PublicationDate>") |
            Should Be $true
        }
      
        It "should have <ImageURL>$($podcast.ImageURL)</ImageURL>" {
          $xmlData.Contains("      <ImageURL>$($podcast.ImageURL)</ImageURL>") |
            Should Be $true
        }
      
        It "should have <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>" {
          $xmlData.Contains("      <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>") |
            Should Be $true
        }
      
        It "should have <AudioURL>$($podcast.AudioURL)</AudioURL>" {
          $xmlData.Contains("      <AudioURL>$($podcast.AudioURL)</AudioURL>") |
            Should Be $true
        }
        
        $audioFileName = $podcast.AudioUrl.Split('/')[-1]      
        It "should have <AudioFileName>$($audioFileName)</AudioFileName>" {
          $xmlData.Contains("      <AudioFileName>$($audioFileName)</AudioFileName>") |
            Should Be $true
        }
      
        It "should have <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>" {
          $xmlData.Contains("      <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>") |
            Should Be $true
        }
      
      } # Context 'That each value in the feed is in the XML'
    } # foreach ($podcast in $rssData)


    # Test as pipeline
    $xmlData = $rssData | ConvertTo-PodcastXML | Out-String

    foreach ($podcast in $rssData)
    {
      Context "Pipeline Acceptance Test: Show $($podcast.Title) data is present and correct" { 
        
        It "should have <Title>$($podcast.Title)</Title>" {
          $xmlData.Contains("      <Title>$($podcast.Title)</Title>") |
            Should Be $true
        }
      
        It "should have <ShowUrl>$($podcast.ShowUrl)</ShowUrl>" {
          $xmlData.Contains("      <ShowUrl>$($podcast.ShowUrl)</ShowUrl>") |
            Should Be $true
        }
      
        It "should have <Hosts>$($podcast.Hosts)</Hosts>" {
          $xmlData.Contains("      <Hosts>$($podcast.Hosts)</Hosts>") |
            Should Be $true
        }
      
        It "should have <PublicationDate>$($podcast.PublicationDate)</PublicationDate>" {
          $xmlData.Contains("      <PublicationDate>$($podcast.PublicationDate)</PublicationDate>") |
            Should Be $true
        }
      
        It "should have <ImageURL>$($podcast.ImageURL)</ImageURL>" {
          $xmlData.Contains("      <ImageURL>$($podcast.ImageURL)</ImageURL>") |
            Should Be $true
        }
      
        It "should have <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>" {
          $xmlData.Contains("      <ImageFileName>$($podcast.ImageUrl.Split('/')[-1])</ImageFileName>") |
            Should Be $true
        }
      
        It "should have <AudioURL>$($podcast.AudioURL)</AudioURL>" {
          $xmlData.Contains("      <AudioURL>$($podcast.AudioURL)</AudioURL>") |
            Should Be $true
        }
        
        $audioFileName = $podcast.AudioUrl.Split('/')[-1]      
        It "should have <AudioFileName>$($audioFileName)</AudioFileName>" {
          $xmlData.Contains("      <AudioFileName>$($audioFileName)</AudioFileName>") |
            Should Be $true
        }
      
        It "should have <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>" {
          $xmlData.Contains("      <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>") |
            Should Be $true
        }
      
      } # Context 'That each value in the feed is in the XML'
    } # foreach ($podcast in $rssData)

  } # InModuleScope Podcast-NoAgenda

} # Describe 'ConvertTo-PodcastXML Acceptance Tests'

