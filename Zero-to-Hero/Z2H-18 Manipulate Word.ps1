<#-----------------------------------------------------------------------------
  Updating and Sorting the Microsoft Word QuickStyle Gallery, ArcaneCode style!

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This script is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  No warranty or guarentee is implied or expressly granted. Use at your own
  risk. 

  This script may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# Set the path / file name of the file you want to update
$wordFile = 'C:\Users\Arcane\OneDrive\PS\Z2H\\Robert Cain New_Template_Normal_Preface_OS.doc'

# Make a backup before we do changes. Note if the BAK exists it will be overwritten
$bakfile = $wordFile + '.bak'
Copy-Item -Path $wordFile -Destination $bakfile -Force

# Create an array of the styles you wish, in the order you want 
# them to appear in the QuickStyle area 
$myStyles = @( 'Normal [PACKT]',
               'Numbered Bullet [PACKT]',
               'Screen Text [PACKT]',
               'Code In Text [PACKT]',
               'Code Within Bullets [PACKT]',
               'Code listing [PACKT]',
               'Italics [PACKT]',
               'Figure [PACKT]',
               'Chapterref [PACKT]',
               'Bold [PACKT]',
               'Heading 1,Heading 1 [PACKT]',
               'Heading 2,Heading 2 [PACKT]',
               'Heading 3,Heading 3 [PACKT]',
               'Tip [PACKT]',
               'Layout Information [PACKT]',
               'Figure Caption [PACKT]',
               'Part Heading [PACKT]',
               'URL [PACKT]'
             )

# Load up the style type enumerations.
$wdStyleTypeParagraph = 1  # Paragraph style.
$wdStyleTypeCharacter = 2  # Body character style.
$wdStyleTypeTable = 3      # Table style.
$wdStyleTypeList = 4       # List style.

# Create a new instance of Word
$word = New-Object -ComObject Word.Application

# This is optional, if set it will display Word and let you watch the fun
$word.Visible = $true

# Open the document you wish to reset the styles for
$doc = $word.Documents.Open($wordFile)

# First, reset all styles to not be Quick Styles, 
# and set the priorty to 100 (which will be 'last' in Word)
foreach ($sty in $doc.Styles)
{
  # Only these two types can be QuickStyles
  if ( ($sty.Type -eq $wdStyleTypeCharacter) -or ($sty.Type -eq $wdStyleTypeParagraph) ) 
    { $sty.QuickStyle = $false }
  
  $sty.Priority = 100
}

# Now set the styles like we wan't 'em!
$priority = 1
foreach ($mySty in $myStyles)
{ 
  # Setting to true will make the style appear in the QuickStyle gallery
  $doc.Styles($mySty).QuickStyle = $true
  # The priority is an integer which determines the sort order within the QS gallery
  $doc.Styles($mySty).Priority = $priority++
}

# Save the document. 
$doc.Save()

# Close up word (Optional, if you want to start editing 
# right away you can comment this out)
$doc.Close()