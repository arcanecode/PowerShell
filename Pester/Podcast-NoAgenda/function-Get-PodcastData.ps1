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
  .SYNOPSIS
  Gets the RSS data associated with the podcast
  
  .DESCRIPTION
  Gets the RSS feed data associated with the podcast
  
  .INPUTS
  rssFeed = The URL to the podcast
    
  .OUTPUTS
  Returns an array of objects with the RSS data in it.
  
  .EXAMPLE
  $rssData = Get-PodcastData

  .EXAMPLE
  $rssData = Get-PodcastData 'http://feed.nashownotes.com/rss.xml'

  .EXAMPLE
  $rssData = Get-PodcastData -rssFeed 'http://feed.nashownotes.com/rss.xml'

  .EXAMPLE
  $feed = 'http://feed.nashownotes.com/rss.xml'
  $rssData = Get-PodcastData -rssFeed $feed
  
#>
function Get-PodcastData()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    [string] $rssFeed = 'http://feed.nashownotes.com/rss.xml'
  )

  Write-Verbose "Get-PodcastData: Getting RSS Data from $rssfeed"
  
  $webData = Invoke-RestMethod $rssFeed

  # Use Select-Object to take each object returned and convert it to
  # custom objects. Name will become the property name of the new object,
  # Expression is the value we are extracting from the returned web data
  $rssData = @()
  foreach($rss in $webData)
  {
    $rssData += [PSCustomObject][Ordered]@{
      # Note the & will mess up the XML, so we'll replace it
      PSTypeName = 'PodcastSight.Podcast'
      Title = $rss.title.Replace('&', 'and')
      ShowUrl = $rss.link
      EmbeddedHTML = $rss.summary
      Hosts = $rss.author.Replace('&', 'and') 
      PublicationDate = $rss.pubDate
      ImageUrl = $rss.image.href
      AudioUrl = $rss.enclosure.url
      AudioLength = $rss.enclosure.length 
    }
  }
 
  return $rssData

}