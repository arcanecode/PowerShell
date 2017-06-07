<#
  .SYNOPSIS
  Deletes all podcast related files from the target folder
  
  .DESCRIPTION
  In the event a user wants to do a complete reset of the output folder, 
  this function will delete all files with the associated extensions:
  jpg png xml mp3

  Warning: This is irrevocable with no "are you sure" type messages.
  
  .INPUTS
  OutputPathFolder - The folder where podcast related files should be deleted
  
  .OUTPUTS
  None
  
  .EXAMPLE
  Clear-OutputPathFolder 'C:\Podcasts\NoAgenda'

  .EXAMPLE
  Clear-OutputPathFolder -OutputPathFolder 'C:\Podcasts\NoAgenda'

  .EXAMPLE
  $outputfolder = 'C:\Podcasts\NoAgenda'
  Clear-OutputPathFolder -OutputPathFolder $outputfolder

#>
function Clear-OutputPathFolder()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    [string] $OutputPathFolder = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Data\'
  )

  process
  {  
    Remove-Item "$($OutputPathFolder)*.jpg"
    Remove-Item "$($OutputPathFolder)*.png"
    Remove-Item "$($OutputPathFolder)*.xml"
    Remove-Item "$($OutputPathFolder)*.mp3"
  }

}
