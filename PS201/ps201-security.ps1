<#-----------------------------------------------------------------------------
  PS201 - Security

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2018 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 

  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

# Just some code to prevent from accidentally running the entire script, as 
# these are demos
Write-Warning 'Don''t press F5 you big dummy.'
return

#-----------------------------------------------------------------------------#
# Determine what the execution policy is for this machine
#-----------------------------------------------------------------------------#

Get-ExecutionPolicy

#-----------------------------------------------------------------------------#
# Note: In order to alter Execution Policy, you must be running as Admin
#-----------------------------------------------------------------------------#

<# 
  Possible values:
  Restricted   - No scripts can be run. User can only use PS interactively.
  AllSigned    - All scripts must be code signed
  RemoteSigned - All scripts marked as unsafe (i.e. downloaded from the
                 internet or network share) must be signed. Local scripts
                 can be run without signing.
  Unrestricted - All scripts can be run, regardless of where it came from
                 and whether or not they are signed. Does warn the user.
  Bypass       - All scripts can be run, regardless of where it came from
                 and whether or not they are signed. Does NOT warn the user.
  Undefined    - No execution policy has been explicitly set. Uses the 
                 "Restricted" values for the session. 

  In addition these can have scope.
  MachinePolicy - Applies to all users on the machine. Must be set via 
                  Group Policy.
  UserPolicy    - Applies to the current user. Again, must be done via
                  Group Policy.
  Process       - Applies only to the current process. Once the process 
                  completes (i.e. the PS window is closed) the previous
                  setting is restored.
  CurrentUser   - Setting is only valid for this user. 
  LocalMachine  - Setting is valid for all users of this computer. 

  Best practice suggests only enabling script execution if you need it. 
  Then, set to RemoteSigned so you can run the scripts you develop but
  will have some protection from malicious scripts from the web.
#>

# Housekeeping, set our current location
Set-Location 'C:\PowerShell\PS201\'

# With Restricted Policy, can't run script
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser 
. 'C:\PowerShell\PS201\ps201-do-something.ps1'

# With RemoteSigned we can run our script. Use -Force so it won't ask us
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
. '.\ps201-do-something.ps1'

# With Unrestricted we can run anything
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
$doSomething = 'C:\PowerShell\PS201\ps201-do-something.ps1'
. $doSomething

#-----------------------------------------------------------------------------#
# Note this also demonstrates 3 ways to execute a script. 
#
# 1: Call using the full path\filename
# 2: Call using .\ to reference the current location in the file system
# 3: Store the script in a variable and execute the variable.
#
# In all cases to execute the script we must use the "dot" notation, i.e.
# a . prior to the script. 
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
# Code Signing a script
#
# In order to sign scripts, you need a code sigining certificate
#-----------------------------------------------------------------------------#

# Get a list certificate locations
Get-ChildItem cert:\

# Get certificates assigned to this machine
Get-ChildItem cert:\LocalMachine

# The other option is certificates assigned to the user
Get-ChildItem cert:\CurrentUser

# Get a list of all certs from certificate authorities
Get-ChildItem cert:\CurrentUser\CA 

# Get a list of our certificates that can be used for code signing
Get-ChildItem cert:\CurrentUser\My -CodeSigningCert

#-----------------------------------------------------------------------------#
# Creating our own certificates
#
# Before we can sign a file, we need to create a certificate.
#
# There are many ways to create a certificate. 
# 1. Create a certificate yourself, this is called self signing
# 2. Have your system admin create a certificate using Active Directory
# 3. Get a certificate from a certificate authority, such as Verisign
# 
# For this demo, we will create a self signed certificate (option 1). 
# Follow the instructions in the document ps201-code-signing.pdf
# to create your certificate before executing the code below
#-----------------------------------------------------------------------------#

# After creating the certificate we should verify it exists.
Get-ChildItem cert:\CurrentUser\My -CodeSigningCert

# After creating our self signed certificate, we need a file to sign. 
# Just copy the do something script.
$demoPath = 'C:\PowerShell\PS201\'
$doSomething = "$($demoPath)ps201-do-something.ps1"
$doSomethingSigned = "$($demoPath)ps201-do-something-signed.ps1"
Copy-Item $doSomething $doSomethingSigned -Force

# To test, we will set the execution policy to require all scripts 
# to be signed
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope CurrentUser -Force

# Now try to execute the script. Should produce an error.
. $doSomethingSigned

# Get a reference to our code signing certificate
$cert = Get-ChildItem cert:\CurrentUser\My -CodeSigningCert |
          Where-Object Subject -eq 'CN=PowerShell User'

# Now we'll sign the script.
Set-AuthenticodeSignature -FilePath $doSomethingSigned -Certificate $cert

# Now try to execute the script a second time. We will be prompted as to
# whether we should run or not. Run Once means the next time we run,
# we will again be prompted. 
# Always will save our choice and henceforth will run. 

# Now run. (Note, depending on machine settings, you may see a dialog
# asking to run once, run always, or not run. Answer appropriatly.)
. $doSomethingSigned

# Open the file to see what happened
psEdit $doSomethingSigned

# Make a simple change to the file. Even adding one space on a blank line.
# Save and try to rerun. Pandamonium ensues. 
. $doSomethingSigned


#-----------------------------------------------------------------------------#
# Unblocking Files
# 
# So what if you have files you need to run from an internet site you trust, 
# have an execution policy of remote-signed, but they are not signed? 
# For example, you have your own github repository of useful scripts you'd 
# like to access. 
# 
# After downloading, you can use Unblock-File to make it runnable
#-----------------------------------------------------------------------------#

# First, download a file from the github site to use for this demo. We'll 
# download the file manually for this example

# Remove the item, if it's not there just keep going
Remove-Item $dlPath -Force -ErrorAction SilentlyContinue

# Copy the file to save as into the clipboard to make d/l easy
$dlPath = 'C:\PowerShell\PS201\ps201-do-something-downloaded.ps1'
Set-Clipboard $dlPath

# Open the file in explorer, once open right click on the 
# "Raw" button, Save Target As... 
$url = 'https://github.com/arcanecode/PowerShell/blob/master/PS201/ps201-do-something.ps1'
Explorer $url

# Now open explorer. Right click on the file and look at its properties
Explorer 'C:\PowerShell\PS201'

# Alternatively, you can identify blocked files as they will have the
# Stream attribute of Zone.Identifier. If a file lacks the stream property
# Get-Item errors, hence the need to silently continue
Get-Item * -Stream "Zone.Identifier" -ErrorAction SilentlyContinue

# Now let's ensure our execution policy is set to RemoteSigned for our test
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser 

# Now try and run. Should fail.
. $dlPath

# Unblock the file so it will run
Unblock-File $dlPath

# Confirm it no longer has the stream identifier on it
Get-Item * -Stream "Zone.Identifier" -ErrorAction SilentlyContinue

# You could also return to file explorer and see the message no
# longer appears.

# Try again, this time should work!
. $dlPath

#-----------------------------------------------------------------------------#
# Reset so we can run demos
#-----------------------------------------------------------------------------#

# We'll make sure to reset our execution policy so I can run more demos. 
# You will want to reset to the standard for your machine / organization
# If in doubt, go with RemoteSigned for the best mix of protection but the
# ability to run your scripts.

# For demoing we'll use Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Confirm
Get-ExecutionPolicy
