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
