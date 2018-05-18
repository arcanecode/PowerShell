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

#-----------------------------------------------------------------------------#
# Access the sql agent
#-----------------------------------------------------------------------------#
# Can use SERVER\INSTANCE
# If instance is default, no need to include it
$serverInstance = "ACDev"
Get-SqlAgent -ServerInstance $serverInstance

# Locahost works too
Get-SqlAgent -ServerInstance "localhost"

# Get a reference to the agent
$agent = Get-SqlAgent -ServerInstance $serverInstance

#-----------------------------------------------------------------------------#
# Get the jobs
#-----------------------------------------------------------------------------#
# Get a list of jobs
Get-SqlAgentJob -InputObject $agent

# Can also pipe in
$serverInstance = "ACDev"
Get-SqlAgent -ServerInstance $serverInstance |
  Get-SqlAgentJob 

$agent | Get-SqlAgentJob

# Get list of job names
$agent | Get-SqlAgentJob | Select-Object -Property Name

$jobName = 'Backup TeenyTinyDB'
Get-SqlAgentJob -Name $jobName -InputObject $agent

$job = Get-SqlAgentJob -Name $jobName -InputObject $agent

#-----------------------------------------------------------------------------#
# Get the job history
#-----------------------------------------------------------------------------#
Get-SqlAgentJobHistory -JobName $job.Name -ServerInstance $serverInstance

# Note that for a job, you get back at least two rows. The 
# first row is for the job itself, then there is one
# row for each step in the job

# Now look at errors
$badJobName = 'Backup Does Not Exist DB'
$badJob = Get-SqlAgentJob -Name $badJobName -InputObject $agent

Get-SqlAgentJobHistory -JobName $badJob.Name -ServerInstance $serverInstance

# Something useful! Get failed jobs
Get-SqlAgentJobHistory -ServerInstance $serverInstance `
                       -OutcomesType Failed 

# You can also limit the time period
Get-SqlAgentJobHistory -ServerInstance $serverInstance `
                       -OutcomesType Failed `
                       -Since Yesterday  # also LastWeek, LastMonth, and Midngiht

# Or since a date you specify
Get-SqlAgentJobHistory -ServerInstance $serverInstance `
                       -OutcomesType Failed `
                       -StartRunDate 2018-05-11

# The date can be dynamic with a little more PowerShell
# Get the failures for the last 12 hours
Get-SqlAgentJobHistory -ServerInstance $serverInstance `
                       -OutcomesType Failed `
                       -StartRunDate (Get-Date).AddHours(-12)

# You could also mine the message property for messages of
# special interest
Get-SqlAgentJobHistory -ServerInstance $serverInstance |
  Where-Object Message -Like 'The job failed*'

#-----------------------------------------------------------------------------#
# Get the steps in a job
#-----------------------------------------------------------------------------#
$serverInstance = "ACDev"
$agent = Get-SqlAgent -ServerInstance $serverInstance
$jobName = 'Backup TeenyTinyDB'
$job = Get-SqlAgentJob -Name $jobName -InputObject $agent

Get-SqlAgentJobStep -InputObject $job

#-----------------------------------------------------------------------------#
# Review the job schedule
#-----------------------------------------------------------------------------#
# Get all of the schdules for the server agent
Get-SqlAgentSchedule -ServerInstance $serverInstance

# Get the schedule for a specific job
Get-SqlAgentJobSchedule -InputObject $job 


#-----------------------------------------------------------------------------#
# Starting/Stopping the SQLAgent
#-----------------------------------------------------------------------------#
$computerName = $env:COMPUTERNAME

# See the status of the SQL Server Agent services
Get-Service -ComputerName $computerName |
  Where-Object DisplayName -like 'SQL Server Agent*'

# Get a reference to the agent service
$agentName = 'SQLSERVERAGENT'
$sqlAgentService = Get-Service -ComputerName $computerName |
                      Where-Object Name -eq $agentName

# Start it up
if ($sqlAgentService.Status -eq 'Stopped')
  { $sqlAgentService.Start() }

# Show the status to ensure it started
Get-Service -ComputerName $computerName |
  Where-Object Name -eq $agentName

# Likewise we can stop it
$sqlAgentService = Get-Service -ComputerName $computerName |
                      Where-Object Name -eq $agentName
if ($sqlAgentService.Status -eq 'Running')
  { $sqlAgentService.Stop() }

# Show the status to ensure it stopped
Get-Service -ComputerName $computerName |
  Where-Object Name -eq $agentName

# Start all instances
$agents = Get-Service -ComputerName $computerName |
            Where-Object DisplayName -like 'SQL Server Agent*'

foreach ($agent in $agents)
{
  if ($agent.Status -eq 'Stopped')
  { $agent.Start() }
}

# See the status of the SQL Server Agent services
Get-Service -ComputerName $computerName |
  Where-Object DisplayName -like 'SQL Server Agent*'


