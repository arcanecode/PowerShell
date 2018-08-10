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

# With Restricted Policy, can't run script
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser 
. 'C:\PowerShell\PS201\bpsd-m06-do-something.ps1'

# With RemoteSigned we can run our script
Set-Location 'C:\PowerShell\PS201\'
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser 
. '.\bpsd-m06-do-something.ps1'

# With Unrestricted we can run anything
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser 
$doSomething = 'C:\PowerShell\PS201\bpsd-m06-do-something.ps1'
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
# Before we can sign a file, we need to create a certificate.
# There are many ways to create a certificate. 
# 1. Create a certificate yourself, this is called self signing
# 2. Have your system admin create a certificate using Active Directory
# 3. Get a certificate from a certificate authority, such as Verisign
# 
# For this demo, we will create a self signed certificate (option 1). 
# Follow the instructions in the document bpsd-m06-code-signing.pdf
# to create your certificate before executing the code below
#-----------------------------------------------------------------------------#

# After creating the certificate we should verify it exists.
Get-ChildItem cert:\CurrentUser\My -CodeSigningCert

# After creating our self signed certificate, we need a file to sign. 
# Just copy the do something script.
$demoPath = 'C:\PowerShell\PS201\'
$doSomething = "$($demoPath)bpsd-m06-do-something.ps1"
$doSomethingSigned = "$($demoPath)bpsd-m06-do-something-signed.ps1"
Copy-Item $doSomething $doSomethingSigned -Force

# To test, we will set the execution policy to require all scripts 
# to be signed
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope CurrentUser

# Now try to execute the script. Should produce an error.
. $doSomethingSigned

# Now we'll sign the script.
Set-AuthenticodeSignature `
  $doSomethingSigned `
  @(Get-ChildItem cert:\CurrentUser\My -CodeSigningCert)[0]

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

# Even reverting the change still won't fix it, must resign. 

