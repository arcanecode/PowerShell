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
  Takes the passed in XML and saves it as a file
  
  .DESCRIPTION
  Saves the pass in XML data and writes it out as a file. 
  
  .INPUTS
  xmlData - The formatted XML as created by the ConvertTo-PodcastXml function
  xmlFilePath - The file name and path to store the data to
  
  .OUTPUTS
  A file is created with the XML data.
  
  .EXAMPLE
  $rssData = Get-PodcastData
  $xmlData = ConvertTo-PodcastXml $rssData
  Write-PodcastXML $xmlData

  .EXAMPLE
  $rssData = Get-PodcastData
  $xmlData = ConvertTo-PodcastXml $rssData $folder
  Write-PodcastXML $xmlData 'C:\Data\NoAgenda.xml'


  .EXAMPLE
  $rssData = Get-PodcastData
  $xmlData = ConvertTo-PodcastXml -rssData $rssData 
  Write-PodcastXML -xmlData $xmlData -xmlFilePath 'C:\Data\NoAgenda.xml'

  .LINK
  Get-PodcastData 
  
#>
function Write-PodcastXML()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true
               , ValueFromPipeline = $true
               , ValueFromPipelineByPropertyName = $true
               ) 
    ]
    [string[]]$XMLData
    ,   
    [parameter (Mandatory = $false) ]
    [string] $XMLFilePath = 'C:\PS\Pester-course\demo\completed-final-module\Podcast-Data\NoAgenda.xml'
  )
  begin 
  { 
    Write-Verbose "Write-PodcastXML: Writing $xmlFilePath" 
    $xmlFileData = ''
  }

  process 
  {
    foreach ($line in $xmlData)
    {
      $xmlFileData += "$line`r`n"
    }
  }

  end 
  {
    $xmlFileData | Out-File $xmlFilePath 
  }

}