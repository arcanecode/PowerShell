<#-----------------------------------------------------------------------------
  Unblock-PSAzureModule
  
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This script is Copyright (c) 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 

  Notes
  Please read the inline comments carefully. As these files were 
  downloaded from the internet, PowerShell marks them as "unsafe" and 
  will block their execution. The steps here show how to unblock them.
  
  Be aware you cannot simply run this script, you will need to copy the
  code into a new script you have created locally.
   
-----------------------------------------------------------------------------#>


# First, you need to understand a bit about PowerShell security. Use the
# following command within the command prompt (at the bottom of the ISE)
# to see your security level.
Get-ExecutionPolicy

# To fully understand execution policies, see the about topic at:
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1
# A brief overview of the polices follows.

# The default policy is Restricted (Undefined is the same thing). In this
# setting, no scripts will run. 

# The most common policy is RemoteSigned. This means scripts that are 
# local to your computer, scripts you create, are allowed to run. Other
# scripts, such as those you download, must a cryptographic hash applied
# using a security certificate. 

# Unrestricted and Bypass mean you can run scripts from the internet, 
# however they will warn you and continually ask if "it's OK". 

# To change the security setting, you can use:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# and set it to something other than Restricted. RemoteSigned is the
# generally recommended setting and was shown above as an example. 

# Unrestricted and Bypass are very powerful and should be used only
# by experienced PowerShell developers.

# Note you will have to have Administrator rights on the computer
# in order to change this. In addition, you will have to be running
# the PowerShell ISE (or PowerShell command prompt) in Admin mode.

# The problem with attempting to use signed code in a learning sample 
# such the PSAzure module is that it prevents you from making changes, 
# something you'd obviously want to do as you experimented while learning 
# how to use PowerShell with Azure. 

# The solution to this is to use the Unblock-File cmdlet. This cmdlet
# changes the flags on the files so that PowerShell now believes they
# are safe, local files. Thus they will execute under the RemoteSigned
# security policy. 

# Unblocking the files is fairly easy, although you do have to 
# indicate the folders where you placed the PSAzure-Module folders
# after downloading. 

# Note, if you downloaded this file from the internet, you cannot
# simply run it, as PowerShell thinks it is stil unsafe. 
# Instead, simply open up a new window in the ISE and copy the
# four lines below into it. PowerShell will understand this is a script
# you've created locally. You don't even have to save the file you copied
# into. 

# Alternative you could simply copy and execute each line, one at 
# a time, into the command window at the bottom of the ISE.

# Before running change the variable to the folder where you placed
# the PSAzure-Module files. It assumes you retained the folder layout
# included in the zip file or from the github site. (See the script
# Install-PSAzureModule.ps1 for more on folder structures.)

$powershellScripts = 'C:\PowerShell'
Unblock-File -Path "$powershellScripts\PSAzure-Module\PSAzure\*.*"
Unblock-File -Path "$powershellScripts\PSAzure-Module\PSAzure-Deploy\*.*"
Unblock-File -Path "$powershellScripts\PSAzure-Module\PSAzure-Examples\*.*"
