This folder has code for deploying the module to the users Documents WindowsPowerShell folder.

Unblock-PSAzure.ps1 contains the code and instructions to "unblock" the files. Because you downloaded these samples from the internet, PowerShell will mark them as unsafe and not run them (or prompt you constantly, depending on your security settings). This file explains how to convert all the in this module to be "local" so PowerShell will execute it.  

WARNING: Don't trust me. Seriously. Look over all the code to ensure it is safe to run before you go off all willy nilly and unblock it. I know I'm a wonderful guy, but you need to review this code so you will learn that too. Hey, my wife doesn't trust my PowerShell so why should you? 

DeployModule.ps1 has functions to aid in deploying modules.

Install-PSAzureModule.ps1 has the code for actually deploying the module. Be sure to update the variables in it for the folder you are deploying from.