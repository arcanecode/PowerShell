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
  Takes the passed in data and reformats it as an HTML webpage.

  .DESCRIPTION
  Takes the output of Get-PodcastData and uses it to generate an HTML
  webpage suitible for display at PodcastSight

  .INPUTS
  PodcastData - The data generated from Get-PodcastData

  .OUTPUTS
  None
  
  .EXAMPLE
  ConvertTo-PodcastHtml -PodcastData $data

#>
function ConvertTo-PodcastHtml()
{ 
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true
               , ValueFromPipeline = $true
               , ValueFromPipelineByPropertyName = $true
               ) 
    ]
    $PodcastData
  )

  begin
  {
    Write-Verbose 'Get-PodcastHtml: Beginning'
    
    $htmlHeader = @"
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
      <script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
      <script src="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
      </head>
      <body>
      
      <div data-role="page" id="pageone">
        <div data-role="header">
          <h1>PodcastSight - The home for the best podcast in the universe</h1>
        </div>
      
        <div data-role="main" class="ui-content">
          <h1>No Agenda Show</h1>
"@
    Write-Output $htmlHeader
  } # begin

  process
  {
    foreach ($podcast in $PodcastData)
    {
      Write-Verbose "Get-PodcastHtml: Processing Podcast $($podcast.Title)"
      $imgUrl = $podcast.ImageUrl
      $imgFileName = $imgUrl.Split('/')[-1]
      $outFileName = "$($OutputPathFile)$($imgFileName)"
      $title = $podcast.Title
      $embedded = $podcast.EmbeddedHtml
      $embedded = $embedded.Replace('<p>Show Notes</p>', '')
      $embedded = $embedded.Replace('</p>', "</p>`r`n              ")
      $embedded = $embedded.Replace('align="right" border="0" vspace="5"', 'align="middle" border="0" vspace="5"')
  
      $html = @"
          <div data-role="collapsible">
            <h2><img src="$($outFileName)" 
                 alt="No Agenda Episode Image" align="left" border="0" vspace="0" 
                 width="64" height="64" hspace="15"
                 >
                 <p/>
                 $title
            </h2>
            <ul data-role="listview">
              <li>
                $embedded
              </li>
            </ul>
          </div>
    
"@  
      Write-Output $html    
    }
  } # process
  
  end
  {
    $htmlFooter = @"
  
    </div>
  
    <div data-role="footer">
      <h3><a href="http://noagendashow.com">http://noagendashow.com</a></h3>
    </div>
  </div> 
  
  </body>
  </html>
  
"@

    Write-Output $htmlFooter

    Write-Verbose 'Get-PodcastHtml: Completed'
  } # end

} # function Get-Html