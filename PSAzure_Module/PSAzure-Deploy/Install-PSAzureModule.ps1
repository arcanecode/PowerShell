$moduleName = 'PSAzure'
$moduleFolder = 'PSAzure-Module'

$oneDrive = $env:OneDrive

$rootLocation = "$onedrive\Pluralsight\$moduleFolder"
$filesLocation = "$rootLocation\$moduleName"

Push-Location
Set-Location $rootLocation

. .\DeployModule.ps1

$files = Get-ChildItem $filesLocation

$moduleFiles = @()
foreach ($file in $files)
{
  $moduleFiles += $file.FullName  
}


Install-MyModule -ModuleName 'PSAzure' -Files $moduleFiles -Replace

$moduleLocation = Get-UserModulePath
$myModuleLocation = "$moduleLocation\PSAzure"

Get-ChildItem $myModuleLocation

Pop-Location