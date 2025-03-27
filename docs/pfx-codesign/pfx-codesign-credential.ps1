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
# Note: Special Characters in Credential                                                      #
#       Characters that may have an impact within a shell command, e.g.: ^&%\<>               #
#---------------------------------------------------------------------------------------------#
# The Xojo Post Build Script tries to escape the Credential when putting it into the Shell    #
# Command to run Docker. It's quite tricky to get it right (x-platform) - especially Windows  #
# needs different escaping depending on other characters within the to-be-escaped string.     #
# So unfortunately not every Credential will work out of the box in the Xojo Example Project. #
# If you suspect an issue with because of such characters in your credential:                 #
# - Try without this script (put it in the .json file)                                        #
# - If it works in the .json - modify the Post Build Scripts so that your special             #
#   escaping needs are covered                                                                #
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
