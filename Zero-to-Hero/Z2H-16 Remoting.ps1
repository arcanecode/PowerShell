<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Simple script that will just 'Do Something'

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>


#-----------------------------------------------------------------------------#
# A few definitions, the "remote" computer is the machine you want to remote
# control from PowerShell. The "local" computer is the one you are using,
# i.e. running PowerShell on. 
#-----------------------------------------------------------------------------#

# First, you will need to enable remoting on the computer you want to control
# On the remote computer, enter the command below. (-Force will run without
# prompts)

Enable-PSRemoting -Force

# If you are NOT running on a domain, for example doing this on a home
# network, you will need to do a few other things. 
# On both the remote computer and the local computer, run:

Set-Item wsman:\localhost\client\trustedhosts *

# Instead of an *, you could specify the IP Addresses of the machines. 

# You will then need to restart the windows remote management service
# on both computers.
Restart-Service WinRM

# On the local computer you are using, you can test by using Test-WSMan
# followed by the name of the remote computer. 
Test-WSMan ACSrv

# Now execute a command on the remote system
Invoke-Command -ComputerName ACSrv `
               -ScriptBlock { Get-ChildItem C:\ } `
               -Credential ArcaneCode


# You can also open up a PowerShell window which will execute
# on the remote computer
Enter-PSSession -ComputerName ACSrv -Credential ArcaneCode




#-----------------------------------------------------------------------------#
# Fix for network connection profile public
#-----------------------------------------------------------------------------#
Get-NetConnectionProfile

# Temporarily Set to Private
Set-NetConnectionProfile `
  -InterfaceAlias 'vEthernet (HWired)' `
  -NetworkCategory Private

Set-NetConnectionProfile `
  -InterfaceAlias 'vEthernet (Internal Ethernet Port Windows Phone Emulator Internal Switch)' `
  -NetworkCategory Private


# Put them back
Set-NetConnectionProfile `
  -InterfaceAlias 'vEthernet (HWired)' `
  -NetworkCategory Public

Set-NetConnectionProfile `
  -InterfaceAlias 'vEthernet (Internal Ethernet Port Windows Phone Emulator Internal Switch)' `
  -NetworkCategory Public
