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

# Set default folder
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"

# Load credentails
$pwFile = "$dir\pw.txt"
$passwordSecure = Get-Content $pwFile |
  ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object PSCredential ('sa', $passwordSecure)

#-----------------------------------------------------------------------------#
# Get Instance info
#-----------------------------------------------------------------------------#

# Can use SERVER\INSTANCE
# If instance is default, no need to include it
$serverInstance = "ACDev"

# or

$serverInstance = "ACDev\n4ixt"

Get-SqlInstance -ServerInstance $serverInstance

# For remote servers, you can use a credential object
Get-SqlInstance -ServerInstance $serverInstance `
                -Credential $cred

# There are a ton of properties for an instance
$instance = Get-SqlInstance -ServerInstance $serverInstance
$instance | Format-List

# Limit to a few popular properties
$instance |
  Select-Object -Property DisplayName, Status, Edition, ServiceName, ResourceVersionString |
  Format-Table

#-----------------------------------------------------------------------------#
# Starting and Stopping instances
#-----------------------------------------------------------------------------#

# In versions prior to 2016, you could stop and start an instance using
# the Stop-SqlInstance and Start-SqlInstance cmdlets. Unfortunately, these are
# broken (as of May 2018). 

# While it doesn't work remotely, you can use the windows NET command
net stop "SQL Server (N4IXT)"

net start "SQL Server (N4IXT)"

# You could also start/stop the services
# Show a list of SQL Server services
Get-Service -DisplayName "SQL Server (*"

# Stop one of them
Stop-Service -Name 'MSSQL$N4IXT' -Force

# This will crash, as there's no service to report the status back
Get-SqlInstance -ServerInstance $serverInstance |
  Select-Object -Property DisplayName, Status, Edition, ServiceName, ResourceVersionString |
  Format-Table

# Start it back, then show it's working
Start-Service -Name 'MSSQL$N4IXT'

Get-SqlInstance -ServerInstance $serverInstance |
  Select-Object -Property DisplayName, Status, Edition, ServiceName, ResourceVersionString |
  Format-Table

