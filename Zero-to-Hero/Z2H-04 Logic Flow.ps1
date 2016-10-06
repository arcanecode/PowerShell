<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Controlling Program Flow

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# Logic Branching
#-----------------------------------------------------------------------------#
#region Logic Branching

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

  
# if elseif else
$var = 2
if ($var -eq 1)
{
  Clear-Host
  "If -eq 1 branch"
}
elseif ($var -eq 2)
{
  Clear-Host
  "ElseIf -eq 2 branch"
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



# Will match all lines that match
Clear-Host
$var = 42
switch  ($var)
{
  42 {"Forty Two"}
  "42" {"Forty Two String"}
  default {"default"}
}
# Note type coercion will cause both 42 lines to have a match


# To stop processing once a block is found use break
Clear-Host
$var = 42
switch  ($var)
{
  42 {"Forty Two"; break}
  "42" {"Forty Two String"; break}
  default {"default"}
}
# Note, if you want to put multiple commands on a single line, use a ; to separate them


# Switch works with collections, looping and executing for each match
Clear-Host
switch (3,1,2,42)
{
  1 {"One"}
  2 {"Two"}
  3 {"Three"}
  default {"The default answer"}
}


# String compares are case insensitive by default
Clear-Host
switch ("PowerShell")
{
  "powershell" {"lowercase"}
  "POWERSHELL" {"uppercase"}
  "PowerShell" {"mixedcase"}
}



# Use the -casesenstive switch to make it so
Clear-Host
switch -casesensitive ("PowerShell")
{
  "powershell" {"lowercase"}
  "POWERSHELL" {"uppercase"}
  "PowerShell" {"mixedcase"}
}


# Supports wildcards
Clear-Host
switch -Wildcard ("Pluralsight")
{
  "plural*" {"*"}
  "?luralsight" {"?"}
  "Pluralsi???" {"???"}
}

# Note it will also support regex matches

#endregion Logic Branching

##


#-----------------------------------------------------------------------------#
# Looping
#-----------------------------------------------------------------------------#
#region Looping

# While
Clear-Host
$i = 1
while ($i -le 5)
{
  "`$i = $i"
  $i = $i + 1
}


# While won't execute if condition is already true
Clear-Host
$i = 6
while ($i -le 5)
{
  "`$i = $i"
  $i = $i + 1
}


# Do
Clear-Host
$i = 1
do
{
  "`$i = $i"
  $i++
} while($i -le 5)


# Do will always execute at least once
Clear-Host
$i = 6
do
{
  "`$i = $i"
  $i++
} while($i -le 5)


# Use until to make the check more positive
Clear-Host
$i = 1
do
{
  "`$i = $i"
  $i++
} until($i -gt 5)


# For loop interates a number of times
Clear-Host
for ($f = 0; $f -le 5; $f++)
{
  "`$f = $f"
}


# Note the initializer can be set seperately
Clear-Host
$f = 2
for (; $f -le 5; $f++)
{
  "`$f = $f"
}


# Iterating over a collection 1 by 1
Clear-Host
$array = 11,12,13,14,15   # Simple Array
for ($i=0; $i -lt $array.Length; $i++)
{
  "`$array[$i]=" + $array[$i]
}


# foreach works on a collection
Clear-Host
$array = 11,12,13,14,15   # Simple Array
foreach ($item in $array)
{
  "`$item = $item"
}


# foreach works with an array of objects
Clear-Host
Set-Location "C:\Users\Arcane\OneDrive\PS\Z2H"
foreach ($file in Get-ChildItem)
{
  $file.Name
}


# Use break to get out of the loop
Clear-Host
Set-Location "C:\Users\Arcane\OneDrive\PS\Z2H"
foreach ($file in Get-ChildItem)
{
  if ($file.Name -like "*.ps1")
  {
    $file.Name
    break  # exits the loop on first hit
  }
}


# Use continue to skip the rest of a loop but go onto the next iteration
Clear-Host
Set-Location "C:\PS"
foreach ($file in Get-ChildItem)
{
  if ($file.Name -like "*.ps1")
  {
    $file.Name
    continue  # exits the loop on first hit
    "More code here"
  }
  "This isn't a powershell file: $file"
}


# When used in a nested loop, break exits to the outer loop
Clear-Host
foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    break
  }
}


# Use loop labels to break to a certain loop
Clear-Host
:outsideloop foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    break outsideloop
  }
}


# Using continue inside an inner loop
Clear-Host
foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    continue
    "this will never execute as continue goes back to start of inner for loop"
    # note, because we continue to the inside loop, the above line
    # will never run but it will go thru all iterations of the inner loop
  }
}


Clear-Host
:outsideloop foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    continue outsideloop
    "this will never execute as continue goes back to start of inner for loop"
    # here, because we break all the way to the outer loop the last two
    # iterations (5 and 6) never run
  }
  "some more stuff here that will never run"
}


#endregion Looping


##


#-----------------------------------------------------------------------------#
# Script Blocks
#-----------------------------------------------------------------------------#
#region Script Blocks

# A basic script block is code inside {}
# The for (as well as other loops) execute a script block
for ($f = 0; $f -le 5; $f++)
{
  "`$f = $f"
}


# A script block can exist on its own
# (note, to put multiple commands on a single line use the ; )
{Clear-Host; "Powershell is cool."}

# Exceucting only shows the contents of the block, doesn't execute it 
# To actually run it, use an ampersand & in front
&{Clear-Host; "Powershell is cool."}

# You can store script blocks inside a variable
$cool = {Clear-Host; "Powershell is cool."}

$cool   # Just entering the variable though only shows the contents, doesn't run it

& $cool # To actually run it, use the & character

# Since scripts can be put in a variable, you can do interesting things
Clear-Host
$cool = {"Powershell is cool."; " So is ArcaneCode"}
for ($i=0;$i -lt 3; $i++)
{ 
  &$cool;
}

#endregion Script Blocks


