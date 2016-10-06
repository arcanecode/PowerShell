<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Zip Code Lookups

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 

  Notes
  This module demonstrates several concepts. First, it illustrates how to 
  call a REST API. The USPS (United States Postal Service) has an API
  which will allow you to retrieve a City and State based on a passed in
  Zip Code. 

  In order to use it, you will need to first register. It's free, just
  go to:

  https://www.usps.com/business/web-tools-apis/welcome.htm

  and register. They'll send you an email with your user ID. 
  In the code below replace the xxxxxxxxx's with your user id, then these
  demos should work.

  Next, it demonstrates how to integrate the new class features of PowerShell
  Version 5 with modules. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# Define the class to lookup up zip codes
#-----------------------------------------------------------------------------#
class ZipCodeLookup
{
  # Properties
  [string] $ZipCode
  [string] $City
  [string] $State

  # Default Constructor
  ZipCodeLookup()
  {
  }

  # Constructor passing in Zip Code
  ZipCodeLookup($zip)
  {
    $this.ZipCode = $zip
  }

  # Set zip code property then call the lookup
  [void] Lookup($zip)
  {
    $this.ZipCode = $zip
    $this.Lookup()
  }

  # Lookup based on zip code in $ZipCode property
  [void] Lookup()
  {
    # Validate our zip code is correct length
    if ($this.ZipCode.Length -ne 5)
    {
      $this.City = 'N/A'
      $this.State = 'N/A'
      throw 'Invalid Zip Code - Zip Code must be exactly five numbers'
      return
    }

    # Validate it is five numbers using a regular expression
    if ($($this.ZipCode -match "[0-9]{5}") -ne $true)
    {
      $this.City = 'N/A'
      $this.State = 'N/A'
      throw 'Invalid Zip Code - Zip Code may only contain numbers'
      return
    }

    # Format the base for our API call
    $urlBase = 'http://production.shippingapis.com/ShippingAPI.dll?API=CityStateLookup&XML='

    # Format the data we need to pass into the API
    # NOTE! WHERE YOU SEE ALL X's IN THE USER ID, REPLACE WITH YOUR USER ID
    $urlXML = @"
    <CityStateLookupRequest%20USERID="XXXXXXXXXXXX">
      <ZipCode ID= "0">
      <Zip5>$($this.ZipCode)</Zip5>
      </ZipCode>
    </CityStateLookupRequest>
"@
    
    # Combine into the URL we will call
    $url = $urlBase + $urlXML
    $url

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
    
    # Call the rest api
    [xml]$response = Invoke-RestMethod $url 

    # If the API doesn't find the passed in zips, it returns
    # empty values. Validate good data came back and if so copy 
    # into the class properties, otherwise flag as invalid
    if ($response.CityStateLookupResponse.ZipCode.City.Length -eq 0)
    {
      $this.City = 'Invalid Zip Code'
    }
    else
    {
      $this.City = $response.CityStateLookupResponse.ZipCode.City
    }

    if ($response.CityStateLookupResponse.ZipCode.State.Length -eq 0)
    {
      $this.State = 'Invalid Zip Code'
    }
    else
    {
      $this.State = $response.CityStateLookupResponse.ZipCode.State
    }
  }

}

#-----------------------------------------------------------------------------#
# Create a new instance of the zip code lookup class and return it
#
# Note
# Currently, you can export functions and variables from a module, but as
# of now there is no way to export a class definition. Thus, in order to
# generate a new instance of the class it is necessary to have a function
# in the module which simply generates a new instance of the class and 
# returns it.
#-----------------------------------------------------------------------------#
function New-ZipCodeLookup()
{
  return [ZipCodeLookup]::new()
}

#-----------------------------------------------------------------------------#
# Create a new instance of zip code lookup, do the lookup, & return the class
#
# Note
# This implements an advanced function. It accepts input from the pipeline,
# and sends the generated classes back out the pipeline. 
#-----------------------------------------------------------------------------#
function Get-ZipCodeData()
{
  # Needed to indicate this is the parameter block for an advanced function
  [CmdletBinding()]   
  param (  
         [Parameter( Mandatory = $true,
                     ValueFromPipeline = $true,
                     ValueFromPipelineByPropertyName = $true,
                     HelpMessage = 'Please enter the zip.'
                     )]
         [string[]] $ZipCodes
        )  # End the parameter block

  process
  {
    foreach($zip in $ZipCodes)
    {
      $zcl = [ZipCodeLookup]::new($zip)
      $zcl.Lookup()
      return $zcl  
    }
  }
}


#-----------------------------------------------------------------------------#
# Export our functions
#-----------------------------------------------------------------------------#
Export-ModuleMember New-ZipCodeLookup
Export-ModuleMember Get-ZipCodeData



