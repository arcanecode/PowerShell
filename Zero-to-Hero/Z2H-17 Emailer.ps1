<#-----------------------------------------------------------------------------
  SQL Saturday Speaker Emailer
  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  No warranty or guarentee is implied or expressly granted. 

  When running a SQL Saturday, or other similar event such as a Code Camp,
  it can be useful to send personalized e-mails to each speaker. For even a
  small event this can get time consuming quickly. 

  I created this PowerShell script in order to automate the process. The
  script is fed from a CSV file with four fields. Here is a sample of
  what the CSV would look like:

To,Name,Note1,Note2
arcane@arcanetc.com,Robert Cain,Pester Testing,Morning Session
rccain@gmail.com,Robert C. Cain,Nuclear Science,
n4ixt@outlook.com,N4IXT,Ham Radio,"Early Afternoon, or Late Morning Session"

  The To field is obviously the email address of the speaker, the
  Name is the speaker name. The Note1 field is intended for the session
  that was selected. The Note2 is for any special requests that may have
  been made, such as a morning session is preferred.

  Obviously this script can be customized and used for all kinds of events.

  One note, for this I am using GMail to send the mails with, hence I've
  put in the GMail SMTP server and SSL port. 

  If you use two factor authentication with your GMail account, (and you
  should be!) you will need to login to your Google account and create 
  a special application password, and use that special application password 
  in this script.

-----------------------------------------------------------------------------#>

# The GMail account used to send emails from
$from = 'ArcaneCode@gmail.com'

# You should CC the SQL Saturday account to keep track of everything
$cc = 'sqlsaturday593@sqlsaturday.com'

# I default the subject to your SQL Saturday name
$subject = 'SQL Saturday 593'

# GMails SMTP info
$smtpServer = 'smtp.gmail.com'
$smtpPort = '587'

# Enter your password, or applicaiton password if you use two factor auth
$pw = Get-Content -Path 'C:\Users\Arcane\OneDrive\PS\Z2H\gpw.txt'

# This will convert your user name/password to a credential 
$credentials = New-Object System.Net.NetworkCredential($from, $pw)

# Import the CSV file
$csvFile = 'C:\Users\Arcane\OneDrive\PS\Z2H\SQLSat593NoHearFrom.csv'
$csvData = Import-Csv $csvFile

# Loop over each speaker in the CSV file
foreach ($row in $csvData)
{  
  # To make the email nice looking we'll send it using HTML format.
  # At the top I include a CSS block to format the email to a 
  # decent font and size. 
  $body = @"
<style>
  p {
    font-size: 19px;
    font-family: Arial;
  }
</style>
<p>Greetings $($row.Name)!</p>
<p>This email is to follow up on the announcement 
of your selection as a speaker for SQL Saturday 593 in Birmingham, Alabama 
on March 18th. </p>
<p>We are working on putting the final schedule together, but need your help. 
Can you please reply to this email by noon CST this Sunday, February 12th and 
confirm you are still eligable to speak?.</p>
<p>As you know marketing is critical to every event, and for SQL Saturday 
the product is you! We 
hope to release the schedule early next week, and confirming your ability to 
speak will only add to the enticement to get people to attend.</p>  
<p>To ensure we can save you a spot on the speaker list, please let us know by 
Sun Feb 12th at noon CST. If we haven't heard back from you we'll be 
(very reluctantly) forced to free up the slot for another speaker. </p>
<p>If you have any questions, or cannot attend please let us know as soon 
as you can. This is also a good time to let us know of any requests, 
such as a preference for a session time. </p>
"@
<#  $body = @"
<style>
  p {
    font-size: 19px;
    font-family: Arial;
  }
</style>
<p>Greetings $($row.Name) and thanks for submitting to SQL Saturday 593!</p>
<p>We're happy to announce your session $($row.Note1) has been selected.
If you have any questions, or cannot attend please let us know as soon as you can. </p>
"@
#>
  # This next part of the body is only included if the speaker made
  # a special request of some type.
<#  if($row.Note2.Length -gt 0)
  {
    $body += "<p>Please note we will be accommidating your request for $($row.Note2).</p>"
  }
#>  
  # Now we can append on a link to the schedule, and hotel information.
<#  $body += @"
<p>Please check the schedule at the 
<a href="http://www.sqlsaturday.com/593/eventhome.aspx">
SQL Saturday 593 website </a>
to see your time slot, and let us know as soon as possible if you need 
a change or suddenly find yourself unavailable.</p>
<p>For hotel accomodations we recommend 
<a href="http://someurl.com">SQL Sleepy Inn.</a></p>
"@
#>
  # Now append on the signature for the person sending the mail.
  # I made it spiffy, but you are free to simplify it. 
  $body += @"
<p>Thanks,</p>
<p>     Robert</p>
<p><b>Robert C. Cain, MVP, Speaker Chairman</b><br>
<b>Arcane Training and Consulting, LLC</b><br>
Author, <a href="https://www.pluralsight.com/authors/robert-cain">Pluralsight</a> | 
Teammate, <a href="http://www.linchpinpeople.com/">Linchpin People</a><br>
<a href="https://twitter.com/arcanetc">@ArcaneTC</a> | 
<a href="http://arcanecode.com">arcanecode.com</a></p>
"@

  # Create a message object to hold the email itself 
  $eMailMsg = New-Object System.Net.Mail.MailMessage
  $eMailMsg.from = $from
  $eMailMsg.to.add($row.To)
  $eMailMsg.cc.add($cc)
  $eMailMsg.subject = $subject
  $eMailMsg.body = $body
  $eMailMsg.IsBodyHtml = $true

  # This message doesn't have attachments, but I left
  # the code in here in case you need it in the future
  #$message.attachments.add($attachment)
  
  # Now create an SMTP object. This will be used to 
  # establish a connection, credentials, then send
  # the email.
  $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort);
  $smtpClient.EnableSSL = $true
  $smtpClient.Credentials = New-Object System.Net.NetworkCredential($from, $pw);
  $smtpClient.send($eMailMsg)

  # Just a little progress message
  Write-Host "Mail Sent to $($row.To)"

  # Some e-mail providers will flag you as a spammer if you try to
  # send a lot of e-mails too quickly. I added a short 10 second 
  # delay between messages to help avoid getting flagged. 
  Start-Sleep -s 10
}
