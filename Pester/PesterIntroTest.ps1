# Sample - Basic Pester Test
Describe 'A dirt simple test' {

  It 'Should be true' {
    $true | Should Be $true
  }

}

# Sample - Should Exist
Describe 'should exist test' {

  It 'Should exist' {
    'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\PesterIntroTest.ps1' |
      Should Exist
  }

}


# Sample - Should Exist with Variables
Describe 'should exist with variables test' {

    $someFile = 'C:\Users\Arcane\OneDrive\PS\Pester-course\demo\completed-final-module\PesterIntroTest.ps1'
    It "$someFile should exist" {
      $someFile | Should Exist
    }

}


# Sample - Context
Describe 'Grouping using Context' {

    Context 'Test Group 1' {    
      It 'Should be true' {
        $true | Should Be $true
      }
      
      It 'Should be false' {
        $false | Should Be $false
      }      
    }

    Context 'Test Group 2' {    
      It 'Should not be true' {
        $false | Should Not Be $true
      }
      
      It 'Should be false' {
        $true | Should Not Be $false
      }      
    }

    Context 'Test Group 3' {    
      It '$x Should be 1' {
        $x = 1  # x gets assigned somewhere
        $x | Should Be 1
      }
      
      It 'Should be true' {
        $y = 2
        ($y -eq 2) | Should Be $true
      }      
    }

}


