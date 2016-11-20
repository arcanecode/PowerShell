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
    Get-PodcastMedia $rssData

    .EXAMPLE
    $rssData = Get-PodcastData
    $folder = 'C:\Temp'
    Get-PodcastMedia $rssData $folder

    .EXAMPLE
    $rssData = Get-PodcastData
    $folder = 'C:\Temp'
    Get-PodcastMedia -rssData $rssData -OutputPathFolder $folder

    .LINK
    Get-PodcastData 
  
#>
function Get-PodcastMedia()
{    
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true
        , ValueFromPipeline = $true
        , ValueFromPipelineByPropertyName = $true
      ) 
    ]
    $rssData
    ,   
    [parameter (Mandatory = $false) ]
    [string] $OutputPathFolder = 'C:\PS\Pester-course\demo\completed-final-module\Podcast-Data\'
  )

  begin
  {
    Write-Verbose 'Get-PodcastMedia: Starting'
  }

  process
  { 
    foreach($podcast in $rssData)
    {
      $audioURL = $podcast.AudioUrl
      $audioFileName = $audioURL.Split('/')[-1]
      $outFileName = "$($OutputPathFolder)$($audioFileName)"
        
      # Download the file if we need to
      if ( Test-Path $outFileName )
      {
        $msg = "`r`nGet-PodcastMedia: Skipping $audioFileName, it already exists as $outFileName`r`n"
        Write-Verbose $msg
      }
      else
      {
        $msg = "`r`nGet-PodcastMedia: Downloading $audioFileName, $($podcast.AudioLength) bytes "
        $msg += " from $audioURL `r`n"
        Write-Verbose $msg
        Invoke-WebRequest $audioUrl -OutFile $outFileName
        Write-Output $audioFileName  # Return list of downloaded files
      }
    
    } # foreach($podcast in $rssData)
  } # process
  
  end
  {
    Write-Verbose 'Get-PodcastMedia: Ending'
  }
}