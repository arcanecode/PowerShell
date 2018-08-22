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

  This file simply shows how to invoke a pester test, in this example
  calling the specific file mentioned in the above article. 
-----------------------------------------------------------------------------#>

# Set tests location
$dir = 'C:\PowerShell\Pester-Demo'
Set-Location $dir

# Invoke all the tests in the file
Invoke-Pester "$dir\Mocks-PretendToDoSomething.Tests.ps1"

# Add these lines so you can run just certain sets of tests
Invoke-Pester "$dir\Mocks-PretendToDoSomething.Tests.ps1" -Tag 'Unit'

Invoke-Pester "$dir\Mocks-PretendToDoSomething.Tests.ps1" -Tag 'Integration'

Invoke-Pester "$dir\Mocks-PretendToDoSomething.Tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$dir\Mocks-PretendToDoSomething.Tests.ps1" -Tag 'Unit', 'Integration'
