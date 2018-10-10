<#-----------------------------------------------------------------------------
  PowerShell Testing with Pester

  This sample code is part of a series of articles entitled 
  
  "Pester the Tester - Testing PowerShell Code"
  
  located on RedGate's SimpleTalk website. You can find all of the authors 
  articles at: http://arcanecode.red

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.me
 
  This code module is Copyright (c) 2018 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 

  This code may not be reproduced in whole or in part without the express
  written consent of the author. You may use it within your own projects.

  The examples below accompany the article, feel free to uncomment some
  or all of them so you can run your own tests. The descriptions for each
  section can be found in the article referenced above. 
-----------------------------------------------------------------------------#>

# Sample - Basic Pester Test
Describe 'Basic Pester Tests' {
  It 'A test that should be true' {
    $true | Should -Be $true
  }
}


Describe 'Basic Pester Tests' {
  It 'A test that should be true' {
    $true | Should -BeTrue
  }

  It 'A test that should fail' {
    $false | Should -Be $true  # or -BeFalse
  }
}


# Sample - Should Exist
Describe 'should exist test' {
  It 'Should exist' {
    'C:\PowerShell\Pester-Demo\Invoke-BasicPesterTests.ps1' |
      Should -Exist
  }
}

# Sample - Should Exist using variables
Describe 'should exist with variables test' {
    $someFile = 'C:\PowerShell\Pester-Demo\Invoke-BasicPesterTests.ps1'
    It "$someFile should exist" {
      $someFile | Should -Exist
    }
}

# Sample - Context
Describe 'Grouping using Context' {

    Context 'Test Group 1 Boolean Tests' {    
      It 'Should be true' { $true | Should -Be $true }
      It 'Should be true' { $true | Should -BeTrue }
      It 'Should be false' { $false | Should -Be $false }      
      It 'Should be false' { $false | Should -BeFalse }      
    }

    Context 'Test Group 2 - Negative Assertions' {    
      It 'Should not be true' { $false | Should -Not -BeTrue }
      It 'Should be false' { $true | Should -Not -Be $false }
    }

    Context 'Test Group 3 - Calculations' {    
      It '$x Should be 42' {
        $x = 42 * 1
        $x | Should -Be 42
      }
      
      It 'Should be greater than or equal to 33' {
        $y = 3 * 11
        $y | Should -BeGreaterOrEqual 33
      }      

      It 'Should with a calculated value' {
        $y = 3
        ($y * 11) | Should -BeGreaterThan 30
      }      
    }

    Context 'Test Group 4 - String tests' {
      $testValue = 'ArcaneCode'

      # Test using a Like (not case senstive)
      It "Testing to see if $testValue has arcane" {
        $testValue | Should -BeLike "arcane*"
      }
    
      # Test using cLike (case sensitive)
      It "Testing to see if $testValue has Arcane" {
        $testValue | Should -BeLikeExactly "Arcane*"
      }
    }

    Context 'Test Group 5 - Array Tests' {
      $myArray = 'ArcaneCode', 'http://arcanecode.red', 'http://arcanecode.me'

      It 'Should contain ArcaneCode' {
        $myArray | Should -Contain 'ArcaneCode'
      }

      It 'Should have 3 items' {
        $myArray | Should -HaveCount 3
      }
    }
}

