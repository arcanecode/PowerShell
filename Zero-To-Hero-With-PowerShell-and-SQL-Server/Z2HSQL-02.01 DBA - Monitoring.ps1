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

<#-----------------------------------------------------------------------------
  Monitoring SQL Server
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# Get a list of counters important to SQL Server. 
#-----------------------------------------------------------------------------#
function Get-SQLCounters ()
{
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the computer'
                   )
         ]
         [string]$ComputerName
       , [string]$Instance = 'SQLServer'
       )
       
  # https://blogs.sentryone.com/allenwhite/sql-server-performance-counters-to-monitor/
  # Note, if you are using a named instance, user MSSQL$<instancename> otherwise use SQLServer
  $counters = @( "\\$ComputerName\Processor(_Total)\% Processor Time"
               , "\\$ComputerName\Paging File(_Total)\% Usage"
               , "\\$ComputerName\PhysicalDisk(_Total)\Avg. Disk sec/Read"
               , "\\$ComputerName\PhysicalDisk(_Total)\Avg. Disk sec/Write"
               , "\\$ComputerName\System\Processor Queue Length"
               , "\\$ComputerName\Network Interface(*)\Bytes total/sec"
               , "\\$ComputerName\$($Instance):Access Methods\Forwarded Records/sec"
               , "\\$ComputerName\$($Instance):Access Methods\Page Splits/sec"
               , "\\$ComputerName\$($Instance):Buffer Manager\Buffer cache hit ratio"
               , "\\$ComputerName\$($Instance):Buffer Manager\Page life expectancy"
               , "\\$ComputerName\$($Instance):General Statistics\Processes blocked"
               , "\\$ComputerName\$($Instance):SQL Statistics\Batch Requests/sec"
               , "\\$ComputerName\$($Instance):SQL Statistics\SQL Compilations/sec"
               , "\\$ComputerName\$($Instance):SQL Statistics\SQL Re-Compilations/sec"
               )
  
  $countersCollection = @()
  $counterSamples = Get-Counter -Counter $counters -MaxSamples 1 
  foreach ($sample in $counterSamples)
  {
    foreach ($row in $sample.CounterSamples)
    {
      $obj = [PSCustomObject]@{ TimeGenerated = $row.TimeStamp
                                Path = $row.Path
                                Value = $row.CookedValue
                              }
      $countersCollection += $obj
    }
  }
  
  return $countersCollection
}

# Set the CSV file name, and remove it if it was leftover from prev demo
$csvName = "$($env:OneDrive)\PS\Z2HSQL\Counters.csv"
Remove-Item -Path $csvName -ErrorAction SilentlyContinue

$computerName = $env:COMPUTERNAME
$passes = 10
for ($x = 1; $x -le $passes; $x++)
{ 
  $myCounters = Get-SQLCounters -ComputerName $computerName
  $myCounters | Export-Csv -Path $csvName -Append -NoTypeInformation
  Write-Host "Pass $x of $passes"
  Start-Sleep 5
}

Invoke-Item $csvName


