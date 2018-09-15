<#-----------------------------------------------------------------------------
  PowerShell for Developers - Working with Data
  
  Export data from SQL Server, then see how to manipulate it (or any other
  types of data) as CSV, XML, and JSON data. 

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  The code in this collection of demos is Copyright (c) 2018 Robert C. Cain. 
  All rights reserved.
  
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted.
   
  This code may not be reproduced in whole or in part without the express
  written consent of the author. Your are free to repurpose it for your
  projects, with no warranty or guarentees provided.

  This module has not yet been tested with PowerShell 6.1/Core
-----------------------------------------------------------------------------#>

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

# Load the SqlServer module
Import-Module SqlServer

# Set a reference to the local execution folder
$dir = "C:\PowerShell\PS-For-Devs"
Set-Location $dir

# Read data from SQL ----------------------------------------------------------

# Create a SQL query to fetch data
$sql = @"
SELECT cu.[CustomerID]
     , cu.[CustomerName]
     , cu.[DeliveryAddressLine2]
     , cu.[DeliveryAddressLine1]
     , ci.[CityName]
     , st.[StateProvinceCode]
  FROM [Sales].[Customers] cu
  JOIN [Application].[Cities] ci
    ON cu.[DeliveryCityID] = ci.CityID
  JOIN [Application].[StateProvinces] st
    ON ci.StateProvinceID = st.StateProvinceID
"@

# Create the connection string
$connectionString = 'Data Source=localhost;Initial Catalog=WideWorldImporters;Integrated Security=True;'

# Execute the query to show the results
Clear-Host
Invoke-Sqlcmd -Query $sql `
              -ConnectionString $connectionString 

# Now run the query again and put the results in a variable
$outputData = Invoke-Sqlcmd -Query $sql `
                            -ConnectionString $connectionString 


# Now it's in a variable we can do things with it.

# CSV -------------------------------------------------------------------------

# Let's save it to a CSV
$csvFile = "$($dir)\CustData.csv"
$outputData | Export-Csv -Path $csvFile -Force -NoTypeInformation
psedit $csvFile

# Now let's read it back in, and loop over it
$csvInputData = Import-Csv $csvFile
foreach ($csvLine in $csvInputData)
{
  # Because the CSV had a header, the header is converted to property names
  $name = $csvLine.CustomerName
  $address = "$($csvLine.DeliveryAddressLine2), $($csvLine.DeliveryAddressLine1)"
  $citySt = "$($csvLine.CityName), $($csvLine.StateProvinceCode)"
  "$name is delivered to $address in $citySt"
}

# XML -------------------------------------------------------------------------

# Now save it to XML

# First, we need to convert it to an XML object
$xmlFile = "$($dir)\CustData.xml"
$xmlOutputData = $outputData | ConvertTo-Xml
$xmlOutputData.GetType() # Note the data type is now XmlDocument

# The XmlDocument data type has a Save method
$xmlOutputData.Save($xmlFile)
psedit $xmlFile

# Now read in XML Data
$xmlInputData = [xml](Get-Content $xmlFile)

$properties = $xmlInputData.SelectNodes("//Property")
foreach ($prop in $properties)
{
  if ($prop.Name -ne 'Property')
  {
    $propName = $prop.Name
    $propValue = $prop.InnerText
    "$propName = $propValue"
  }
}

# JSON ------------------------------------------------------------------------

# JSON? No problem
$jsonData = $outputData | ConvertTo-Json
$jsonData

$jsonFile = "$($dir)\CustData.json"
Set-Content $jsonFile $jsonData
psedit $jsonFile

# Now read it back in. Make sure to use -Raw to load the entire file as
# one big long string, then use ConvertFrom-Json to convert it back to
# a collection of PowerShell objects
$jsonInputData = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
$jsonInputData


# Bonus! Saving object state to XML -------------------------------------------

$cliXmlFile = "$($dir)\CustDataCli.xml"
$outputData | Export-Clixml -Path $cliXmlFile -Force

# This isn't your father's XML
psedit $cliXmlFile

# Read it in to recreate the object
$cliXmlInputData = Import-Clixml -Path $cliXmlFile
$cliXmlInputData