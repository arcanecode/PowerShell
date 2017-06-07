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
  Creates a new PodcastSight standard database
  
  .DESCRIPTION
  PodcastSight has determined a standard format for its database. This
  function will first ensure the database doesn't already exist. If it
  does not, it will create it. 

  In addition, it also creates a stored procedure used to update the staging
  table. This staging table is used by a Merge statement elsewhere in this
  module to update a target table from the staging table.

  Finally, it creates the staging table itself. 
  
  .INPUTS
  PodcastDatabaseName - The name of the database to create. If omitted, the
  company standard name of 'PodcastSight' is used.

  .OUTPUTS
  None
  
  .EXAMPLE
  New-PodcastDatabase -PodcastDatabaseName 'PodcastSight'

  .EXAMPLE
  New-PodcastDatabase 'PodcastSight'

  .EXAMPLE
  New-PodcastDatabase 

#>
function New-PodcastDatabase()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $false) ]
    $PodcastDatabaseName = 'PodcastSight'
  )

  if ($(Test-PodcastDatabase $PodcastDatabaseName) -eq $false)
  {                    
    Write-Verbose "New-PodcastDatabase...: Creating database $PodcastDatabaseName "
    $dbcmd = "CREATE DATABASE $PodcastDatabaseName"
    Invoke-Sqlcmd -Query $dbcmd `
                  -ServerInstance $env:COMPUTERNAME `
                  -SuppressProviderContextWarning 

    # If successful create the stored procedure and staging table
    if ($(Test-PodcastDatabase $PodcastDatabaseName) -eq $true)
    {
      # Create the stored proc
      $dbcmd = @"
        CREATE PROCEDURE InsertStagingData	
            @Title NVARCHAR(200)
          , @ShowUrl NVARCHAR(256)
          , @EmbeddedHTML NVARCHAR(MAX)
          , @Hosts NVARCHAR(200)
          , @PublicationDate NVARCHAR(100)
          , @ImageUrl NVARCHAR(256)
          , @AudioUrl NVARCHAR(256)
          , @AudioLength NVARCHAR(50)
        AS
        BEGIN
          SET NOCOUNT ON;
        
          INSERT INTO [dbo].[Staging]
            ( [Title]
            , [ShowUrl]
            , [EmbeddedHTML]
            , [Hosts]
            , [PublicationDate]
            , [ImageUrl]
            , [AudioUrl]
            , [AudioLength]
            )
          VALUES
            ( @Title 
            , @ShowUrl 
            , @EmbeddedHTML 
            , @Hosts 
            , @PublicationDate 
            , @ImageUrl 
            , @AudioUrl 
            , @AudioLength 
            )
        
        END
        GO
"@

      Invoke-Sqlcmd -Query $dbcmd `
                    -ServerInstance $env:COMPUTERNAME `
                    -Database $PodcastDatabaseName `
                    -SuppressProviderContextWarning 
      
      # Create the staging table
      New-PodcastTable -PodcastDatabaseName $PodcastDatabaseName `
                       -PodcastTableName 'Staging'

    } # if ($(Test-PodcastDatabase $PodcastDatabaseName) -eq $true)

  } # if ($(Test-PodcastDatabase $PodcastDatabaseName) -eq $false)
  else
  {
    Write-Verbose "New-PodcastDatabase..: Database $PodcastDatabaseName already exists"
  }

} # function New-PodcastDatabase