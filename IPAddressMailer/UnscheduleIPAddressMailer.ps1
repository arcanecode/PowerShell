<#-----------------------------------------------------------------------------
  UnscheduleIPAddressMailer.ps1

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me

  This script is a companion to the ScheduleIPAddressMailer.ps1 script.
  It will remove (delete) all scheduled tasks it creates. 

  Note it assumes that any task beginning with "SendExternalIP_at"
  were created by the ScheduleIPAddressMailer.ps1, so if you create one
  manually with the same prefix it too will be deleted.

  While this script is designed to work with the IPAddressMailer system,
  it could easily be adapted to remove any set of scheduled tasks. 
   
  This script was designed to be run by the average person who may not be
  a PowerShell expert. As such I included many Write-Host statements, 
  to give the user feedback that things were working. 

  If you are a system admin who will regularly run this in unattended mode,
  just remove the Write-Host cmdlet calls. 
   
  This code is Copyright (c) 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author.

-----------------------------------------------------------------------------#>


# Get a list of scheduled tasks beginning with SendExternalIP_at. Note we
# use the ErrorAction parameter, as if there are no tasks with that name
# we don't want to generate a big scary red error message. 
#
# If there are no tasks, that's OK with us as we were going to remove them
# anyway.

$tasks = Get-ScheduledTask -TaskPath '\' `
                           -TaskName 'SendExternalIP_at*' `
                           -ErrorAction SilentlyContinue

# Now just loop over each task it found and remove it
foreach ($task in $tasks)
{
  Write-Host "Removing Task $($task.TaskName)" -ForegroundColor Yellow
  Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
}

#Confirm they are gone
$tasks = Get-ScheduledTask -TaskPath '\' `
                           -TaskName 'SendExternalIP_at*' `
                           -ErrorAction SilentlyContinue
if ($tasks -eq $null)
{
  Write-Host "All tasks for the IPAddressMailer have been removed. Good job buddy!" `
             -ForegroundColor Green
}
else
{
  Write-Host "There was an issue removing IPAddressMailer tasks. Here is a list of tasks that still exist:" `
             -ForegroundColor Red
  $tasks
}
