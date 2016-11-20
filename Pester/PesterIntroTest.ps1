# Sample - Basic Pester Test
Describe 'A dirt simple test' {

  It 'Should be true' {
    $true | Should Be $true
  }

}

# Sample - Should Exist

Describe 'should exist test' {

  It 'Should exist' {
    'C:\PS\Pester-course\demo\completed-final-module\PesterIntroTest.ps1' |
      Should Exist
  }

}

# Sample - Should Exist with Variables

Describe 'should exist with variables test' {

    $someFile = 'C:\PS\Pester-course\demo\completed-final-module\PesterIntroTest.ps1'
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

}

