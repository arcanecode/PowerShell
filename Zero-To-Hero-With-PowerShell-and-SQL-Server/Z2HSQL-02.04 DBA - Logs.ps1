#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Demonstrate common DBA tasks for SQL Server with PowerShell

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This sample is part of the Zero To Hero with PowerShell and SQL Server
  pre-con. 

  This code is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

-----------------------------------------------------------------------------#>

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

Import-Module SqlServer

# Can use SERVER\INSTANCE
# If instance is default, no need to include it
$serverInstance = "ACDev"

# There are a ton of properties for an instance
$instance = Get-SqlInstance -ServerInstance $serverInstance

# While the command is "error" it is actually all log entries
Get-SqlErrorLog -Since Yesterday -InputObject $instance

# Also supports passing in the Server\Instance name
Get-SqlErrorLog -Since Yesterday -ServerInstance $serverInstance

# Can reformat to make a bit more readable
Get-SqlErrorLog -Since Yesterday -InputObject $instance |
  Format-Table

# In addition you can also enter a specific time range
# Here we'll get all errors that have happened after four hours ago
Get-SqlErrorLog -After (Get-Date).AddHours(-4) -InputObject $instance |
  Format-Table

# You can also limit the range
Get-SqlErrorLog -After (Get-Date).AddMinutes(-60) `
  -Before (Get-Date).AddMinutes(-30) `
  -InputObject $instance |
  Format-Table

# Instead of having to do date calculations, you can also
# specify the last X amount of time, here the last 10 minutes
Get-SqlErrorLog -Timespan '00:10:00' `
  -InputObject $instance |
  Format-Table

# Now let's limit to just actual errors
Get-SqlErrorLog -Since Yesterday -InputObject $instance |
  Where-Object { $_.Text -match 'Error' } |
  Format-Table

# Make it a bit easier to view
Get-SqlErrorLog -Since Yesterday -InputObject $instance |
  Where-Object { $_.Text -match 'Error' } |
  Out-GridView
