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
    Connect-PSToAzure
    Set-PSSubscription

-----------------------------------------------------------------------------#>


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
  If a path/file is passed in, will attempt to copy the contents to the
  clipboard with the assumption it is your password. It will then call the
  cmdlet to connect to Azure. You just key in your user ID, then can paste
  in your password. 

  WARNING: Of course it is dangerous to leave your password laying around
  in a text file. Be sure your machine is secure, or optionally omit the
  file and just key it in each time. 

  .PARAMETER Path
  The directory where your password file is stored

  .PARAMETER PasswordFile
  The file holding your password.

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE
  Connect-PSToAzure 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test' -PasswordFile 'mypw.txt'

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

  # Login if we need to
  if ( $(Get-AzureRmContext).Account -eq $null )
  {
    # Copy your password to the clipboard
    if ($Path -ne $null)
    {
      $contextPathFile = "$Path\$ContextFile"
      Write-Verbose "$fn Context File: $contextPathFile"
      if ($(Test-Path $contextPathFile))
      {
        # Old method I copied my PW to the clipboard
        # Set-Clipboard $(Get-Content $pwPathFile )

        # With AzureRM 4.4 update they fixed Import-AzureRmContext, so am
        # going back to that method
        try 
        {
          Import-AzureRmContext -Path $contextPathFile
        }
        catch
        {
          # Don't sweat an error if the file is gone, so just begin 
          # the manual login process
          Add-AzureRMAccount  # Login
        }
      }
      else
      {
        # Begin the manual login process
        Add-AzureRMAccount  # Login
      }
    }    
  }

}
#endregion Connect-PSToAzure

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
