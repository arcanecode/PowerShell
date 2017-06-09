<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester - Open-DemoFiles

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This file is just a harnass to make it easier to explore and run individual
  tests on the NoAgenda modules. Having this type of script during development
  can make it easier to develop and test your code, although is not required.

  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 

  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# Load up some variables with paths to the various files. 
$demoPath = "$($env:OneDrive)\PS\Pester-Course\demo\"
$pnaPath = "$($demoPath)completed-final-module\Podcast-NoAgenda\"
$pdbPath = "$($demoPath)completed-final-module\Podcast-Database\"
$pdaPath = "$($demoPath)completed-final-module\Podcast-Data\"

Set-Location $demoPath

# Show how to get the Pester module -------------------------------------------
psedit "$($demoPath)completed-final-module\Get-Pester.ps1"

# Import the Pester module ----------------------------------------------------
Import-Module Pester
Get-Module -Name Pester | Select-Object -ExpandProperty ExportedCommands

# You can explore the functions in Pester by looking at it's code base
Explorer (Get-Module -Name Pester).ModuleBase

#------------------------------------------------------------------------------
# Open the basic Intro files
#------------------------------------------------------------------------------
psedit "$($demoPath)completed-final-module\PesterIntroTest.ps1"
psedit "$($demoPath)completed-final-module\PesterIntroCall.ps1"


<#-----------------------------------------------------------------------------
  Tests for the NoAgenda Module
-----------------------------------------------------------------------------#>
#region NoAgendaTests

# Load the module and the tests for it
psedit "$($pnaPath)Podcast-NoAgenda.psm1"
psedit "$($pnaPath)Podcast-NoAgenda.psd1"
psedit "$($pnaPath)Podcast-NoAgenda.Module.tests.ps1"
Invoke-Pester "$($pnaPath)Podcast-NoAgenda.Module.tests.ps1" -Tag 'Acceptance'

# Get the RSS feed and its tests
psedit "$($pnaPath)function-Get-PodcastData.ps1"
psedit "$($pnaPath)function-Get-PodcastData.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Get-PodcastData.tests.ps1" 
Invoke-Pester "$($pnaPath)function-Get-PodcastData.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Get-PodcastData.tests.ps1" -Tag 'Acceptance'

# Download the images for each podcast
psedit "$($pnaPath)function-Get-PodcastImage.ps1"
psedit "$($pnaPath)function-Get-PodcastImage.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Get-PodcastImage.tests.ps1"
Invoke-Pester "$($pnaPath)function-Get-PodcastImage.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Get-PodcastImage.tests.ps1" -Tag 'Acceptance'
Explorer 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Data'

# Download the audio file for each podcast
psedit "$($pnaPath)function-Get-PodcastMedia.ps1"
psedit "$($pnaPath)function-Get-PodcastMedia.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Get-PodcastMedia.tests.ps1" 
Invoke-Pester "$($pnaPath)function-Get-PodcastMedia.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Get-PodcastMedia.tests.ps1" -Tag 'Acceptance'
Explorer 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Data'

# Take the Podcast data and create an XML structure in memory
psedit "$($pnaPath)function-Format-PodcastXML.ps1"
psedit "$($pnaPath)function-Format-PodcastXML.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Format-PodcastXML.tests.ps1"
Invoke-Pester "$($pnaPath)function-Format-PodcastXML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Format-PodcastXML.tests.ps1" -Tag 'Acceptance'

# Write out the XML from the in memory structure
psedit "$($pnaPath)function-Write-PodcastXML.ps1"
psedit "$($pnaPath)function-Write-PodcastXML.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Write-PodcastXML.tests.ps1" 
Invoke-Pester "$($pnaPath)function-Write-PodcastXML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Write-PodcastXML.tests.ps1" -Tag 'Acceptance'
psedit "$($pdaPath)NoAgenda.xml"

# Take the Podcast data and create an XML structure in memory
psedit "$($pnaPath)function-Format-PodcastHtml.ps1"
psedit "$($pnaPath)function-Format-PodcastHtml.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Format-PodcastHtml.tests.ps1"
Invoke-Pester "$($pnaPath)function-Format-PodcastHtml.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Format-PodcastHtml.tests.ps1" -Tag 'Acceptance'

# Write out the HTML from the in memory structure
psedit "$($pnaPath)function-Write-PodcastHtml.ps1"
psedit "$($pnaPath)function-Write-PodcastHtml.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Write-PodcastHtml.tests.ps1" 
Invoke-Pester "$($pnaPath)function-Write-PodcastHtml.tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pnaPath)function-Write-PodcastHtml.tests.ps1" -Tag 'Acceptance'
Start-Process "$($pdaPath)NoAgenda.html"

# Test the main function, which calls everything else
psedit "$($pnaPath)function-Get-NoAgenda.ps1"
psedit "$($pnaPath)function-Get-NoAgenda.Tests.ps1"
Invoke-Pester "$($pnaPath)function-Get-NoAgenda.Tests.ps1"

# To run every single test, simply set location to the folder with the
# tests and invoke pester
Set-Location $pnaPath
Invoke-Pester 

# This is just a little support function for doing cleanup
psedit "$($pnaPath)function-Clear-OutputPathFolder.ps1"

#endregion NoAgendaTests


<#-----------------------------------------------------------------------------
  BONUS Material!

  I've included a handy script called DeployModule which will let you copy
  a module from your development folder to the windows PowerShell folder
  located in your users Documents folder. This makes it easier for testing
-----------------------------------------------------------------------------#>

#region Bonus

# Run the script to load the Install-MyModule function into memory
. "$($demoPath)completed-final-module\DeployModule.ps1"

# This will copy all of the files located in the second parameter (in this
# example $pnaPath) to the module folder of Podcast-NoAgenda. The Replace
# switch will force an overwrite of existing files. 
Install-MyModule "Podcast-NoAgenda" "$($pnaPath)*.*" -Replace

# Now reload the module from the newly deployed to folder. Using -Force
# to force the reload (by default PowerShell won't reload if it is already
# in memory)
Import-Module Podcast-NoAgenda -Force

#endregion Bonus 

<#-----------------------------------------------------------------------------
  Tests for the Database module
  The database module has it's own set of tests, and it's own version of
  an Open-DemoFiles script. You can open it using the command below.

  In addition to working with 
-----------------------------------------------------------------------------#>

#region Database

Set-Location $pdbPath 

psedit "$($pdbPath)Podcast-Database.psm1"
psedit "$($pdbPath)Podcast-Database.psd1"
Invoke-Pester "$($pdbPath)Podcast-Database.Module.Tests.ps1"

psedit "$($pdbPath)function-New-PodcastDatabase.ps1"
psedit "$($pdbPath)function-New-PodcastDatabase.Tests.ps1"
Invoke-Pester "$($pdbPath)function-New-PodcastDatabase.Tests.ps1"

psedit "$($pdbPath)function-Test-PodcastDatabase.ps1"
psedit "$($pdbPath)function-Test-PodcastDatabase.Tests.ps1"
Invoke-Pester "$($pdbPath)function-Test-PodcastDatabase.Tests.ps1"

psedit "$($pdbPath)function-New-PodcastTable.ps1"
psedit "$($pdbPath)function-New-PodcastTable.Tests.ps1"
Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" 

# With strict, pending and skipped tests are executed
Invoke-Pester "$($pdbPath)\function-New-PodcastTable.Tests.ps1" -Strict

psedit "$($pdbPath)function-Test-PodcastTable.ps1"
psedit "$($pdbPath)function-Test-PodcastTable.Tests.ps1"
Invoke-Pester "$($pdbPath)function-Test-PodcastTable.Tests.ps1"


psedit "$($pdbPath)function-Update-PodcastTable.ps1"
psedit "$($pdbPath)function-Update-PodcastTable.Tests.ps1"
Invoke-Pester "$($pdbPath)function-Update-PodcastTable.Tests.ps1" -Tag 'Unit'
Invoke-Pester "$($pdbPath)function-Update-PodcastTable.Tests.ps1" -Tag 'Acceptance'


# This function is called by one of the other functions to clean up
# the encoding. It doesn't currently have any tests
psedit "$($pdbPath)function-Remove-PodcastHtmlEncoding.ps1"

# This script was written to show that the tests could include their own
# set of specialized functions you could call. Various tests call the
# functions in here, and by placing these in functions we get good reuse
# and streamline the main tests.
psedit "$($pdbPath)Podcast-Database-Tests-Helper-Functions.ps1"

#endregion Database


<#-----------------------------------------------------------------------------
  Advanced Pester 

  This section contains examples of advanced ways to invoke Pester testing
-----------------------------------------------------------------------------#>

#region Advanced Invoke-Pester options 

# Create test output compatible with NUnit ------------------------------------
Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" `
              -OutputFile "$($pdbPath)nunit.xml" `
              -OutputFormat NUnitXml

psedit "$($pdbPath)nunit.xml"

# Code Coverage ---------------------------------------------------------------
Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" `
              -CodeCoverage "$($pdbPath)function-New-PodcastTable.ps1"


# PassThru --------------------------------------------------------------------
$testResults = Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" 
$testResults

$testResults = Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" -PassThru
$testResults 

# Strict ----------------------------------------------------------------------

# Without strict, any skipped or pending tests are just listed, but don't fail
Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1"

# With Strict, skipped or pending tests generate a failure
Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" -Strict


# EnableExit ------------------------------------------------------------------
# Note, don't run this in the ISE or it will close it!
# This is used to cause PowerShell to exit with a return code
Invoke-Pester "$($pdbPath)function-New-PodcastTable.Tests.ps1" -EnableExit

# Instead, open up a new PowerShell command window and enter (or copy/paste)
# the lines below.
$demoPath = "$($env:OneDrive)\PS\Pester-Course\demo\"
$pdbPath = "$($demoPath)completed-final-module\Podcast-Database\"
$x = powershell.exe "Invoke-Pester $($pdbPath)function-New-PodcastTable.Tests.ps1 -EnableExit"

# then print out the value of $x
$x

#endregion Advanced Invoke-Pester options 



