<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell
  Using PowerShell with JSON

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 -----------------------------------------------------------------------------#>

#region Working with json

#-----------------------------------------------------------------------------#
# Convert a CSV to JSON
#-----------------------------------------------------------------------------#

$csvFilePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\Z2H-15 NameZip.csv'
#psedit $csvFilePath

# Set a header variable so we know the column names
$csvHeader = 'First', 'Last', 'ZipCode'

# Import the CSV data to a variable
$csvData = Import-Csv $csvFilePath -Header $csvHeader

# Convert CSV to Json
$jsonData = $csvData | ConvertTo-Json

# Show what's there
$jsonData

# Write out the results
$jsonFilePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\Z2H-15 NameZip.json'
Set-Content $jsonFilePath $jsonData
psedit $jsonFilePath

#endregion Working with json
