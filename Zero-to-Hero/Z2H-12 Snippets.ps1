<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell
  Snippets

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 -----------------------------------------------------------------------------#>

# Use CTRL+J to bring up snippet list, or Edit, Start Snippets on the menu

# Insert your own snippet here

# List the custom snippets you have
Get-IseSnippet

# Snippets are stored in the following folder
Get-ChildItem "$home\Documents\WindowsPowerShell\Snippets"

# To create a snippet use the New-IseSnippet command
New-IseSnippet -Title Comment-BasedHelp `
               -Force `
               -Description "A template for comment-based help." `
               -Text "<#
    .SYNOPSIS             
    .DESCRIPTION            
    .PARAMETER  <Parameter-Name>
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
#>" 



# Only way to delete is to remove the file
Remove-Item "$home\Documents\WindowsPowerShell\Snippets\Comment-BasedHelp.snippets.ps1xml"
Get-IseSnippet
# Note it won't be gone from the ISE's list until you reload the IDE