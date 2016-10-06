<#-----------------------------------------------------------------------------
  PowerShell Quickstart
  A quick look at the PowerShell platform

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# Comments begin with a # (aka hashtag or pound sign)

dir # same as ls

<#
  Comment blocks use angle brackets with comment sign
  They can be multiline 
#>

#region
  # Put your code here
#endregion

#region The Region Title is Optional

# some code here

#endregion The Region Title is Optional

#-----------------------------------------------------------------------------#
# Cmdlets
#-----------------------------------------------------------------------------#

# Verb-Noun syntax
Get-Command

Get-Help Get-Command 

Get-Help Get-Command -full

# Some popular cmdlets
Get-Process
Get-ScheduledTask
Get-ChildItem

#-----------------------------------------------------------------------------#
# Alias
#-----------------------------------------------------------------------------#
#region Aliasing

# Notice how older DOS/Linux commands work in PowerShell
dir
ls

# But how? With command aliasing
# The aliases dir and ls both point to the cmdlet Get-Childitem
Get-Alias dir
Get-Alias ls

# We can see all of the aliases for a cmdlet
Get-Alias -Definition Get-ChildItem

# There are lots of aliases
Get-Alias

# Note: Aliases are fine for command line use or quick prototypes
# For clarity however it is a best practice to use the full cmdlet
# name in all scripts you write.

#endregion Aliasing

#-----------------------------------------------------------------------------#
# Cmdlet Pipelining 
#-----------------------------------------------------------------------------#
Set-Location C:\users\Arcane\OneDrive\ps\Z2H
Get-ChildItem | Where-Object { $_.Length -gt 10kb } 

Get-ChildItem | Where-Object { $_.Length -gt 10kb } | Sort-Object Length

Get-ChildItem |
  Where-Object { $_.Length -gt 10kb } |
  Sort-Object Length

#-----------------------------------------------------------------------------#
# Providers
#-----------------------------------------------------------------------------#

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

Set-Location C:\users\Arcane\OneDrive\ps\Z2H

#-----------------------------------------------------------------------------#
# Variables
#-----------------------------------------------------------------------------#
Clear-Host

# All variables start with a $. Show a simple assignment
$hi = "Hello World"

# Print the value
$hi

# This is a shortcut to Write-Host
Write-Host $hi

# Variables are objects. Show the type
$hi.GetType()

# Display all the members of this variable (object)
$hi | Get-Member

# Use some of those members
$hi.ToUpper()
$hi.ToLower()
$hi.Length

# Types are mutable
Clear-Host
$hi = 5
$hi.GetType()

$hi | Get-Member

# Variables can be strongly typed 
Clear-Host
[System.Int32]$myint = 42  
$myint
$myint.GetType()

$myint = "This won't work"

# There are shortcuts for most .net types
Clear-Host
[int] $myotherint = 42
$myotherint.GetType()

[string] $mystring="PowerShell"
$mystring.GetType()

# Others include short, float, decimal, single, bool, byte, etc

# Comparisons
$var = 33

$var -gt 30
$var -lt 30
$var -eq 33

# List is:
#   -eq        Equals
#   -ne        Not equal to
#   -lt        Less Than
#   -gt        Greater then
#   -le        Less than or equal to
#   -ge        Greater then or equal to

#   -in        See if value in an array
#   -notin     See if a value is missing from an array
#   -Like      Like wildcard pattern matching
#   -NotLike   Not Like 
#   -Match     Matches based on regular expressions
#   -NotMatch  Non-Matches based on regular expressions

# Calculations are like any other language
$var = 3 * 11  # Also uses +, -, and / 
$var

# Supports post unary operators ++ and --
$var++  
$var

# And pre unary operators as well
++$var 
$var

Clear-Host
$var = 33
$post = $var++
$post
$var

Clear-Host
$var = 33
$post = ++$var
$post
$var

#-----------------------------------------------------------------------------#
# String Handling
#-----------------------------------------------------------------------------#

# String Quoting 
Clear-Host
"This is a string"
'This is a string too!'

# Here Strings - for large blocks of text ------------------------------
Clear-Host
$heretext = @"
Some text here
Some more here
     a bit more

a blank line above
"@
     
$heretext

# the @ and quote must be last on starting line then first on ending line
# also works with single quotes
$moreheretext = @'
Here we go again
another line here
   let's indent this
   
a blank line above
'@

# Without here strings
$sql = 'SELECT col1' `
     + '     , col2' `
     + '     , col3' `
     + '  FROM someTable ' `
     + ' WHERE col1 = ''a value'' '

# With here strings
$sql = @'
SELECT col1
     , col2
     , col3
  FROM someTable
 WHERE col1 = 'a value'
'@

# String Interpolation ---------------------------------------------------------------------------------------------------
Set-Location C:\Users\Arcane\OneDrive\PS\Z2H
Clear-Host

# Take the output of Get-ChildItem, which is an object, and gets that objects count property
$items = (Get-ChildItem).Count

# Take the output of Get-Location and store it in a variable
$loc = Get-Location

# Use these variables in a string
"There are $items items are in the folder $loc."

# String interpolation only works with double quotes
'There are $items items are in the folder $loc.'

#-----------------------------------------------------------------------------#
# Arrays
#-----------------------------------------------------------------------------#

# Simple array
Clear-Host
$array = "Robert", "Cain"
$array
$array[0]
$array[1]

$array.GetType()
$array.Count

$array += "Arcane"
$array += "Code"
$array 
$array.Count

#-----------------------------------------------------------------------------#
# Hash tables 
#-----------------------------------------------------------------------------#

$hash = @{"Key"         = "Value"; 
          "PowerShell"  = "PowerShell.com"; 
          "Arcane Code" = "arcanecode.com"}
          
$hash                  # Display all values
$hash["PowerShell"]    # Get a single value from the key

$hash."Arcane Code"    # Get single value using object syntax

#-----------------------------------------------------------------------------#
# Logic Branching
#-----------------------------------------------------------------------------#
# if/else
$var = 2
if ($var -eq 1)  # Be sure to use -eq instead of =
{
  Clear-Host
  "If branch"
}
else
{
  Clear-Host
  "else branch"
}

# Switch statement for multiple conditions
Clear-Host
$var = 42                   # Also test with 43 and 49
switch  ($var)
{
  41 {"Forty One"}
  42 {"Forty Two"}
  43 {"Forty Three"}
  default {"default"}
}

#-----------------------------------------------------------------------------#
# Looping
#-----------------------------------------------------------------------------#
# While
Clear-Host
$i = 1
while ($i -le 5)
{
  "`$i = $i"
  $i = $i + 1
}

# Also supported:
# do while
# do until
# for
# foreach

#-----------------------------------------------------------------------------#
# Functions
#-----------------------------------------------------------------------------#
function Get-AValue($one, $two)
{
  return $one * $two
}

Get-AValue 33 42

$returnValue = Get-AValue 33 42
"Returned value is $returnValue"

$returnValue = Get-AValue -one 11 -two 13
"Returned value is $returnValue"

#-----------------------------------------------------------------------------#
# Something useful
#-----------------------------------------------------------------------------#
# Restart Services
Get-Service | Where-Object Status -eq 'Stopped' # | Start-Service

# Test a web api
Invoke-RestMethod 'http://feed.nashownotes.com/rss.xml'


