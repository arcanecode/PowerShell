<#-----------------------------------------------------------------------------
  PowerShell 201 - Simple script that will just 'Do Something' for
  demonstrating security rules.
 
  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2018 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 

  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

#-----------------------------------------------------------------------------#
# This very simple script is used to demonstrate being able
# to run scripts, work with execution policies, and the like.
#-----------------------------------------------------------------------------#

Set-Location 'C:\PowerShell\PS201'

Get-ChildItem |
  Out-GridView -Wait

# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtgfxcuONnuiMMhPOlRcU9LWT
# zv2gggNCMIIDPjCCAiqgAwIBAgIQoGGUm4xQjZhI9G8bM+04tjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xODA4MTAxNTA4MzJaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK+sMesk
# PZISMdXtMP5JqbHWNRrM1DT7+lLHKpZYSL2F+H+bbym/Sl+KQWUQ/iGUsePrqmcL
# eWEEL6rJbfRgOeMTx7udP2EwdMEw4fcq45CI3ARgSNtCOYDgx+zxQVL6oXWId5/I
# tL5ck65iCF4Y94Ll4s2ktzEf81pOk0YdDl+/BtqEmYj73vS9NPJgpadjb7x1aPqz
# kvo813mxwxRYp+rYo2sKUsIcwde59C1c+YyiyrAmELbJHpEKcPGLusxe34CDdH/c
# WFpKH1t2k02Y7KG5gqcZNCPCyxY1lcj7hMLSHFGTHCSCBxinjPb5vJjFMhynV2QE
# Xo10aFZuEJRv9kECAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQng+LurgRQB/fdooeRHI26aEuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQ5T/0RmbvorBDqJNJg6V+vTAJBgUrDgMC
# HQUAA4IBAQAsXu52AHCxBphdk48v3MmVtEb1HTikOCHT6B57rcgNEWr6gfF5cpR9
# aDIqOY1NeKkubFeX0yvfQw0fAr6xQG/HkkPCEDLXlmW9HllKheuv9FHR/IXSREdY
# QIT0GQ/h7XTeFZYwVu+chiEF7kUYhj86Kjb8K0byWEJubzJMrWneUaX+NQKNmaLx
# yGeIJou5FuQ9RepSKCCPIE8j8hzAUinDzoxzpL/fsUbStKBH6dXNAIYhQFYuFPmp
# uk8twt503bZFV0BLgVE/40BseMSVGu1rXlhmoHeSG94yKg/QvIPT9YN3yWVw6RpH
# 5XIEGG5cmzRnOwKEttClPqXPHbznRomwMYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCEKBhlJuMUI2YSPRv
# GzPtOLYwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFFGIg27JhKGMYpnY465/FPLRwZqqMA0GCSqG
# SIb3DQEBAQUABIIBAINtExsrYh+ja3nbJ2pXbXmcRnc7cWGb54dxQmsT07DQen88
# RiiMm8NksJ+m7T3At+eSBuv3kWqfiUmu+KNyTXt50ZW59oBF0pnJ+Qy813K2/J6y
# kZoGqWIn/XTxbN3mh9o1Q/VkbmNVdQtVBWZ2a3/G9EGvsA37tagDBGg56uf0Hxdv
# SVU+OrYgELrK4ofLFkBH6Kel5Nv4TUmbgxYvjXhAN0YwksPMYKL165jd/vJ+J3dW
# cirv3cOFAJz9lQ6eNGDLhZsji/ulgti9q0ZYVHfRmnzYLQj1SNwL+zMsmurgVYGY
# ixZqjQZSmVWrjY0UklJdjzWGi8PVM90zX8MLqfk=
# SIG # End signature block
