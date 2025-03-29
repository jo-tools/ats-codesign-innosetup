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
