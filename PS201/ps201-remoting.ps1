<#-----------------------------------------------------------------------------
  PS201 - Remoting

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2018 Robert C. Cain. All rights reserved.

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

# Configure WinRM, allow it to make any changes. 
# (Note, sometimes I've had problems in PowerShell so you might want to
#  open a CMD window in Admin mode and run the following command).
winrm quickconfig

# First, you will need to enable remoting on the computer you want to control
# On the remote computer, enter the command below. (-Force will run without
# prompts)

Enable-PSRemoting -Force

# If you are NOT running on a domain, for example doing this on a home
# network, you will need to do a few other things. 
# On both the remote computer and the local computer, run:

Set-Item wsman:\localhost\client\trustedhosts *

# Instead of an *, you should specify the IP Addresses of the machines. 

# You will then need to restart the windows remote management service
# on both computers.
Restart-Service WinRM

# On the local computer you are using, you can test by using Test-WSMan
# followed by the name of the remote computer. 
Test-WSMan ACSrv

# Setup credential for ACSrv
$credACSrv = Get-Credential -UserName ArcaneCode -Message 'Enter the password'

# Now execute a command on the remote system
Invoke-Command -ComputerName ACSrv `
               -ScriptBlock { Get-ChildItem C:\ } `
               -Credential $credACSrv


# You can also open up a PowerShell window which will execute
# on the remote computer
Enter-PSSession -ComputerName ACSrv -Credential $credACSrv

# Try on a different machine
# Setup credential for ACDev
$credACDev = Get-Credential -UserName arcanecode@gmail.com -Message 'Enter password'

# Now execute a command on the remote system
Invoke-Command -ComputerName ACDev `
               -ScriptBlock { Get-ChildItem C:\ } `
               -Credential $credACDev


# You can also open up a PowerShell window which will execute
# on the remote computer
Enter-PSSession -ComputerName ACDev -Credential $credACDev


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
