#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Using the SQL Provider

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This sample is part of the Zero To Hero with PowerShell and SQL Server
  pre-con. 

  This code is Copyright (c) 2014 - 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

# Set a reference to the local execution folder
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"
Set-Location $dir


#-----------------------------------------------------------------------------#
# Load the SQLServer Module
#-----------------------------------------------------------------------------#
#region Load the SQLServer Module

# First we need to see if the SQLServer module is loaded
Get-Module

# If not loaded, see if it is available
# This will list all available modules on the system. It may take a minute.
$sqlserverModules = Get-Module -ListAvailable | Where-Object Name -eq "SQLServer"
$sqlserverModules 

if ($sqlserverModules.Count -eq 0)
  { "The SQLServer module is not installed on this computer.  :-(" }
else
  { "Hurray! The SQLServer module is installed.  :-)" }


# For normal operations you can just import the SQLServer module
Import-Module SQLServer

#endregion Load the SQLServer Module

#-----------------------------------------------------------------------------#
# A Quick Review on PowerShell Providers
#-----------------------------------------------------------------------------#
#region Providers

#List default Providers
Clear-Host
Get-PSProvider

# Now show how these providers equate to "drives" we can navigate
Clear-Host
Get-PSDrive

# Move to the ENV (environmental variables) drive
Clear-Host
Set-Location env:
Get-ChildItem

Clear-Host
Get-ChildItem | Format-Table -Property Name, Value -AutoSize

# Get a list of aliases
Clear-Host
Set-Location alias:
Get-ChildItem

# Access the variables via Variables provider

$zvar = "Providers are cool!"  # add a variable so we can show it

Clear-Host
Set-Location variable:
Get-ChildItem

# Setting up provider aliases
New-PSDrive -Name BPSD `
            -PSProvider FileSystem `
            -Root "$($env:ONEDRIVE)\PS\Z2HSQL"

Set-Location BPSD:
Get-ChildItem | Format-Table

# When done, either use the remove cmdlet below, otherwise
# when this session ends so does the lifespan of the PSDrive
# Make sure to set your location outside the PSDrive first
Set-Location "$($env:ONEDRIVE)\PS\Z2HSQL"
Remove-PSDrive BPSD

#endregion Providers


#-----------------------------------------------------------------------------#
# A quick tour around the SQL Provider
#-----------------------------------------------------------------------------#
#region Provider Tour

Clear-Host
  
# Navigate to the provider
Set-Location SQLSERVER:\
Get-ChildItem

# Move to the SQL folder to see the Machine  
Set-Location SQLSERVER:\SQL
Get-ChildItem

# Move down to the Machine to see the installed instances
Set-Location SQLSERVER:\SQL\ACDev
Get-ChildItem

# Move down to the instance to see server level objects
Set-Location SQLSERVER:\SQL\ACDev\default
Get-ChildItem

# Providers are variable friendly
# (Note, if you have a named instance replace 'default' with it
$machine = $env:COMPUTERNAME
$instance = "SQLSERVER:\SQL\$machine\default"
"The path to the instance is $instance"

# Move down to databases to see them
Set-Location $instance\Databases
Get-ChildItem

# Note by default system databases are hidden. To see them use the Force switch
Get-ChildItem -Force

# Move down to a specific databases to see its objects
Set-Location $instance\Databases\WideWorldImportersDW
Get-ChildItem

# Move to the table collection to see all the tables
Set-Location $instance\Databases\WideWorldImportersDW\Tables
Get-ChildItem

# Show the table objects for the product table
Set-Location $instance\Databases\WideWorldImportersDW\Tables\Dimension.City
Get-ChildItem

# Show the columns for the table
Set-Location $instance\Databases\WideWorldImportersDW\Tables\Dimension.City\Columns
Get-ChildItem

# and so on!  

# Reset location back to root of the provider
Set-Location SQLServer:\

#endregion Provider Tour


