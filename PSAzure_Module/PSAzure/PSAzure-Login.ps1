<#-----------------------------------------------------------------------------
  Defines helper functions for logging into Azure

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    Test-PSToAzure
    Connect-PSToAzure
    Disconnect-PSToAzure
    Set-PSSubscription

-----------------------------------------------------------------------------#>

#region Test-PSToAzure
<#---------------------------------------------------------------------------#>
<# Test-PSToAzure                                                            #>
<#---------------------------------------------------------------------------#>
function Test-PSToAzure ()
{
<#
  .SYNOPSIS
  Checks to see if the current PowerShell session is connected to Azure. 
  Returns true or false.
  
  .DESCRIPTION
  Checks the current context. If the AccountName is null, we are not logged
  in to Azure, and it will return false. Otherwise it returns true.

  .INPUTS
  None

  .OUTPUTS
  Boolean - $true if logged in, $false otherwise

  .EXAMPLE
  Test-PSToAzure 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param ()

  $fn = "Test-PSToAzure:"

  Write-Verbose "$fn Testing for current context"
  $currentContext = Get-AzureRMContext
  $userName = $currentContext.Name
  $account = $currentContext.Account

  if ( $account -eq $null )
  { 
    Write-Verbose "$fn Not logged in, running under the $userName context"
    $retVal = $false
  }
  else
  {
    Write-Verbose "$fn Logged in using name $userName and account $account"
    $retVal = $true
  }

  return $retVal
}
#endregion Test-PSToAzure


#region Connect-PSToAzure
<#---------------------------------------------------------------------------#>
<# Connect-PSToAzure                                                         #>
<#---------------------------------------------------------------------------#>
function Connect-PSToAzure ()
{ 
<#
  .SYNOPSIS
  Connects the current PowerShell session to Azure, if it is not already 
  connected.
  
  .DESCRIPTION
  This script will help automate the connection process. First, it checks to
  see if your are already logged in. If so, it just skips the rest of the
  process.

  Next, it checks to see if the user passed in a path. If so, it will 
  combine the path with the context file parameter, which can be passed in
  or use the default of ProfileContext.ctx. It then tests to see if the
  file exists. If so it will attempt to login using that context file.

  If the user did not pass in a path, it then looks in the folder the
  scripts are executing from for the context file. If found, it will
  attempt to use it to login. 

  Should no context file be found in either the path parameter or the 
  current folder, it will check the folder the PSAzure module is in.
  If found, it will try to load the context from there. 

  If no context file is found in any of those locations, then it will
  launch the manual login process.

  If a context file is found, but the login fails, it will launch the
  manual login. Write-Verbose statements will update the user to what
  is going on, these will be useful should the login not perform as 
  expected. 

  .PARAMETER Path
  The directory where your password file is stored

  .PARAMETER ContextFile
  The file holding your context. See the demo file Create-ProfileContext.ps1
  in the PSAzure-Examples folder of this project for an example of how to
  create a profile context.  

  .INPUTS
  System.String

  .OUTPUTS
  None

  .EXAMPLE
  Connect-PSToAzure 

  .EXAMPLE
  Connect-PSToAzure 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test' -ContextFile "MyContext.ctx"

  .EXAMPLE
  Connect-PSToAzure -ContextFile "MyContext.ctx"

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [string]$Path
       , [string]$ContextFile = 'ProfileContext.ctx'
       )

  $fn = 'Connect-PSToAzure:'
  Write-Verbose "$fn Checking to see login status"

  # Login if we need to
  if ( $(Test-PSToAzure) -eq $false )
  {
    # Set a default
    $contextPathFile = $null

    # See if they passed in a path, then test for existance
    if ($Path -ne $null)
    {
      $contextPathFile = "$Path\$ContextFile"
      Write-Verbose "$fn Checking using the path parameter for $contextPathFile"
      # If not there, reset the contextPathFile
      if ($(Test-Path $contextPathFile) -eq $false)
      { 
        Write-Verbose "$fn Context file $contextPathFile not found"
        $contextPathFile = $null 
      }
    }
    
    # If the context file is still null, check the
    # current folder
    if ($contextPathFile -eq $null)
    {
      $currentFolder = (Get-Item -Path ".\").FullName
      $contextPathFile = "$currentFolder\$ContextFile"
      Write-Verbose "$fn Checking the script execution folder for $contextPathFile"
      # If not there, reset the contextPathFile
      if ($(Test-Path $contextPathFile) -eq $false)
      { 
        Write-Verbose "$fn Context file $contextPathFile not found in script execution folder"
        $contextPathFile = $null 
      }
    }
    
    # Finally if the context file is still not found,
    # try the modules folder
    if ($contextPathFile -eq $null)
    {
      $psUserModulePath = "C:\Users\$([Environment]::UserName)\Documents\WindowsPowerShell\Modules\PSAzure"
      $contextPathFile = "$psUserModulePath\$ContextFile"
      Write-Verbose "$fn Checking the module folder for $contextPathFile"
      # If not there, reset the contextPathFile
      if ($(Test-Path $contextPathFile) -eq $false)
      { 
        Write-Verbose "$fn Context file $contextPathFile not found in module folder"
        $contextPathFile = $null 
      }
    }
      
    # If the context path file is not null, then it exists.
    # Attempt to use it to login
    if ($contextPathFile -ne $null)
    {
      Write-Verbose "Attempting to login using context file $contextPathFile"
      # Attempt to login using the context file
      try 
      {
        Import-AzureRmContext -Path $contextPathFile
        Write-Verbose "$fn Login successful!"
      }
      catch
      {
        # If there was an error logging in with the context file,
        # login using the manual login process
        Write-Verbose "$fn Login failed using context file $contextPathFile, attempting manual login"
        Connect-AzureRmAccount  
      }
    }
    else # No context file found, just login manually
    {
      # Begin the manual login process
      Write-Verbose "$fn No context file was found. Logging into Azure Manually."
      Connect-AzureRmAccount 
    } # if ($contextPathFile -ne $null)   
  } # if ( $(Get-AzureRmContext).Account -eq $null )

}
#endregion Connect-PSToAzure

#region Disconnect-PSToAzure
<#---------------------------------------------------------------------------#>
<# Disconnect-PSToAzure                                                      #>
<#---------------------------------------------------------------------------#>
function Disconnect-PSToAzure ()
{
<#
  .SYNOPSIS
  If to current PowerShell session is connected to Azure, it will disconnect
  the session.
  
  .DESCRIPTION
  Will logout of the current Azure session, returning to the "Default"
  context. 

  .INPUTS
  None

  .OUTPUTS
  None

  .EXAMPLE
  Disconnect-PSToAzure 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param ()

  $fn = "Disconnect-PSToAzure:"
  
  Write-Verbose "$fn Seeing if we need to logout of Azure"

  if ( $(Test-PSToAzure) -eq $true )
  {
    $currentContext = Get-AzureRMContext
    $userName = $currentContext.Name
    Write-Verbose "$fn Logging out as user $userName"

    Remove-AzureRmContext -Name $userName -Force

    if ( $(Test-PSToAzure) -eq $false )
    {
      Write-Verbose "$fn Now logged out as user $userName"
    }
  }
  else
  {
    Write-Verbose "$fn Not currently logged into Azure"
  }

}
#endregion Disconnect-PSToAzure

#region Set-PSSubscription
<#---------------------------------------------------------------------------#>
<# Set-PSSubscription                                                        #>
<#---------------------------------------------------------------------------#>
function Set-PSSubscription ()
{
<#
  .SYNOPSIS
  Sets the current Azure subscription.

  .DESCRIPTION
  When you have multiple Azure subscriptions, this function provides an easy
  way to change between them. The function will check to see what your current
  subscription is, and if different from the one passed in it will change it.

  .PARAMETER Subscription
  The name of the subscription to change to
  
  .INPUTS
  System.String

  .OUTPUTS
  n/a

  .EXAMPLE
  Set-PSSubscription -Subscription 'Visual Studio Ultimate with MSDN'

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
                   , HelpMessage='The subscription name to change to'
                   )
         ]
         [string]$Subscription
       )

  $fn = 'Set-PSSubscription:'
  # Get the current context we're running under. From that we can
  # derive the current subscription name
  $currentAzureContext = Get-AzureRmContext
  $currentSubscriptionName = $currentAzureContext.Subscription.Name

  if ($currentSubscriptionName -eq $Subscription)
  {
    # If we're already running under it, do nothing
    Write-Verbose "$fn Current Subscription is already set to $Subscription"  
  }
  else
  {
    # Change to the new subscription
    Write-Verbose "$fn Current Subscription: $currentSubscriptionName"
    Write-Verbose "$fn Changing Subscription to $Subscription "

    # Set the subscription to use
    Set-AzureRmContext -SubscriptionName $Subscription
  }
  
}
#endregion Set-PSSubscription
