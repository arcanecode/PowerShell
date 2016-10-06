<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  The manifest file for the Advanced Module

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

@{

# Name of the module to process
# Both the PSD1 and PSM1 must have same file name
ModuleToProcess = 'Z2H-09.2 Module Advanced Module'

# Each module has to be uniquely identified. To do that PS uses a GUID.
# To generate a GUID, use the New-Guid cmdlet and copy the result in here
GUID = '38ec7954-d069-4768-9890-d49d06729dfe'

# Who wrote this module
Author = 'Robert C. Cain'

# Company who made this module
CompanyName = 'Arcane Training and Consulting'

# Copyright 
Copyright = '(c) 2016 All rights reserved'

# Description of the module
Description = 'Module demo'

# Version number for the module
ModuleVersion = '1.0.0.0'

# Minimum version of PowerShell needed to run this module
PowerShellVersion = '3.0'

# Min version of .NET Framework required 
DotNetFrameworkVersion = '2.0'

# Min version of the CLR required 
CLRVersion = '2.0.50727'

# Note there are many more items you can set.
}


