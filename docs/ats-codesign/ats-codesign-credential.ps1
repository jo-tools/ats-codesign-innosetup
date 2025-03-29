###############################################################################################
# Credential Helper Script | Secret Storage                                                   #
###############################################################################################
# 1. Place this file in the folder ~/.ats-codesign                                            #
# 2. Read the comments below and store your Azure Client Secret                               #
# 3. Make sure you don't have the Azure Client Secret in plain text in the configuration file #
#    azure.json - remove it there (or leave it blank in the .json file)                       #
# 4. If this file is found by the Post Build Script of the Xojo Example Project, it will      #
#    pick up the Azure Client Secret from the secret storage                                  #
###############################################################################################


###############################################################################################
# Store the Azure Client Secret in Windows Credential Manager                                 #
###############################################################################################
# Run the following PowerShell command to securely store the password:                        #
#---------------------------------------------------------------------------------------------#
# cmdkey /generic:ats-azure-client-secret /user:ats-codesign /pass:[azure-client-secret]      #
#---------------------------------------------------------------------------------------------#
# Replace [azure-client-secret] with your actual credential                                   #
###############################################################################################
# Open Windows Credentials Manager GUI                                                        #
#---------------------------------------------------------------------------------------------#
# control.exe keymgr.dll                                                                      #
###############################################################################################


###############################################################################################
# Note: Special Characters sequences in Credential, e.g. My\a{a}Secret                        #
#---------------------------------------------------------------------------------------------#
# The Xojo Post Build Script reads the credential from this script and puts it into an        #
# Environment Variable. In the docker run command the variable name is handed over, so that   #
# Docker can pick it up.                                                                      #
# Some character sequences might get interpretated so that the credential looks different     #
# when running jsign, which then obviously won't work for codesigning.                        #
# If you suspect an issue because of such characters in your credential:                      #
# - Use a secret without character sequences that might get interpretated                     #
# - Try without this script (put it the secret in the .json file - just for a test)           #
# - Worst case: modify the Post Build Scripts so that your special escaping needs are covered #
###############################################################################################


# Install the CredentialManager module if not installed
if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    Install-Module -Name CredentialManager -Force -Scope CurrentUser
}

# Import the module
Import-Module CredentialManager

# Retrieve the stored credential
$cred = Get-StoredCredential -Target "ats-azure-client-secret"

if ($cred) {
    Write-Output $([System.Net.NetworkCredential]::new("", $cred.Password).Password)
}

# SIG # Begin signature block
# MIIt5AYJKoZIhvcNAQcCoIIt1TCCLdECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD1iEIxu0ulZXsL
# FPPN8Uc5ji9pijWZa8e9F/jAYzo2h6CCFfwwggb4MIIE4KADAgECAhMzAAMiQhP5
# +pqDqakUAAAAAyJCMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjUwMzI4MTMwMzMzWhcNMjUwMzMx
# MTMwMzMzWjB3MQswCQYDVQQGEwJDSDEVMBMGA1UECB4MAFoA/AByAGkAYwBoMRMw
# EQYDVQQHEwpXaW50ZXJ0aHVyMR0wGwYDVQQKHhQASgD8AHIAZwAgAE8AdAB0AGUA
# cjEdMBsGA1UEAx4UAEoA/AByAGcAIABPAHQAdABlAHIwggGiMA0GCSqGSIb3DQEB
# AQUAA4IBjwAwggGKAoIBgQDJeKSCFF2duYYqoY0ZLEwQLjqKgAafZK4JKdHHrcIK
# MVe9Tjp0JDR6N4T5Pv3AgXGq/UtUrbymIjU/JmHE82FbANx5Umdvyl8ctgwrZczx
# lp12vA4hTBgVB/fPNXFXcBKrR8AbKSjKUbLHNmQ8cSlxE6P5aO54BsqeE0QTPC9P
# CFzgVCzUhsdwseZ6MJrX5b1YDepf1ICoKTGCvZm2Ja8CpmGMKviaLuZPpYC0OW5W
# QX+ogJNCo9VlJafPeQUVHI1X63oMpqHiAjVLVyi7XWWfjSTQYqk+ewpsRWSQbd4+
# hgjHToTT6F7dvt0goUFUXVRy3mob5/6pFnYwv6XfwKAZBN1i2AAc/jjwyyO/vMsd
# 9Hu+fkus5Mi2NNtdflLA8YkntLxb8WotMDKhkvWgs1sGS1VKf0qgB5tcMEQ4R43N
# My8RKTvQbNQKZnTYsTuA2MEbkHr9YDKQRXGyNxcoSGAJS2VvA5xeEj0VvsiLQmq4
# SMl9I3lQQ77DYuFyBOpAqXkCAwEAAaOCAhgwggIUMAwGA1UdEwEB/wQCMAAwDgYD
# VR0PAQH/BAQDAgeAMDsGA1UdJQQ0MDIGCisGAQQBgjdhAQAGCCsGAQUFBwMDBhor
# BgEEAYI3YYGBwbsqgYnW4XrohZttjoH5DTAdBgNVHQ4EFgQU3/YzIWDC2w/xeb1N
# laU04J1weEAwHwYDVR0jBBgwFoAU6IPEM9fcnwycdpoKptTfh6ZeWO4wZwYDVR0f
# BGAwXjBcoFqgWIZWaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwv
# TWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAwMS5j
# cmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQGCCsGAQUFBzAChlhodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZp
# ZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwZgYDVR0gBF8wXTBRBgwrBgEEAYI3
# TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
# aW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEEATANBgkqhkiG9w0BAQwF
# AAOCAgEAXjI/B89FfzCprPS7Fut4O6yBowxaMwZ6nIvo2kx9PXz8qvvEpMjNTa+t
# lZJnu05g8bOqFW1h1AB1edzP8LZt6MiOgXKckSQ7dTq+9SMoZCSCDz2vgDDSa4Z8
# qCPx7Sk/bGZqI5lDVtb4OJXcz8l01ty45jgmMEwin7ux68ERRl/sjSiOgy7wTaJh
# l2ayj9kcy3PoEkcIMl4KG9CJyJhvk1H3+KotiF875ZJv2HuLwPY8XdtdL4IWhgq2
# 3/LoNf9kNPZBvBeWwtiXXSBuRb4oqZvlYkEzgBBb7KfcRpwqE95LlYCHXARiv59h
# r5CQA++rYMu0wbaYDHkTImP8leuZrGUbocsKzYKtb80lJRP8y0YyAyRfi0dDpYhg
# nTw/2Y88FJoYH42TE0xNhTnhMrasDZFXsqKWbhh/Oke/b5iExBg31wT2NIassseD
# nE4aseo7rjKL1x7+N083izkaxb4vymqz/5uF5O1JQhFI27JKyhSaUba1YM7TT5Pb
# cxrTJG2TUcKTfVZvQBCdUoYFw1bxAOz9Belguhkkb2NIgFUlIoZTogrZ6/wNiqUn
# 944d4KDenEGTfPOAIszatt7pFnT8PcQn0wKkyz7dfoB8Sf+mgSwvaFq5B3CxWuJN
# Eysj3MQTn5jXPE/RvWtnvphGQn0dsbn1Y2JkDU007b/TxeB/DtowggdaMIIFQqAD
# AgECAhMzAAAABzeMW6HZW4zUAAAAAAAHMA0GCSqGSIb3DQEBDAUAMGMxCzAJBgNV
# BAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xNDAyBgNVBAMT
# K01pY3Jvc29mdCBJRCBWZXJpZmllZCBDb2RlIFNpZ25pbmcgUENBIDIwMjEwHhcN
# MjEwNDEzMTczMTU0WhcNMjYwNDEzMTczMTU0WjBaMQswCQYDVQQGEwJVUzEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQg
# SUQgVmVyaWZpZWQgQ1MgQU9DIENBIDAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAt/fAAygHxbo+jxA04hNI8bz+EqbWvSu9dRgAawjCZau1Y54IQal5
# ArpJWi8cIj0WA+mpwix8iTRguq9JELZvTMo2Z1U6AtE1Tn3mvq3mywZ9SexVd+rP
# OTr+uda6GVgwLA80LhRf82AvrSwxmZpCH/laT08dn7+Gt0cXYVNKJORm1hSrAjjD
# QiZ1Jiq/SqiDoHN6PGmT5hXKs22E79MeFWYB4y0UlNqW0Z2LPNua8k0rbERdiNS+
# nTP/xsESZUnrbmyXZaHvcyEKYK85WBz3Sr6Et8Vlbdid/pjBpcHI+HytoaUAGE6r
# SWqmh7/aEZeDDUkz9uMKOGasIgYnenUk5E0b2U//bQqDv3qdhj9UJYWADNYC/3i3
# ixcW1VELaU+wTqXTxLAFelCi/lRHSjaWipDeE/TbBb0zTCiLnc9nmOjZPKlutMNh
# o91wxo4itcJoIk2bPot9t+AV+UwNaDRIbcEaQaBycl9pcYwWmf0bJ4IFn/CmYMVG
# 1ekCBxByyRNkFkHmuMXLX6PMXcveE46jMr9syC3M8JHRddR4zVjd/FxBnS5HOro3
# pg6StuEPshrp7I/Kk1cTG8yOWl8aqf6OJeAVyG4lyJ9V+ZxClYmaU5yvtKYKk1FL
# BnEBfDWw+UAzQV0vcLp6AVx2Fc8n0vpoyudr3SwZmckJuz7R+S79BzMCAwEAAaOC
# Ag4wggIKMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4E
# FgQU6IPEM9fcnwycdpoKptTfh6ZeWO4wVAYDVR0gBE0wSzBJBgRVHSAAMEEwPwYI
# KwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9S
# ZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTASBgNVHRMB
# Af8ECDAGAQH/AgEAMB8GA1UdIwQYMBaAFNlBKbAPD2Ns72nX9c0pnqRIajDmMHAG
# A1UdHwRpMGcwZaBjoGGGX2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2RlJTIwU2lnbmluZyUy
# MFBDQSUyMDIwMjEuY3JsMIGuBggrBgEFBQcBAQSBoTCBnjBtBggrBgEFBQcwAoZh
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQl
# MjBJRCUyMFZlcmlmaWVkJTIwQ29kZSUyMFNpZ25pbmclMjBQQ0ElMjAyMDIxLmNy
# dDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0LmNvbS9vY3Nw
# MA0GCSqGSIb3DQEBDAUAA4ICAQB3/utLItkwLTp4Nfh99vrbpSsL8NwPIj2+TBnZ
# GL3C8etTGYs+HZUxNG+rNeZa+Rzu9oEcAZJDiGjEWytzMavD6Bih3nEWFsIW4aGh
# 4gB4n/pRPeeVrK4i1LG7jJ3kPLRhNOHZiLUQtmrF4V6IxtUFjvBnijaZ9oIxsSSQ
# P8iHMjP92pjQrHBFWHGDbkmx+yO6Ian3QN3YmbdfewzSvnQmKbkiTibJgcJ1L0TZ
# 7BwmsDvm+0XRsPOfFgnzhLVqZdEyWww10bflOeBKqkb3SaCNQTz8nshaUZhrxVU5
# qNgYjaaDQQm+P2SEpBF7RolEC3lllfuL4AOGCtoNdPOWrx9vBZTXAVdTE2r0IDk8
# +5y1kLGTLKzmNFn6kVCc5BddM7xoDWQ4aUoCRXcsBeRhsclk7kVXP+zJGPOXwjUJ
# bnz2Kt9iF/8B6FDO4blGuGrogMpyXkuwCC2Z4XcfyMjPDhqZYAPGGTUINMtFbau5
# RtGG1DOWE9edCahtuPMDgByfPixvhy3sn7zUHgIC/YsOTMxVuMQi/bgamemo/VNK
# ZrsZaS0nzmOxKpg9qDefj5fJ9gIHXcp2F0OHcVwe3KnEXa8kqzMDfrRl/wwKrNSF
# n3p7g0b44Ad1ONDmWt61MLQvF54LG62i6ffhTCeoFT9Z9pbUo2gxlyTFg7Bm0fgO
# lnRfGDCCB54wggWGoAMCAQICEzMAAAAHh6M0o3uljhwAAAAAAAcwDQYJKoZIhvcN
# AQEMBQAwdzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjFIMEYGA1UEAxM/TWljcm9zb2Z0IElkZW50aXR5IFZlcmlmaWNhdGlvbiBS
# b290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDIwMB4XDTIxMDQwMTIwMDUyMFoX
# DTM2MDQwMTIwMTUyMFowYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVkIENv
# ZGUgU2lnbmluZyBQQ0EgMjAyMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBALLwwK8ZiCji3VR6TElsaQhVCbRS/3pK+MHrJSj3Zxd3KU3rlfL3qrZilYKJ
# NqztA9OQacr1AwoNcHbKBLbsQAhBnIB34zxf52bDpIO3NJlfIaTE/xrweLoQ71lz
# CHkD7A4As1Bs076Iu+mA6cQzsYYH/Cbl1icwQ6C65rU4V9NQhNUwgrx9rGQ//h89
# 0Q8JdjLLw0nV+ayQ2Fbkd242o9kH82RZsH3HEyqjAB5a8+Ae2nPIPc8sZU6ZE7iR
# rRZywRmrKDp5+TcmJX9MRff241UaOBs4NmHOyke8oU1TYrkxh+YeHgfWo5tTgkoS
# MoayqoDpHOLJs+qG8Tvh8SnifW2Jj3+ii11TS8/FGngEaNAWrbyfNrC69oKpRQXY
# 9bGH6jn9NEJv9weFxhTwyvx9OJLXmRGbAUXN1U9nf4lXezky6Uh/cgjkVd6CGUAf
# 0K+Jw+GE/5VpIVbcNr9rNE50Sbmy/4RTCEGvOq3GhjITbCa4crCzTTHgYYjHs1Nb
# Oc6brH+eKpWLtr+bGecy9CrwQyx7S/BfYJ+ozst7+yZtG2wR461uckFu0t+gCwLd
# N0A6cFtSRtR8bvxVFyWwTtgMMFRuBa3vmUOTnfKLsLefRaQcVTgRnzeLzdpt32cd
# YKp+dhr2ogc+qM6K4CBI5/j4VFyC4QFeUP2YAidLtvpXRRo3AgMBAAGjggI1MIIC
# MTAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNlB
# KbAPD2Ns72nX9c0pnqRIajDmMFQGA1UdIARNMEswSQYEVR0gADBBMD8GCCsGAQUF
# BwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3Np
# dG9yeS5odG0wGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwDwYDVR0TAQH/BAUw
# AwEB/zAfBgNVHSMEGDAWgBTIftJqhSobyhmYBAcnz1AQT2ioojCBhAYDVR0fBH0w
# ezB5oHegdYZzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWlj
# cm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlm
# aWNhdGUlMjBBdXRob3JpdHklMjAyMDIwLmNybDCBwwYIKwYBBQUHAQEEgbYwgbMw
# gYEGCCsGAQUFBzAChnVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Nl
# cnRzL01pY3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUy
# MENlcnRpZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcnQwLQYIKwYBBQUHMAGG
# IWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20vb2NzcDANBgkqhkiG9w0BAQwF
# AAOCAgEAfyUqnv7Uq+rdZgrbVyNMul5skONbhls5fccPlmIbzi+OwVdPQ4H55v7V
# OInnmezQEeW4LqK0wja+fBznANbXLB0KrdMCbHQpbLvG6UA/Xv2pfpVIE1CRFfNF
# 4XKO8XYEa3oW8oVH+KZHgIQRIwAbyFKQ9iyj4aOWeAzwk+f9E5StNp5T8FG7/VEU
# RIVWArbAzPt9ThVN3w1fAZkF7+YU9kbq1bCR2YD+MtunSQ1Rft6XG7b4e0ejRA7m
# B2IoX5hNh3UEauY0byxNRG+fT2MCEhQl9g2i2fs6VOG19CNep7SquKaBjhWmirYy
# ANb0RJSLWjinMLXNOAga10n8i9jqeprzSMU5ODmrMCJE12xS/NWShg/tuLjAsKP6
# SzYZ+1Ry358ZTFcx0FS/mx2vSoU8s8HRvy+rnXqyUJ9HBqS0DErVLjQwK8VtsBde
# kBmdTbQVoCgPCqr+PDPB3xajYnzevs7eidBsM71PINK2BoE2UfMwxCCX3mccFgx6
# UsQeRSdVVVNSyALQe6PT12418xon2iDGE81OGCreLzDcMAZnrUAx4XQLUz6ZTl65
# yPUiOh3k7Yww94lDf+8oG2oZmDh5O1Qe38E+M3vhKwmzIeoB1dVLlz4i3IpaDcR+
# iuGjH2TdaC1ZOmBXiCRKJLj4DT2uhJ04ji+tHD6n58vhavFIrmcxghc+MIIXOgIB
# ATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEC
# EzMAAyJCE/n6moOpqRQAAAADIkIwDQYJYIZIAWUDBAIBBQCgajAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgehExNZaauAxnMjkKtiCgB5G0qULK3P8P0IaKJXo6J/Qw
# DQYJKoZIhvcNAQEBBQAEggGAFdHq4zQ3una6krjoz76jIWo8hmNF7sF47ziB9/X+
# Not+Si6BzaJq2W1kijd1kzJQ9zxjKerk9cWgHGG8SBWJllt0B/zMnsKyVx1WZX8W
# 5FJZQ17mO7HGCUVq0nsuFOyxTgsVPArOICLdOTH69uOx5D/nDpesMdAvu/7OCLmr
# lZas7kbCrgZx/8iEtETftJI3H67PuxXeewj79LddGpcNncwtDEOdd3fCc6DpqHpR
# M7ZOzWDj7VZWoo4bb9Gpraa4z/48Dc7XO0Yqmgfzps7e9v2HgkcSQPgP0kBD+Huf
# D+9oEqzchZ4pM+oxjUEK/c2hTTTSkoF1MhDvi8emlCtA83ueZo3ZupQOE3w+Plnu
# 1wPOrf8AwA/r3erqh4mysNT68uWDElNHysRPWo/vfF7PDXhhJ4LCfSSV+/+gia7a
# 4wDr5BVZK+7z1dP2lxLxvnokZQPUvWWe3au6i/mVe4ElREWs1lEj+GgdXWaDY1Aw
# /AYLuntN9dt1ApH5fA3yJJF6oYIUsjCCFK4GCisGAQQBgjcDAwExghSeMIIUmgYJ
# KoZIhvcNAQcCoIIUizCCFIcCAQMxDzANBglghkgBZQMEAgEFADCCAWoGCyqGSIb3
# DQEJEAEEoIIBWQSCAVUwggFRAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIB
# BQAEIADJio6Y3urc46qp/VTY32PYGRhymb6W6RCDq5KGVEVRAgZn5TyzVA8YEzIw
# MjUwMzI5MTAyNTUzLjg3OFowBIACAfSggemkgeYwgeMxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5k
# IE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjdC
# MUEtMDVFMC1EOTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1l
# IFN0YW1waW5nIEF1dGhvcml0eaCCDykwggeCMIIFaqADAgECAhMzAAAABeXPD/9m
# LsmHAAAAAAAFMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVu
# dGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAy
# MDAeFw0yMDExMTkyMDMyMzFaFw0zNTExMTkyMDQyMzFaMGExCzAJBgNVBAYTAlVT
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jv
# c29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAnnznUmP94MWfBX1jtQYioxwe1+eXM9ETBb1l
# Rkd3kcFdcG9/sqtDlwxKoVIcaqDb+omFio5DHC4RBcbyQHjXCwMk/l3TOYtgoBjx
# nG/eViS4sOx8y4gSq8Zg49REAf5huXhIkQRKe3Qxs8Sgp02KHAznEa/Ssah8nWo5
# hJM1xznkRsFPu6rfDHeZeG1Wa1wISvlkpOQooTULFm809Z0ZYlQ8Lp7i5F9YciFl
# yAKwn6yjN/kR4fkquUWfGmMopNq/B8U/pdoZkZZQbxNlqJOiBGgCWpx69uKqKhTP
# Vi3gVErnc/qi+dR8A2MiAz0kN0nh7SqINGbmw5OIRC0EsZ31WF3Uxp3GgZwetEKx
# Lms73KG/Z+MkeuaVDQQheangOEMGJ4pQZH55ngI0Tdy1bi69INBV5Kn2HVJo9XxR
# YR/JPGAaM6xGl57Ei95HUw9NV/uC3yFjrhc087qLJQawSC3xzY/EXzsT4I7sDbxO
# mM2rl4uKK6eEpurRduOQ2hTkmG1hSuWYBunFGNv21Kt4N20AKmbeuSnGnsBCd2cj
# RKG79+TX+sTehawOoxfeOO/jR7wo3liwkGdzPJYHgnJ54UxbckF914AqHOiEV7xT
# nD1a69w/UTxwjEugpIPMIIE67SFZ2PMo27xjlLAHWW3l1CEAFjLNHd3EQ79PUr8F
# UXetXr0CAwEAAaOCAhswggIXMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEEAYI3FQEE
# AwIBADAdBgNVHQ4EFgQUa2koOjUvSGNAz3vYr0npPtk92yEwVAYDVR0gBE0wSzBJ
# BgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZ
# BgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/MB8GA1Ud
# IwQYMBaAFMh+0mqFKhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmgd6B1hnNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJ
# ZGVudGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1
# dGhvcml0eSUyMDIwMjAuY3JsMIGUBggrBgEFBQcBAQSBhzCBhDCBgQYIKwYBBQUH
# MAKGdWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9z
# b2Z0JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNh
# dGUlMjBBdXRob3JpdHklMjAyMDIwLmNydDANBgkqhkiG9w0BAQwFAAOCAgEAX4h2
# x35ttVoVdedMeGj6TuHYRJklFaW4sTQ5r+k77iB79cSLNe+GzRjv4pVjJviceW6A
# F6ycWoEYR0LYhaa0ozJLU5Yi+LCmcrdovkl53DNt4EXs87KDogYb9eGEndSpZ5ZM
# 74LNvVzY0/nPISHz0Xva71QjD4h+8z2XMOZzY7YQ0Psw+etyNZ1CesufU211rLsl
# LKsO8F2aBs2cIo1k+aHOhrw9xw6JCWONNboZ497mwYW5EfN0W3zL5s3ad4Xtm7yF
# M7Ujrhc0aqy3xL7D5FR2J7x9cLWMq7eb0oYioXhqV2tgFqbKHeDick+P8tHYIFov
# IP7YG4ZkJWag1H91KlELGWi3SLv10o4KGag42pswjybTi4toQcC/irAodDW8HNtX
# +cbz0sMptFJK+KObAnDFHEsukxD+7jFfEV9Hh/+CSxKRsmnuiovCWIOb+H7DRon9
# TlxydiFhvu88o0w35JkNbJxTk4MhF/KgaXn0GxdH8elEa2Imq45gaa8D+mTm8LWV
# ydt4ytxYP/bqjN49D9NZ81coE6aQWm88TwIf4R4YZbOpMKN0CyejaPNN41LGXHeC
# UMYmBx3PkP8ADHD1J2Cr/6tjuOOCztfp+o9Nc+ZoIAkpUcA/X2gSMkgHAPUvIdto
# SAHEUKiBhI6JQivRepyvWcl+JYbYbBh7pmgAXVswggefMIIFh6ADAgECAhMzAAAA
# TzS1B8Erl1T8AAAAAABPMA0GCSqGSIb3DQEBDAUAMGExCzAJBgNVBAYTAlVTMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29m
# dCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMB4XDTI1MDIyNzE5NDAx
# OVoXDTI2MDIyNjE5NDAxOVowgeMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMg
# TGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjdCMUEtMDVFMC1EOTQ3
# MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0YW1waW5nIEF1
# dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMJgplrGyzoQ
# ujPidzNmuc1QElb4s9Hh6DFjfZ0iSDDGRO3lFVwS4aO+dAV2kWzM6ZMPUu5xCCH/
# tLWISpVirWHOy0wcPeeOTI1PMMuw/jGGgooz1N8KhVkhGDkRwzmValp8ec/SQSzi
# uY4Cn6Plx2jp8m3EO4cNSv1nqv1Y3+DnJzwinsY+ctWXlEJa3RzdlRcD6e+HuBRX
# BUU/UhMhpO1YUQNlFhO22CqNNyltCoYXDpizC1Pp21fk8uOYYMOyRDWgJlWcEG/8
# MWEbQF4dG142fpFIyV+esDWPMn35dB3JwZ7bgbJv/6I5nNOGsYjqjzN3Xu/FkAYu
# BLz+XYEXo9yvtrWm1fylEl52Eu7pb8cmI2u89TPqIT0gSdq9o8L0DZT7xALM5Eq3
# m6r17ul2na8i8XLa3iLfAzEPe1rj/og3SHVZociHvbFzRkjeFoLsyt/SdGcMwEBe
# 192vlWJ1OXIo//AXQbhcW+avgz5TMyPPWeJEnjzgNrZjy4crEJBrHc+g1budRvBm
# j81+weFMBkteL0/AkZzVeqCHpIqWQ4BeYnG6Rnc5P8aeFQEDwg/w7d7hIVwbLTo1
# L1mRj+dxVgUYvcA9xMJ4hqysj+A9IovKB3TQ5R2AInDRaCRkNYyamFv8BGnvpgNQ
# 8w5Jiy7U+YHMK1SKSo4n5jcsQGpbQqUhAgMBAAGjggHLMIIBxzAdBgNVHQ4EFgQU
# v6LTt+z8Zp55tkdI0e6HVEbqNzAwHwYDVR0jBBgwFoAUa2koOjUvSGNAz3vYr0np
# Ptk92yEwbAYDVR0fBGUwYzBhoF+gXYZbaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1w
# aW5nJTIwQ0ElMjAyMDIwLmNybDB5BggrBgEFBQcBAQRtMGswaQYIKwYBBQUHMAKG
# XWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0
# JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0ElMjAyMDIwLmNydDAM
# BgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQE
# AwIHgDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQCMA0GCSqGSIb3DQEBDAUAA4ICAQA2szaHVDYlYVXSudVldhG9
# 4j89l1t63++gstu5Kp/tMRpiDubP8YN5e2El2hKKzvCV6B8oYS6bfp0AU68uCIfY
# aUhgFycxUIwYTjVS5uME4jum7vBfs66HYWKzTDIhIBaQxAuVoiq5u3PTWWHc7NNO
# le4NYrVT37ffAJysafwb6gal9wSpbZ1gWsCTe4xAOGutgVbb2+8sGNucoE3IIywy
# AH5EbdfNke63fFAOox+VkPd23q3yMYFlUVl3kHBMSkempW/KGloNYmjh3GER1jrD
# TgyA9qs9ciUkA8hc7lNtZiBx4djpMJyA/cLaNbNbUSsXY/6PXBdvHBP6NWnKihJA
# lOiJr14M4o5SQkQnpShHBwIcniLfboQVkO45ij8q8j2npgyjGP1rxnJbh+hQgEg9
# UNAcpKt44miahIuROzHAono2j4cPH6mhIepCEzFRZiF/V3M9qR/lx1o1x4vpQnGr
# Y1H9fFGpT+kCqKHDEdvXdBAzr5q3qyKNIfDkUd/iE9yM+qgrKsDrycdeU5tGeBxB
# +0g0XfXVFGmiRTydaUE/Ejcr5LAs4u3d5isDcu1YSvw96PtWuqZxpLMOR4YCczNs
# u/eYA/VAdWibcGIJbGtSf3iolQI6wDahsSxF7zlHVyBCDm0CaoEz2zFNFeaBMxuR
# dyowSLFizlvOkpcWd3fxZDGCA9QwggPQAgEBMHgwYTELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAABPNLUHwSuXVPwA
# AAAAAE8wDQYJYIZIAWUDBAIBBQCgggEtMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0B
# CRABBDAvBgkqhkiG9w0BCQQxIgQgiIGG8xrkE92tTmGoduJk0YF+jqoI1+hx/AkS
# Amg7Xhswgd0GCyqGSIb3DQEJEAIvMYHNMIHKMIHHMIGgBCBBZitGD5IetHKtHaLk
# fbENdoJzjFcg0DaAspLgL4LqDjB8MGWkYzBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAAE80tQfBK5dU/AAAAAAA
# TzAiBCDMLqTsJLAEVwOn/Bouhscb2ypymtpooQslfW7IJsEiOjANBgkqhkiG9w0B
# AQsFAASCAgBOkMt4Bt9DneZzoDfWLyt9fLbEb15NMEqF+sn3tfV1UWOrop9uRvKh
# m5TC2d3/dBgh+TqLAIYAiSWSZMlnGsSt6mWW3BlwGvU6XY+uJcr6Xk1kv/Df5Lgu
# WB0LsFoVbKD6/QaHRZ7+8Q/85qTamaEN/DnneuIi9XLFHcfTx0tADvirrr0zQg0y
# DUnTWvMTv1/ua+Ta0UkeGI9rPp3k+1x3I6AO+aS1uCb4E19tGV2Anlqhy9/NTQrR
# mf3sU0vSWTqmGrNOcopnUEgm88EwY+KY0OIFfn6urtILXh+4NBIBK5ndXAanPr7s
# 52ouAZoTiX3yKwVjcHg7KJGaAnN6LqqA7D/qAOVtGVh22vcFTPbSILBRiN8qghbn
# wBtjbT+JzQpUu1GcgJ2fwIMgfucwmJezRf9i3hYc+rtVBYZ/V8+4LZznjeekbzk9
# v81KlysiLAv9EvGKsOx9DxtujHgAmo1NZXUOd3UR0mftX6Ej4J4iUd+1afATbIka
# YpadGd+zAfGyCiZXwTyfHeU/dTWjnpHyw6CIN8xmccrnOGLFs5nCzLvER24NHi8I
# 7rRZjKk173yUEwbfrCz+40JiPg8z/hu4Z/0quOBBOVsFbsyhb5KJQ33LhPh5JJ8S
# xHR/iJ0HZjh1kI0TLnFRl/pKvivEr5AXeiu7juD0k86K+oWTEi83fg==
# SIG # End signature block
