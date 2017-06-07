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

function Remove-PodcastHtmlEncoding
{ 
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true) ]
    $HtmlStringToClean
  )

  $cleanedHTML = $HtmlStringToClean -replace '\"', ''
  $cleanedHTML = $cleanedHTML -replace '&lt;p&gt;', "`r`n"
  $cleanedHTML = $cleanedHTML -replace '/p', ''
  
  $cleanedHTML = $cleanedHTML -replace '&lt;font size= -1&gt;', ''
  $cleanedHTML = $cleanedHTML -replace '&lt;/font&gt;', ''
  
  $cleanedHTML = $cleanedHTML -replace '&lt;br&gt;', "`r`n"
  $cleanedHTML = $cleanedHTML -replace '&lt;a href=http://freedomcontroller.com&gt;&lt;font size= -2&gt;', ''
  
  $cleanedHTML = $cleanedHTML -replace '&lt;b&gt;', ''
  $cleanedHTML = $cleanedHTML -replace '&lt;/b&gt;', ''
  
  $cleanedHTML = $cleanedHTML -replace '&lt;/a&gt;', ''
  
  $cleanedHTML = $cleanedHTML -replace '&lt;a href=', ''
  $cleanedHTML = $cleanedHTML -replace '&gt;', ''
  $cleanedHTML = $cleanedHTML -replace '&lt;img src=', "`r`nImage Source: "
  $cleanedHTML = $cleanedHTML -replace 'alt=', "`r`nImage Description: "
  $cleanedHTML = $cleanedHTML -replace 'align=right border=0 vspace=5 width=256 height=256 hspace=15', ''
  $cleanedHTML = $cleanedHTML -replace '&lt;/a&gt;', "`r`n"
  
  $cleanedHTML = $cleanedHTML -replace 'audio src=', 'Audio Source: '
  
  $cleanedHTML = $cleanedHTML -replace '&lt;', ''
  $cleanedHTML = $cleanedHTML -replace 'p&gt;', ''
  $cleanedHTML = $cleanedHTML -replace 'b&gt;', ''
  $cleanedHTML = $cleanedHTML -replace '&gt;', ''
  $cleanedHTML = $cleanedHTML -replace '_x000A_', ''
  $cleanedHTML = $cleanedHTML -replace '<b>', ''
  $cleanedHTML = $cleanedHTML -replace '</b>', ''
  $cleanedHTML = $cleanedHTML -replace '<a href=', ''
  $cleanedHTML = $cleanedHTML -replace '&amp;', 'and'
  $cleanedHTML = $cleanedHTML -replace 'scriptdocument.write', ''
  $cleanedHTML = $cleanedHTML -replace 'Last Modified ', ''
  $cleanedHTML = $cleanedHTML -replace '\)', ''
  $cleanedHTML = $cleanedHTML -replace '\(', ''
  $cleanedHTML = $cleanedHTML -replace '\[', ''
  $cleanedHTML = $cleanedHTML -replace '\]', ''
  
  $cleanedHTML = $cleanedHTML -replace 'controls\/audio', ''
  $cleanedHTML = $cleanedHTML -replace '\+ document.lastModified\/script', ''
  $cleanedHTML = $cleanedHTML -replace 'http://', ''
  $cleanedHTML = $cleanedHTML -replace ':', ''
  
  $cleanedHTML = $cleanedHTML -replace '->' , ''
  $cleanedHTML = $cleanedHTML -replace '<.*?>' , ''
  $cleanedHTML = $cleanedHTML -replace '<' , ''
  $cleanedHTML = $cleanedHTML -replace '>' , ''
  
  return $cleanedHTML 

}
<#
$fix = @'
<S N="EmbeddedHTML">&lt;p&gt;Show Notes&lt;/p&gt;&lt;p&gt;_x000A_No Agenda Episode 811 - "Dead Men Can't Sue"&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dead Men Can't Sue&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;audio src="http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3" controls&gt;&lt;/audio&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3"&gt;&lt;img src="http://adam.curry.com/enc/20160327154435_na-811-art-sm.jpg" alt="A picture named NA-811-Art-SM" align="right" border="0" vspace="5" width="256" height="256" hspace="15"&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Direct [&lt;a href="http://mp3s.nashownotes.com/NA-811-2016-03-27-Final.mp3"&gt;link&lt;/a&gt;] to the mp3 file&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://811.noagendanotes.com/"&gt; 811.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPFS Hash for the mp3: QmdZCSsfgzfj5LPZK4XtAA4YME2hKQJBP9t5dccA1XwGo5 &lt;/p&gt;&lt;p&gt;_x000A_BitTorrentSync Secret: BBE35UBVKPKSUWGDLUZN5DIPFIB3TTQ5I&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Credits&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Dead Men Can't Sue&lt;/b&gt;&lt;/p&gt;&lt;p&gt;_x000A_Executive Producers: Jessie Lorenz Blind Dame of the SF Bay, Sir Phillip Rodokanakis, &lt;/p&gt;&lt;p&gt;_x000A_Associate Executive Producers: Sir Matt McVader,-Knight of Edgewater, Sir Hank Scorpio of the Electrical Grid&lt;/p&gt;&lt;p&gt;_x000A_Become a member of the 812 Club, support the show &lt;a href="http://dvorak.org/na"&gt;here&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;Sign Up&lt;/b&gt; for the &lt;a href="http://www.dvorak.org/blog/no-agenda-mailing-list-signup-here/"&gt;newsletter&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Knights &amp; Dames: Douglas Chick -&gt; Sir Hank Scorpio of the Electrical Grid, Matt McVader -&gt; Sir Matt McVader, Knight of Edgewater, Phillip Rodokanakis -&gt; Sir Rodokanakis, Jessie Lorenz -&gt; Blind Dame of the SF Bay&lt;/p&gt;&lt;p&gt;_x000A_Art By: &lt;a href="http://noagendaartgenerator.com/artist/10"&gt;Nick the Rat&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_ShowNotes Archive of links and Assets (clips etc) &lt;a href="http://811.noagendanotes.com/"&gt; 811.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_New: Directory Archive of Shownotes (includes all audio and video assets used) &lt;a href="http://archive.noagendanotes.com/"&gt;archive.noagendanotes.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_The No Agenda News Network- &lt;a href="http://noagendanewsnetwork.com/"&gt;noagendanewsnetwork.com&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_RSS Podcast&lt;a href="http://feed.nashownotes.com/rss.xml"&gt; Feed&lt;/a&gt; &lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://nanewsapp.com/"&gt;No Agenda News App&lt;/a&gt; for your iPhone and iPad&lt;/p&gt;&lt;p&gt;_x000A_Get the &lt;a href="http://www.noagendroid.com/"&gt;NoAgendDroid app&lt;/a&gt; for your Android Phone&lt;/p&gt;&lt;p&gt;_x000A_&lt;a href="http://bitlove.org/adamc1999/noagenda"&gt;Torrents&lt;/a&gt; of each episode via BitLove&lt;/p&gt;&lt;p&gt;_x000A_IPSH:QmdZCSsfgzfj5LPZK4XtAA4YME2hKQJBP9t5dccA1XwGo5 &lt;/p&gt;&lt;p&gt;_x000A_&lt;b&gt;New!&lt;/b&gt; &lt;a href="http://inthemorningzen.wordpress.com/2013/08/02/bittorrent-sync-the-no-agenda-show/"&gt;BitTorrent Sync&lt;/a&gt; the No Agenda Show&lt;/p&gt;&lt;p&gt;_x000A_&lt;font size= -1&gt;&lt;script&gt;document.write("Last Modified " + document.lastModified)&lt;/script&gt;&lt;/font&gt;&lt;br&gt;&lt;a href="http://freedomcontroller.com"&gt;&lt;font size= -2&gt;This page created with the FreedomController&lt;/font&gt;&lt;/a&gt;&lt;/p&gt;&lt;p&gt;_x000A_Keywords&lt;/p&gt;</S>
'@

$fix = $fix -replace "'", ""

$fixed = Remove-PodcastHtmlEncoding $fix
$fixed 

#>


