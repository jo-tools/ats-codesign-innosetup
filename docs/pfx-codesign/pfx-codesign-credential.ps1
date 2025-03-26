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
