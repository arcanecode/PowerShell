# Example of using stored credentials to login
$password = Get-Content "$($pwd)\apw.txt"
$tenantID = Get-Content "$($pwd)\TenantIdCredential.txt"
$applicationID = Get-Content "$($pwd)\ApplicationIdCredential.txt"
$login = $applicationID.ToString() `
           + '@rccaingmail191.onmicrosoft.com'

# Create a Credential object
$pass = ConvertTo-SecureString $password -AsPlainText –Force 
$cred = New-Object -TypeName pscredential –ArgumentList $login, $pass

# Now login
Login-AzureRmAccount `
  -Credential $cred `
  -ServicePrincipal `
  –TenantId $tenantId
