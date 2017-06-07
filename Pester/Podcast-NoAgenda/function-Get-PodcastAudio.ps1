<#
  .SYNOPSIS
  Downloads the audio files associated with the podcast feed
  
  .DESCRIPTION
  Uses the passed in RSS feed to get the names of the audio files, 
  then checks to see if the file exists in the output folder. 
  If it does exist, it is then checked to see if the length matches 
  the length specified in the feed. If it does not exist, 
  or if the lengths don't match, the audio file is downloaded.
  
  .INPUTS
  rssData - The RSS feed returned by Get-PodcastData
  OutputPathFolder - The target folder where the audio files should exist
  
  .OUTPUTS
  No values are returned. 
  
  .EXAMPLE
  $rssData = Get-PodcastData
  Get-PodcastAudio $rssData

  .EXAMPLE
  $rssData = Get-PodcastData
  $folder = 'C:\Temp'
  Get-PodcastAudio $rssData $folder

  .EXAMPLE
  $rssData = Get-PodcastData
  $folder = 'C:\Temp'
  Get-PodcastAudio -rssData $rssData -OutputPathFolder $folder

  .LINK
  Get-PodcastData 
  
#>
function Get-PodcastAudio()
{    
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true) ]
    $rssData
    ,   
    [parameter (Mandatory = $false) ]
    [string] $OutputPathFolder = 'C:\PS\Pester-course\demo\completed-final-module\Podcast-Data\'
  )

  foreach($podcast in $rssData)
  {
    $audioURL = $podcast.enclosure.url
    $audioSize = $podcast.enclosure.length
    $audioFileName = $audioURL.Split('/')[-1]
    $outFileName = "$($OutputPathFolder)$($audioFileName)"

    # Set flag to indicate if we need to download this file or not
    $dl = $false

    # Check to see if the file exists. We use slientlycontinue because
    # an error is returned if the file does not exist. If it doesn't
    # exist the variable will be null, which we'll check for and handle
    $checkFileName = Get-ChildItem $outFileName -ErrorAction SilentlyContinue

    if ($checkFileName -eq $null) 
      { $dl = $true }
    else
      {
        if ($checkFileName.Length -ne $audioSize)
          { $dl = $true }
      }
  
    # Download the file if we need to
    if ($dl)
    {      
      Write-Verbose "Downloading $audioFileName, $($podcast.enclosure.length) bytes from $audioURL `r`n"
      Invoke-WebRequest $audioUrl -OutFile $outFileName
    }
    else
    {
      Write-Verbose "Skipping $audioFileName, it already exists as $outFileName`r`n"
    }

  }

}