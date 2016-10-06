<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Debugging

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# The code in here is not horribly important. It is being used to demonstrate 
# the debugging features of the ISE
#-----------------------------------------------------------------------------#

Clear-Host

# A function we can step into 
function Write-ITM()
{
  $v1 = 33
  $v2 = $v1 * 10
  $retval = "In The Morning"
  return $retval
}

# Set a breakpoint on this line
$hi = "Hello World"

$hi

# Use the Step Into feature to step in the function
Write-ITM

# Now use Step Over to execute the function as a single command
$hi = Write-ITM
$hi

# Use the Step Into feature. Inside, alter the $retval variable
# in the command window to see its output change
Write-ITM

