<#--------------------------------------------------------------------
  Z2H-AZ-02 Access-Azure
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          https://arcanecode.com | https://github.com/arcanecode
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights 
  reserved. No warranty or guarentee is implied or expressly granted. 

  All information was accurate at the time of the demo creation. Note
  that things are changing very rapidly in the world of Azure in 
  general and Azure's PowerShell modules in particular, so be sure
  to check Microsoft online documentation for the latest information.
  
  Once you've installed Azure, you'll want to know how to login
  to Azure from PowerShell, in order to execute the cmdlets you'll
  learn about in other demos. 

  There are currently four methods for logging into Azure, this 
  script will demonstrate each one. Note that each has their own
  benefits and drawbacks. 
--------------------------------------------------------------------#>

#region Method 1 - Manual Login
<#--------------------------------------------------------------------
   Method 1

   Add the Azure Account to the current session. This will bring up 
   a dialog for you to login. Only downside is you have to do this 
   each time you execute your script
--------------------------------------------------------------------#>
Add-AzureRmAccount

# Note many documentation list Login-AzureRmAccount. This is just
# an alias to Add-AcureRmAccount

# List the Current context for this session. Note the SubscriptionName
# which indicates which subscription is active
Get-AzureRMContext

# This will get a listing of all of your subscriptions
Get-AzureRMSubscription

# If you have multiple subscriptions, you can use
# the next cmdlet to select which one 
# Note this cmdlet used to be Select-AzureRMSubscription
Set-AzureRmContext -SubscriptionName 'Azure Free Trial'

Set-AzureRmContext `
  -SubscriptionName 'Visual Studio Ultimate with MSDN'

#endregion Method 1 - Manual Login

#region Method 2 - Importing Context
<#-------------------------------------------------------------------- 
   Method 2 - Saving and importing your context

   Please note that what is now called Context was originally called
   Profile. MS has changed the main noun to be Context in the most 
   recent versions of AzureRM

   First, you will need to have logged in manually, using the
   method above.

   Then, you will need to save your context to a spot on your local
   drive. 

   After that, you can just import the context in future scripts.

   The danger to this method is the file you've saved to must be 
   kept secure. Otherwise if someone were to obtain the context 
   file, they could login as you.
--------------------------------------------------------------------#>
# Set a variable with the path to the working directory as we'll
# use it over and over
$dir = "$($env:OneDrive)\Pluralsight\Azure\PS"

# Setup - First login manually per previous section
Add-AzureRmAccount

# Now save your context locally (Force will overwrite if there)
$path = "$dir\ProfileContext.ctx"
Save-AzureRmContext -Path $path -Force

# Once the above two steps are done, you can simply import
$path = "$dir\ProfileContext.ctx"
Import-AzureRmContext -Path $path

#endregion Method 2 - Importing Context

#region Method 3 - Certificates
<#-------------------------------------------------------------------- 
   Method 3

   Use an AzureAD Certificate

   This requires several steps to setup. 

   First, you would need to get your Azure AD admin to create a 
   certificate for use in signing in. Next, that certificate would
   have to be installed, usually through Group Policy or perhaps
   DSC, to all machines that would be running your Azure Scripts.

   In this example, rather than having an AD Admin create our 
   certificate, we'll be generating a self signed certificate that
   we can use for testing. Note that this certificate will only
   work on the PC on which it is created, and will not be
   transferrable to another computer. 

   Also note the method we'll be using, New-SelfSignedCertificate,
   only works on PowerShell 5. For previous versions there is
   a script called New-SelfSignedCertifcateEx.ps1 (search for it
   on the interwebs) that will assist you. Alternatively, in the
   downloads for this course I've included a PDF which walks you 
   through the manual creation of a self signed certificate.

   I need to give a shout out to DexterPosh's blog post, which 
   guided me on creating this code.
   http://www.dexterposh.com/2017/03/powershell-azurerm-using-certificate.html


   A few terms to help clarifiy what we are doing.
   -- A Tenant is equivalent to an instance of an Active Directory
      in Azure.
   -- An Application defines all of the components which can
      interact with your Azure tenant. This could be databases,
      websites, etc. It is used to authenticate against the 
      Active Directory. 
   -- The Service Principal holds roles. Roles define what
      rights and permissions are available within the application.

--------------------------------------------------------------------#>
<# 
   As a first step, we'll obviously need to login to Azure manually,
   so we can interact with it. 
#>
Add-AzureRmAccount

# Later in the process we'll have to have the tenant ID. The tenant
# is a property of the object returned by the Get-AzureRMContext,
# so let's grab it now. 
$context = Get-AzureRMContext

<# 
  Later we'll need the tenant ID. You could display it, then copy
  and hard code it. To make it easy to share among multiple runs
  and PS1 scripts, we'll place it into a file and read it from
  there. 
#>
$context.Tenant  # Display on screen

# Write it to a file in the current folder
Set-Content -Value $context.Tenant -Path "$dir\TenantId.txt"

# If curious you can open it to view
psedit "$dir\TenantId.txt"

<# 
   Our first step to certificate logins is the need to have a 
   certificate. For our development, we'll create a new self-signed
   certificate. But before we can do so I need to make sure none
   exist already with that name.
#>
# See if any already exist (this would usually only happen from 
# running this demo previously)
Get-Item -Path 'Cert:\CurrentUser\my\*' |
  Where-Object Subject -eq 'CN=AutomatePSLogin' 
  
# If one does, remove it  
Get-Item -Path 'Cert:\CurrentUser\my\*' |
  Where-Object Subject -eq 'CN=AutomatePSLogin' |
  Remove-Item

# OK now we're clear to create a new certificate
$selfSignedCertificate = New-SelfSignedCertificate `
  -CertStoreLocation 'cert:\CurrentUser\My' `
  -Subject 'CN=AutomatePSLogin' `
  -KeySpec KeyExchange `
  -KeyExportPolicy NonExportable

# Show the newly created certificate
Get-Item -Path 'Cert:\CurrentUser\my\*' |
  Where-Object Subject -eq 'CN=AutomatePSLogin' 
  
<# 
   Now we'll take the certificate, and extract is as a base64 
   encoded string. This will become the key to associating
   the certificate with the new AD Application.
#>
$certKey = [System.Convert]::ToBase64String($selfSignedCertificate.GetRawCertData())

# Now we can create our new AD application. Note the identifierUris 
# must be unique across your apps. If you try to create one that
# already exists you'll get an error.
$app = New-AzureRmADApplication `
        -DisplayName 'ACTestCertificate' `
        -HomePage 'https://datadynasty.org' `
        -IdentifierUris 'https://datadynasty.org/certificate' `
        -CertValue $certKey `
        -EndDate $selfSignedCertificate.NotAfter `
        -StartDate $selfSignedCertificate.NotBefore 
                   
# Later we'll need the application ID. Since we won't be logged in,
# we won't be able to get it in an automated fashion, thus we'll
# display it now. You can either hard code it, or save it to
# a file like we did with the tenant ID.
$app.ApplicationId
Set-Content -Value $app.ApplicationId `
            -Path "$dir\ApplicationId.txt"
psedit "$dir\ApplicationId.txt" # Show the file for confirmation

<# 
   So far we've created our certificate, then created an AD app
   linking it to the certificate.

   Next, we'l need to create a service principal for the AD App.
#>
New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

# It takes a bit for the SP to get setup, so pause for a moment
Start-Sleep -Seconds 20

<#
   Now that the service principal exists, we need to define the role
   it will serve. 
   The Role Definition Name defines the RBAC (Role Based Access 
   Control) role that needs to be assigned. For a complete list
   of roles and their associated permissions in Azure, see:

   https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-built-in-roles
  
   WARNING: For our demos were using Owner. This is the highest level,
   but in our case OK because all we are doing is demos on a sample
   environment. For your production purposes you should review the
   roles at the URL above and only grant permissions you need.
#>
New-AzureRmRoleAssignment -RoleDefinitionName Owner `
                          -ServicePrincipalName $app.ApplicationId

<#
   Now that everything is setup, we can login in an automated
   fashion. This is the basic code we'd use at the top of every 
   script where we need to login. 
  
   First, get a reference to the certificate. In our case it is
   our self signed certificate, in an enterprise it would be the
   cert provided by the AD admin.
#>
$certificateSubject = 'CN=AutomatePSLogin'
$certificate = Get-ChildItem -path 'Cert:\CurrentUser\my' |
  Where-Object Subject -eq $certificateSubject

# Retrieve the tenant and app ids from the files we previously
# saved them to. 
$tenantID = Get-Content "$dir\TenantId.txt"
$appID = Get-Content "$dir\ApplicationId.txt"

<#
   Now we have our certificate, application ID, and
   tenant ID. We're ready to login. First though, let's logout
   just to prove it works.
#>

# OK, now we can login.
Add-AzureRmAccount -ServicePrincipal `
                   -CertificateThumbprint $certificate.Thumbprint `
                   -ApplicationId $appID `
                   -TenantId $tenantID 

# And run a command again to show we are in. 
Get-AzureRMContext

# Now at the top of the scripts we can include:
. "$dir\Z2H-AZ-AzureLogin.ps1"

# To view everything open the Azure portal, and go to Azure 
# Active Directory, then App Registrations.

# After experimenting you will likely want to delete everything. 
# Note be sure to login using your normal credentials, not
# those provided by the certificate
Add-AzureRMAccount

# Get the app object for our application
$app = Get-AzureRmADApplication |
  Where-Object DisplayName -eq 'ACTestCertificate'

# Use -Force to suppress the 'are you sure' message
Remove-AzureRmADApplication `
  -ObjectId $app.ObjectId `
  -Force

# Remove the self-signed certificate we created
Get-Item -Path 'Cert:\CurrentUser\my\*' |
  Where-Object Subject -eq 'CN=AutomatePSLogin'|
  Remove-Item

# Show it has been deleted
Get-AzureRmAdApplication

#endregion Method 3 - Certificates

#region Method 4 - Embedded Password
<#-------------------------------------------------------------------- 

   Method 4

   Method 4 of logging in allows you to use your normal credentials,
   without the need to create a certificate. It is very dangerous
   however, in that you must either embed your password in the
   script itself, or storing them in a file. This is a very bad
   practice. However it does wind up getting done a lot,
   so we'll show it for completeness. 

--------------------------------------------------------------------#>

# First, login to Azure
# Note Login-AzureRmAccount was replaced by Add-AzureRmAccount
Add-AzureRmAccount

<#
   As before we'll need to create an Azure RM Active Directory 
   Application. The Display Name is the name of your App
   and IdentifyURIS is how you can find the app. Note it must
   be unique across all apps. Also note that unlike the previous
   example where we used a certificate, we must supply a password.
#>

$password = Get-Content "$dir\apw.txt"

$azureRmAdApplication = New-AzureRmADApplication `
  -DisplayName 'ACTestAppTest1' `
  -HomePage 'https://datadynasty.net' `
  -IdentifierUris 'https://datadynasty.net/example' `
  -Password $Password

# Now create a new service principal
New-AzureRmADServicePrincipal `
  -ApplicationId $azureRmAdApplication.ApplicationId

<#
   Now assign a role to the service principal. Note what while there
   are many roles, in this case we'll be using the owner role.
   See the notes in the previous section on roles.
   As with before we'll give it a few seconds to complete.
#>
New-AzureRmRoleAssignment `
  -RoleDefinitionName Owner `
  -ServicePrincipalName $azureRmAdApplication.ApplicationId.Guid

Start-Sleep -Seconds 20

<#
  Obtain your domain name.
  To get your domain name, you'll have to open the azure portal.
  Then, hover over your name in the upper right corner. A small 
  pop up will appear. The domain name will be the bottom item
  and  having some variation on your user name plus
  .onmicrosoft.com (as of writing this demo it is mislabeled
  'Directory', as is the line above it)
#>

# Mine is rccaingmail191.onmicrosoft.com

# We'll get the account ID from the azure app variable we got earlier
$accountId = $azureRmAdApplication.ApplicationId.Guid

# While we're here, let's write the account ID to a file
Set-Content -Value $accountId -Path "$dir\ApplicationIdCredential.txt"

# We will also need the Tenant, we can get that from AzureRMContext
$rmContext = Get-AzureRMContext
$tenantId = $rmContext.Tenant

# And write it to a file
Set-Content -Value $tenantId -Path "$dir\TenantIdCredential.txt"

# Determine the login by combining the account id plus your
# domain name
$login = $accountId.ToString() + '@rccaingmail191.onmicrosoft.com'

#Create Credentials
$pass = ConvertTo-SecureString $password -AsPlainText –Force 
$cred = New-Object -TypeName pscredential –ArgumentList $login, $pass
 
# Test the Automated Login
Add-AzureRmAccount `
  -Credential $cred `
  -ServicePrincipal `
  –TenantId $tenantId


# With all that done, you can now automate your logins.
$password = Get-Content "$dir\apw.txt"
$tenantID = Get-Content "$dir\TenantIdCredential.txt"
$applicationID = Get-Content "$dir\ApplicationIdCredential.txt"
$login = $applicationID.ToString() `
           + '@rccaingmail191.onmicrosoft.com'

# Create a Credential object
$pass = ConvertTo-SecureString $password -AsPlainText –Force 
$cred = New-Object -TypeName pscredential –ArgumentList $login, $pass

# Now test the login
Add-AzureRmAccount `
  -Credential $cred `
  -ServicePrincipal `
  –TenantId $tenantId

# Verify by running a command
Get-AzureRmContext

#endregion Method 4 - Embedded Password

#region Cleanup
<#--------------------------------------------------------------------
# After experimenting you will likely want to delete everything. 
# Note be sure to login using your normal credentials, not
# those provided by the certificate
--------------------------------------------------------------------#>
Add-AzureRMAccount

# Get the app object for our application
$app = Get-AzureRmADApplication |
  Where-Object DisplayName -eq 'ACTestAppTest1'

# Use -Force to suppress the 'are you sure' message
Remove-AzureRmADApplication `
  -ObjectId $app.ObjectId `
  -Force

# Show it has been deleted
Get-AzureRmAdApplication

#endregion Cleanup
