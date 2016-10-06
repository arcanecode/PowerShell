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

Set-Location 'C:\Users\Arcane\OneDrive\PS\Z2H'

Get-ChildItem |
  Out-GridView -Wait

# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkD0an+E2XAIx6p5sAVuUGoug
# CwigggNCMIIDPjCCAiqgAwIBAgIQv5W+rNZAxodBEvEdgvMETjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNjA4MTgxOTM3MzZaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKG/sr62
# vJ15tVzW7L8emxOr/f2Fdi+nOs61k/aDAIKV62bCv9CYcJN2XOQEMvr2cGgftYsx
# C0LL3HCqfamf6Wox3iIr6S5K2wVGqhsolIw1WQa/yKkmga2q+f1W5Zo8M8oOUA89
# +21fb3JcBTLwLoZnmmvd4SX3TFCAQCRfL4dmz55wWpK4fPDDYoWsmkp4yYoJuz6l
# ON/LePfBzQ/qFfOffAxDGPc8OJeJ7b0ToVpzUGyzkTAuGwqhHfNwINkP9R/HSUB8
# eoquKg5nDBi1oB5SSJkzMqj6Kr+MYnHlGpnhBPbQsZ9EUeO1FvB1gxc7MJzYC6P/
# 6fsjT8qJdM39G9kCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQlc2XikAMKqtP3x7ok8DlTKEuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQcnGbqxqwJa1K2pIIKS0ZTDAJBgUrDgMC
# HQUAA4IBAQBn9RzwohV7soTyibDL9yj0iUfloky8oGk4Te+BcQFHHqAGXTwOx2Ly
# vTBDbd1Dqqjkdjp+pKyK5yllJrnQpjp1vwmPeQTvO+vCcby+HKduL3YTHqkDC/QN
# mE/Om6hjsv59Sk1LqCx3lvRT4ZNASCtkCqAfC/Vtl7SY5fOQ10vE/3/UFYKPMyT/
# Aei7J8n+iyP6z3JHnuzEsG7WMRdBzwdSZ4oGVSpLIL9ZxvcUHsXG43KVtrYbewK/
# 3dHQGvqtqm6wkIREDns0SHI4rz81aOEMJJkU3GgyNytWgW8oEZQaWfNS2XQytYyS
# MxSKnfrn6CMI1P8oCytMbZpYtQ2y5nEkMYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCEL+VvqzWQMaHQRLx
# HYLzBE4wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFD3SyBtScHaqjy7Tb/uw8y9QfU/+MA0GCSqG
# SIb3DQEBAQUABIIBAE5VlKwbEe0lTWIbQxvyRxbV2GjOwXOXtbeHSG56+YdMV2DB
# BPQW7NW6/dao5XyW7nYUHg+cCorEKZJZYSVgQn69XP3sgyAJ/ORbkHisluTG9bHs
# 0gMg53SVKGz7it5jmXgm2+nkGYutRHnj0QtomTklnnw93b2Qx7C/qvjRR67iJzQ8
# rnUgneV1C4dfDCF7noqXrb6ARrR9cWfJOEEZ92TZnNedT6brG5n/HFmhciCKqoQl
# ZutaWGrJlitX3A8aX0KH3OOMm9nSSXGG7qZvxzxz9B+hCa9yq3GQxd+ti+SxvALo
# +yUingb45nXYQBWnGYzkmCS2Tl7esSYvqbD+Cqw=
# SIG # End signature block
