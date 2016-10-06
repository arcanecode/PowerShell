<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Reusing Your Code in Functions and Modules

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# Functions
#-----------------------------------------------------------------------------#
#region Functions

$hw = {
        Clear-Host
        "Hello World"
      }
& $hw


# Functions are basically script blocks with names.
function Write-HelloWorld()
{
  Clear-Host
  "Hello World"
}

# Running the above simply places the function in memory for us to use
# To use it, call it like you would a cmdlet
Write-HelloWorld



# When writing functions, use an approved verb
# Get a list of approved verbs
Get-Verb


# Parameters can be passed in by placing them in parenthesis
function Get-Fullname($firstName, $lastName)
{
  Write-Host ($firstName + " " + $lastName)
}

# Note when calling the function with parameters, do not use commas or ()
Get-Fullname "Arcane" "Code"

$myVar = "Arcane"

Get-Fullname $myVar "Code"

Get-Fullname $("Ar" + "cane") "Code"


# Any changes to a paramater inside a function are scoped to that function
function Set-NonRefVar($myparam)
{
  $myparam = 33
  "Inside function `$myparam = $myparam"
}

Clear-Host
$myparam = 42
"Prior to funciton `$myparam = $myparam"
Set-NonRefVar($myparam)
"After funciton `$myparam = $myparam"

# To change a value inside a funciton, use [ref]
# Passing by reference simply requires a [ref] tag before the variable
# Note however it turns it into an object, thus requiring the .Value syntax
function Set-RefVar([ref] $myparam)
{
  $myparam.Value = 33
  "Inside function `$myparam = $($myparam.Value)"
}

Clear-Host
$myparam = 42
"Prior to funciton `$myparam = $myparam"
Set-RefVar ([ref] $myparam) # Must add ref to call
"After funciton `$myparam = $myparam"

# NOTE: Altering the value of parameters is considered poor programming 
#       practiceand should be avoided. Instead use return.

function Get-AValue($one, $two)
{
  return $one * $two
}

Get-AValue 33 42

$returnValue = Get-AValue 33 42
"Returned value is $returnValue"

# Functions also support named parameters
# Simply put the name of the parameter with a -
$returnValue = Get-AValue -one 33 -two 42
"Returned value is $returnValue"

# With named parameters, order is no longer important
$returnValue = Get-AValue -two 42 -one 33 
"Returned value is $returnValue"



# It is possible to pipeline enable your functions
# These are referred to as advanced functions
function Get-PSFiles ()
{
  # The begin block executes once at the start of the function
  begin  { $retval = "Here are some PowerShell files: `r`n" }

  # The process block is executed once for each object being
  # passed in from the pipe
  process { 
            if ($_.Name -like "*.ps1")
            { 
              $retval += "`t$($_.Name)`r`n"
              # Note this line could also be rendered as
              # $retval = $retval + "`t" + $_.Name + "`r`n" 
              # `t     Tab Character
              # `r     Carriage Return
              # `n     Line Feed
              # $( )   Tells PS to evaute the expression in () first then return it
              # $_     The current object being passed in the pipeline
              # .Name  The name property of the current object 
            }
          }
  
  # The end block executes once, after the rest of the function
  end { return $retval }          
}

Clear-Host
Set-Location "C:\Users\Arcane\OneDrive\PS\Z2H"
Get-ChildItem | Get-PSFiles

$output = Get-ChildItem | Get-PSFiles


$output.GetType()

Clear-Host
$i = 0
foreach($f in $output)
{
  $i++
  "$i : $f"
}


# To pipeline the output, push the output in the process area
function Get-PSFiles ()
{
  begin  { }

  process { 
            if ($_.Name -like "*.ps1")
            { 
              $retval = "`tPowerShell file is $($_.Name)"
              $retval  # This is the equivalent of: return $retval
            }
          }
  
  end { }          
}

$output = Get-ChildItem | Get-PSFiles
$output.GetType()

Clear-Host
$i = 0
foreach($f in $output)
{
  $i++
  "$i : $f"
}


function Write-SomeText ()
{
  # begin  { }

  process { 
            $retval = "Here is the output: $($_)"
            $retval
          }
  
  # end { }          
}


Clear-Host
Set-Location "C:\Users\Arcane\OneDrive\PS\Z2H"
Get-ChildItem | Get-PSFiles | Write-SomeText



# Similar to original function but truly pipelined
"Here are some PowerShell files: `r`n"
Get-ChildItem | Get-PSFiles 









# Advanced functions also allow parameters with extra helping hints
function Get-AValue ()
{
  [CmdletBinding()]   # Needed to indicate this is an advanced function
  param (  # Begin the parameter block
         [Parameter( Mandatory = $true,
                     HelpMessage = 'Please enter value one.'
                     )]
         [int] $one,
         # Note in the second we are strongly typing, and are providing a default value
         [Parameter( Mandatory = $false,
                     HelpMessage = 'Please enter value two.'
                     )]
         [int] $two = 42
        )  # End the parameter block

  begin { }

  process { 
            return $one * $two
          }

  end { }

}

# Example 1 pass in values
Get-AValue -one 33 -two 42

# Example 2 pass in value for one, take default for two
Get-AValue -one 33 

# Example 3 no params, will prompt for one and take default for two
Get-AValue 

# Example 4, use a string for one (generates error)
Get-AValue -one "x"

#endregion Functions





#-----------------------------------------------------------------------------#
# Error Handling
#-----------------------------------------------------------------------------#
#region Error Handling

# No error handling produces ugly errors

function divver($enum,$denom)
{   
  Write-Host "Divver begin."
  $result = $enum / $denom
  Write-Host "Result: $result"
  Write-Host "Divver done."    
}

Clear-Host
divver 33 3   # No Error
divver 33 0   # Generate Error

# Handle errors using try/catch/finally
function divver($enum,$denom)
{   
  Write-Host "Divver begin."

  try
  {
    $result = $enum / $denom
    Write-Host "Result: $result"
  }
  catch
  {
    Write-Host "Oh NO! An error has occurred!!"
    Write-Host $_.ErrorID
    Write-Host $_.Exception.Message
    break  # With break, or omitting it, error bubbles up to parent
  }
  finally
  {
    Write-Host "Divver done."    
  }
}

Clear-Host
divver 33 3   # No Error
divver 33 0   # Generate Error

#endregion Error Handling


#-----------------------------------------------------------------------------#
# Adding Help to Your Functions
#-----------------------------------------------------------------------------#
#region Help

# Robust help built into PowerShell
Get-Help Get-ChildItem

# Help for your function?
function Get-ChildName ()
{
  Write-Output (Get-ChildItem | Select-Object "Name")
}
Clear-Host
Get-Help Get-ChildName


# Custom tags within a comment block that Get-Help will recognize
# Note that not all of them are required
# .SYNOPSIS - A brief description of the command
# .DESCRIPTION - Detailed command description
# .PARAMETER name - Include one description for each parameter
# .EXAMPLE - Detailed examples on how to use the command
# .INPUTS - What pipeline inputs are supported
# .OUTPUTS - What this funciton outputs
# .NOTES - Any misc notes you haven't put anywhere else
# .LINK - A link to the URL for more help. Use one .LINK tag per URL
# Use "Get-Help about_comment_based_help" for full list and details


function Get-ChildName ()
{
<#
  .SYNOPSIS
  Returns a list of only the names for the child items in the current location.
  
  .DESCRIPTION
  This function is similar to Get-ChildItem, except that it returns only the name
  property. 
  
  .INPUTS
  None. 
  
  .OUTPUTS
  System.String. Sends a collection of strings out the pipeline. 
  
  .EXAMPLE
  Example 1 - Simple use
  Get-ChildName
  
  .EXAMPLE
  Example 2 - Passing to another object in the pipeline
  Get-ChildName | Where-Object {$_.Name -like "*.ps1"}

  .LINK
  Get-ChildItem 
  
#>

  Write-Output (Get-ChildItem | Select-Object "Name")
  
}

Clear-Host
Get-Help Get-ChildName


Clear-Host
Get-Help Get-ChildName -full

#endregion Help
