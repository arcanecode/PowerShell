<#-----------------------------------------------------------------------------
  PowerShell for Developers - Automate Excel

  Manipulate an Excel file. Open a CSV in Excel, save it as a true Excel format,
  then bold column headers and resize each column.fs

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  The code in this collection of demos is Copyright (c) 2018 Robert C. Cain. 
  All rights reserved.
  
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted.
   
  This code may not be reproduced in whole or in part without the express
  written consent of the author. Your are free to repurpose it for your
  projects, with no warranty or guarentees provided.

  Works with PowerShell 5.1 for Windows.
  Not compatible with PowerShell Core due to Office using ComObjects
-----------------------------------------------------------------------------#>

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

# Set a reference to the local execution folder on Windows
$dir = "C:\PowerShell\PS-For-Devs\"

Set-Location $dir

# Set our file names
$csvFile = "$($dir)CustData.csv"
$xlsxFile = "$($dir)CustData.xlsx"

# Remove the Excel file if it was leftover from a previous run,
# but don't error out if it does not exist
Remove-Item -Path $xlsxFile -ErrorAction SilentlyContinue

# Create a new variable referencing Excel in memory
$excel = New-Object -ComObject Excel.Application

# For this demo, make Excel visible so we can see what happens
$excel.Visible = $true

# Open the CSV file we created in the "Export from SQL.ps1" demo
$workbook = $excel.Workbooks.Open($csvFile)

# Save as XLSX to convert to a full Excel Spreadsheet
# The following value is an enumeration, value from the online docs at:
# https://docs.microsoft.com/en-us/office/vba/api/excel.xlfileformat
$xlWorkbookDefault = 51 
$workbook.SaveAs( $xlsxFile, $xlWorkbookDefault)

# Get a reference to the first worksheet in our Worksheets collection
$worksheet = $workbook.Worksheets.Item(1)

# Bold the column headers in the first row
$worksheet.Range('A1:F1').Font.Bold = $true

# Determine a range that will encompass all rows for our columns
$rangeAddress = "A1:F$($worksheet.Rows.Count.ToString())"

# Autofit those columns
$worksheet.Range($rangeAddress).Columns.Autofit()

# Save our hard work!
$workbook.Save()

# Close Excel 
$excel.Quit()
