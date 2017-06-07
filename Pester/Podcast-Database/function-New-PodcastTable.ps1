<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

<#
  .SYNOPSIS
  Creates a new table for holding podcasts.

  .DESCRIPTION
  PodcastSight has a standard format for it's tables which will hold podcast
  data. This function will create a table to hold those podcasts. Per
  company standard, each podcast should have it's own table.

  PodcastDatabaseName - The name of the database to look in. By default if
  no name is passed in the company standard of PodcastSight is used. 

  PodcastTableName - The name of the table to create. 
  
  .OUTPUTS
  None
  
  .EXAMPLE
  $result = New-PodcastTable -PodcastDatabaseName 'PodcastSight' -PodcastTableName 'NoAgenda'

  .EXAMPLE
  $result = New-PodcastTable 'PodcastSight' 'NoAgenda'

  .EXAMPLE
  $result = New-PodcastTable -PodcastTableName 'NoAgenda'

  .EXAMPLE
  $result = New-PodcastTable 'NoAgenda'

#>
function New-PodcastTable()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $PodcastDatabaseName = 'PodcastSight'
    ,
    [parameter (Mandatory = $true) ]
    $PodcastTableName 
  )
  Write-Verbose "New-PodcastTable......: Beginning creation of table $PodcastTableName  "

  # Check to see if they included a schema, if not use dbo
  if ($PodcastTableName.Contains('.'))
  {
    $tbl = $PodcastTableName
  }
  else
  {
    $tbl = "dbo.$PodcastTableName"
  }

  $dbcmd = @"
  CREATE TABLE $tbl
  (   Title            NVARCHAR(200)
    , ShowUrl          NVARCHAR(256)
    , EmbeddedHTML     VARCHAR(MAX)
    , Hosts            NVARCHAR(200)
    , PublicationDate  NVARCHAR(100)
    , ImageUrl		   NVARCHAR(256)
    , AudioUrl		   NVARCHAR(256)
    , AudioLength	   NVARCHAR(50)
  )    
"@

  if ($(Test-PodcastTable $PodcastDatabaseName $tbl) -eq $false)
  {
    Write-Verbose "New-PodcastTable......: Table $tbl did not exist, creating it"
    Invoke-Sqlcmd -Query $dbcmd `
                  -ServerInstance $env:COMPUTERNAME `
                  -Database $PodcastDatabaseName `
                  -SuppressProviderContextWarning 
  

    Write-Verbose "New-PodcastTable......: Validating Table $tbl was created"
    $exists = $(Test-PodcastTable $PodcastDatabaseName $tbl)
    if ($exists)
    { 
      Write-Verbose "New-PodcastTable......: Table $tbl was created"
    }
    else
    { 
      Write-Verbose "New-PodcastTable......: Failed to create Table $tbl"
      Write-Debug "New-PodcastTable......: Failed to create Table $tbl"
    }
  }
  else
  {
    Write-Verbose "New-PodcastTable......: Table $tbl already exists, no action taken"
  }
  
  return $exists

} # function New-PodcastTable