# Getting Pester
$PSVersionTable # Confirm on version 5

<#
  PowerShell 5 implemented a new module called Package Mangement (Formerly known
  as OneGet). This makes it easy to download updates of various PowerShell 
  modules, most notably Pester
#>
Import-Module PackageManagement

# Display the commands in PackageManagement
Get-Command -Module PackageManagement

# Shows the package in the repository (If prompted to install nuget, say yes)
Find-Package Pester

<# 
  Installing Pester
  First, make sure you are running PowerShell as an admin!
  By default 3.3.5 ships with Windows 10. To install the latest 
  you have to use the -Force switch. (If it's not installed, using
  -Force won't have a negative impact)
#>
Install-Module Pester -Force

# Once you have installed the latest, hereafter you can 
# use Update-Module to keep it up to date. 
Update-Module Pester -Force

