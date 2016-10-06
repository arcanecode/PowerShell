<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Understanding the PowerShell Platform

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
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
#region Cmdlets

# Get-Command - Retrieves a list of all system commands
Get-Command

# Can expand by searching for just a verb or noun
Get-Command -verb "get"
Get-Command -noun "service"

# Get-Help can be used to explain a command 
Get-Help Get-Command
Get-Help Get-Command -examples
Get-Help Get-Command -detailed
Get-Help Get-Command -full
Get-Help Get-Command -Online   # PS 3

# Most commands can also be passed a -? paramter to get help
Get-Command -?

#endregion Cmdlets









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
#region Cmdlet Pipelining

# Moving around the file tree
# Get-ChildItem lists all items in current path
Get-ChildItem 

# Set-Location will change the current path
Set-Location "C:\Temp"
Set-Location C:\users\Arcane\OneDrive\ps\Z2H

# Pipelining - combine CmdLets for power
Get-ChildItem | Where-Object { $_.Length -gt 10kb } 

Get-ChildItem | Where-Object { $_.Length -gt 10kb } | Sort-Object Length

# Can break commands up among several lines 
# (note pipe must be last char on line)
Get-ChildItem |
  Where-Object { $_.Length -gt 10kb } |
  Sort-Object Length

# To specify columns in the output and get nice formatting, use Format-Table  
Get-ChildItem |
  Where-Object { $_.Length -gt 10kb } |
  Sort-Object Length |
  Format-Table -Property Name, Length -AutoSize
  
# You can also use the Select-Object to retrieve certain properties from an object
Get-ChildItem | Select-Object Name, Length

# If you have an especially long command without pipes, you can also use
# a line continuation charcter of the reverse single quote ` (typically 
# located to the left of the number 1 on your keyboard)
# Note that just as with the |, the ` must be the very last character
# on the line. No spaces or comments are allowed after it

Get-ChildItem -Path C:\Temp `
              -File "*.ps1" `
              -Verbose

# Can combine line continuation and pipes
Get-ChildItem -Path C:\PS `
              -File "*.ps1" `
              -Verbose |
              Format-Table -Property Name, Length -AutoSize

#endregion Cmdlet Pipelining









#-----------------------------------------------------------------------------#
# Out-GridView
#-----------------------------------------------------------------------------#
#region Out-GridView

# With no params, just displays the results in the output panel
Get-ChildItem | Out-GridView

# Use -passthru to pipe the results to the next item
# (without -PassThru nothing gets displayed)
Get-ChildItem | Out-GridView -PassThru

# Use output mode to determine way in which user 
# can select output, single or mutliple
Get-ChildItem | Out-GridView -OutputMode Single

Get-ChildItem | Out-GridView -OutputMode Multiple

# Can add useful titles to the display
Get-ChildItem | Out-GridView -PassThru -Title "Hello World" 

# You can send the output of the GridView to a variable

# Works with -OutputMode too!
Get-ChildItem | Out-GridView -OutputMode Single -OutVariable ov

Clear-Host
$ov

# Cancel stops the flow. Run this twice, the second time hit cancel
Get-ChildItem |
  Out-GridView -OutputMode Single |
  Format-Table -AutoSize 

# Waiting around
# Without wait, when launched from a command line 
# the gridview won't wait. Open a CMD window then 
# try these two commands.
Powershell "Get-ChildItem | Out-GridView"
Powershell "Get-ChildItem | Out-GridView -Wait" 


# Gotcha: Don't try to use format-* before it
# Yields an error
Get-ChildItem |
  Format-Table -Property Name,Length -AutoSize |
  Out-GridView -PassThru

# Instead use Select-Object
Get-ChildItem |
  Select-Object -Property Name, Length |
  Out-GridView -PassThru

#endregion Out-GridView










#-----------------------------------------------------------------------------#
# Providers
#-----------------------------------------------------------------------------#
#region Providers

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

Clear-Host
Get-ChildItem | Format-Table -Property Name, Value -AutoSize

# Get a list of aliases
Clear-Host
Set-Location alias:
Get-ChildItem

# Access the variables via Variables provider

$zvar = 0  # add a variable so we can show it

Clear-Host
Set-Location variable:
Get-ChildItem

# Setting up provider aliases
New-PSDrive -Name BPSD `
            -PSProvider FileSystem `
            -Root 'C:\Users\Arcane\OneDrive\PS\Z2H'

Set-Location BPSD:
Get-ChildItem | Format-Table

Set-Location BPSD:\demo
Get-ChildItem | Format-Table


# When done, either use the remove cmdlet below, otherwise
# when this session ends so does the lifespan of the PSDrive
# Make sure to set your location outside the PSDrive first
Set-Location 'C:\Users\Arcane\OneDrive\PS\Z2H'
Remove-PSDrive BPSD

#endregion Providers
