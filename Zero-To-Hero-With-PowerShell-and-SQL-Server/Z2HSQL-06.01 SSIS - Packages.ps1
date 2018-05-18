#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  Demonstrate common SSIS tasks for SQL Server with PowerShell

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

if (1 -eq 1) { exit }  # In case I hit F5 by accident

Import-Module SqlServer

# Set default folder
$dir = "$($env:ONEDRIVE)\PS\Z2HSQL"
Set-Location $dir

# Load the helper functions
. '.\Z2HSQL-06.02 SSIS - Helper Functions.ps1'


#-----------------------------------------------------------------------------#
# Execute a package
#-----------------------------------------------------------------------------#
$serverInstance = $env:COMPUTERNAME  # Use default instance
$folderName = 'WWI'
$projectName = 'wwi-ssis'
$packageName = 'DailyETLMain.dtsx'

#$connectionString = "Server = $serverInstance; Database = SSISDB; Integrated Security = True;"

# Run a single package
$execution = Execute-ACPackage -ServerInstance $serverInstance `
                               -FolderName $folderName `
                               -ProjectName $projectName `
                               -PackageName $packageName `
                               -Verbose

#-----------------------------------------------------------------------------#
# See the execution results
#-----------------------------------------------------------------------------#

# Get the result of the single package execution
Get-ACExecutionStatus -ServerInstance $serverInstance `
                      -ExecutionID $execution.ExecutionID `
                      -Verbose

#-----------------------------------------------------------------------------#
# Get detailed results
#-----------------------------------------------------------------------------#

# Get detailed execution data for recent package runs
Get-ACExecutionData -ServerInstance $serverInstance `
                    -Verbose |
  Format-Table


# Get the results with only the critical columns
# Get detailed execution data for recent package runs
Get-ACExecutionData -ServerInstance $serverInstance `
                    -Brief `
                    -Verbose |
  Format-Table

# Get detailed data for a specific package run
Get-ACExecutionData -ServerInstance $serverInstance `
                    -ExecutionID $execution.ExecutionID


#-----------------------------------------------------------------------------#
# Simulate package execution over time to generate data for testing
#-----------------------------------------------------------------------------#
# Important note!
# Before generating package executions for other dates, you need to go
# into Windows settings and turn off auto update of time

# If we're running in a VM, we can just stop the Hyper-V time autoupdate
# servce
Stop-Service 'vmictimesync' -Force

$serverInstance = $env:COMPUTERNAME  # Use default instance
$folderName = 'WWI'
$projectName = 'wwi-ssis'
$packageName = 'DailyETLMain.dtsx'
$startDate = '04/15/2018'
$startTime = '00:15:00'
$endDate = '04/15/2018'
$endTime = '00:59:59'

# Now generate package runs
Invoke-ACSimulatedPackageExecution -ServerInstance $serverInstance `
                                   -FolderName $folderName `
                                   -ProjectName $projectName `
                                   -PackageName $packageName `
                                   -StartDate $startDate `
                                   -StartTime $startTime `
                                   -EndDate $endDate `
                                   -EndTime $endTime `
                                   -IncrementUnit 'm' `
                                   -IncrementAmount 10 `
                                   -Verbose

# Show the results
Get-ACExecutionData -ServerInstance $ServerInstance `
                    -StartDate $startDate `
                    -EndDate $endDate `
                    -Brief `
                    -Verbose |
  Format-Table

# Now that it has been run, go back into the time setting in windows and start the auto time update
# If you want a PowerShell method of doing this, take a look at Chris Warwicks script at:
# https://gallery.technet.microsoft.com/scriptcenter/Get-Network-NTP-Time-with-07b216ca

# If running in Hyper-V, we can reset the time by restarting the Hyper-V time service.
Start-Service 'vmictimesync' 

