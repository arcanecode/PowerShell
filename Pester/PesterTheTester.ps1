# Pester the Tester
# Open-Demofiles

$host.ui.RawUI.WindowTitle = 'Pester Course Completed Demo'
psedit 'C:\PS\Pester-course\demo\completed-final-module\Get-Pester.ps1'

$naPath = 'C:\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda'
$testsFolder = 'C:\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda'

Set-Location 'C:\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda\'

Import-Module Pester

# Podcast-NoAgenda
psedit "$naPath\Podcast-NoAgenda.psm1"
psedit "$naPath\Podcast-NoAgenda.psd1"
psedit "$naPath\Podcast-NoAgenda.Module.Tests.ps1"
Invoke-Pester "$testsFolder\Podcast-NoAgenda.Module.Tests.ps1" 

# Get-NoAgenda
psedit "$naPath\function-Get-PodcastData.ps1"
psedit "$naPath\function-Get-PodcastData.Tests.ps1"
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Acceptance'

# Get-PodcastImage
psedit "$naPath\function-Get-PodcastImage.ps1"
psedit "$naPath\function-Get-PodcastImage.Tests.ps1"
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1"
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Acceptance'
