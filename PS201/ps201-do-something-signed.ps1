<#-----------------------------------------------------------------------------
  Beginning PowerShell Scripting for Developers
  Simple script that will just 'Do Something'

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2015 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# This very simple script is used to demonstrate being able
# to run scripts, work with execution policies, and the like.
#-----------------------------------------------------------------------------#

Set-Location 'C:\PS\Beginning PowerShell Scripting for Developers\demo'

Get-ChildItem |
  Out-GridView -Wait

# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYsA5I3hPjzcUvMbKPbLbxY6a
# TDGgggNCMIIDPjCCAiqgAwIBAgIQ2aLRC0YUUqJKB16ibvjqQjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNTA5MTMxODMyMDRaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK55NmWD
# TaI7WrRxAlyW4+frd5Pldvim9Ha7/0Oh0TZnxdCxUgZ60s4O3vokUpLPrrpwruSn
# mNcbOvH2i0/s0FHLyWKwm6bCsf/Slf3nvkD4kRiPsJXmXmY063f3w/Y+/WrkO6wV
# vSTcxbgpfTUuY7xmjEitWys5U91dVpo3rAB5bvGSNgF6/diMLnyxxpdgG91u207X
# hSGvwnH5gN2zsA2Z9VEH6Eye+OiL7UWg8x3qai1mw6b9ahE9hf9krQUq+kTo/V9u
# 0JAq0DEZR2jpgezT2ugiPGTHJADmPUpSEyqUAqf2F9kim+T2Bx7PX4vVhnJYIiyO
# vMkCnl8pR39XaTkCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQi+hDQTWUpRdXFI03QEQgBqEuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQRJE15R9w+rxOqRscF1KYVzAJBgUrDgMC
# HQUAA4IBAQBsan2WdM6PUDCFGZcS5Ua7kMUuSOnVRpDfhFBvFkgz1IFCXvhs378a
# dzxFG/zTGUQI2K4O3ni5Pgk0KlkvEyobeOjyEZphUOxgkq7voZJvu902t29GHDs3
# qq92UW/Ei6NEHTMLfIUnOSaS3f93KnfWkmEx1rW6afA+XhCsn9teSh5eQzjOW5y8
# 26q9ceEMDC+M+oXUNjyu1miP56RIcpQaMx9DaR9xEElPVnUuR9smlu3yA3VBfVMP
# iWL/xvrP74Jtvb8rq7YhxeKhdunNYW6B0ydkO5uVbPeHx5wlhOPDunb51JSw95jM
# k9t84uSuqNiiaWXstou39u0gFPbrnBmSMYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCENmi0QtGFFKiSgde
# om746kIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFBjB5WLO6wK6lHZ/ed3E44nDEmyhMA0GCSqG
# SIb3DQEBAQUABIIBAI1ZN+ZBw2NNlfQ0UiuQg+pe1XNvZsTLSoBk+1TfJ/gr6f+w
# rdb4Tewub8mcOGEMYM8AyGiSRYXRZh7moCbpExmGICv9g1MJpLcsHk6vz+UJBu1b
# TCUqfgN1LpIeDm3zh6PBlOCH2o/YC9/vs471tWOGkn8r3X3Zs+SaN+/MffydW2au
# dOgcRPoCNsZuGeDWsu2bwhHpRP2bHyvjgIc6bzkYJIjX7KBT1YYm7hAvXKJT1EnR
# cL+pYDVJU6qPnA5RHOsHfucX+dahkbe7JYm58UaAU02W60hJKBRLCWsij7hd6MFL
# MvHxuPPkEsTD7JXvgHZpOgXu+eJaFGX/fEtVHeM=
# SIG # End signature block
