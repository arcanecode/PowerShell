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
  Downloads the image files associated with the podcast feed
  
  .DESCRIPTION
  Uses the passed in RSS feed to get the names of the image files, 
  then checks to see if the file exists in the output folder. 
  If it does not exist, the audio file is downloaded.
  
  .INPUTS
  rssData - The RSS feed returned by Get-PodcastData
  OutputPathFolder - The target folder where the audio files should exist
  
  .OUTPUTS
  No values are returned. 
  
  .EXAMPLE
  $rssData = Get-PodcastData
  Get-PodcastImage $rssData

  .EXAMPLE
  $rssData = Get-PodcastData
  $folder = 'C:\Temp'
  Get-PodcastImage $rssData $folder

  .EXAMPLE
  $rssData = Get-PodcastData
  $folder = 'C:\Temp'
  Get-PodcastImage -rssData $rssData -OutputPathFolder $folder

  .LINK
  Get-PodcastData 
  
#>
function Get-PodcastImage()
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
    [string] $OutputPathFolder = 'C:\PowerShell\Pester-Module\Podcast-Data\'
  )

  begin 
  {
    Write-Verbose 'Get-PodcastImage: Starting'
  }
  
  process 
  {
    foreach($podcast in $rssData)
    {
      $imgFileName = $podcast.ImageUrl.Split('/')[-1]
      $outFileName = "$($OutputPathFolder)$($imgFileName)"
    
      # If the file exists, skip it, otherwise download it    
      if ( Test-Path $outFileName )
      {
        Write-Verbose "`r`nGet-PodcastImage: Skipping $imgFileName, it already exists as $outFileName`r`n"
      }
      else
      {      
        Write-Verbose "`r`nGet-PodcastImage: Downloading $imgFileName from $($podcast.ImageUrl) `r`n"
        Invoke-WebRequest $podcast.ImageUrl -OutFile $outFileName
        Write-Output $imgfileName 
      }
    
    } # foreach($podcast in $rssData)
  } # process

  end
  {
    Write-Verbose 'Get-PodcastImage: Ending'
  }
}