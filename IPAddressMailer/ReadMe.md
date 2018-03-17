# IPAddressMailer

Readers of my blog over at [ArcaneCode](http://arcanecode.me) may know I'm a ham radio operator (N4iXT that's me!). One my my ham radio buddies has a cool radio that can be remotely controlled over the internet. With their software he just enters the IP address of his home (his home router that is, after we setup soem port forwarding), and he can connect to and operate his radio remotely, make contacts around the world and more. 

The tricky part of all this came in the sentence *enters the IP address of his rome...*. His home router tends to change it's address on the whim of his service provider. If the router reboots, it will definately have a new address when it comes up. You may be thinking "well just get a static IP address". Unfortunately his provider can't provide him this, something about him using a bonded pair of 10 gig lines to get 20 gig prevents it. 

So how could he get notified when his IP address changes? Well I was fairly certain I could solve his problem with some simple PowerShell scripting! This solution consists of three PowerShell scripts. 

---
### IPAddressMailer.ps1

The core is **IPAddressMailer.ps1**. This is what handles checking for changes, and emails the results. At the top of the script are a few variables the user of the script will need to set. 

First is the email address the email is to be sent from, and the password. The script is setup using GMail, as it's pretty friendly to use with scripting. Before anyone says anything about passwords in scripts, I recommend a GMail account be setup expressly for this purpose. That way if someone did hack in, all they'd see is a bunch of messages "Hi your IP address is..." and some spam. Under those circumstances the cost of lost data (i.e. lost email account) were negligable to the point I didn't spend the time to come up with some elaborate encryption scheme. 

The next piece of information is the email account the messages are being sent to. No password needed here, and it could be the same email address as the one you are sending from. 

The next piece of information the script needs to know is where the scripts are being executed from. By default I use C:\IPAddressMailer, but you are free to run from another folder. One important point, do not install into a user space such as Documents or OneDrive. A later script will setup this script to run even when the user is not logged in. As such it can't run out of some user specific folder. 

The last two pieces of info indicate the frequency at which the IP Address is emailed. By default email is only sent when a change in IP Address is detected. The variable $alwaysEmail can be changed to a value of $true, with that setting an email will always be sent every time the script runs. This isn't recommended, although you may want to set it to true for testing purposes.

The final variable in this script that a user may wish to set is $emailOnceADay. Setting it to $true will email the IP address the first time the script is executed during a calendar day, even if it hasn't changed. Some people like a "warm fuzzy" to assure themselves the address hasn't changed, to remind themselves of their home IP address, or just to validate their home computer is up and running. 

That's all that needs to be covered here in the overview for this particular script. There are plenty of comments within it if you want to see more about how it works.

OK, so as you see this script is what does the bulk of the work as far as checking the IP address and emailing it. But what calls the script? That's where the next script comes into play. 

---
### ScheduleIPAddressMailer.ps1

This solution uses the Windows Task Scheduler to run the IPAddressMailer.ps1 script. If you are unfamilar with it, the Task Scheduler looks in its database and says "do I have any tasks I need to run right now?". If it finds a task, it then runs it. 

The **ScheduleIPAddressMailer.ps1** setups up entries in the Windows Task Scheduler that will execute the IPAddressMailer.ps1 script. This is a rather nice solution in that the IPAddressMailer script is not constantly running in the background, consuming resources. It runs, then exits. 

There are only two things that a user of this script may need to change. First, is the $timesToRun array at the top. By default it executes at the top of every hour. If you want to run more frequently, just add more entries. You could, for example, have it run every fifteen minutes. If you go with the defaults of only emailing when the address changes, the resources used will be minimal and you won't be flooded with emails. You could also reduce the amount of times it runs by removing entries. 

Just be sure that if you are adding or removing entries, that every entry have a comma after it, except the very last one. Note too the 0's on the front of the times isn't necessary for the scheduler, you could also put '1:00pm'. The zeros were just included as the time becomes part of the task name in Windows Task Scheduler and it makes the list within it a bit easier to read. 

The second important variable to note is the $path variable. Just like with IPAddressMailer.ps1, this is where you have the scripts installed. By default it is C:\IPAddressMailer. 

And that's it! Once you setup the times you want to run, and where you are running from (and you could just use the defaults), just run the script and it will create tasks that begin with *SendExternalIP_at* followed by the time, for example SendExternalIP_at_01_00am. 

When the script completes it will display a list of all the tasks that were created. If at any time you just want to see what you have, just open the script and copy the last line into a PowerShell window, namely:

```powershell
Get-ScheduledTask -TaskPath '\' -TaskName 'SendExternalIP_at*'
```

So now you have the emailer script setup, and you've scheduled everything to run in the task scheduler using this script. What if you change your mind? Perhaps you want to alter the schedule when the IPAddressMailer runs? Or maybe you get lucky and can get a static IP address? That's where the next script comes in.

---

### UnscheduleIPAddressMailer.ps1

The final script in this solution is **UnscheduleIPAddressMailer.ps1**. It simply cycles through the Windows Task Scheduler and deletes any task that begins with *SendExternalIP_at* . No modifications are needed on the part of the user. Just beware if you setup any tasks manually that begin with this same text, they will be deleted as well. 

---

### Other Files

When the IPAddressMailer.ps1 script, it creates two text files: **LastIPAddress.txt** and **LastIPAddressRunDate.txt**. The use of these files is pretty self-explanatory from their names. If at some point you delete them, all that will happen is you'll get an email the next time the task scheduler executes IPAddressMailer, as without the files it'll think the IP address has changed. 
