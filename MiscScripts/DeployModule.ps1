<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  DeployModule.ps1

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 

  Notes
  This script can be used to deploy a module to the users WindowsPowershell
  Modules folder. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# This checks to see if the WindowsPowerShell folder is in the users
# document folder, then checks to see if the Modules folder exists under
# the WindowsPowerShell folder. If they do not exist, they are created. 
# This is primarily a helper function for the Install-MyModule function
#-----------------------------------------------------------------------------#
function Add-WindowsPowerShellFolder()
{
  
  $psUserPath = "C:\Users\$([Environment]::UserName)\Documents\WindowsPowerShell"
  if($(Test-Path $psUserPath) -eq $false)
  {
    New-Item -ItemType Directory -Force $psUserPath 
  }

  $psUserModulePath = "$($psUserPath)\Modules"
  if($(Test-Path $psUserModulePath) -eq $false)
  {
    New-Item -ItemType Directory -Force $psUserModulePath
  }

}

#-----------------------------------------------------------------------------#
# This checks to see if the folder for the Module you want to install 
# exists, and if not it adds it. 
# This is primarily a helper function for the Install-MyModule function
#-----------------------------------------------------------------------------#
function Add-ModuleFolder($ModuleName)
{
  
  $psUserModulePath = "C:\Users\$([Environment]::UserName)\Documents\WindowsPowerShell\Modules"

  $psModulePath = "$($psUserModulePath)\$($moduleName)"
  if($(Test-Path $psModulePath) -eq $false)
  {
    New-Item -ItemType Directory -Force $psModulePath
  }

}

#-----------------------------------------------------------------------------#
# This is the main function of this script. It first ensures the requisite
# folders exist in order to deploy. 
#
# If the -Replace switch is used, the target folder will be cleaned out 
# prior to the copy. 
#
# Next, it iterates over the list of files passed in and copies them to the
# target folder. 
#-----------------------------------------------------------------------------#
function Install-MyModule()
{
  [CmdletBinding()]   
  param (  
         [Parameter( Mandatory = $true,
                     ValueFromPipeline = $false,
                     ValueFromPipelineByPropertyName = $false,
                     HelpMessage = 'Module Name.'
                     )]
         [string] $ModuleName,
         [Parameter( Mandatory = $true,
                     ValueFromPipeline = $false,
                     ValueFromPipelineByPropertyName = $false,
                     HelpMessage = 'File to deploy.'
                     )]
         [string[]] $Files,
         [switch] $Replace
        )  # End the parameter block

  begin
  {
    # Validate the PS folder exists 
    Add-WindowsPowerShellFolder

    # Set the path to the users modules folder
    $psUserModulePath = "C:\Users\$([Environment]::UserName)\Documents\WindowsPowerShell\Modules"

    # Add a new folder for the module name being installed
    Add-ModuleFolder -ModuleName $ModuleName

    # Set the path to the users module folder including the module to create
    $psModulePath = "$($psUserModulePath)\$($ModuleName)"

    # If the user passed the -Replace switch delete all files from 
    # the target folder
    if ($Replace -eq $true)
    {
      Remove-Item "$psModulePath\*.*" -Force -Recurse
    }

  }
  
  process
  {

    foreach($file in $files)
    {
      # Copy our module to the users module folder (force will overwrite if there)
      Copy-Item $file `
                $psModulePath `
                -Force
    }
  }
  
}




