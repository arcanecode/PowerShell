<#-----------------------------------------------------------------------------
  Defines helper functions for working with AzureSQL

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    New-PSAzureSQLServer
    New-PSAzureSQLServerFirewallRule
    New-PSBacPacFile
    Remove-PSAzureSQLDatabase
    New-PSAzureSQLDatabaseImport
    Remove-PSAzureSqlDatabase
    Remove-PSAzureSqlServerFirewallRule
    Remove-PSAzureSqlServer

-----------------------------------------------------------------------------#>

#region New-PSAzureSQLServer
<#---------------------------------------------------------------------------#>
<# New-PSAzureSQLServer                                                      #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSQLServer ()
{
<#
  .SYNOPSIS
  Create a new AzureSQL SQL Server.

  .DESCRIPTION
  Checks to see if an AzureSQL SQL Server already exists for the name passed
  in. If not, it will create a new AzureSQL SQL Server. 

  .PARAMETER ServerName
  The name of the server to create.

  .PARAMETER ResourceGroupName
  The name of the resource group to create the AzureSQL SQL Server in.

  .PARAMETER Location
  The geographic location to place the server in (southcentralus, etc)

  .PARAMETER UserName
  The name to use as the administrator user

  .PARAMETER Password
  The password to associate with the administrator user

  .INPUTS
  System.String

  .OUTPUTS
  A new AzureSQL SQL Server

  .EXAMPLE
  New-PSAzureSQLServer -ServerName 'MySQLServer' `
                       -ResourceGroupName 'ArcaneRG' `
                       -Location 'southcentralus' `
                       -UserName 'ArcaneCode' `
                       -Password 'mypasswordgoeshere'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SQL Server to create'
                   )
         ]
         [string]$ServerName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to put the SQL Server in'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the geographic location to create the server in'
                   )
         ]
         [string]$Location
       , [Parameter( Mandatory=$true
                   , HelpMessage='The user name for the administrator of the SQL Server'
                   )
         ]
         [string]$UserName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The password for the administrator of the SQL Server'
                   )
         ]
         [string]$Password
       )

  $fn = 'New-PSAzureSQLServer:'
  Write-Verbose "$fn Checking for SQL Server $ServerName"
  $exists = Get-AzureRmSqlServer | Where-Object ServerName -eq $serverName

  # If the server doesn't exist, create it.
  if ($exists -eq $null)
  {   
    # Generate a credential object for use with the server
    $passwordSecure = $Password | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object PSCredential ($username, $passwordSecure)
  
    # Now create the server
    Write-Verbose "$fn Creating the SQL Server $serverName"
    New-AzureRmSqlServer -ResourceGroupName $resourceGroupName `
                         -ServerName $serverName `
                         -Location $location `
                         -SqlAdministratorCredentials $cred
  }

}
#endregion New-PSAzureSQLServer

#region New-PSAzureSQLServerFirewallRule
<#---------------------------------------------------------------------------#>
<# New-PSAzureSQLServerFirewallRule                                          #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSQLServerFirewallRule ()
{
<#
  .SYNOPSIS
  Create a new firewall on an existing AzureSQL SQL Server.

  .DESCRIPTION
  Checks to see if the passed in name for the firewall on the specified 
  AzureSQL SQL Server already exists. If not, it will create the firewall 
  using the supplied parameters. 

  .PARAMETER ServerName
  The name of the server to apply the firewall rule to.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the AzureSQL SQL Server

  .PARAMETER FirewallRuleName
  The name to give to this firewall rule

  .PARAMETER StartIpAddress
  The beginning IP address to open up

  .PARAMETER EndIpAddress
  The last IP address to open up

  .INPUTS
  System.String

  .OUTPUTS
  A new firewall rule

  .EXAMPLE
  New-PSAzureSQLServerFirewallRule -ServerName 'MySQLServer' `
                                   -ResourceGroupName 'ArcaneRG' `
                                   -FirewallRuleName 'myfirewallrule' `
                                   -StartIpAddress '192.168.0.1' `
                                   -EndIpAddress '192.168.1.255'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SQL Server to create the rule for'
                   )
         ]
         [string]$ServerName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the SQL Server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the firewall rule to create'
                   )
         ]
         [string]$FirewallRuleName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The beginning IP Address this rule applies to'
                   )
         ]
         [string]$StartIpAddress
       , [Parameter( Mandatory=$true
                   , HelpMessage='The ending IP Address this rule applies to'
                   )
         ]
         [string]$EndIpAddress
       )

  $fn = 'New-PSAzureSQLServerFirewallRule:'

  Write-Verbose "$fn Checking for Firewall Rule $FirewallRuleName"
  $exists = Get-AzureRmSqlServerFirewallRule `
              -ResourceGroupName $ResourceGroupName `
              -ServerName $Servername `
              -FirewallRuleName $FirewallRuleName `
              -ErrorAction SilentlyContinue
  

  # If not found, create it
  if ($exists -eq $null)
  { 
    Write-Verbose "$fn Creating Firewall Rule $FirewallRuleName"
    New-AzureRmSqlServerFirewallRule `
       -ResourceGroupName $ResourceGroupName `
       -ServerName $Servername `
       -FirewallRuleName $FirewallRuleName `
       -StartIpAddress $StartIpAddress `
       -EndIpAddress $EndIpAddress
  }
  
}
#endregion New-PSAzureSQLServerFirewallRule

#region New-PSBacPacFile
<#---------------------------------------------------------------------------#>
<# New-PSBacPacFile                                                          #>
<#---------------------------------------------------------------------------#>
function New-PSBacPacFile ()
{
<#
  .SYNOPSIS
  Generates a BACPAC file from a SQL Server Database.

  .DESCRIPTION
  Uses the SQLPackage application to generate a BACPAC file from a 
  SQL Server database. 

  .PARAMETER DatabaseName
  The name of the database to create a bacpac from.

  .PARAMETER Path
  The folder (aka directory) to place the created bacpac file in.

  .PARAMETER SourceServer
  The SQL Server holding the database to create the bacpac from

  .INPUTS
  System.String

  .OUTPUTS
  A bacpac file

  .EXAMPLE
  New-PSBacPacFile -DatabaseName 'MyDbToBacPac' `
                   -Path 'C:\Temp' `
                   -SourceServer 'localhost' 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The database to create a backpac file from'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The folder to write the bacpac file to'
                   )
         ]
         [string]$Path
       , [Parameter( Mandatory=$true
                   , HelpMessage='The server holding the database to export'
                   )
         ]
         [string]$SourceServer
       )
  
  $fn = 'New-PSBacPacFile:'

  # Out output file name
  $targetFile = "$Path\$($DatabaseName).bacpac"
  Write-Verbose "$fn Creating bacpac $targetFile"
  
  # This uses the SQLPackage utility that ships with SQL Server. Note your
  # location may change. In addition, the most recent versions of SQL Server
  # (2017 and later) may have SQLPackage as a separate download. 
  $sqlPackage = '"C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\sqlpackage.exe"'
  Write-Verbose "$fn Loading SQLPackage from $sqlPackage"

  # These are the parameters that are passed into the SQLPackage.exe
  $params = '/Action:Export ' `
          + "/SourceServerName:$($SourceServer) " `
          + "/SourceDatabaseName:$($DatabaseName) " `
          + "/targetfile:`"$($TargetFile)`" " `
          + '/OverwriteFiles:True '
  
  # Combine the sqlpackage.exe with the parameters
  $cmd = "& $($sqlPackage) $($params)"
  
  # Now execute it to create the bacpac
  Write-Verbose "$fn Executing $cmd"
  Invoke-Expression $cmd

}
#endregion New-PSBacPacFile

#region Remove-PSAzureSQLDatabase
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSQLDatabase                                                 #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSQLDatabase ()
{
<#
  .SYNOPSIS
  Removes (aka drops) a database from an AzureSQL SQL Server

  .DESCRIPTION
  The routine first checks to see if the passed in database exists on the 
  target AzureSQL SQL Server. If so, it removes (or in SQL terminology drops)
  the database. It does so without prompting or any request for confirmation. 

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be dropped.

  .PARAMETER DatabaseName
  The name of the database to drop (remove).

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureSQLDatabase -ResourceGroupName 'MyResourceGroup' `
                            -ServerName 'localhost' `
                            -DatabaseName 'UnneededDatabase' 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server holding the db to drop'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to drop'
                   )
         ]
         [string]$DatabaseName
       )

  $fn = 'Remove-PSAzureSQLDatabase:'

  Write-Verbose "$fn Checking to see if $DatabaseName exists on server $ServerName"
  $exists = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                                   -ServerName $ServerName |
            Where-Object DatabaseName -eq $DatabaseName
  
  if ($exists -ne $null)
  {
    Write-Verbose "$fn Removing database $DatabaseName from server $ServerName"
    Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                              -ServerName $ServerName `
                              -DatabaseName $DatabaseName `
                              -Force
  }

}
#endregion Remove-PSAzureSQLDatabase

#region New-PSAzureSQLDatabaseImport
<#---------------------------------------------------------------------------#>
<# New-PSAzureSqlDatabaseImport                                              #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSqlDatabaseImport ()
{
<#
  .SYNOPSIS
  Begins the importation of a bacpac file into an AzureSQL SQL Server.

  .DESCRIPTION
  Begin the process to import a bacpac file into an AzureSQL SQL Server. This
  is an asyncronous process, once the process begins control is returned to
  PowerShell. 
  
  The routine returns a request object which can then be used to monitor the
  progress of the import. 

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be imported to.

  .PARAMETER DatabaseName
  The name of the database to import.

  .PARAMETER StorageAccountName
  Storage Account Name holding the bacpac file

  .PARAMETER StorageContainerName
  Storage Container Name holding the bacpac file
             
  .PARAMETER UserName
  Username for the SQL Administrator

  .PARAMETER Password
  The SQL Admins Password

  .PARAMETER DbEdition
  The database edition (Basic, Premimum, Standard, etc)'

  .PARAMETER ServiceObjectiveName
  Database Service Objective (Basic, P1, etc)'

  .PARAMETER DatabasemaxSizeBytes 
  (Optional) The projected maximum database size in bytes. Default value is 5000000

  .INPUTS
  System.String

  .OUTPUTS
  Return an object of type 
  Microsoft.Azure.Commands.Sql.Database.Model.AzureSqlDatabaseImportExportBaseModel

  .EXAMPLE
  $request = New-PSAzureSQLDatabaseImport `
                -ResourceGroupName 'myresourcegroup' `
                -ServerName 'myazuresqlserver' `
                -DatabaseName 'adatabase' `
                -StorageAccountName 'myaccountname' `
                -StorageContainerName 'mycontainer' `
                -UserName 'ArcaneCode' `
                -Password 'mypassword' `
                -DbEdition 'Basic' `
                -ServiceObjectiveName 'Basic'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will hold the imported db'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to import'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Storage Account Name holding the bacpac file'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Storage Container Name holding the bacpac file'
                   )
         ]
         [string]$StorageContainerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Username for the SQL Admin'
                   )
         ]
         [string]$UserName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The SQL Admins Password'
                   )
         ]
         [string]$Password
       , [Parameter( Mandatory=$true
                   , HelpMessage='The database edition (Basic, Premimum, Standard, etc)'
                   )
         ]
         [string]$DbEdition
       , [Parameter( Mandatory=$true
                   , HelpMessage='DB Service Objective (Basic, P1, etc)'
                   )
         ]
         [string]$ServiceObjectiveName
       , [int]$DatabasemaxSizeBytes = 5000000
       )

  $fn = 'New-PSAzureSqlDatabaseImport:'
  Write-Verbose "$fn ResourceGroupName $ResourceGroupName"
  Write-Verbose "$fn ServerName $ServerName"
  Write-Verbose "$fn DatabaseName $DatabaseName"
  Write-Verbose "$fn StorageAccountName $StorageAccountName"
  Write-Verbose "$fn StorageContainerName $StorageContainerName"
  Write-Verbose "$fn UserName $UserName"
  Write-Verbose "$fn DbEdition $DbEdition"
  Write-Verbose "$fn ServiceObjectiveName $ServiceObjectiveName"
  
  # Generate a credential object for use with the server
  $passwordSecure = $Password | ConvertTo-SecureString -AsPlainText -Force
  $cred = New-Object PSCredential ($UserName, $passwordSecure)

  # We now need the storage account key, and storage context
  Write-Verbose "$fn Getting Key for Storage Account $StorageAccountName"
  $storageAccountKey = Get-PSStorageAccountKey `
                          -ResourceGroupName $ResourceGroupName `
                          -StorageAccountName $StorageAccountName

  Write-Verbose "$fn Getting Storage Context for Storage Account $StorageAccountName"
  $context = Get-PSStorageContext -ResourceGroupName $ResourceGroupName `
                                  -StorageAccountName $StorageAccountName
  
  # With the key and context, we can get the URI to the bacpac file
  $storageUri = ( Get-AzureStorageBlob `
                    -blob "$($DatabaseName).bacpac" `
                    -Container $StorageContainerName `
                    -Context $context `
                ).ICloudBlob.uri.AbsoluteUri
  Write-Verbose "$fn StorageURI $storageUri"

  # Now we can begin the import process
  Write-Verbose "$fn Beginning Import of $DatabaseName"
  $request = New-AzureRmSqlDatabaseImport `
                -ResourceGroupName $ResourceGroupName `
                -ServerName $ServerName `
                -DatabaseName $DatabaseName `
                -StorageKeyType StorageAccessKey `
                -StorageKey $storageAccountKey `
                -StorageUri $storageUri `
                -AdministratorLogin $cred.UserName `
                -AdministratorLoginPassword $cred.Password `
                -Edition $DbEdition `
                -ServiceObjectiveName $ServiceObjectiveName `
                -DatabasemaxSizeBytes $DatabasemaxSizeBytes  

  Write-Verbose "New-PSAzureSqlDatabaseImport request $($request)"
  return $request               
}
#endregion New-PSAzureSqlDatabaseImport

#region Remove-PSAzureSqlDatabase
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSqlDatabase                                                 #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSqlDatabase ()
{
<#
  .SYNOPSIS
  Remove an Azure SQL Database

  .DESCRIPTION
  Removes an AzureSQL SQL Server Database, if it exists. 

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be imported to.

  .PARAMETER DatabaseName
  The name of the database to remove.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will holds the db to remove'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to remove'
                   )
         ]
         [string]$DatabaseName
       )

  $fn = 'Remove-PSAzureSqlDatabase:'

  Write-Verbose "$fn Checking for the existance of $DatabaseName"
  $exists = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                                   -ServerName $ServerName |
            Where-Object DatabaseName -eq $DatabaseName
  
  if ($exists -ne $null)
  {
    Write-Verbose "$fn Removing database $DatabaseName"
    Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                              -ServerName $ServerName `
                              -DatabaseName $DatabaseName `
                              -Force
  } 
  
}
#endregion Remove-PSAzureSQLDatabase

#region Remove-PSAzureSqlServerFirewallRule
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSqlServerFirewallRule                                       #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSqlServerFirewallRule ()
{
<#
  .SYNOPSIS
  Remove a firewall rule from an Azure SQL Server.

  .DESCRIPTION
  Removes a firewall rule from an Azure SQL Server.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the firewall rule to remove.

  .PARAMETER FirewallRuleName
  The name of the firewall rule to remove

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureSqlServerFirewallRule -ResourceGroupName 'myresourcegroup' `
                                      -ServerName 'myservername' `
                                      -FirewallRuleName 'firewallruletodelete'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will holds the firewall rule to remove'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the firewall rule to remove'
                   )
         ]
         [string]$FirewallRuleName
       )
  
  $fn = 'Remove-PSAzureSqlServerFirewallRule:'

  Write-Verbose "$fn Checking for the existance of the firewall rule $FirewallRuleName on the server $servername"
  $exists = Get-AzureRmSqlServerFirewallRule `
               -ResourceGroupName $ResourceGroupName `
               -ServerName $ServerName `
               -FirewallRuleName $FirewallRuleName `
               -ErrorAction SilentlyContinue

  if ($exists -ne $null)
  { 
     Write-Verbose "$fn Removing the firewall rule $FirewallRuleName from the server $Servername"
     Remove-AzureRmSqlServerFirewallRule `
           -ResourceGroupName $ResourceGroupName `
           -ServerName $ServerName `
           -FirewallRuleName $FirewallRuleName `
           -Force
  }

}
#endregion Remove-PSAzureSqlServerFirewallRule

#region Remove-PSAzureSqlServer
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSqlServer                                                   #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSqlServer ()
{
<#
  .SYNOPSIS
  Remove an Azure SQL Server

  .DESCRIPTION
  Removes an Azure SQL Server from Azure

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be imported to.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
   Remove-PSAzureSqlServer -ResourceGroupName 'myresourcegroup' `
                           -ServerName 'servernametodelete' 
   
  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will holds the db to remove'
                   )
         ]
         [string]$ServerName
       )

  $fn = 'Remove-PSAzureSqlServer:'

  Write-Verbose "$fn Checking for the existance of the SQL Server $ServerName"
  $exists = Get-AzureRmSqlServer | Where-Object ServerName -eq $ServerName

  if ($exists -ne $null)
  { 
    Write-Verbose "$fn Remove-PSAzureSqlServer Removing the SQL Server $ServerName"
    Remove-AzureRmSqlServer -ResourceGroupName $ResourceGroupName `
                            -ServerName $ServerName `
                            -Force
  } 

}
#endregion Remove-PSAzureSqlServer
