<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell
  Classes and Enums

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 -----------------------------------------------------------------------------#>

#region Enum

#-----------------------------------------------------------------------------#
# Show Enums in PS
#-----------------------------------------------------------------------------#

# Define the valid values for the enum
Enum MyTwitters
{
  ArcaneCode
  ArcaneMining
  N4IXT
}

# Note when typing the last : will trigger intellisense!
$tweet = [MyTwitters]::ArcaneCode
$tweet

# See if they picked something valid
[enum]::IsDefined(([MyTwitters]), $tweet)

# Set it to something invalid and see if it passes as an enum
$tweet = 'Invalid'
[enum]::IsDefined(([MyTwitters]), $tweet)

#endregion Enum





#region Basic Class

#-----------------------------------------------------------------------------#
# Basic Class
#-----------------------------------------------------------------------------#
  
Class Twitterer
{
  # Create a property
  [string]$TwitterHandle
  
  # Create a property and set a default value
  [string]$Name = 'Robert C. Cain'

  # Function that returns a string
  [string] TwitterURL()
  {
    $url = "http://twitter.com/$($this.TwitterHandle)"
    return $url
  }

  # Function that has no return value
  [void] OpenTwitter()
  {
    Start-Process $this.TwitterURL()
  }

}

$twit = [Twitterer]::new()
$twit.TwitterHandle = 'ArcaneCode'
$twit.TwitterHandle
  
# See default property value
$twit.Name

# Override default value
$twit.Name = 'Mrs. Code'
$twit.Name

$myTwitter = $twit.TwitterURL()
$myTwitter

$twit.OpenTwitter()

#endregion Basic Class


#region Advanced Class

#-----------------------------------------------------------------------------#
# Advanced Class
#   Constructors
#   Overloaded Methods
#-----------------------------------------------------------------------------#

Class TwittererRedux
{
  # Default Constructor
  TwittererRedux ()
  {
  }

  # Constructor passing in Twitter Handle
  TwittererRedux ([string]$TwitterHandle)
  {
    $this.TwitterHandle = $TwitterHandle
  }

  # Constructor passing in Twitter Handle and Name
  TwittererRedux ([string]$TwitterHandle, [string]$Name)
  {
    $this.TwitterHandle = $TwitterHandle
    $this.Name = $Name
  }

  # Create a property
  [string]$TwitterHandle
  
  # Create a property and set a default value
  [string]$Name = 'Robert C. Cain'

  # Static Properties
  static [string] $Version = '2016.10.15.001'

  # Function that returns a string
  [string] TwitterURL()
  {
    # Call the function to build the twitterurl
    # passing in the property we want
    $url = $this.TwitterURL($this.TwitterHandle)

    return $url
  }

  # Overloaded Function that returns a string
  [string] TwitterURL($twitterHandle)
  {
    $url = "http://twitter.com/$($twitterHandle)"
    return $url
  }

  # Function that has no return value
  [void] OpenTwitter()
  {
    Start-Process $this.TwitterURL()
  }

  # Can launch a twitter page without instantiating the class
  static [void] OpenTwitterPage([string] $TwitterHandle)
  {
    # Note here we cannot call the $this.TwitterUrl function
    # because no object exists (hence no $this)
    $url = "http://twitter.com/$($TwitterHandle)"
    Start-Process $url
  }

}

# Create a class using default constructor
$twitDefault = [TwittererRedux]::new()

# Display without assigning
"TwitterHandle = $($twitDefault.TwitterHandle)"

# Now assign and display again
$twitDefault.TwitterHandle = 'ArcaneMining'
"TwitterHandle = $($twitDefault.TwitterHandle)"

# Show version one of TwitterURL
"URL = $($twitDefault.TwitterURL())"

# Show overloaded version
"URL = $($twitDefault.TwitterURL('ArcaneCode'))"

# Create a new instance using the second constructor
$twitAdvanced = [TwittererRedux]::new('N4IXT')

# Display without assigning - Should have what was passed in constructor
"TwitterHandle = $($twitAdvanced.TwitterHandle)"

# Create yet another instance using the third constructor
$twitAdvanced2 = [TwittererRedux]::new('ArcaneMining', 'R Cain')
$twitAdvanced2.TwitterHandle
$twitAdvanced2.Name

# Static Value - Can be called without initializing the class
[TwittererRedux]::Version

# Use the static method
[TwittererRedux]::OpenTwitterPage('N4IXT')


#endregion Advanced Class

