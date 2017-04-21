# Example of using a certificate to login
$certificateSubject = 'CN=AutomatePSLogin'
$certificate = Get-ChildItem -path 'Cert:\CurrentUser\my' |
  Where-Object Subject -eq $certificateSubject

$tenant = Get-Content "$($pwd)\TenantId.txt"

$appID = Get-Content "$($pwd)\ApplicationId.txt"

Add-AzureRmAccount -ServicePrincipal `
                   -CertificateThumbprint $certificate.Thumbprint `
                   -ApplicationId $appId `
                   -TenantId $tenant 
