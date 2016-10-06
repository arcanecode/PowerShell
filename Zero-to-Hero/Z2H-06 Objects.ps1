<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server
  Demo 4 - Objects
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2014 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# Demo 0 -- Object Oriented Terminology
#-----------------------------------------------------------------------------#
<#
                                  class = blueprints
                             properties = describe
                    methods (functions) = actions
                                 object = house
             instantiating a new object = building a new house
each object is an instance of the class = each house is a copy of the blueprint


#>


#-----------------------------------------------------------------------------#
# Demo 1 -- Create a new object 
# This is the most common method of creating objects
#-----------------------------------------------------------------------------#
function Create-Object ($Schema, $Table, $Comment)
{
  # Build a hash table with the properties
  $properties = [ordered]@{ Schema = $Schema
                   Table = $Table
                   Comment = $Comment
                 }

  # Start by creating an object of type PSObject
  $object = New-Object –TypeName PSObject -Property $properties

  # Return the newly created object
  return $object
}

$myObject = Create-Object -Schema "MySchema" -Table "MyTable" -Comment "MyComment"
$myObject

# Display in text. Note because it is an object need to wrap in $() to access a property
"My Schema = $($myObject.Schema)"

$myObject.Schema = "New Schema"
$myObject.Comment = "New Comment"
$myObject


#-----------------------------------------------------------------------------#
# Demo 2 -- Create a new object by adding properties one at a time
# In the previous demo a property hash table was used to generate the object
# Behind the scenes it does the equivalent of what this function does
#-----------------------------------------------------------------------------#
function Create-Object ($Schema, $Table, $Comment)
{
  # Start by creating an object of type PSObject
  $object = New-Object –TypeName PSObject

  # Add-Member by passing in input object
  Add-Member -InputObject $object `
             –MemberType NoteProperty `
             –Name Schema `
             –Value $Schema

  # Alternate syntax, pipe the object as an input to Add-Member
  $object | Add-Member –MemberType NoteProperty `
                       –Name Table `
                       –Value $Table
  
  $object | Add-Member -MemberType NoteProperty `
                       -Name Comment `
                       -Value $Comment

  return $object
}

$myObject = Create-Object -Schema "MySchema" -Table "MyTable" -Comment "MyComment"
$myObject

# Display in text. Note because it is an object need to wrap in $() to access a property
"My Schema = $($myObject.Schema)"

$myObject.Schema = "New Schema"
$myObject.Comment = "New Comment"
$myObject


#-----------------------------------------------------------------------------#
# Demo 3 -- Add alias for one of the properties
#-----------------------------------------------------------------------------#
Clear-Host
Add-Member -InputObject $myObject `
           -MemberType AliasProperty `
           -Name 'Description' `
           -Value 'Comment' `
           -PassThru
"Comment......: $($myObject.Comment)"
"Description..: $($myObject.Description)"

# Demo 3 -- Add script block to object
Clear-Host
$block = { 
           $fqn = $this.Schema + '.' + $this.Table 
           return $fqn
         }

Add-Member -InputObject $myObject `
           -MemberType ScriptMethod `
           -Name 'FullyQualifiedName' `
           -Value $block `
           -PassThru

# Parens are very important, without it will just display the function
$myObject.FullyQualifiedName()  


#-----------------------------------------------------------------------------#
# Demo 4 -- Script block with parameters
#-----------------------------------------------------------------------------#
Clear-Host
$block = { 
           param ($DatabaseName)
           $fqn = "$DatabaseName.$($this.Schema).$($this.Table)"
           return $fqn
         }

Add-Member -InputObject $myObject `
           -MemberType ScriptMethod `
           -Name 'DatabaseQualifiedName' `
           -Value $block `
           -PassThru

# Parens are very important, without it will just display the function
$myObject.DatabaseQualifiedName('MyDBName')  


#-----------------------------------------------------------------------------#
# Demo 5 -- Script Property
#-----------------------------------------------------------------------------#
# These are analogues to properties in C#, with a Getter and Setter function
Clear-Host

# Add a property we can work with
Add-Member -InputObject $myObject `
           –MemberType NoteProperty `
           –Name AuthorName `
           –Value 'No Author Name'

# This defines the GET for this property
$getBlock = { return $this.AuthorName }

# This defines the SET. Adding a simple check for the name
$setBlock = { 
              param ( [string]$author )
                            
              if($author.Length -eq 0)
              { $author = 'Robert C. Cain, MVP' }
              
              $this.AuthorName = $author
            }

# Now add the custom Get/Set ScriptProperty to the member
Add-Member -InputObject $myObject `
           -MemberType ScriptProperty `
           -Name Author `
           -Value $getBlock `
           -SecondValue $setBlock

# Demo its use when passing as value
$myObject.Author = 'ArcaneCode'
"`$myObject.Author now equals $($myObject.Author )"

# Now pass in nothing to see the setter functionality kicking in
$myObject.Author = ''
$myObject.Author

# Unfortunately the original property is still available, and thus
# the custom get/set can be bypassed
$myObject.AuthorName = 'Evil Author'
$myObject.Author                       # Author reflects value of AuthorName


#-----------------------------------------------------------------------------#
# Demo 6 -- Set default properties
# Note: Thanks to Poshoholic for his cool code sample, see it at:
# http://poshoholic.com/2008/07/05/essential-powershell-define-default-properties-for-custom-objects/
#-----------------------------------------------------------------------------#
Clear-Host

# When just running the object, it displays all properties
$myObject

# If you have a lot, this can get overwhelming. Instead you can define a
# default set to display.

# Define the property names in an array
$defaultProperties = @('Schema', 'Table', 'Comment', 'Author')

# Create a property set object and pass in the array 
$defaultDisplayPropertySet `
  = New-Object System.Management.Automation.PSPropertySet(`
      ‘DefaultDisplayPropertySet’ `
      ,[string[]]$defaultProperties `
      )

# Create a PS Member Info object from the previous property set object
$PSStandardMembers `
  = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

# Now add to the object
$myObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

# Now the object will just display the default list in standard output
$myObject

# Little easier to read in a list
$myObject | Format-List

# To display all properties, pipe through format-list with wild card for property
$myObject | Format-List -Property *


#-----------------------------------------------------------------------------#
# Demo 7 - Create a class from .Net Code and call a static method
#-----------------------------------------------------------------------------#

# Load the contents of the file into a variable
$code = @"
using System;

public class Z2HObjectStatic
{
  public static string composeFullName(string pSchema, string pTable)
  {
    string retVal = "";  // Using retVal for Write-Verbose purposes

    retVal = pSchema + "." + pTable;

    return retVal;

  } // public static void composeFullName
} // class Z2HObjectStatic

"@

# Add a new type definition based on the code
Add-Type -TypeDefinition $code `
         -Language CSharpVersion3 

# Call the static method of the object
$mySchema = "dbo"
$myTable = "ArcaneCode"
$result = [Z2HObjectStatic]::composeFullName($mySchema, $myTable)
$result


#-----------------------------------------------------------------------------#
# Demo 8 - Instantiate an object from .Net Code in embedded code
#-----------------------------------------------------------------------------#

$code = @"
using System;

public class Z2HObjectEmbedded
{
  public string SomeStringName;

  public string composeFullName(string pSchema, string pTable)
  {
    string retVal = "";  // Using retVal for Write-Verbose purposes

    retVal = pSchema + "." + pTable;

    return retVal;

  } // public void composeFullName
} // class Z2HObjectEmbedded

"@

# Add a new type definition based on the code
Add-Type -TypeDefinition $code `
         -Language CSharpVersion3 

# Instantiate a new version of the object
$result = New-Object -TypeName Z2HObjectEmbedded

# Set and display the property
$result.SomeStringName = "Temp"
$result.SomeStringName

# Call the method
$result.composeFullName($mySchema, $myTable)


#-----------------------------------------------------------------------------#
# Demo 9 - Create object from .Net Code in an external file
#-----------------------------------------------------------------------------#

# Set the folder where the CS file is
$assyPath = "C:\Users\Arcane\OneDrive\PS\Z2H\"

# Path and File Name
$file = "$($assyPath)Z2H-06 Objects Code.cs"

# Load the contents of the file into a variable
$code = Get-Content $file | Out-String

# Add a new type definition based on the code
Add-Type -TypeDefinition $code `
         -Language CSharpVersion3 

# Call the static method of the object
$mySchema = "dbo"
$myTable = "ArcaneCode"
$result = [Z2HObjectExternal]::composeFullName($mySchema, $myTable)
$result


#-----------------------------------------------------------------------------#
# Demo 10 - Add to an existing object
#-----------------------------------------------------------------------------#
Set-Location C:\Users\Arcane\OneDrive\PS\Z2H

$items = Get-ChildItem

# Returns a collection of DirectoryInfo objects (System.IO.FileSystemInfo)
$items[0].GetType()

# Define the custom script property
$script = { 
            $retValue = "Unknown"

            if($this.Extension -eq '.ps1')
            {
              $retValue = 'Script'
            }
            else
            {
              $retValue = 'Not A Script'
            }

            return $retValue
          }

$itemCount = 0
foreach($item in $items)
{
  # Add a note property, setting it to the current item counter
  $itemCount++
  $item | Add-Member –MemberType NoteProperty `
                     –Name ItemNumber `
                     –Value $itemCount

  # Add script property to the individual file object
  Add-Member -InputObject $item `
             -MemberType ScriptMethod `
             -Name 'ScriptType' `
             -Value $script 

  "$($item.ItemNumber): $($item.Name) = $($item.ScriptType())"
}


