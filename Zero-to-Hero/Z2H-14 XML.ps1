<#-----------------------------------------------------------------------------
  Zero to Hero with PowerShell
  Using PowerShell with XML

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
 -----------------------------------------------------------------------------#>

#region Reading and Updating XML

#-----------------------------------------------------------------------------#
# Reading and Updating XML
#-----------------------------------------------------------------------------#
$xmlFilePath = 'C:\Users\Arcane\OneDrive\PS\Z2H\Z2H-14 Books.xml'
psedit $xmlFilePath

$booksXml = [xml](Get-Content $xmlFilePath)

# Selecting a list of titles using XPath syntax
$booksXml.SelectNodes("//title")

# Select a single node using XPath style syntax
$booksXml.SelectSingleNode("//book[1]")

# Remainder use Object style syntax
# Return a list of objects in the catalog
$booksXml.catalog | Format-Table 

# Return as a list
$booksXml.catalog.book | Format-Table 

# Get a single book
$booksXml.catalog.book[1] 

# Update a node (in memory)
$booksXml.catalog.book[1].author = 'Cain, Robert' 
$booksXml.catalog.book[1].title = 'PowerShell MVP Deep Dives'
$booksXml.catalog.book[1].genre = 'Computer'
$booksXml.catalog.book[1].price = '29.95'
$booksXml.catalog.book[1].description = 'Cool PowerShell Stuff'
$booksXml.catalog.book[1] 

# Save the changes
$xmlFilePathNew = 'C:\Users\Arcane\OneDrive\PS\Z2H\Z2H-14 BooksNew.xml'
$booksXml.Save($xmlFilePathNew)
psedit $xmlFilePathNew

# Add a new node
$newBook = $booksXml.catalog.book[0].Clone()
$newBook.id = 'bk201'  
$newBook.author = 'Cain, Robert'
$newBook.title = 'SQL Server MVP Deep Dives 2'
$newBook.genre = 'Computer'
$newBook.price = '39.95'
$newBook.description = 'Cool SQL Server Stuff'
$newBook.publish_date = '2012-11-01'
$booksXml.catalog.AppendChild($newBook)

$xmlFilePathNew = 'C:\Users\Arcane\OneDrive\PS\Z2H\BooksNew.xml'
$booksXml.Save($xmlFilePathNew)
psedit $xmlFilePathNew
  
#endregion Reading and Updating XML


