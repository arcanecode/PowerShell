# This script assumes you have placed the module in a folder with
# the name in the $moduleFolder
$moduleFolder = 'PSAzure-Module'

# This is the name of your module, it should match the folder
# name containing the PSAzure module
$moduleName = 'PSAzure'

# The developer stored his work in OneDrive, there is a convienient
# shortcut in PowerShell to get a users OneDrive folder. 
$oneDrive = $env:OneDrive

# Set this to the location where you have unzipped or placed the module
# If not OneDrive, the set it to another folder, such as C:\MyPowerShellCode 
# or whever you store your code
$rootLocation = "$onedrive\Pluralsight\$moduleFolder"

# This sets the location of the root folder
$filesLocation = "$rootLocation\$moduleName"

# Save the current folder location
Push-Location

# Then set it to the root where the three folders from github
# were downloaded (or unzipped) to
Set-Location $rootLocation

# We assume you retained the module heirarchy as found in github
# (or the zip file). This script will load helper functions for
# installing a module
. .\PSAzure-Deploy\DeployModule.ps1

# Gets a list of files in the module folder
$files = Get-ChildItem $filesLocation

# Create an array with the full path and file name for each file
# in the modules folder
$moduleFiles = @()
foreach ($file in $files)
{
  $moduleFiles += $file.FullName  
}

# Now call the installer to copy the files into the users
# WindowsPowerShell folder inside their documents folder
# It uses a helper function from the DeployModule.ps1 script
Install-MyModule -ModuleName 'PSAzure' -Files $moduleFiles -Replace

# For verifcation, we'll call another fuction from DeployModule.ps1,
# which returns the path to the users WindowsPowerShell folder from
# inside their documents folder
$moduleLocation = Get-UserModulePath

# Now add on the folder for this specific module we're installing
$myModuleLocation = "$moduleLocation\$moduleName"

# Now just display the results of our work
Get-ChildItem $myModuleLocation

# Restore the directory the user had previously been in
Pop-Location