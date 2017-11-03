param( [string]$AccountToUse )

switch ($accountToUse)
{
  'AC' {
         $useSub = 'Azure Free Trial'
         $resourceGroupName = 'ArcaneFTDemo'
         $storageAccountName = 'arcaneftstoragedemo'
         $containerName = 'arcaneftstoragecontainer'
         $serverName = 'arcaneftsqlserver'
         break
       }
  'PS' { 
         $useSub = 'Pluralsight Azure Content'
         $resourceGroupName = 'PSAZDemo'
         $storageAccountName = 'psazstoragedemo'
         $containerName = 'psazstoragecontainer'
         $serverName = 'psazsqlserver'
         break
       }
  'VS' { 
         $useSub = 'Visual Studio Ultimate with MSDN'
         $resourceGroupName = 'PSDemo'
         $storageAccountName = 'psstoragedemo'
         $containerName = 'psstoragecontainer'
         $serverName = 'pssqlserver'
         break
       }
  'FT' {
         $useSub = 'Azure Free Trial'
         $resourceGroupName = 'PSFTDemo'
         $storageAccountName = 'psftstoragedemo'
         $containerName = 'psftstoragecontainer'
         $serverName = 'psftsqlserver'
         break
       }
  default      
       { 
         $useSub = 'Visual Studio Ultimate with MSDN'
         $resourceGroupName = 'PSDemo'
         $storageAccountName = 'psstoragedemo'
         $containerName = 'psstoragecontainer'
         $serverName = 'pssqlserver'
         break
       }
}
