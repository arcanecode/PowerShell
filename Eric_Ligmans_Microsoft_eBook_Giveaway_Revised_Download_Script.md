Every year, Eric Ligman, director of Sales Excellence for Microsoft, creates a blogpost in which he gives away tons of FREE Microsoft eBooks. 

You name it, it’s in the list. SQL Server, Azure, PowerShell, .NET, BizTalk, SharePoint, Windows Server, and more. You can find Eric’s post at:

https://blogs.msdn.microsoft.com/mssmallbiz/2017/07/11/largest-free-microsoft-ebook-giveaway-im-giving-away-millions-of-free-microsoft-ebooks-again-including-windows-10-office-365-office-2016-power-bi-azure-windows-8-1-office-2013-sharepo/#comments

While there are individual links to each file, what if you want every one of them? He explains on the post why he doesn’t provide a big zip file. He does, however, provide a PowerShell script (attributed to David Crosby) that will do the job.

However, I found some issues with the script. Not that it didn’t work, it did, but there were several things I felt could be done to improve it. 

First, there was no progress message issued during the download. As a user, I had no idea which file I was on, so had no concept of how much longer it would take. Thus, I’ve added a little progress message.

I then thought “Hmm, what if my downloads were interrupted, I don’t want to have to start all over”. So, I added some code that sees if the file we’re downloading already exists. This way it won’t re-download a file it already has.

But then another problem arose. What if it had partially downloaded a file? Just checking the file names wouldn’t catch that. So I added further code to compare the file size at the source with the file size on disk. If different, then it will re-download. 

So now it will skip the file only if the file name is already on the local disk, and the file sizes match. 

I now encountered my next concern. Crappy internet. I live out in the country, and while I love my privacy and rural living, my internet sucks. It is prone to go down or drop packets. If it hic-cuped during a  download I didn’t want it to crash, but instead go onto the next file. 

Thus I added a try/catch error handler, which displays an error message and continues on. 

At this point I thought I was done. Just I was about to call it finished though, a typical afternoon Alabama thunderstorm came up. Kaboom! House rattled and power blinked. 

This presented my final issue, what if the power went out? I’d want to know where it got to with the downloads. So I added some further code such that when the script starts it creates a new log file and appends each message to it. 

I realize some of you have superfast gigabit internet and will be able to download these almost instantly. (I hate you by the way. #jealous). So I made logging optional, so it wouldn’t create an extra file if you didn’t want it. Just set the $log variable to $false, and it will skip logging. 

So there you go, a revised download script that will handle stopping and restarting the script gracefully, will look for errors, and adds logging so you can track progress. 
