############################################################### 
# Eric Ligmans Amazing Free Microsoft eBook Giveaway 
# https://blogs.msdn.microsoft.com/mssmallbiz/2017/07/11/largest-free-microsoft-ebook-giveaway-im-giving-away-millions-of-free-microsoft-ebooks-again-including-windows-10-office-365-office-2016-power-bi-azure-windows-8-1-office-2013-sharepo/
# Link to download list of eBooks 
# http://ligman.me/2sZVmcG 
# Thanks David Crosby for the template (https://social.technet.microsoft.com/profile/david%20crosby/)
#
# Modified by Robert Cain (http://arcanecode.me)
# Added code to check to see if a book was already downloaded,
# and if so was it the correct file size. If so, the book
# download is skipped. This allows users to simply rerun the
# script if their download process is interrupted. 
############################################################### 
# Set the folder where you want to save the books to
$dest = "C:\Book\" # Make sure the file path ends in a \
 
# Download the source list of books 
$downLoadList = "http://ligman.me/2sZVmcG" 
$bookList = Invoke-WebRequest $downLoadList 
 
# Convert the list to an array 
[string[]]$books = "" 
$books = $bookList.Content.Split("`n") 

# Remove the first line - it's not a book 
$books = $books[1..($books.Length -1)] 
$books # Here's the list 

# Get the total number of books we need to download
$bookCount = $($books).Count

# Set a simple counter to let the user know what book 
# number we're currently downloading
$currentBook = 0 

# As an option, we can have it log progress to a file
$log = $true

if ($log -eq $true)
{
  # Construct a log file name based on the date that
  # we can save progress to
  $dlStart = Get-Date
  $dlStartDate = "$($dlStart.Year)-$($dlStart.Month)-$($dlStart.Day)"
  $dlStartTime = "$($dlStart.Hour)-$($dlStart.Minute)-$($dlStart.Second)"
  $logFile = "$($dest)BookDlLog-$dlStartDate-$dlStartTime.txt"
}

# Download the books 
foreach ($book in $books) 
{ 
  # Increment current book number
  $currentBook++
  try
  {
    # Grab the header with the books full info
    $hdr = Invoke-WebRequest $book -Method Head 
    
    # Get the title of the book from the header then
    # make it a safe string (remove special characters)
    $title = $hdr.BaseResponse.ResponseUri.Segments[-1] 
    $title = [uri]::UnescapeDataString($title) 
    
    # Construct the path to save the file to
    $saveTo = $dest + $title 
    
    # If the file doesn't exist, download it
    if ($(Test-Path $saveTo) -eq $false)
    {
      $msg = "Downloading book $currentBook of $bookCount - $title"
      $msg
      if ($log -eq $true) { "`n$($msg)" | Add-Content $logFile }
      Invoke-WebRequest $book -OutFile $saveTo 
    }
    else
    { 
      # If it does exist, we need to make sure it wasn't
      # a partial download. If the file size on the server
      # and the file size on local disk don't match, 
      # redownload it
      
      # Get the size of the file from the download site
      $dlSize = $hdr.BaseResponse.ContentLength
      # Get the size of the file on disk
      $fileSize = $(Get-ChildItem $saveTo).Length
    
      if ($dlSize -ne $fileSize)
      {
        # If not equal we need to download the book again
        $msg = "Redownloading book $currentBook of $bookCount - $title"
        $msg
        if ($log -eq $true) { "`n$($msg)" | Add-Content $logFile }
        Invoke-WebRequest $book -OutFile $saveTo 
      }
      else
      {
        # Otherwise we have a good copy of the book, just
        # let the user know we're skipping it.
        $msg = "Book $currentBook of $bookCount ($title) already exists, skipping it"
        $msg
        if ($log -eq $true) { "`n$($msg)" | Add-Content $logFile }
      }
    }
  } # end try
  catch 
  {
    $msg = "There was an error downloading $title. You may wish to try to download this book manually." 
    Write-Host $msg -ForegroundColor Red
    if ($log -eq $true) { "`n$($msg)" | Add-Content $logFile }
  } # end catch
} # end foreach 

# Let user know we're done, and give a happy little beep 
# in case they aren't looking at the screen.
"Done downloading all books"
[Console]::Beep(500,300)
