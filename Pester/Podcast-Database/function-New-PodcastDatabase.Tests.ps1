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

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module Podcast-Database| Remove-Module -Force
Import-Module $here\Podcast-Database.psm1 -Force

# Import the test helper functions
. "$here\Podcast-Database-Tests-Helper-Functions.ps1"

Describe 'New-PodcastDatabase Tests' {

  InModuleScope Podcast-Database {

    # Load the SQL PS module so we can talk to the db. If SQLPS is already loaded, no harm done.
    Push-Location
    Import-Module SqlPS -DisableNameChecking
    Pop-Location

    $expectedColumnNames = 'Title',
                           'ShowUrl', 
                           'EmbeddedHTML', 
                           'Hosts', 
                           'PublicationDate', 
                           'ImageUrl', 
                           'AudioUrl', 
                           'AudioLength'

    # First test against the PodcastSight default db
    Context 'Test with PodcastSight db name' {
      if ((Confirm-PodcastDbExists) -eq $false)
      {
        New-PodcastDatabase
      }

      It 'should have created database PodcastSight, or it should already exist' {
        Confirm-PodcastDbExists | Should Be $true
      }

      # Ensure the staging table exists
      It 'should have created the table Staging in the PodcastSight database ' {
        Confirm-PodcastTableExists | Should Be $true
      }

      # Validate the column names exist
      $columnNames = Get-PodcastColumnNames
      foreach ($colName in $expectedColumnNames)
      {
        It "should have column name $colName " {
          $columnNames.ColumnName.Contains($colName) | Should Be $true
        }
      }
      
      # Ensure the stored procedure exists
      It 'should have created the stored procedure in the PodcastSight database ' {
        Confirm-PodcastProcedureExists | Should Be $true
      }

    }

    # Next test with a db name that isn't there
    $testDbName = Find-NonexistantPodcastDbName -RootDatabaseName 'NewPodcastDatabaseTest'
    Context "Test with new database $testDbName" { 
      # Now Attempt to create the db
      New-PodcastDatabase $testDbName
      
      It "should have created database $testDbName" {
        Confirm-PodcastDbExists $testDbName | Should Be $true
      }
      
      # Ensure the staging table exists
      It "should have created the table Staging in the $testDbName database " {
        Confirm-PodcastTableExists -DatabaseName $testDbName -TableName 'Staging' |
          Should Be $true
      }
      
      # Validate the column names exist
      $columnNames = Get-PodcastColumnNames -DatabaseName $testDbName -TableName 'Staging'
      foreach ($colName in $expectedColumnNames)
      {
        It "should have column name $colName " {
          $columnNames.ColumnName.Contains($colName) | Should Be $true
        }
      }

      # Ensure the stored procedure exists
      It "should have created the stored procedure in the $testDbName database " {
        Confirm-PodcastProcedureExists -DatabaseName $testDbName | Should Be $true
      }

      # Drop the created database
      $dbDrop = @"
        ALTER DATABASE $testDbName SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE $testDbName;
"@
      $result = Invoke-Sqlcmd -Query $dbDrop `
                              -ServerInstance $env:COMPUTERNAME `
                              -Database 'master' `
                              -SuppressProviderContextWarning 
      
      
      It "should have dropped database $testDbName as part of the test cleanup" {
        Confirm-PodcastDbExists $testDbName | Should Be $false
      }

    }  # Context "Test with new database $testDbName" 

  } # InModuleScope Podcast-Database 

} # Describe 'New-PodcastDatabase Tests' 
