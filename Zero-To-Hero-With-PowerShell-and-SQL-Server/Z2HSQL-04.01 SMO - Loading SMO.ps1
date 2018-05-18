#requires -Version 3.0 -Modules SqlServer

<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell and SQL Server

  SMO (SQL Management Objects) - Loading SMO

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

  Note
  The code herein was written against SQL Server 2016. It was run on the same
  machine with SQL Server 2016 installed. 

  The SMO (SQL Management Object) is a .Net library for working with 
  SQL Server. The object model shows all the available objects, and how they 
  are related. All objects in SMO extend from the root node of "Server". Once 
  you create a server object, you can then drill down and work with the rest 
  of the objects on the server. 
  
  To see the object model for SMO, a diagram of everything in the library, visit:
  http://msdn.microsoft.com/en-us/library/ms162209.aspx
    or
  http://bit.ly/smodiagram

  To see the details about the namespace visit:
  http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo
    or
  http://bit.ly/smonamespace

-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# Load the SMO Assemblies
#-----------------------------------------------------------------------------#
#region Import-SMOAssemblies
function Import-SMOAssemblies ()
{
  [cmdletbinding()]
  param( [Parameter( Mandatory=$true
                   , HelpMessage='Version to load. Valid choices are: 2016, 2014, 2012, 2008R2 '
                   )
         ]
         [string]$Version
       )
  
  $fn = 'Import-SMOAssemblies:'

  # Check to see if they are already loaded. 
  # If not, add them to the current session
  if( ([appdomain]::currentdomain.getassemblies() | 
       Where {$_ -match "Microsoft.SqlServer.Smo"}
       ) -eq $null
    )
  {
    Write-Verbose "$fn Loading Assemblies"

    $asmPath = 'C:\Program Files\Microsoft SQL Server'
    $asmPathx86 = 'C:\Program Files (x86)\Microsoft SQL Server'
    switch ($Version)
    {
      "2012"   { $assyPath = "$asmPath\110\SDK\Assemblies\" }
      "2014"   { $assyPath = "$asmPath\120\SDK\Assemblies\" }
      "2016"   { $assyPath = "$asmPath\130\SDK\Assemblies\" }
      "2008R2" { $assyPath = "$asmPathx86\100\SDK\Assemblies\" }
      default  { $assyPath = "$asmPath\130\SDK\Assemblies\" }
    }

    Write-Verbose "$fn Assembly Path is $assyPath"

    $assemblylist = 
      "Microsoft.SqlServer.Smo", 
      "Microsoft.SqlServer.ConnectionInfo", 
      "Microsoft.SqlServer.SmoExtended", 
      "Microsoft.SqlServer.Dmf", 
      "Microsoft.SqlServer.SqlWmiManagement", 
      "Microsoft.SqlServer.Management.RegisteredServers", 
      "Microsoft.SqlServer.Management.Sdk.Sfc", 
      "Microsoft.SqlServer.SqlEnum", 
      "Microsoft.SqlServer.RegSvrEnum", 
      "Microsoft.SqlServer.WmiEnum", 
      "Microsoft.SqlServer.ServiceBrokerEnum", 
      "Microsoft.SqlServer.ConnectionInfoExtended", 
      "Microsoft.SqlServer.Management.Collector", 
      "Microsoft.SqlServer.Management.CollectorEnum"
  
    foreach ($asm in $assemblylist) 
    {
      if (Test-Path -Path "$($assyPath)$($asm).dll")
      {
        Write-Verbose "$fn Loading $asm"
        # Note you may see some online examples use Load Assembly with Partial Name
        # That is now depricated, use Add-Type instead
        Add-Type -Path "$($assyPath)$($asm).dll"
      }
      else
      {
        Write-Verbose "$fn Assembly $asm was not found at $assyPath"
      }
    }
  }
  else
  {
    Write-Verbose "$fn Assemblies are already loaded. No action needed."
  }
}
#endregion Import-SMOAssemblies


# Indicate which version of SMO to load
$Version = "2016"

# Load the assemblies. Note if you have run Import-Module SqlServer,
# these assemblies will already be loaded
Import-SMOAssemblies -Version $Version -Verbose
