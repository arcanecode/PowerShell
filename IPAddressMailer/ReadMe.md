# IPAddressMailer

Readers of my blog over at [ArcaneCode](http://arcanecode.me) may recall I'm an amateur (ham) radio operator (N4IXT that's me!). One of my ham radio buddies has a cool radio that can be remotely controlled over the internet. With their software he just enters the IP address of his home (his home router that is, after we setup some port forwarding), and he can connect to and operate his radio remotely, make contacts around the world and more. 

The tricky part of all this came in the sentence *enters the IP address of his home...*. His home router tends to change its address on the whim of his service provider. If the router reboots, it will definitely have a new address when it comes up. You may be thinking "well just get a static IP address". Unfortunately, his internet service provider can't give him this, something about him using a bonded pair of 10 mb lines to get 20 mb prevents it. 

So how could he get notified when his IP address changes? Well I was fairly certain I could solve his problem with some simple PowerShell scripting! This solution consists of three PowerShell scripts. 

---
### IPAddressMailer.ps1

The core is **IPAddressMailer.ps1**. This is what handles checking for changes, and emails the results. At the top of the script are a few variables the user of the script will need to set. 

First is the email address the email is to be sent from, and the password. The script is setup using GMail, as it's pretty friendly to use with scripting. Before anyone says anything about passwords in scripts, I recommend a GMail account be setup expressly for this purpose. That way if someone did hack in, all they'd see is a bunch of messages "Hi your IP address is..." (and probably some spam). Under those circumstances the cost of lost data (i.e. lost email account) were negligible to the point I didn't spend the time to come up with some elaborate encryption scheme. 

The next piece of information is the email account the messages are being sent to. No password needed here, and it could be the same email address as the one you are sending from. 

The next piece of information the script needs to know is where the scripts are being executed from. By default I use C:\IPAddressMailer, but you are free to run from another folder. One important point, *do not install into a user space folder* such as Documents or OneDrive. A later script will setup this script to run even when the user is not logged in. As such it can't run out of some user specific folder. 

The last two pieces of info indicate the frequency at which the IP Address is emailed. By default email is only sent when a change in the router's IP address is detected. The variable $alwaysEmail can be changed to a value of $true, with that setting an email will always be sent every time the script runs. This isn't recommended, although you may want to set it to true for testing purposes.

The final variable in this script that a user may wish to set is $emailOnceADay. Setting it to $true will email the IP address the first time the script is executed during a calendar day, even if it hasn't changed. Some people like a "warm fuzzy" to assure themselves the address hasn't changed, to remind themselves of their home IP address, or just to validate their home computer is up and running. 

That's all that needs to be covered here in the overview for this particular script. There are plenty of comments within it if you want to see more about how it works.

OK, so as you see this script is what does the bulk of the work as far as checking the IP address and emailing it. But what calls the script? That's where the next script comes into play. 

---

### ScheduleIPAddressMailer.ps1

This solution uses the Windows Task Scheduler to run the IPAddressMailer.ps1 script. If you are unfamiliar with it, at regular intervals the Task Scheduler looks in its list and says "do I have any tasks I need to run right now?". If it finds a task, it then runs it. 

The **ScheduleIPAddressMailer.ps1** setups up entries in the Windows Task Scheduler that will execute the IPAddressMailer.ps1 script. This is a rather nice solution in that the IPAddressMailer script is not constantly running in the background, consuming resources. It runs, then exits. 

There are only two things that a user of this script may need to change. First is the $timesToRun array at the top. By default, it executes at the top of every hour. If you want to run more frequently, just add more entries. You could, for example, have it run every fifteen minutes. If you go with the defaults of only emailing when the address changes, the resources used will be minimal and you won't be flooded with emails. You could also reduce the amount of times it runs by removing entries. 

Just be sure that if you are adding or removing entries, that every entry has a comma after it except the very last one. Note too the 0's on the front of the times isn't necessary for the scheduler, you could also put '1:00pm'. The zeros were just included as the time becomes part of the task name in Windows Task Scheduler and it makes the list within it a bit easier to read. 

The second important variable to note is the $path variable. Just like with IPAddressMailer.ps1, this is where you have the scripts installed. By default it is C:\IPAddressMailer. 

And that's it! Once you setup the times you want to run, and where you are running from (and you could just use the defaults), just run the script and it will create tasks that begin with *SendExternalIP_at* followed by the time, for example SendExternalIP_at_01_00am. 

When the script completes it will display a list of all the tasks that were created. If at any time you just want to see what you have, just open the script and copy the last line into a PowerShell window, namely:

```powershell
Get-ScheduledTask -TaskPath '\' -TaskName 'SendExternalIP_at*'
```

So now you have the emailer script setup, and you've scheduled everything to run in the task scheduler using this script. What if you change your mind? Perhaps you want to alter the schedule when the IPAddressMailer runs? Or maybe you get lucky and can finally get a static IP address? That's where the next script comes in.

---

### UnscheduleIPAddressMailer.ps1

The final script in this solution is **UnscheduleIPAddressMailer.ps1**. It simply cycles through the Windows Task Scheduler and deletes any task that begins with *SendExternalIP_at* . No modifications are needed on the part of the user. Just beware if you setup any tasks manually that begin with this same text, they will be deleted as well. 

---

### Other Files

When the IPAddressMailer.ps1 script runs, it creates two text files: **LastIPAddress.txt** and **LastIPAddressRunDate.txt**. The use of these files is pretty self-explanatory from their names. If at some point you delete them, all that will happen is you'll get an email the next time the task scheduler executes IPAddressMailer, as without the files it'll think the IP address has changed and it is the start of a new day. 

---

### Setup

If you are an experienced PowerShell user then you could probably just skim over this session. If not, then read on!

First, create a folder to hold the files. It's suggested you use C:\IPAddressMailer. 

Next, save the three files mentioned above into this folder. Alternatively, you could copy and paste. In the next step we'll see a great tool for this. It's called the Windows PowerShell ISE, short for Integrated Scripting Environment. The ISE is a great tool for editing and executing your scripts, and is built right into Windows.

In the Windows search bar type in PowerShell ISE, or (in Windows 10) go to the Start menu and scroll down to the Windows PowerShell menu. In it you'll see Windows PowerShell ISE (if you are on a 64-bit version of Windows, don't use the one that ends in "(x86)"). **Don't run it yet though!** Instead, *right click*, and pick **Run as administrator**, then confirm you do indeed wish to run it. 

Why? You will need administrator rights to setup the tasks in Task Scheduler, as well as confirm you can run scripts. 

PowerShell has built in security that, by default, prevents PowerShell scripts from running on your system. This prevents people from delivering malicious PowerShell code over the internet. To determine your current setting, go to the blue area at the bottom of the ISE and type in the following command:

```powershell
Get-ExecutionPolicy
```

If this shows *Unrestricted* you are good to go, although this is a bit risky. It should only be used by advanced PowerShell users, as it allows any script from anywhere to run. 

If it reads RemoteSigned, you are also good to go. This is a good balance for most users. It allows you to run scripts you create on your computer (such as when you'll manually copy the scripts here to your PC) but prevents bad guys from hacking into your system and trying to run scripts remotely. 

If it reads anything else, you'll have to update it to RemoteSigned in order to run the scripts in this project. To update, simply type in the following command into the same area where you just did the Get.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

Assuming you are running the ISE as an administrator, it should update without any errors. 

Next, you'll want to create the PS1 files in this project. The ISE works like any other editor. Use File, New to create a new empty script, copy the code for IPAddressMailer.ps1 into it, and do a File, Save As... to save it into the C:\IPAddressMailer folder. Repeat with the other two scripts. 

If you want to test, you can run the IPAddressMailer.ps1 file. After you update the script per the instructions within (as described above) you can run it by one of three methods: File, Run on the menu; clicking the big green arrow in the toolbar; or (my favorite) just hitting the F5 key. If you configured it right, you should have an e-mail pop up with your IPAddress. If you want to test again, you could either update the *always run* variable to true, or delete the two txt files that were created. (See the *other files* section above.)

You're almost done! After making the (optional) changes described in the ScheduleIPAddressMailer section, just run the ScheduleIPAddressMailer.ps1 file to setup the task scheduler. Note you can update the IPAddressMailer.ps1 file without having to rerun the scheduler. For example, maybe you setup to email you once a day ($emailOnceADay = $true) and you decide you no longer want this. You can just change it back to false without having to recreate the schedule. 

---

### Other Uses

While this entire project was created to solve a specific problem, the files within could be used as a template in your own projects. The IPAddressMailer.ps1 has code that could be used to check the external IP address of a system. Additionally, it has code for sending emails via GMail. 

The scheduler and unscheduler could serve as examples of setting up and tearing down tasks within Windows Task Scheduler that could call your own PowerShell scripts. 

---

### Future

There are some things I may revisit in the future. The scripts and functions were written very basically, it was coded quickly to solve a real-world problem. There is likely some clean up that could be done. For example, the functions could be rewritten as advanced functions. 

It may also be worth converting some of the variables that have to be setup in the scripts as parameters, or perahaps create a separate config file with those pieces of information. A user could just update the config file without updating the scripts themselves. 

The password issue is also something I may revisit. As stated, if you setup an email account for just this script the risk is negligible, but putting unencrypted passwords in a script still annoys me. 

I'm also open to other ideas or suggestions. 

---

### System Specs

I developed this on a Windows 10 Pro 64-bit system with PowerShell 5.1. My ham buddy who I wrote this for is also on Win 10 Pro. Your mileage may vary depending on your version of Windows and PowerShell. 

---

### Copyright

This entire project is Copyright (c) 2018 by Robert C. Cain. It is free for you to use, with no warranty or guarantees expressed or implied. Use at your own risk. As I am able I will try to provide support for this code, answer questions, and the like. Understand my time, like everyone's, is limited so replies may take some time. 

You are free to use sections of code within your own project. Attribution is appreciated, although not required.

You may not reproduce the entire project in its entirety elsewhere on the internet, nor resell it. You are more than welcome to provide links back to this project or to my blog. 

---

### Acknowledgements

In 1675 Sir Isaac Newton wrote "If I have seen further it is by standing on the shoulders of Giants." There are a few people who helped out with this project through blog posts and suggestions. 

The first is the (now retired) scripting legend Ed Wilson. Some time back he wrote a blog post on [The Scripting Guy](https://blogs.technet.microsoft.com/heyscriptingguy/2015/01/13/use-powershell-to-create-scheduled-tasks/) website on setting up scheduled tasks in PowerShell. This article served as the foundation for my setting up of tasks. 

Next, some of my fellow Microsoft MVP's from the PowerShell side of the house assisted me with additional parameters needed in setting up the task to run unattended. A special shout out to [Michael B Smith](https://www.linkedin.com/in/theessentialexchange/), [Jan Egil Ring](http://www.powershell.no/about/), [Arnaud Petitjean](https://www.editions-eni.fr/supports-de-cours/arnaud-petitjean), and [Chrissy LeMaire](https://blog.netnerds.net/author/chrissy/) for their suggestions. 

Finally, thanks to my ham buddy for giving me such an interesting project to work on!
