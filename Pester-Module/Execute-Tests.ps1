<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester
  The code in this script provides examples on how to execute Pester tests
  in a variety of methods.

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>


# Pester
Import-Module Pester

# Move to the folder with your module code and tests
$testsFolder = 'C:\PowerShell\Pester-Module\Podcast-NoAgenda'
Set-Location  $testsFolder 

# Run the structure tests
Invoke-Pester "$testsFolder\Podcast-NoAgenda.Module.Tests.ps1" 

# Run all tests in the file
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" 

# Run only tests tagged with Unit
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Unit'

# Run only tests tagged with Acceptance
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1"
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-ConvertTo-PodcastHtml.tests.ps1"
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastHtml.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastHtml.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-ConvertTo-PodcastXML.tests.ps1"
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastXML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastXML.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Write-PodcastHTML.tests.ps1" 
Invoke-Pester "$testsFolder\function-Write-PodcastHTML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Write-PodcastHTML.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" 
Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" -Tag 'Acceptance'


# When you don't specify a file name, Pester will attempt to execute all
# files with a .Tests.ps1 extension. You can add the tag parameter to 
# limit which sets of tests get run
Invoke-Pester                       # Call all tests
Invoke-Pester -Tag 'Unit'           # Call just Unit Tests
Invoke-Pester -Tag 'Acceptance'     # Call just Acceptance Tests

# You can also execte a single, specific test by passing in its name
Invoke-Pester -TestName 'Write-PodcastXML Unit Tests'  # Call a specific test


