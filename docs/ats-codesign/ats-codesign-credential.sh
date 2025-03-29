#!/bin/bash
#
###############################################################################################
# Credential Helper Script | Secret Storage | macOS / Linux                                   #
###############################################################################################
# 1. Place this file in the folder ~/.ats-codesign                                            #
# 2. Read the comments below and store your Azure Client Secret                               #
# 3. Make sure you don't have the Azure Client Secret in plain text in the configuration file #
#    azure.json - remove it there (or leave it blank in the .json file)                       #
# 4. Run this Shell Script once in Terminal and check if you get the stored secret as output. #
# 5. If this file is found by the Post Build Script of the Xojo Example Project, it will      #
#    pick up the Azure Client Secret from the secret storage                                  #
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


###############################################################################################
# macOS | Keychain                                                                            #
###############################################################################################
# Store the Azure Client Secret in macOS Keychain                                             #
# In Terminal.app:                                                                            #
#---------------------------------------------------------------------------------------------#
# security add-generic-password -s ats-codesign -a ats-azure-client-secret -w [ClientSecret]  #
###############################################################################################
# Open Keychain on macOS to see/edit/delete the entry.                                        #
# Additional Terminal commands:                                                               #
#---------------------------------------------------------------------------------------------#
# Lookup item: security find-generic-password -s ats-codesign -a ats-azure-client-secret -w   #
###############################################################################################

if [[ $OSTYPE == 'darwin'* ]]; then
  # macOS
  security find-generic-password -s ats-codesign -a ats-azure-client-secret -w
  exit $?
fi


###############################################################################################
# Linux | Gnome Keyring (tested on Ubuntu 24.04)                                              #
###############################################################################################
# Ensure GNOME Keyring and Tools are Installed                                                #
#---------------------------------------------------------------------------------------------#
# sudo apt update && sudo apt install gnome-keyring libsecret-1-0 libsecret-tools seahorse    #
###############################################################################################
# Store the Azure Client Secret in GNOME Keyring                                              #
# In Terminal type in exactly this (don't use your actual client secret here!):               #
#---------------------------------------------------------------------------------------------#
# secret-tool store --label="ats-codesign" ats azure-client-secret                            #
#---------------------------------------------------------------------------------------------#
# - when prompted by secret-tool: type in the Azure Client Secret                             #
###############################################################################################
# Additional Terminal commands:                                                               #
#---------------------------------------------------------------------------------------------#
# Lookup item: secret-tool lookup ats azure-client-secret                                     #
# List (all) Stored Secret(s): secret-tool search --all ats azure-client-secret               #
# Delete Stored Secret: secret-tool clear ats azure-client-secret                             #
# Launch GUI (seahorse): seahorse                                                             #
###############################################################################################

secret-tool lookup ats azure-client-secret
