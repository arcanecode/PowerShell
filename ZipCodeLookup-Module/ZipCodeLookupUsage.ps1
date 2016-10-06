<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Using the Zip Code Lookups Module

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 

  Notes
  This script demonstrates how to use a module which contains a class.
-----------------------------------------------------------------------------#>

# Assemble our module name into variables, makes it easier to move
$modulePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\'
Set-Location $modulePath

$moduleName = 'ZipCodeLookup_WithID'

# Note for this simple demo we did not create a PSD1 file, and will just
# load the PSM1 module directly
$module = "$($modulePath)$($moduleName).psm1"

# To use a module, you first need to import it
# Since this is a develoment environment we'll include the -Force switch
Import-Module $module -Force

#-----------------------------------------------------------------------------#
# In this first section we will create a new instance of the class and 
# work with it
#-----------------------------------------------------------------------------#

# Create a new instance of the Zip Code Lookup
$myZip = New-ZipCodeLookup

# Set the zip code then call the lookup
$myZip.ZipCode = '35051'
$myZip.Lookup()

# Display the results
$myZip.City
$myZip.State

# Call again, passing in the zip code into the overload of the lookup function
$myZip.Lookup('90210')
"$($myZip.ZipCode) is located in $($myZip.City), $($myZip.State)"

# Demonstrate the error when the zip code is not five characters
$myZip.Lookup('')

# Demonstrate the error when the zip code is not numeric
$myZip.Lookup('abcde')

# Show how to trap for the error
try
{
  $myZip.Lookup('abcde')
}
catch
{
  Write-Host "Error!" -ForegroundColor Yellow
  Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Yellow
}


#-----------------------------------------------------------------------------#
# In this section, look at how to use the pipeline enabled function to return
# a class data
#-----------------------------------------------------------------------------#

# Use the cmdlet to call the lookup and return an object
$newZip = Get-ZipCodeData('84025')
"$($newZip.ZipCode) is located in $($newZip.City), $($newZip.State)"

# Now call it via pipeline
$zipArray = '90210', '35051', '84025'
$zipResult = $zipArray | Get-ZipCodeData

$zipResult

# Use a for each to iterate over the result
foreach ($z in $zipResult)
{
  "$($z.ZipCode) is located in $($z.City), $($z.State)"
}

# What about bad data in the pipe?
$zipArray = '90210','1', '35051', 'abcde', '84025', '99999'
$zipResult = $zipArray | Get-ZipCodeData

$zipResult

# Suppress the red errors by catching but doing nothing
try
{
  $zipArray = '90210','1', '35051', 'abcde', '84025', '99999'
  $zipResult = $zipArray | Get-ZipCodeData
}
catch
{
  # Do Nothing
}
finally
{
  $zipResult
}


