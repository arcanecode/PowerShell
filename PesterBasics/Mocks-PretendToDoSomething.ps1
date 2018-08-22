# Function to test Mocks with
function PretendToDoSomething ()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true) ]
    $OutputFile
  )

  # For demo purposes, we're going to pretend to read 
  # from a database, do some calculations, and create a file.
  
  # First though, we're going to check to see if the target file
  # exists and if so warn the user and exit the function
  Write-Verbose "Checking to see if $OutputFile exists"
  $exists = Test-Path $OutputFile
  if ($exists)
  { 
    Write-Warning "Output file $OutputFile already exists!"
    return $false
  }
    
  # We're going to pretend, for this demo, that the Write-Verbose
  # statements are really a long series of complex code we've written.
  # In a non-demo situation this area is the code we really care about
  # testing. 
  Write-Verbose 'Pretending to read data from a database'
  Write-Verbose 'Pretending to do some calculations'

  # Write-Verbose "Pretending to write our results to the file $OutputFile"  
  Write-Verbose "Really writing our results to the file $OutputFile"
  "Some text was written at $(Get-Date)" | Out-File $OutputFile
  
  return $true
}