<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

<#-----------------------------------------------------------------------------
  Pester
  The manifest file for Podcast-Database

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

@{

# Name of the module to process
ModuleToProcess = 'Podcast-Database.psm1'

# Each module has to be uniquely identified. To do that PS uses a GUID.
# To generate a GUID, use the New-Guid cmdlet and copy the result in here
GUID = 'd488e9e1-7e98-4c0a-aba2-675efd8474dd'

# Who wrote this module
Author = 'Robert C. Cain'

# Company who made this module
CompanyName = 'Pluralsight'

# Copyright 
Copyright = '(c) 2016 All rights reserved'

# Description of the module
Description = 'Create and manage the Podcastsight Podcast Database'

# Version number for the module
ModuleVersion = '1.0.0.0'

# Minimum version of PowerShell needed to run this module
PowerShellVersion = '5.0'

# Min version of .NET Framework required 
DotNetFrameworkVersion = '2.0'

# Min version of the CLR required 
CLRVersion = '2.0.50727'

# Note there are many more items you can set.
}
