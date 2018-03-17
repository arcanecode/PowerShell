<#-----------------------------------------------------------------------------
  IPAddressMailer.ps1

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me

  The purpose of this script is to email someone with the current external
  IP address for your system, in other words the IP Address of the router. 
  The only way to accomplish this is to make a call to a website which 
  returns the IP address it sees you coming from. 

  This is ideal for situations where you cannot obtain static IP address for
  your home router, your router's IP address changes regularly, and you are 
  away from home but need that information for remote login purposes. 

  In this routine we employ the ipinfo.io site, which returns just the IP
  address it sees your computer coming from (i.e. your router). Getting the
  external IP is actually the trivial part of this script.

  Next, we will email that information to someone. Please note this routine
  has only been tested using GMail to send the message. You will need to
  adjust the parameters accordingly if you are using someone other than 
  GMail to send. 

  Two other important points. First, if you are using two factor 
  authentication (and you should be) you will need to setup what they
  call an "app password". Instructions are in the script below.

  Second, in the recieving account if you don't see the message be sure
  to check your spam filter. In my testing the receiving account threw
  the first message into spam, I had to mark it as "trust this user".

  Another IMPORTANT note, this is part of a two step solution. This
  script will actually get the external IP Address and mail it. The
  second part is the ScheduleIPAddressMailer.ps1 script. You run that
  script once, and it will setup the WindowsTaskScheduler with the times
  to execute this script. Alternatively you can manually setup the call
  to this in the task scheduler itself. 

  VERY IMPORTANT!!!! You must run this script in ADMINISTRATIVE MODE.
  The script needs to run under a system login, and you can only select
  a system login user when in admin mode. 
   
  This code is Copyright (c) 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author.

-----------------------------------------------------------------------------#>

# These are the three lines you MUST modify. Enter the email address you 
# are sending from, it's password, and the email address you are sending to.
# Note the from and to can be the same if you want.

# Two notes (in case you skipped the comments above)
# 1. This is setup to work with GMail as the sending email address
# 2. If you are using two factor authentication you'll have to setup an 
#    app password, see the instrucitons below. 
$fromEmailAddress = "yourmail@gmail.com"
$fromEmailPassword = "yourpassword"
$toEmailAddress = "you@somewhere.com"

# If you want to have multile emails in the TO, load them into an array
# like this:
#
# $toEmailAddress = @("email1@gmail.com", "email2@outlook.com", "email3@yahoo.com")
#
# Just add more addresses to the end (with commas) as needed.

# The script assumes you are placing all scripts that are part of this 
# package into the folder 'C:\IPAddressMailer'. If you alter that, please
# update the variable below. Be sure to pick a path NOT in the 'user space'
# such as Documents or OneDrive, otherwise the Scheduled Task will fail.
$path = 'C:\IPAddressMailer'

# By Default, you will only get emailed when the External IP Addresse changes.
# You can override this and have it email every time the process runs by
# setting this variable to true. 
$alwaysEmail = $false

# Another option is to email once per day, in addition to on change. Set this
# variable to true if you want to turn this on
$emailOnceADay = $false

<#-----------------------------------------------------------------------------
  If you have two factor authentication (2fa) turned on,  you will need to 
  create what Google calls an "App Password". This is a password for a specific
  appliation to be able to use. 

  Here are the steps to create an App Password.

  1. Login to Google with your normal ID and Password.
  2. Click on the circle in the upper right with your picture or initials.
  3. Click on My Account
  4. Click on "Signing in to Google" on the right side (as of this writing).
  5. Scroll down to App Passwords
  6. If prompted enter your normal password, to again verify it's you.
  7. At the bottom, click on Select App, Other, then enter "PowerShell" 
     or something similar.
  8. Click on Generate. A window will pop up with your generated password. 
     While it displays as
         XXXX XXXX XXXX XXXX
     In fact there are no actual spaces, Google just does this to make it
     easier to write down. If you had actually copied it to the clipboard
     and pasted you'd see:
         XXXXXXXXXXXXXXXX

  9. WRITE DOWN YOUR PASSWORD! Or better yet save it to a password manager
     such as LastPass. Once you generate the password you won't be able to
     go back and see it again. You could of course generate another password,
     but then you start to accumulate them pretty quickly.
 10. Paste or enter your generated password into the $fromEmailPassword
     variable above, again excluding any spaces. 
    
-----------------------------------------------------------------------------#>

# From this section down, it is unnecessary to change anything. However,
# you are certainly welcome to alter the Body or Subject to add additional
# information should you desire. 

# The following functions assist with getting info to determine if we need
# to send out an email

function Get-LastIpAddress ($Path)
{
  # Get the IP Address from the last time the script ran
  $lastIPAddressFile = "$Path\LastIPAddress.txt"
  
  if ((Test-Path $lastIPAddressFile) -eq $false)
  {
    # If the file doesn't exist, just set to empty string
    $lastIPAddress = ''
  }
  else
  {
    # Get the IP Address from the last run, and strip out any special characters
    $lastIPAddress = Get-Content $lastIPAddressFile -Raw
    $lastIPAddress = $lastIPAddress -replace "`t|`r|`n", ""
  }
  
  return $lastIPAddress
}

function Get-ExternalIPAddress ()
{
  # Get external IP Address
  $externalIP = Invoke-RestMethod ipinfo.io/ip
  
  # The string that is returned includes a carriage return/line feed character
  # at the end. We have to strip it off otherwise if we use it in the email 
  # subject the Send-MailMessage cmdlet will reject it, as CRLF isn't allowed
  # in email subject lines.
  $externalIP = $externalIP -replace "`t|`r|`n", ""

  return $externalIP
}


function Get-LastIPAddressRunDate ($Path)
{
  $yesterdayFile = "$path\LastIPAddressRunDate.txt"

  if ((Test-Path $yesterdayFile) -eq $false)
  {
    # If the file doesn't exist, just set to empty string
    $yesterday = ''

    # Then go ahead and create the file
    Set-Content -Path $yesterdayFile -Value $today

  }
  else
  {
    # Get the IP Address from the last run, and strip out any special characters
    $yesterday = Get-Content $yesterdayFile -Raw
    $yesterday = $yesterday -replace "`t|`r|`n", ""
  }

  return $yesterday

}

# Get today's date and the date the script last ran
$today = Get-Date -Format d
$yesterday = Get-LastIPAddressRunDate -Path $path 

# Get the current IP address, and the IPAddress from the last time
# the script ran
$lastIPAddress = Get-LastIpAddress -Path $path
$externalIP = Get-ExternalIPAddress

# Go through checks to determine if we need to send an email
$sendEmail = $false   # for the default assume we don't need to send

# If the IP address has changed, send an email
if ($externalIP -ne $lastIPAddress) 
{ $sendEmail = $true }

# If user wants a mail daily, and we haven't sent it yet, do so
if ($emailOnceADay -eq $true)
{
  if ($today -ne $yesterday)
  { $sendEmail = $true }
}

# If user said always send, well then send it
if ($alwaysEmail -eq $true)  
{ $sendEmail = $true }


# Send the email if the checks said we need to
if ( $sendEmail -eq $true   )
{
  # Including the IP Address in the subject line will make it nice for
  # the receiver, as they won't even have to open the message to see it.
  $subject = "Your IP as of $(Get-Date -Format g) is $externalIP"
  
  # One minor change you may wish to make is add someone's name after the
  # word Hi, so it's a bit friendlier, such as Hi Robert,
  $body = @"
Hi,

It's $(Get-Date -Format g), and your IP address is $externalIP. 

Have a great day!
"@

  # As previously stated, this is setup to work with GMail, so here
  # we've entered their smtp server and SSL port. 
  $SMTPServer = "smtp.gmail.com"
  $SMTPPort = "587"
  
  # Send-MailMessage expects a secure credential be passed in. Thus,
  # we first have to convert the plain text password to a secure string.
  # Once that is done we can generate a credential object.
  # Note for testing we are using the App Password, not your regular
  # password. 
  $passwordSecure = $fromEmailPassword | 
                      ConvertTo-SecureString -AsPlainText -Force
  $cred = New-Object PSCredential ($fromEmailAddress, $passwordSecure)
  
  # OK, we are finally done, let's send an e-mail!
  Send-MailMessage -From $fromEmailAddress `
                   -To $toEmailAddress `
                   -Subject $subject `
                   -Body $body `
                   -SmtpServer $SMTPServer `
                   -port $SMTPPort `
                   -UseSsl `
                   -Credential $cred 

  # Update the last IP address file
  $lastIPAddressFile = "$Path\LastIPAddress.txt"
  Set-Content -Path $lastIPAddressFile -Value $externalIP -Force

  # And the date we ran
  $yesterdayFile = "$path\LastIPAddressRunDate.txt"
  Set-Content -Path $yesterdayFile -Value $today -Force
  
}

# Note Send-MailMessage has other capabilities, you could add a CC
# parameter to add other email addresses to send to. Additionally
# it can also send attachments. In this case though, neither was 
# needed for this script.

