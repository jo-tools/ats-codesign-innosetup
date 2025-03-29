###############################################################################################
# Credential Helper Script | Secret Storage                                                   #
###############################################################################################
# 1. Place this file in the folder ~/.pfx-codesign                                            #
# 2. Read the comments below and store your codesigning certificate password                  #
# 3. Make sure you don't have the password in plain text in the configuration file            #
#    pfx.json - remove it there (or leave it blank in the .json file)                         #
# 4. If this file is found by the Post Build Script of the Xojo Example Project, it will      #
#    pick up the codesigning certificate password from the secret storage                     #
###############################################################################################
# PowerShell: Allow Execution                                                                 #
#---------------------------------------------------------------------------------------------#
# 5. Try to run this script once manually with Powershell                                     #
#    Especially if you have downloaded this script it might be blocked by PowerShell's        #
#    Execution Policy. When running it manually: allow this script to be run always.          #
###############################################################################################


###############################################################################################
# Store the PFX Password in Windows Credential Manager                                        #
###############################################################################################
# Run the following PowerShell command to securely # store the password:                      #
#---------------------------------------------------------------------------------------------#
# cmdkey /generic:pfx-password /user:pfx-codesign /pass:[pfx-password]                        #
#---------------------------------------------------------------------------------------------#
# Replace [pfx-password] with your actual credential                                          #
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
$cred = Get-StoredCredential -Target "pfx-password"

if ($cred) {
    Write-Output $([System.Net.NetworkCredential]::new("", $cred.Password).Password)
}

# SIG # Begin signature block
# MIIt5AYJKoZIhvcNAQcCoIIt1TCCLdECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA4qbIHemXGK9g0
# BHCLvAr4/se27bB3rWRc/4kdTWDD4KCCFfwwggb4MIIE4KADAgECAhMzAAMiQhP5
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
# BgkqhkiG9w0BCQQxIgQgDkXobwtdbTfr4G6U22ayrdb1t5BYOAnJqmjkcQb3CVkw
# DQYJKoZIhvcNAQEBBQAEggGAneRihTszx3KgQKXCvXrzX1w2mz/yzEfJrvQE9D8N
# jYhfNfOFzpxzddcQ11wMTfqH+6JdDiYcL/kBCCUp65QVdZE2VEj5cH8/ntPOHo8B
# ddOQpEFZOMaUmI+x/8LKsNFKvveoIU2v0RPqYTgR+FJLNDPLXlKNpY2ZrO5K3J03
# P17OWxODq8Tnu3IbDjUdCXfC1AAvbhWtkj85HSOO3R+6/v36XCxL34DxHLNWZfqI
# HNmj1llBPiBWjUtPIgzXOhrtoHWIY0lhf1S7cb83wghAANyAZQKvxsobpM18S0mQ
# ktMhnJpBZ0M/0Ywiepjp+Wc6+UXU0eK0gVSCjjgDvYxYdY09jqD4FGTMUawdMOm3
# nYJnOnBi9k27JoGSi4gju3+f2rNjD1A1ARS6Hy1F4uLg9KV1JGlc7EasleylonAV
# Nby0Yj1tTBZ+7cPUxYdh1Vbs6SfLbmu9pJ42EBxrMxna5f24uvSw1bttC1+zoc4+
# oUl8jd7yafVv5smAUsd+dgZvoYIUsjCCFK4GCisGAQQBgjcDAwExghSeMIIUmgYJ
# KoZIhvcNAQcCoIIUizCCFIcCAQMxDzANBglghkgBZQMEAgEFADCCAWoGCyqGSIb3
# DQEJEAEEoIIBWQSCAVUwggFRAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIB
# BQAEIKUTUF6wBIBnpwX00XACCaX8cFz10PyHZ9cexIML1BUuAgZn5ToCk9QYEzIw
# MjUwMzI5MTExMjM3LjQ3OVowBIACAfSggemkgeYwgeMxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5k
# IE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjQ5
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
# TqPGDj4xw3QnAAAAAABOMA0GCSqGSIb3DQEBDAUAMGExCzAJBgNVBAYTAlVTMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29m
# dCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMB4XDTI1MDIyNzE5NDAx
# N1oXDTI2MDIyNjE5NDAxN1owgeMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMg
# TGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjQ5MUEtMDVFMC1EOTQ3
# MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0YW1waW5nIEF1
# dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIbflIu6bAlt
# ld7nRX0T6SbF4bEMjoEmU7dL7ZHBsOQtg5hiGs8GQlrZVE1yAWzGArehop47rm2Q
# 0Widteu8M0H/c7caoehVD1so8GY0Vo12kfImQp1qt5A1kcTcYXWmyQbeLx9w8KHB
# nIHpesP+sk2STglYsFu3CtHtIFXjrLAF7+NjA0Urws3ny5bPd+tjxO6vFIY3V6yX
# b3GIbcHbfmleNfra4ZEAA/hFxDDdm2ReLt/6ij7iVM7Q6EbDQrguRMQydF8HEyLP
# 98iGKHEH36mcz+eJ9Xl/bva+Pk/9Yj1aic2MBrA7YTbY/hdw3HSskxvUUgNIcKFQ
# Vsz36FSMXQOzVXW1cFXL4UiGqw+ylClJcZ0l3H0Aiwsnpvo0t9v4zD5jwJrmeNIl
# KBeH5EGbfXPelbVEZ2ntMBCgPegB5qelqo+bMfSz9lRTO2c7LByYfQs6UOJL2Jhg
# rZoT+g7WNSEZKXQ+o6DXujpif5XTMdMzWCOOiJnMcevpZdD2aYaOEGFXUm51QE2J
# LKni/71ecZjI6Df4C6vBXRV7WT76BYUgcEa08kYbW5kN0jjnBPGFASr9SSnZNGFK
# Q4J8MyRxEBPZTN33MX9Pz+3ZfZF4mS8oyXMCcOmE406M9RSQP9bTVWVuOR0MHo56
# EpUAK1hVLKfuSD0dEwbGiMawHrelOKNBAgMBAAGjggHLMIIBxzAdBgNVHQ4EFgQU
# 8Me6g3SqStL0tyd5iw4rvw1NamIwHwYDVR0jBBgwFoAUa2koOjUvSGNAz3vYr0np
# Ptk92yEwbAYDVR0fBGUwYzBhoF+gXYZbaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1w
# aW5nJTIwQ0ElMjAyMDIwLmNybDB5BggrBgEFBQcBAQRtMGswaQYIKwYBBQUHMAKG
# XWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0
# JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0ElMjAyMDIwLmNydDAM
# BgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQE
# AwIHgDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQCMA0GCSqGSIb3DQEBDAUAA4ICAQATJnMrpCGuWq9ZOgEKcKyP
# Zj71n/JpX9SYaTK/qOrPsIxzf/qvq//uj0dTBnfx7KW0aI1Yz2C6Q78g1b80AU8A
# RNyoIhmT2SWNI8k7FLo7qeWSzN4bcgDgTRSaKGPiWWbJtEjbCgbIkNJ3ZTP9iBJC
# sxZwv6a45an9ApG1NV/wP8niV0RBCH9SIHmD6sv34lxlzHTgGGf1n289fg/LoSMs
# LFPZ4+G3p0KYu7A5fz616IBk9ZWpXQxHFNcSMg/rlwbO65k0k0sRrUlIWkk+71nt
# 2NgpsFaWi2JYq0msX0uzV3LbLaWfKzg1B3ugoSXLypZg3pPypkdXh1wra9h222Ru
# zjyOmwyWi7jTQUBOPZenyapbJhAZXlCxOBaN00bs1V+zUg2miNte9E8CWHagq+Rt
# s/1iSiPCwWmMKfqilSSdSMtYSXMyciCKWexeRjAX0QovSsGv0pMqkYfPa5ubnI03
# ab/A6Kod2TEF8ufShV9sQSqbDscMW12TQOboyTUhc8wPp8p2WWejvrH+9AUO6hTo
# aYeM4jMmmOcAAlpHm2AY+GAk+Y54d6DYA6NBED+CSEFSakUVRqNbkN4mN1SOklod
# ZhvRphmF9Ot0DuzLu/KByWIfHbaY/wTusrEVGH4W4n39FmcMIvVbMpeOENZ59+xG
# iFwt5izuabZiHN/EFR4leTGCA9QwggPQAgEBMHgwYTELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAABOo8YOPjHDdCcA
# AAAAAE4wDQYJYIZIAWUDBAIBBQCgggEtMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0B
# CRABBDAvBgkqhkiG9w0BCQQxIgQg/uBTOpbhm1nGhScOySKwutUHeHJbLorRmGi/
# iKv08OMwgd0GCyqGSIb3DQEJEAIvMYHNMIHKMIHHMIGgBCBvsqfT7ygFHbDe/Tj3
# QCn25JHDuUhgytNPRb67/5ZKFzB8MGWkYzBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAAE6jxg4+McN0JwAAAAAA
# TjAiBCCMXJVsmw+hIfNIC+4aPSsn4D1cKmbGVZIQNN4QRhoQDTANBgkqhkiG9w0B
# AQsFAASCAgBicr/X2eR4vimmp//zwSn7xIXRi/l9ZI45rDvG/0GCyOO7Z5oLajfR
# 8z4nno5DzEMz2z+zay/PXKN0osaZ64XRNXccCZggHLT0L4XSmGuqjrMmqA3Zkvhr
# 2I+JCBZC8sYT8azuxSKxzV1mX8ZqOL1wtS9UFWKn+laapP782uM0xIjU8zU3e00A
# 3T6LDZyQkEtEhpUQqokB3dsVvIdRJVb9JPOXgpDjxOnVWa4in7/edSVYykvpA6J7
# A4L7E50GdyAgE0dsuSBO+G865J7VPNqijSdixVtgrJD+cXpYGucE3f9Ga3qqZJeW
# h62eAkRrxLQ+oGyTDUxk+JQbU/F6JMVbW59UWAWebmupwh1w8yT3PD6m6h3AhFJ2
# FD2HxWxrZYQLs3YJxJWMa3pPUw4VhINbNh1DwPEJom3yhiG/QgOUvNH9UD2EHeSp
# sJrJ/xD/0ZrvC5a09xVWtRenpJSQDyIkX4HfhR0vwgnX08clv6FiC1CxO8JeWjUa
# JpGzWyVAzmKQnopzjj57ZCjlaGcPKseUWTM+NipIRQa8XRKSEgVKGDgLam4n2GeW
# Rg4KIyXph795c1msBE8cBE2H07zpEHAauNJueuJv5GMmvbHir/OdAj5TR8fnW9Zz
# VHxss9cZwGQiuUKzOD/vaHlJKiI+8bwrc02bkzE6vepeenWdDe7WZA==
# SIG # End signature block
