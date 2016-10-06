<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Using Variables in PowerShell

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# Variables
#-----------------------------------------------------------------------------#
#region Variables

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

# Not just variables have types - so do static values
"PowerShell Rocks".GetType()

# Accessing methods on objects
"PowerShell Rocks".ToUpper()
"PowerShell Rocks".Contains("PowerShell")

# For nonstrings you need to wrap in () so PS will evaluate as an object
(33).GetType()  


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



# Be cautious of Implicit Type Conversions
"42" -eq 42
42 -eq "42"

# Whatever is on the right is converted to the data type on the left
# Can lead to some odd conversions
42 -eq "042"   # True because the string on the right is coverted to an int
"042" -eq 42   # False because int on the right is converted to a string

##


#-----------------------------------------------------------------------------#
# Built in variables
#-----------------------------------------------------------------------------#
# Automatic Variables
Clear-Host

# False and true
$false
$true

# Null
$NULL

# Current directory
$pwd

# Users Home Directory
$Home  

# Info about a users scripting environment
$host

# Process ID
$PID

# Info about the current version of Powershell
$PSVersionTable

$_   # Current Object
Set-Location "C:\Users\Arcane\OneDrive\PS\Z2H"
Get-ChildItem | Where-Object {$_.Name -like "*.ps1"}

#endregion Variables

##










#-----------------------------------------------------------------------------#
# Using the *-Variable cmdlets
#-----------------------------------------------------------------------------#
Clear-Host

# Normal variable usage
$normal = 33
$normal

$text = "In The Morning"
$text


# Long version of $var = 33
New-Variable -Name var -Value 33
$var

# Note if you try to use New-Variable and it already exists, you get an error
# Try again with $var already existing
New-Variable -Name var -Value 99
$var

# Displays the variable and it's value
Get-Variable var -valueonly

Get-Variable var

Get-Variable   # Without params it shows all variables

# Assign a new value to an existing variable
# $var = "In The Morning"
Set-Variable -Name var -Value "In The Morning"
$var

# Clear the contents of a variable
# Same as $var = $null
Clear-Variable -Name var
$var   

# Variable is now set to null
$var -eq $null

# Even though null, it still exists
Get-Variable var   


# Wipe out a variable
Remove-Variable -Name var
# Now var is gone, if you try to remove or clear again an error occurs
# (note if you try to access it by just doing a $var the var is recreated)

Get-Variable var   # Now produces an error


##



