# Path to demos - Set this to where you want to store your code
$dir = "$($env:OneDrive)\Pluralsight\PSAzure-Module\PSAzure-Examples"
Set-Location $dir

# First login manually
Connect-AzureRmAccount

# Now save your context locally (Force will overwrite if there)
$path = "$dir\ProfileContext.ctx"
Save-AzureRmContext -Path $path -Force
