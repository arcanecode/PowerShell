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
  Returns a string of formatted XML for the input RSS Feed
  
  .DESCRIPTION
  Podcastsight has a defined format for its XML feeds. This function takes the
  passed in RSS data and reformats it in XML to match the Podcastsight format.
  A string is returned containing the data. 
  
  .INPUTS
  PodcastData - The RSS feed returned by Get-PodcastData
  
  .OUTPUTS
  A string with the formatted XML
  
  .EXAMPLE
  $PodcastData = Get-PodcastData
  $xmlData = Format-PodcastXML $PodcastData

  .EXAMPLE
  $PodcastData = Get-PodcastData
  $xmlData = Format-PodcastXML $PodcastData 

  .EXAMPLE
  $PodcastData = Get-PodcastData
  $xmlData = Format-PodcastXML -rssData $PodcastData 

  .LINK
  Get-PodcastData 
  
#>
function Format-PodcastXML()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true) ]
    $PodcastData
  )

  Write-Verbose 'Format-PodcastXML: Starting'

  $xmlOutput = "<Shows>`r`n"
  foreach($podcast in $PodcastData)
  {
    $imgUrl = $podcast.ImageUrl
    $imageFileName = $imgUrl.Split('/')[-1]

    $audioURL = $podcast.AudioUrl
    $audioFileName = $audioURL.Split('/')[-1]

    Write-Verbose "Format-PodcastXML: Formatting file $audioFileName"

    $row = @"
    <Show>
      <Title>$($podcast.Title)</Title>
      <Link>$($podcast.ShowUrl)</Link>
      <Hosts>$($podcast.Hosts)</Hosts>
      <PublicationDate>$($podcast.PublicationDate)</PublicationDate>
      <ImageURL>$($podcast.ImageUrl)</ImageURL>
      <ImageFileName>$($imageFileName)</ImageFileName>
      <AudioURL>$($podcast.AudioUrl)</AudioURL>
      <AudioFileName>$($audioFileName)</AudioFileName>
      <AudioFileLength>$($podcast.AudioLength)</AudioFileLength>
    </Show>`r`n
"@
    $xmlOutput += $row
  }
  # Create the closing tag for the XML
  $xmlOutput += "</Shows>`r`n"

  return $xmlOutput
}