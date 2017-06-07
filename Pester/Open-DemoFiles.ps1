$host.ui.RawUI.WindowTitle = 'Pester Course Completed Demo'
$host.ui.RawUI.WindowTitle = 'Pester Course Database Demo'

#region Load Podcast-NoAgenda --------------------------------------------------

psedit 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Get-Pester.ps1'

$naPath = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda'
Set-Location 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda\'

psedit "$naPath\Podcast-NoAgenda.psm1"
psedit "$naPath\Podcast-NoAgenda.psd1"
psedit "$naPath\function-Get-NoAgenda.ps1"
psedit "$naPath\function-ConvertTo-PodcastHtml.ps1"
psedit "$naPath\function-ConvertTo-PodcastXML.ps1"
psedit "$naPath\function-Get-PodcastData.ps1"
psedit "$naPath\function-Get-PodcastImage.ps1"
psedit "$naPath\function-Get-PodcastMedia.ps1"
psedit "$naPath\function-Write-PodcastHtml.ps1"
psedit "$naPath\function-Write-PodcastXML.ps1"


psedit "$naPath\Podcast-NoAgenda.Module.Tests.ps1"
psedit "$naPath\function-Get-NoAgenda.Tests.ps1"
psedit "$naPath\function-ConvertTo-PodcastHtml.Tests.ps1"
psedit "$naPath\function-ConvertTo-PodcastXML.Tests.ps1"
psedit "$naPath\function-Get-PodcastData.Tests.ps1"
psedit "$naPath\function-Get-PodcastImage.Tests.ps1"
psedit "$naPath\function-Get-PodcastMedia.Tests.ps1"
psedit "$naPath\function-Write-PodcastHtml.Tests.ps1"
psedit "$naPath\function-Write-PodcastXML.Tests.ps1"
#endregion Load Podcast-NoAgenda

#region Load Podcast-Database --------------------------------------------------
$dbPath = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Database'
Set-Location $dbPath

psedit "$dbPath\Podcast-Database.psm1"
psedit "$dbPath\Podcast-Database.psd1"
psedit "$dbPath\function-Test-PodcastDatabase.ps1"
psedit "$dbPath\function-New-PodcastDatabase.ps1"
psedit "$dbPath\function-Test-PodcastTable.ps1"
psedit "$dbPath\function-New-PodcastTable.ps1"
psedit "$dbPath\function-Update-PodcastTable.ps1"

psedit "$dbPath\Podcast-Database.Module.Tests.ps1"
psedit "$dbPath\function-Test-PodcastDatabase.Tests.ps1"
psedit "$dbPath\function-New-PodcastDatabase.Tests.ps1"
psedit "$dbPath\function-Test-PodcastTable.Tests.ps1"
psedit "$dbPath\function-New-PodcastTable.Tests.ps1"
psedit "$dbPath\function-Update-PodcastTable.Tests.ps1"
psedit "$dbPath\Podcast-Database-Tests-Helper-Functions.ps1"
#endregion Load Podcast-Database


#region Pester Podcast-NoAgenda ------------------------------------------------
# Pester
Import-Module Pester

$testsFolder = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda'
Set-Location  $testsFolder 

# Run tests for each file
Invoke-Pester "$testsFolder\Podcast-NoAgenda.Module.Tests.ps1" 

Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1"
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Acceptance'
# Restore
Get-PodcastData | Get-PodcastImage 

Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" -Tag 'Acceptance'
Get-PodcastData | Get-PodcastMedia

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
Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" 

Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" -Tag 'Acceptance'


# Run all the tests
Invoke-Pester 
Invoke-Pester -Tag 'Unit'           # Call just Unit Tests
Invoke-Pester -Tag 'Acceptance'     # Call just Acceptance Tests
Invoke-Pester -TestName 'Write-PodcastXML Unit Tests'  # Call a specific test

#endregion Pester Podcast-NoAgenda



#region Pester Podcast-Database ------------------------------------------------
Import-Module Pester

$dbPath = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Database'
Set-Location $dbPath 

psedit "$dbPath\Podcast-Database.Module.Tests.ps1"
psedit "$dbPath\function-Test-PodcastDatabase.Tests.ps1"
psedit "$dbPath\function-New-PodcastDatabase.Tests.ps1"
psedit "$dbPath\function-Test-PodcastTable.Tests.ps1"
psedit "$dbPath\function-New-PodcastTable.Tests.ps1"
psedit "$dbPath\function-Update-PodcastTable.Tests.ps1"
psedit "$dbPath\function-Remove-PodcastHtmlEncoding.Tests.ps1"
psedit "$dbPath\Podcast-Database-Tests-Helper-Functions.ps1"


Invoke-Pester "$dbPath\Podcast-Database.Module.Tests.ps1"
Invoke-Pester "$dbPath\function-Test-PodcastDatabase.Tests.ps1"
Invoke-Pester "$dbPath\function-New-PodcastDatabase.Tests.ps1"
Invoke-Pester "$dbPath\function-Test-PodcastTable.Tests.ps1"

Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" 

# With strict, pending and skipped tests are executed
#Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -Strict

Invoke-Pester "$dbPath\function-Update-PodcastTable.Tests.ps1"

#endregion Pester Podcast-Database


#region Advanced Invoke-Pester options ----------------------------------------
# Create test output compatible with NUnit
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" `
              -OutputFile "$dbPath\nunit.xml" `
              -OutputFormat NUnitXml

psedit "$dbPath\nunit.xml"

# Code Coverage
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" `
              -CodeCoverage "$dbPath\function-New-PodcastTable.ps1"


# PassThru
$testResults = Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" 
$testResults

$testResults = Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -PassThru
$testResults 

# Strict

# Without strict, any skipped or pending tests are just listed, but don't fail
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1"

# With Strict, skipped or pending tests generate a failure
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -Strict


# EnableExit
# Note, don't run this in the ISE or it will close it!
# This is used to cause PowerShell to exit with a return code
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -EnableExit

# Instead, open up a new PowerShell command window and enter (or copy/paste)
# the line below.
$x = powershell.exe 'Invoke-Pester C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\Podcast-Database\function-New-PodcastTable.Tests.ps1 -EnableExit'

# then print out the value of $x
$x

#endregion Advanced Invoke-Pester options 


