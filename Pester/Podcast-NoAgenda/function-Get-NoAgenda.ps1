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
  Calls all of the needed functions in order to download the podcast
  
  .DESCRIPTION
  This function will call all the required functions in order to download the
  No Agenda podcast
  
  .INPUTS
  ShowName - The name of the podcast
  ShowURL - The main website for the podcast (note not the RSS feed)
  RssFeed - The url containing the RSS feed for the show
  OutputPathFolder - The folder where the episodes should be downloaded to

  .OUTPUTS
  None
  
  .EXAMPLE
  Get-NoAgenda

  .EXAMPLE
  Get-NoAgenda -ShowName 'NoAgenda' `
               -ShowURL = 'http://noagendashow.com' `
               -RssFeed = 'http://feed.nashownotes.com/rss.xml' `
               -OutputPathFolder = 'C:\Podcasts\NoAgenda\'


#>
function Get-NoAgenda()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    [string] $OutputPathFolder = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Data\'
    ,
    [parameter (Mandatory = $false) ]
    [string] $XmlFileName = 'NoAgenda.xml'
    ,
    [parameter (Mandatory = $false) ]
    [string] $HtmlFileName = 'NoAgenda.html'
  )

  Write-Verbose 'Get-NoAgenda: Starting'

  Write-Verbose 'Get-NoAgenda: Getting Podcast Data Feed'
  $data = Get-PodcastData

  Write-Verbose 'Get-NoAgenda: Getting Podcast Images'
  Get-PodcastImage $data $outputPathFolder 

  Write-Verbose 'Get-NoAgenda: Getting Podcast Media'
  Get-PodcastMedia $data $outputPathFolder 

  Write-Verbose 'Get-NoAgenda: Getting Podcast HTML'
  $html = ConvertTo-PodcastHtml $data

  Write-Verbose 'Get-NoAgenda: Writing Podcast HTML'
  $outFile = "$($outputPathFolder)$($HtmlFileName)"  
  Write-PodcastHtml -HtmlData $html -HtmlPathFile $outFile

  Write-Verbose 'Get-NoAgenda: Getting Podcast XML'
  $xml = ConvertTo-PodcastXml $data

  $outFile = "$($outputPathFolder)$($XmlFileName)"
  Write-Verbose "Get-NoAgenda: Writing Podcast XML $outFile" 
  Write-PodcastXml -XMLData $xml -XMLFilePath $outFile

  Write-Verbose 'Get-NoAgenda: Done'

}
