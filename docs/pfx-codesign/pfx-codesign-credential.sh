#!/bin/bash
#
###############################################################################################
# Credential Helper Script | Secret Storage                                                   #
###############################################################################################
# 1. Place this file in the folder ~/.pfx-codesign                                            #
# 2. Read the comments below and store your codesigning certificate password                  #
# 3. Make sure you don't have the password in plain text in the configuration file            #
#    pfx.json - remove it there (or leave it blank in the .json file)                         #
# 4. Run this Shell Script once in Terminal and check if you get the stored secret as output. #
# 5. If this file is found by the Post Build Script of the Xojo Example Project, it will      #
#    pick up the codesigning certificate password from the secret storage                     #
###############################################################################################


###############################################################################################
# macOS | Keychain                                                                            #
###############################################################################################
# Store the Codesign Certificate (.pfx) Password in macOS Keychain                            #
# In Terminal.app:                                                                            #
#---------------------------------------------------------------------------------------------#
# security add-generic-password -s pfx-codesign -a pfx-codesign-certificate -w [pfx-password] #
###############################################################################################
# Open Keychain on macOS to see/edit/delete the entry.                                        #
# Additional Terminal commands:                                                               #
#---------------------------------------------------------------------------------------------#
# Lookup item: security find-generic-password -s pfx-codesign -a pfx-codesign-certificate -w  #
###############################################################################################

if [[ $OSTYPE == 'darwin'* ]]; then
  # macOS
  security find-generic-password -s pfx-codesign -a pfx-codesign-certificate -w
  exit $?
fi


###############################################################################################
# Linux | Gnome Keyring (tested on Ubuntu 24.04)                                              #
###############################################################################################
# Ensure GNOME Keyring and Tools are Installed                                                #
#---------------------------------------------------------------------------------------------#
# sudo apt update && sudo apt install gnome-keyring libsecret-1-0 libsecret-tools seahorse    #
###############################################################################################
# Store the Codesign Certificate (.pfx) Password in GNOME Keyring                             #
# In Terminal type in exactly this (don't use your actual pfx password here!):                #
#---------------------------------------------------------------------------------------------#
# secret-tool store --label="pfx-codesign" pfx password                                       #
#---------------------------------------------------------------------------------------------#
# - when prompted by secret-tool: type in password of the codesign certificate.pfx            #
###############################################################################################
# Additional Terminal commands:                                                               #
#---------------------------------------------------------------------------------------------#
# Lookup item: secret-tool lookup pfx password                                                #
# List (all) Stored Secret(s): secret-tool search --all pfx password                          #
# Delete Stored Secret: secret-tool clear pfx password                                        #
# Launch GUI (seahorse): seahorse                                                             #
###############################################################################################

secret-tool lookup pfx password
