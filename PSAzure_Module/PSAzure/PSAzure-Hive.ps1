<#-----------------------------------------------------------------------------
  Defines helper functions for working with Hive on Azure

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    Limit-PSHqlResults
    Invoke-PSHqlCmd
    Get-PSHiveTables
    Test-PSHiveTable

-----------------------------------------------------------------------------#>

<#---------------------------------------------------------------------------#>
<# Limit-PSHqlResults                                                        #>
<#---------------------------------------------------------------------------#>
function Limit-PSHqlResults ()
{
<#
  .SYNOPSIS
  Filter the result set of a Hive query to only data.  

  .DESCRIPTION
  PowerShell returns a lot of extra data as a header prior to the actual data.
  This function will remove the extra header data and only return the data as
  an array of data.

  .PARAMETER HqlResults
  The result of an HQL Query.

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE


  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The object that is the result of your query'
                   )
         ]
         [object]$HqlResults
       )

  # The first item in the array is an AzureHDInsightJob object, 
  #remove it from the results
  $jobType = 'Microsoft.Azure.Commands.HDInsight.Models.AzureHDInsightJob'
  $resultNoAzureJob = $HqlResults | Where-Object { $_.GetType().ToString() -ne $jobType}

  # As of Oct 2017 there is a bug with HDInsight that returns a warning message
  # WARN  [main] conf.HiveConf (HiveConf.java:initialize(3081)) - HiveConf of name hive.custom-extensions.root does not exist 
  # We can safely strip this from the result.
  $filter = '*hive.custom-extensions.root*'
  $resultNoError = $resultNoAzureJob | Where-Object { $_ -notlike $filter}
  
  # Finally strip out any empty strings in the result  
  $resultFinal = $resultNoError | Where-Object { $_.Length -gt 0}

  # OK Return the result
  return $resultFinal 

}

<#---------------------------------------------------------------------------#>
<# Invoke-PSHqlCmd                                                           #>
<#---------------------------------------------------------------------------#>
function Invoke-PSHqlCmd ()
{
<#
  .SYNOPSIS
  
  .DESCRIPTION

  .PARAMETER 

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE
  $result =  Limit-PSHqlResults -HqlResults $jobSplit

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Enter the HQL to execute'
                   )
         ]
         [string]$Query
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the Resource Group Name'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the HDInsight Cluster Name'
                   )
         ]
         [string]$ClusterName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the credential object'
                   )
         ]
         [PSCredential]$ClusterCredential
       , [string]$JobName = 'Job'
       )

  Write-Verbose "Defining the Hive Query $JobName"
  $hiveJobDef = New-AzureRMHDInsightHiveJobDefinition -Query $Query
  
  Write-Verbose "Starting the Hive Query $JobName"
  $hiveJob = Start-AzureRMHDInsightJob -ClusterName $ClusterName `
                                       -JobDefinition $hiveJobDef `
                                       -HttpCredential $ClusterCredential `
                                       -ResourceGroupName $ResourceGroupName
  
  
  Write-Verbose "Waiting for Hive Query $JobName"
  $waitFor = Wait-AzureRmHDInsightJob -Job $hiveJob.JobId `
                           -WaitIntervalInSeconds 10 `
                           -ClusterName $ClusterName `
                           -HttpCredential $ClusterCredential
  
  
  Write-Verbose "Getting Output of Hive Query $JobName" 
  $jobOutput = Get-AzureRmHDInsightJobOutput `
                  -ClusterName $ClusterName `
                  -JobId $hiveJob.JobId `
                  -HttpCredential $ClusterCredential `
                  -DisplayOutputType StandardOutput 
  
  # The job output is a big blob, split it into an array
  $jobSplit = $jobOutput.Split([Environment]::NewLine)

  # Filter the output to just the data we want
  $result =  Limit-PSHqlResults -HqlResults $jobSplit

  # OK Return the result
  return $result

}

<#---------------------------------------------------------------------------#>
<# Get-PSHiveTables                                                          #>
<#---------------------------------------------------------------------------#>
function Get-PSHiveTables ()
{
<#
  .SYNOPSIS
  Get a list of all tables in a hive database

  .DESCRIPTION
  Returns a list of all tables in the hive database for the cluster passed
  in via parameters.

  .PARAMETER ResourceGroupName
  The resource group holding the HDInsight cluster

  .PARAMETER ClusterName
  The name of the HDInsight cluster

  .PARAMETER ClusterCredential
  A PSCredential object used to access the HDInsight Cluster

  .PARAMETER Query
  Optional, the query to execute. By default it is 'show tables', but could
  be overwritten to further limit the result set.

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE
  $hiveTables = Get-PSHiveTables -ResourceGroupName $resourceGroupName `
                                 -ClusterName $clusterName `
                                 -ClusterCredential $clusterCred 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Enter the name of the Resource Group'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the Name of the HDInsight Cluster'
                   )
         ]
         [string]$ClusterName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the credentials to the cluster'
                   )
         ]
         [PSCredential]$ClusterCredential
       , [string]$Query = 'show tables;'
       )

  Write-Verbose 'Getting Hive Tables'
  $tables = Invoke-PSHqlCmd -Query $Query `
                            -ResourceGroupName $ResourceGroupName `
                            -ClusterName $ClusterName `
                            -ClusterCredential $ClusterCredential `
                            -JobName 'Hive Tables' `
                            -Verbose

  return $tables

}

<#---------------------------------------------------------------------------#>
<# Test-PSHiveTable                                                          #>
<#---------------------------------------------------------------------------#>
function Test-PSHiveTable ()
{
<#
  .SYNOPSIS
  Checks to see if a hive table exists.

  .DESCRIPTION
  Checks to see if a hive table exists on the target cluster

  .PARAMETER ResourceGroupName
  The resource group holding the HDInsight cluster

  .PARAMETER ClusterName
  The name of the HDInsight cluster

  .PARAMETER ClusterCredential
  A PSCredential object used to access the HDInsight Cluster

  .PARAMETER TableName
  The name of the table whose existance you want to check for

  .INPUTS
  System.String

  .OUTPUTS
  Boolean (True if table exists, false otherwise)

  .EXAMPLE
  $hasTable = Test-PSHiveTable -ResourceGroupName $resourceGroupName `
                               -ClusterName $clusterName `
                               -ClusterCredential $clusterCred `
                               -TableName $tableName

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='Enter the Resource Group Name'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the HDInsight Cluster Name'
                   )
         ]
         [string]$ClusterName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Submit a credential object'
                   )
         ]
         [PSCredential]$ClusterCredential
       , [Parameter( Mandatory=$true
                   , HelpMessage='Enter the table name to look for'
                   )
         ]
         [string]$TableName
       )

  Write-Verbose 'Getting Hive Table List'
  $tables = Get-PSHiveTables -ResourceGroupName $ResourceGroupName `
                             -ClusterName $ClusterName `
                             -ClusterCredential $ClusterCredential `
                             -Verbose
  
  $result = $tables.Contains($TableName)
  
  return $result

}
