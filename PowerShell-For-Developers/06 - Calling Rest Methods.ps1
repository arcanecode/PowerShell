<#-----------------------------------------------------------------------------
  PowerShell for Developers - Calling Rest Methods
  
  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  The code in this collection of demos is Copyright (c) 2018 Robert C. Cain. 
  All rights reserved.
  
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted.
   
  This code may not be reproduced in whole or in part without the express
  written consent of the author. Your are free to repurpose it for your
  projects, with no warranty or guarentees provided.
-----------------------------------------------------------------------------#>

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

$dir = 'C:\PowerShell\PS-For-Devs'

#-----------------------------------------------------------------------------#
# Retrieve data from the No Agenda podcast feed
#-----------------------------------------------------------------------------#

# First call the rest method to see the results
Invoke-RestMethod 'http://feed.nashownotes.com/rss.xml'

# Next, send the results to a variable
$noAgenda = Invoke-RestMethod 'http://feed.nashownotes.com/rss.xml'

# Now you can examine the variable, here we'll just select two columns of it
$noAgenda | Select-Object subtitle, pubdate


#-----------------------------------------------------------------------------#
# Pass data into, and get data from, an API
#-----------------------------------------------------------------------------#

# The US post office has a public API to which you can pass in a zip code,
# and get the city/state in return. 

# You will need to register and get a unique user ID. It's free, go to
# https://www.usps.com/business/web-tools-apis/welcome.htm
# fill out the requested info and within a day they will send you your ID

# This is the zip code we'll look up
$zipCode = '35051'

# For demos I didn't want to expose my personal key. Thus it has been stored
# in a text file (that isn't included in the downloads). Here the key is
# read in from the file and stored in a variable.
$zipIdFile = "$dir\ZipId.txt"
$zipId = Get-Content -Raw $zipIdFile

# Format the base for our API call
$urlBase = 'http://production.shippingapis.com/ShippingAPI.dll?API=CityStateLookup&XML='

# Format the data we need to pass IN to the API
$urlXML = @"
<CityStateLookupRequest%20USERID="$zipId">
  <ZipCode ID= "0">
  <Zip5>$zipCode</Zip5>
  </ZipCode>
</CityStateLookupRequest>
"@
    
# Combine into the URL we will call
$url = $urlBase + $urlXML

# Now we will call the post office rest api. Note we are strong typing the
# variable to XML so we can use some of the methods inherent in the XML 
# data type
[xml]$response = Invoke-RestMethod $url 

 <#
   Note: This is what the response XML looks like
 
   <?xml version="1.0"?>
     <CityStateLookupResponse>
       <ZipCode ID="0">
         <Zip5>90210</Zip5>
         <City>BEVERLY HILLS</City>
         <State>CA</State>
       </ZipCode> 
     </CityStateLookupResponse>
#>

# If the API doesn't find the passed in zips, it returns
# empty values. Set the variables to either the returned values
# or a response indicating the Zip was invalid
if ($response.CityStateLookupResponse.ZipCode.City.Length -eq 0)
  { $City = 'Invalid Zip Code' }
else
  { $City = $response.CityStateLookupResponse.ZipCode.City }

if ($response.CityStateLookupResponse.ZipCode.State.Length -eq 0)
  { $State = 'Invalid Zip Code' }
else
  { $State = $response.CityStateLookupResponse.ZipCode.State }

# Output the result  
"$zipCode is $City, $State"
