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
  Updates the podcast table for the specified podcast from the data passed in.
    
  .DESCRIPTION
  Takes the passed in data array, as returned from the Get-PodcastData function,
  and updates the target table in the specified database. The table must be
  a standard table as creatd by the New-PodcastTable function. 

  PodcastDatabaseName - The name of the database to look in. By default if
  no name is passed in the company standard of PodcastSight is used. 

  PodcastTableName - The name of the table to load. 

  PodcastData - An array of Podcast objects as obtained by the Get-PodcastData
  function.
  
  .OUTPUTS
  None
  
  .EXAMPLE
  $podcastData = Get-PodcastData  
  $result = Update-PodcastTable -PodcastDatabaseName 'PodcastSight' `
                                -PodcastTableName 'NoAgenda' `
                                -PodcastData $podcastData

  .EXAMPLE
  $podcastData = Get-PodcastData  
  $result = Update-PodcastTable -PodcastTableName 'NoAgenda' `
                                -PodcastData $podcastData

  .EXAMPLE
  $podcastData = Get-PodcastData  
  $result = Update-PodcastTable 'PodcastSight' 'NoAgenda' $podcastData

  .EXAMPLE
  $podcastData = Get-PodcastData  
  $result = Update-PodcastTable 'NoAgenda' $podcastData

#>
function Update-PodcastTable()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $PodcastDatabaseName = 'PodcastSight'
    ,
    [parameter (Mandatory = $true) ]
    $PodcastTableName 
    ,
    [parameter (Mandatory = $true) ]
    $PodcastData
  )

  # Ensure the Staging Table exists
  if ($(Test-PodcastTable -PodcastDatabase $PodcastDatabaseName `
                          -PodcastTable 'Staging') -eq $false)
  {
    $stagingSuccess = New-PodcastTable -PodcastDatabase $PodcastDatabaseName `
                                       -PodcastTable 'Staging'
    
    if ($stagingSuccess -eq $false)
    { throw 'New-PodcastTable: Failed to create staging table'}

  }

  # Truncate the Staging Table
  Write-Verbose 'Update-PodcastTable: Truncating Staging'

  $dbcmd = 'TRUNCATE TABLE dbo.Staging'
  Invoke-Sqlcmd -Query $dbcmd `
                -ServerInstance $env:COMPUTERNAME `
                -Database $PodcastDatabaseName `
                -SuppressProviderContextWarning 

  # Check to see if they included a schema, if not use dbo
  if ($PodcastTableName.Contains('.'))
  {
    $tbl = $PodcastTableName
  }
  else
  {
    $tbl = "dbo.$PodcastTableName"
  }

  # Insert into the staging table
  foreach($podcast in $PodcastData)
  {
    Write-Verbose "Update-PodcastTable: Inserting $($podcast.Title) to Staging"

    # Need to fix single quotes
    $title = $($podcast.Title).Replace("'", "''")
    $EmbeddedHTML = $($podcast.EmbeddedHTML).Replace("'", "''")

    $dbcmd = @"
    EXEC dbo.InsertStagingData
        '$Title'
      , '$($podcast.ShowUrl)'
      , '$EmbeddedHTML'
      , '$($podcast.Hosts)'
      , '$($podcast.PublicationDate)'
      , '$($podcast.ImageUrl)'
      , '$($podcast.AudioUrl)'
      , '$($podcast.AudioLength)'
      ;

"@

    Invoke-Sqlcmd -Query $dbcmd `
                  -ServerInstance $env:COMPUTERNAME `
                  -Database $PodcastDatabaseName `
                  -SuppressProviderContextWarning 
  } # foreach($podcast in $PodcastData)

  # Now Merge the data
  Write-Verbose "Update-PodcastTable: Merging Staging to $tbl"

  $dbcmd = @"
    MERGE $tbl  AS [Target]
    USING dbo.Staging   AS [Source]
       ON Target.Title = Source.Title
    WHEN MATCHED AND
        (    Target.ShowUrl          <> Source.ShowUrl        
          OR Target.EmbeddedHTML     <> Source.EmbeddedHTML   
          OR Target.Hosts            <> Source.Hosts          
          OR Target.PublicationDate  <> Source.PublicationDate
          OR Target.ImageUrl         <> Source.ImageUrl       
          OR Target.AudioUrl         <> Source.AudioUrl       
          OR Target.AudioLength      <> Source.AudioLength    
        )
        THEN UPDATE SET
               Target.ShowUrl          = Source.ShowUrl        
             , Target.EmbeddedHTML     = Source.EmbeddedHTML   
             , Target.Hosts            = Source.Hosts          
             , Target.PublicationDate  = Source.PublicationDate
             , Target.ImageUrl         = Source.ImageUrl       
             , Target.AudioUrl         = Source.AudioUrl       
             , Target.AudioLength      = Source.AudioLength    
    
    WHEN NOT MATCHED
        THEN INSERT 
             ( Title
             , ShowUrl        
             , EmbeddedHTML   
             , Hosts          
             , PublicationDate
             , ImageUrl       
             , AudioUrl       
             , AudioLength    
             )
             VALUES 
             ( Source.Title
             , Source.ShowUrl        
             , Source.EmbeddedHTML   
             , Source.Hosts          
             , Source.PublicationDate
             , Source.ImageUrl       
             , Source.AudioUrl       
             , Source.AudioLength    
             )
          ;
"@

    Invoke-Sqlcmd -Query $dbcmd `
                  -ServerInstance $env:COMPUTERNAME `
                  -Database $PodcastDatabaseName `
                  -SuppressProviderContextWarning 

} # Update-PodcastTable