<#-----------------------------------------------------------------------------
  Defines helper functions for parsing and cleaning text. 

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017, 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 

  This script contains the following functions:
    Find-PSCharactersInFile
    Write-PSArrayToFile
    Add-RightPadding
-----------------------------------------------------------------------------#>

function Find-PSCharactersInFile
{
<#
  .SYNOPSIS
  
  .DESCRIPTION

  .PARAMETER

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE


  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  Param(
         [string]$FilePath
       , [int]$Position
       , [int]$CharactersToGrab = 50
       )

  $data = Get-Content $FilePath -Raw
  $array = [char[]]$data
  
  if (($Position - $CharactersToGrab) -lt 0)
  { $begin = 0 }
  else
  { $begin = $Position - $CharactersToGrab }
  
  if ($array.Length -gt ($Position + $CharactersToGrab))
  { $halt = $Position + $CharactersToGrab }
  else
  { $halt = $array.Length }
  
  $text = $null # reset from previous runs
  for ($x = $begin; $x -le $halt; $x += 1) 
  {
    $text += $array[$x]
  }
  
  return $text
}

<#---------------------------------------------------------------------------#>
<# Takes an array and writes it to a file.                                   #>
<# Yes, you could use $DataToWrite | Out-File $PathFile, but on huge         #>
<# datasets the StreamWriter can be orders of magnatude faster.              #>
<#---------------------------------------------------------------------------#>
function Write-PSArrayToFile()
{
<#
  .SYNOPSIS
  
  .DESCRIPTION

  .PARAMETER

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE


  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  Param (
          [array]$DataToWrite
        , [string]$PathFile
        )

  $stream = [System.IO.StreamWriter] $PathFile
  foreach($item in $DataToWrite)
  {
    $stream.WriteLine($item)
  }

  $stream.Close()

}


# Add-RightPadding ------------------------------------------------------------------------------
#region Add-RightPadding
function Add-RightPadding()
{
    <#
      .SYNOPSIS
      Adds spaces to the end of the string to bring the string up to a specified length
      
      .DESCRIPTION
      The passed in string has spaces added to the end to bring it up to the length specified
      in the -PadTo paramter. If the passed in string already exceeds that length, a single 
      space is added to the end 
    
      .PARAMETER PadTo
      The number of spaces to make the passed in string.
    
      .PARAMETER StringToPad
      The string that needs spaces added to the end

      .INPUTS
      System.String
    
      .OUTPUTS
      System.String
    
      .EXAMPLE
      $added = Add-RightPadding -PadTo 10 -StringToPad "XYZ"  # Test with named parameters
      $added + "*"
      Output:
        XYZ       *
      .EXAMPLE      
      $added = Add-RightPadding 10 "XYZ"  # Test with unnamed parameters
      $added + "*"
      Output:
        XYZ       *
      .EXAMPLE            
      $added = Add-RightPadding -PadTo 10 -StringToPad "1234567890XYZ" # Test where passed in string is longer than PadTo parameter
      $added + "*"
      Output:
        1234567890XYZ *
      .EXAMPLE                  
      $padme = "XYZ", "Arcane", "Code", "PowerShell"  # Test passing in as an array
      $padme | Add-RightPadding -PadTo 10
      Output:
        XYZ       
        Arcane    
        Code      
        PowerShell 
      .EXAMPLE      
      $padme = "XYZ", "Arcane", "Code", "PowerShell"   # Test with returning to an array and printing
      $padmeout = $padme | Add-RightPadding -PadTo 10
      foreach($p in $padmeout)
        { $p + "*" }
      Output:
        XYZ       *
        Arcane    *
        Code      *
        PowerShell *
      .NOTES
      Author: Robert C. Cain  @arcanecode
      Website: http://arcanecode.com
      Copyright (c) 2014 All rights reserved
    
      This would be a good tool to use with SQL Select statements, to make the AS
      clauses line up to the right.

    .LINK
      http://arcanecode.com
    #>
  [CmdletBinding()]
  param ([Parameter(Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The final width the string should be.'
    )]
    [int] $PadTo,
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true,
               HelpMessage = 'The string to be padded.'
    )]
    [string[]] $StringToPad)
  
  
  begin { }
  
  process
  {
    foreach ($str in $StringToPad)
    {
      Write-Verbose "Add-RightPadding Input: $str"
      
      if ($str.Length -ge $PadTo)
      { $padded = $str + " " }
      else
      {
        $padding = " " * ($PadTo - $str.Length)
        $padded = $str + $padding
      }
      
      $outputHash = @{ Name = $padded }
      $outputObject = New-Object PSObject -Property $outputHash
      
      Write-Verbose "Add-RightPadding Output: $outputObject"
      Write-Output $outputObject
    }
  }
  end { }
}
#endregion Add-RightPadding

