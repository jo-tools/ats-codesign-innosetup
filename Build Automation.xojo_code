#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin SignProjectStep Sign
				  DeveloperID=
				  macOSEntitlements={"App Sandbox":"False","Hardened Runtime":"False","Notarize":"False","UserEntitlements":""}
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin IDEScriptBuildStep AzureTrustedSigning , AppliesTo = 2, Architecture = 0, Target = 0
					'**************************************************
					' CodeSign | Azure Trusted Signing | Docker
					'**************************************************
					' https://github.com/jo-tools/ats-codesign
					'**************************************************
					' Requirements
					'**************************************************
					' 1. Set up Azure Trusted Signing
					' 2. Have Docker up and running
					' 3. Read the comments in this Post Build Script
					' 4. Modify it according to your needs
					'
					'    Especially look out for sDOCKER_EXE
					'    You might need to set the full path to the executable
					'**************************************************
					' 5. If it's working for you:
					'    Do you like it? Does it help you? Has it saved you time and money?
					'    You're welcome - it's free...
					'    If you want to say thanks I appreciate a message or a small donation.
					'    Contact: xojo@jo-tools.ch
					'    PayPal:  https://paypal.me/jotools
					'**************************************************
					
					'**************************************************
					' Note: Xojo IDE running on Linux
					'**************************************************
					' Make sure that docker can be run without requiring 'sudo':
					' More information e.g. in this article:
					' https://medium.com/devops-technical-notes-and-manuals/how-to-run-docker-commands-without-sudo-28019814198f
					' 1. sudo groupadd docker
					' 2. sudo gpasswd -a $USER docker
					' 3. (reboot)
					'**************************************************
					
					If DebugBuild Then Return 'don't CodeSign DebugRun's
					
					'bSILENT=True : don't show any messages until checking configuration
					'               once .json required files are found: expect Docker and codesign to work
					'               use this e.g. in Open Source projects so that your builds will be codesigned,
					'               but if others are building the project it won't show messages to them
					Var bSILENT As Boolean = False 'in this example project we want to show if it's not going to work
					
					'Check Build Target
					Select Case CurrentBuildTarget
					Case 3  'Windows (Intel, 32Bit)
					Case 19 'Windows (Intel, 64Bit)
					Case 25 'Windows(ARM, 64Bit)
					Else
					If (Not bSILENT) Then Print "AzureTrustedSigning: Unsupported Build Target"
					Return
					End Select
					
					'Don't CodeSign Development and Alpha Builds
					Select Case PropertyValue("App.StageCode")
					Case "0" 'Development
					If (Not bSILENT) Then Print "AzureTrustedSigning: Not enabled for Development Builds"
					Return
					Case "1" 'Alpha
					If (Not bSILENT) Then Print "AzureTrustedSigning: Not enabled for Alpha Builds"
					Return
					Case "2" 'Beta
					Case "3" 'Final
					End Select
					
					'Configure what to be CodeSigned
					Var sSIGN_FILES() As String
					
					Select Case PropertyValue("App.StageCode")
					Case "3" 'Final
					' sign all .exe's and all .dll's
					sSIGN_FILES.Add("""./**/*.exe""") 'recursively all .exe's
					sSIGN_FILES.Add("""./**/*.dll""") 'recursively all .dll's
					Else
					' only sign all .exe's for Beta/Alpha/Development builds
					sSIGN_FILES.Add("""./**/*.exe""") 'recursively all .exe's
					end select
					
					'Note: In your project use jotools/ats-codesign if you are not using the InnoSetup Build Step.
					'      It's a smaller Docker Image...
					'      Should your project use the Post Build Script 'InnoSetup' too, then change here to use jotools/ats-innosetup.
					'      InnoSetup includes ats-codesign, too. So you don't need having two different Docker Images taking up space on your machine.
					Var sDOCKER_IMAGE As String = "jotools/ats-codesign" 'or: "jotools/ats-innosetup"
					
					Var sFILE_ACS_JSON As String = "" 'will be searched in ~/.ats-codesign
					Var sFILE_AZURE_JSON As String = "" 'will be searched in ~/.ats-codesign
					Var sBUILD_LOCATION As String = CurrentBuildLocation
					
					'Check Environment
					Var sDOCKER_EXE As String = "docker"
					If TargetWindows Then 'Xojo IDE is running on Windows
					sFILE_ACS_JSON = DoShellCommand("if exist %USERPROFILE%\.ats-codesign\acs.json echo %USERPROFILE%\.ats-codesign\acs.json").Trim
					sFILE_AZURE_JSON = DoShellCommand("if exist %USERPROFILE%\.ats-codesign\azure.json echo %USERPROFILE%\.ats-codesign\azure.json").Trim
					ElseIf TargetMacOS Or TargetLinux Then 'Xojo IDE running on macOS or Linux
					sDOCKER_EXE = DoShellCommand("[ -f /usr/local/bin/docker ] && echo /usr/local/bin/docker").Trim
					If (sDOCKER_EXE = "") Then sDOCKER_EXE = DoShellCommand("[ -f /snap/bin/docker ] && echo /snap/bin/docker").Trim
					sFILE_ACS_JSON = DoShellCommand("[ -f ~/.ats-codesign/acs.json ] && echo ~/.ats-codesign/acs.json").Trim
					sFILE_AZURE_JSON = DoShellCommand("[ -f ~/.ats-codesign/azure.json ] && echo ~/.ats-codesign/azure.json").Trim
					sBUILD_LOCATION = sBUILD_LOCATION.ReplaceAll("\", "") 'don't escape Path
					Else
					If (Not bSILENT) Then Print "AzureTrustedSigning: Xojo IDE running on unknown Target"
					Return
					End If
					
					If (sFILE_ACS_JSON = "") Or (sFILE_AZURE_JSON = "") Then
					If (Not bSILENT) Then Print "AzureTrustedSigning: acs.json and azure.json not found in [UserHome]-[.ats-codesign]-[acs|azure.json]"
					Return
					End If
					
					'Check Docker
					Var iCHECK_DOCKER_RESULT As Integer
					Var sCHECK_DOCKER_EXE As String = DoShellCommand(sDOCKER_EXE + " --version", 0, iCHECK_DOCKER_RESULT).Trim
					If (iCHECK_DOCKER_RESULT <> 0) Or (Not sCHECK_DOCKER_EXE.Contains("Docker")) Or (Not sCHECK_DOCKER_EXE.Contains("version")) Or (Not sCHECK_DOCKER_EXE.Contains("build "))Then
					Print "AzureTrustedSigning: Docker not available"
					Return
					End If
					
					Var sCHECK_DOCKER_PROCESS As String = DoShellCommand(sDOCKER_EXE + " ps", 0, iCHECK_DOCKER_RESULT).Trim
					If (iCHECK_DOCKER_RESULT <> 0) Then
					Print "AzureTrustedSigning: Docker not running"
					Return
					End If
					
					'CodeSign in Docker Container
					Var sSIGN_COMMAND As String = _
					sDOCKER_EXE + " run " + _
					"--rm " + _
					"-v """ + sFILE_ACS_JSON + """:/etc/ats-codesign/acs.json " + _
					"-v """ + sFILE_AZURE_JSON + """:/etc/ats-codesign/azure.json " + _
					"-v """ + sBUILD_LOCATION + """:/data " + _
					"-w /data " + _
					"--entrypoint ats-codesign.sh " + _
					sDOCKER_IMAGE + " " + _
					String.FromArray(sSIGN_FILES, " ")
					
					Var iSIGN_RESULT As Integer
					Var sSIGN_OUTPUT As String = DoShellCommand(sSIGN_COMMAND, 0, iSIGN_RESULT)
					
					If (iSIGN_RESULT <> 0) Then
					Clipboard = sSIGN_OUTPUT
					Print "AzureTrustedSigning: ats-codesign.sh Error" + EndOfLine + _
					"[ExitCode: " + iSIGN_RESULT.ToString + "]" + EndOfLine + EndOfLine + _
					"Note: Shell Output is available in Clipboard."
					
					If (iSIGN_RESULT <> 125) Then
					Var iCHECK_DOCKERIMAGE_RESULT As Integer
					Var sCHECK_DOCKERIMAGE_OUTPUT As String = DoShellCommand(sDOCKER_EXE + " image inspect " + sDOCKER_IMAGE, 0, iCHECK_DOCKERIMAGE_RESULT)
					If (iCHECK_DOCKERIMAGE_RESULT <> 0) Then
					Print "AzureTrustedSigning: Docker Image '" + sDOCKER_IMAGE + "' not available"
					End If
					End If
					End If
					
				End
				Begin IDEScriptBuildStep CreateZIP , AppliesTo = 2, Architecture = 0, Target = 0
					'**************************************************
					' Create .zip for Windows Builds
					'**************************************************
					' https://github.com/jo-tools
					'**************************************************
					' 1. Read the comments in this PostBuild Script
					' 2. Edit the values according to your needs
					'**************************************************
					' 3. If it's working for you:
					'    Do you like it? Does it help you? Has it saved you time and money?
					'    You're welcome - it's free...
					'    If you want to say thanks I appreciate a message or a small donation.
					'    Contact: xojo@jo-tools.ch
					'    PayPal:  https://paypal.me/jotools
					'**************************************************
					
					If DebugBuild Then Return 'don't create .zip for DebugRuns
					
					'bSILENT=True : don't show any error messages
					Var bSILENT As Boolean = False
					
					'Check Build Target
					Select Case CurrentBuildTarget
					Case 3 'Windows (Intel, 32Bit)
					Case 19 'Windows (Intel, 64Bit)
					Case 25 'Windows(ARM, 64Bit)
					Else
					If (Not bSILENT) Then Print "CreateZIP: Unsupported Build Target"
					Return
					End Select
					
					'Xojo Project Settings
					Var sPROJECT_PATH As String
					Var sBUILD_LOCATION As String = CurrentBuildLocation
					Var sAPP_NAME As String = CurrentBuildAppName
					If (sAPP_NAME.Right(4) = ".exe") Then
					sAPP_NAME = sAPP_NAME.Left(sAPP_NAME.Length - 4)
					End If
					Var sCHAR_FOLDER_SEPARATOR As String
					If TargetWindows Then 'Xojo IDE is running on Windows
					sPROJECT_PATH = DoShellCommand("echo %PROJECT_PATH%", 0).Trim
					sCHAR_FOLDER_SEPARATOR = "\"
					ElseIf TargetMacOS Or TargetLinux Then 'Xojo IDE running on macOS or Linux
					sPROJECT_PATH = DoShellCommand("echo $PROJECT_PATH", 0).Trim
					If sPROJECT_PATH.Right(1) = "/" Then
					'no trailing /
					sPROJECT_PATH = sPROJECT_PATH.Left(sPROJECT_PATH.Length - 1)
					End If
					If sBUILD_LOCATION.Right(1) = "/" Then
					'no trailing /
					sBUILD_LOCATION = sBUILD_LOCATION.Left(sBUILD_LOCATION.Length - 1)
					End If
					sBUILD_LOCATION = sBUILD_LOCATION.ReplaceAll("\", "") 'don't escape Path
					sCHAR_FOLDER_SEPARATOR = "/"
					End If
					
					If (sPROJECT_PATH = "") Then
					If (Not bSILENT) Then Print "CreateZIP: Could not get the Environment Variable PROJECT_PATH from the Xojo IDE." + EndOfLine + EndOfLine + "Unfortunately, it's empty.... try again after re-launching the Xojo IDE and/or rebooting your machine."
					Return
					End If
					
					'Check Stage Code for ZIP Filename
					Var sSTAGECODE_SUFFIX As String
					Select Case PropertyValue("App.StageCode")
					Case "0" 'Development
					sSTAGECODE_SUFFIX = "-dev"
					Case "1" 'Alpha
					sSTAGECODE_SUFFIX = "-alpha"
					Case "2" 'Beta
					sSTAGECODE_SUFFIX = "-beta"
					Case "3" 'Final
					'not used in filename
					End Select
					
					'Build ZIP Filename
					Var sZIP_FILENAME As String
					Select Case CurrentBuildTarget
					Case 3 'Windows (Intel, 32Bit)
					sZIP_FILENAME = sAPP_NAME.ReplaceAll(" ", "_") + sSTAGECODE_SUFFIX + "_Windows_Intel_32Bit.zip"
					Case 19 'Windows (Intel, 64Bit)
					sZIP_FILENAME = sAPP_NAME.ReplaceAll(" ", "_") + sSTAGECODE_SUFFIX + "_Windows_Intel_64Bit.zip"
					Case 25 'Windows(ARM, 64Bit)
					sZIP_FILENAME = sAPP_NAME.ReplaceAll(" ", "_") + sSTAGECODE_SUFFIX + "_Windows_ARM_64Bit.zip"
					Else
					Return
					End Select
					
					'Create .zip
					Var sPATH_PARTS() As String = sBUILD_LOCATION.Split(sCHAR_FOLDER_SEPARATOR)
					Var sAPP_FOLDERNAME As String = sPATH_PARTS(sPATH_PARTS.LastIndex)
					sPATH_PARTS.RemoveAt(sPATH_PARTS.LastIndex)
					Var sFOLDER_BASE As String = String.FromArray(sPATH_PARTS, sCHAR_FOLDER_SEPARATOR)
					
					If TargetWindows Then 'Xojo IDE is running on Windows
					Var sPOWERSHELL_COMMAND As String = "cd """ + sFOLDER_BASE + """; Compress-Archive -Path .\* -DestinationPath ""..\" + sZIP_FILENAME + """ -Force"
					Var iPOWERSHELL_RESULT As Integer
					Var sPOWERSHELL_OUTPUT As String = DoShellCommand("powershell -command """ + sPOWERSHELL_COMMAND.ReplaceAll("""", "'") + """", 0, iPOWERSHELL_RESULT)
					If (iPOWERSHELL_RESULT <> 0) Then
					If (Not bSILENT) Then Print "CreateZIP Error" + EndOfLine + EndOfLine + _
					sPOWERSHELL_OUTPUT.Trim + EndOfLine + _
					"[ExitCode: " + iPOWERSHELL_RESULT.ToString + "]"
					End If
					ElseIf TargetMacOS Or TargetLinux Then 'Xojo IDE running on macOS or Linux
					Var iZIP_RESULT As Integer
					Var sZIP_OUTPUT As String = DoShellCommand("cd """ + sFOLDER_BASE + """ && zip -r ""../" + sZIP_FILENAME + """ ""./" + sAPP_FOLDERNAME + """", 0, iZIP_RESULT)
					If (iZIP_RESULT <> 0) Then
					If (Not bSILENT) Then Print "CreateZIP Error" + EndOfLine + EndOfLine + _
					sZIP_OUTPUT.Trim + EndOfLine + _
					"[ExitCode: " + iZIP_RESULT.ToString + "]"
					End If
					End If
					
				End
				Begin IDEScriptBuildStep InnoSetup , AppliesTo = 2, Architecture = 0, Target = 0
					'**************************************************
					' InnoSetup | Azure Trusted Signing | Docker
					'**************************************************
					' https://github.com/jo-tools/ats-codesign
					'**************************************************
					' Requirements
					'**************************************************
					' 1. Optional: Set up Azure Trusted Signing
					'    (only if you want a codesigned Installer)
					' 2. Have Docker up and running
					' 3. Put your own InnoSetup Script to the project
					'    location (or use the universal script provided
					'    with the example project)
					' 4. Read the comments in this Post Build Script
					' 5. Modify it according to your needs
					'
					'    Especially look out for sDOCKER_EXE
					'    You might need to set the full path to the executable
					'
					'    And at least change the sAPP_PUBLISHER_URL to
					'    your own Website if you're using the provided
					'    universal InnoSetup script
					'**************************************************
					' 6. If it's working for you:
					'    Do you like it? Does it help you? Has it saved you time and money?
					'    You're welcome - it's free...
					'    If you want to say thanks I appreciate a message or a small donation.
					'    Contact: xojo@jo-tools.ch
					'    PayPal:  https://paypal.me/jotools
					'**************************************************
					
					'**************************************************
					' Note: Xojo IDE running on Linux
					'**************************************************
					' Make sure that docker can be run without requiring 'sudo':
					' More information e.g. in this article:
					' https://medium.com/devops-technical-notes-and-manuals/how-to-run-docker-commands-without-sudo-28019814198f
					' 1. sudo groupadd docker
					' 2. sudo gpasswd -a $USER docker
					' 3. (reboot)
					'**************************************************
					
					If DebugBuild Then Return 'don't create a windows installer for DebugRun's
					
					'bSILENT=True : don't show any messages until checking configuration
					Var bSILENT As Boolean = False 'in this example project we want to show if it's not going to work
					
					'bVERYSILENT=True : don't show any messages at all - even if Docker not Available or InnoSetup errors
					'                   use this e.g. in Open Source projects so that your builds will get an installer,
					'                   but if others are building the project it won't show messages to them if that fails
					Var bVERYSILENT As Boolean = False 'in this example project we want to show if it's not going to work
					
					'Sanity Check
					If bVERYSILENT Then bSILENT = True
					
					'Set InnoSetup Script
					'Note: This project includes a universal .iss script
					'      That's why we specify the same .iss for all WIN32, WIN64 and ARM64
					'Note: Folder Separator in this variable can be both \ or /
					Var sINNOSETUP_SCRIPT As String
					Select Case CurrentBuildTarget
					Case 3 'Windows (Intel, 32Bit)
					sINNOSETUP_SCRIPT = "_build/innosetup_universal.iss"
					Case 19 'Windows (Intel, 64Bit)
					sINNOSETUP_SCRIPT = "_build/innosetup_universal.iss"
					Case 25 'Windows(ARM, 64Bit)
					sINNOSETUP_SCRIPT = "_build/innosetup_universal.iss"
					Else
					If (Not bSILENT) Then Print "InnoSetup: Unsupported Build Target"
					Return
					End Select
					
					'Don't create Windows Installer for Development and Alpha Builds
					Select Case PropertyValue("App.StageCode")
					Case "0" 'Development
					If (Not bSILENT) Then Print "InnoSetup: Not enabled for Development Builds"
					Return
					Case "1" 'Alpha
					If (Not bSILENT) Then Print "InnoSetup: Not enabled for Alpha Builds"
					Return
					Case "2" 'Beta
					Case "3" 'Final
					End Select
					
					'Publisher Website
					Var sAPP_PUBLISHER_URL As String = "https://www.jo-tools.ch/"
					
					'****************************************************
					' Note: No more changes needed below here
					'****************************************************
					' This example includes a universal InnoSetup script.
					' All required information is being picked up from
					' the Xojo Project Settings.
					' Of course: feel free to change and modify it
					' according to your needs
					'****************************************************
					
					'Xojo Project Settings
					Var sBUILD_LOCATION As String = CurrentBuildLocation
					Var sAPP_NAME As String = CurrentBuildAppName
					If (sAPP_NAME.Right(4) = ".exe") Then
					sAPP_NAME = sAPP_NAME.Left(sAPP_NAME.Length - 4)
					End If
					Var sAPP_PRODUCTNAME As String = PropertyValue("App.ProductName")
					If (sAPP_PRODUCTNAME = "") Then
					sAPP_PRODUCTNAME = sAPP_NAME
					End If
					Var sAPP_COMPANYNAME As String = PropertyValue("App.CompanyName")
					If (sAPP_COMPANYNAME = "") Then
					sAPP_COMPANYNAME = sAPP_NAME
					End If
					
					'Check Stage Code for Installer Filename
					Var sSTAGECODE_SUFFIX As String
					Select Case PropertyValue("App.StageCode")
					Case "0" 'Development
					sSTAGECODE_SUFFIX = "-dev"
					Case "1" 'Alpha
					sSTAGECODE_SUFFIX = "-alpha"
					Case "2" 'Beta
					sSTAGECODE_SUFFIX = "-beta"
					Case "3" 'Final
					'not used in filename
					End Select
					
					'Build Installer Filename
					Var sSETUP_BASEFILENAME As String
					Select Case CurrentBuildTarget
					Case 3 'Windows (Intel, 32Bit)
					sSETUP_BASEFILENAME = sAPP_NAME.ReplaceAll(" ", "_") + sSTAGECODE_SUFFIX + "_Setup_Intel_32Bit"
					Case 19 'Windows (Intel, 64Bit)
					sSETUP_BASEFILENAME = sAPP_NAME.ReplaceAll(" ", "_") + sSTAGECODE_SUFFIX + "_Setup_Intel_64Bit"
					Case 25 'Windows(ARM, 64Bit)
					sSETUP_BASEFILENAME = sAPP_NAME.ReplaceAll(" ", "_") + sSTAGECODE_SUFFIX + "_Setup_ARM_64Bit"
					Else
					Return
					End Select
					
					'Set Parameters for InnoSetup Script
					Var sISS_csProductName As String = sAPP_PRODUCTNAME
					Var sISS_csExeName As String = sAPP_NAME
					Var sISS_csAppPublisher As String = sAPP_COMPANYNAME
					Var sISS_csAppPublisherURL As String = sAPP_PUBLISHER_URL
					Var sISS_csOutputBaseFilename As String = sSETUP_BASEFILENAME
					
					'Variables for Docker
					Var sDOCKER_IMAGE As String = "jotools/ats-innosetup"
					Var sFILE_ACS_JSON As String = "" 'will be searched in ~/.ats-codesign
					Var sFILE_AZURE_JSON As String = "" 'will be searched in ~/.ats-codesign
					Var sPROJECT_PATH As String
					
					'Check Environment
					Var sDOCKER_EXE As String = "docker"
					Var sCHAR_FOLDER_SEPARATOR As String
					Var bAZURE_TRUSTED_SIGNING_AVAILABLE As Boolean
					
					If TargetWindows Then 'Xojo IDE is running on Windows
					sPROJECT_PATH = DoShellCommand("echo %PROJECT_PATH%", 0).Trim
					sCHAR_FOLDER_SEPARATOR = "\"
					sFILE_ACS_JSON = DoShellCommand("if exist %USERPROFILE%\.ats-codesign\acs.json echo %USERPROFILE%\.ats-codesign\acs.json").Trim
					sFILE_AZURE_JSON = DoShellCommand("if exist %USERPROFILE%\.ats-codesign\azure.json echo %USERPROFILE%\.ats-codesign\azure.json").Trim
					ElseIf TargetMacOS Or TargetLinux Then 'Xojo IDE running on macOS or Linux
					sPROJECT_PATH = DoShellCommand("echo $PROJECT_PATH", 0).Trim
					If sPROJECT_PATH.Right(1) = "/" Then
					'no trailing /
					sPROJECT_PATH = sPROJECT_PATH.Left(sPROJECT_PATH.Length - 1)
					End If
					sCHAR_FOLDER_SEPARATOR = "/"
					sDOCKER_EXE = DoShellCommand("[ -f /usr/local/bin/docker ] && echo /usr/local/bin/docker").Trim
					If (sDOCKER_EXE = "") Then sDOCKER_EXE = DoShellCommand("[ -f /snap/bin/docker ] && echo /snap/bin/docker").Trim
					sFILE_ACS_JSON = DoShellCommand("[ -f ~/.ats-codesign/acs.json ] && echo ~/.ats-codesign/acs.json").Trim
					sFILE_AZURE_JSON = DoShellCommand("[ -f ~/.ats-codesign/azure.json ] && echo ~/.ats-codesign/azure.json").Trim
					sBUILD_LOCATION = sBUILD_LOCATION.ReplaceAll("\", "") 'don't escape Path
					Else
					If (Not bSILENT) Then Print "InnoSetup: Xojo IDE running on unknown Target"
					Return
					End If
					
					If (sPROJECT_PATH = "") Then
					If (Not bSILENT) Then Print "CreateZIP: Could not get the Environment Variable PROJECT_PATH from the Xojo IDE." + EndOfLine + EndOfLine + "Unfortunately, it's empty.... try again after re-launching the Xojo IDE and/or rebooting your machine."
					Return
					End If
					
					'Check InnoSetup Script
					If (sINNOSETUP_SCRIPT <> "") Then
					sINNOSETUP_SCRIPT = sINNOSETUP_SCRIPT.ReplaceAll("/", sCHAR_FOLDER_SEPARATOR).ReplaceAll("\", sCHAR_FOLDER_SEPARATOR)
					If TargetWindows Then 'Xojo IDE is running on Windows
					sINNOSETUP_SCRIPT = DoShellCommand("if exist """ + sPROJECT_PATH + sCHAR_FOLDER_SEPARATOR + sINNOSETUP_SCRIPT + """ echo " + sPROJECT_PATH + sCHAR_FOLDER_SEPARATOR + sINNOSETUP_SCRIPT).Trim
					ElseIf TargetMacOS Or TargetLinux Then 'Xojo IDE running on macOS or Linux
					sINNOSETUP_SCRIPT = DoShellCommand("[ -f """ + sPROJECT_PATH + sCHAR_FOLDER_SEPARATOR + sINNOSETUP_SCRIPT + """ ] && echo " + sPROJECT_PATH + sCHAR_FOLDER_SEPARATOR + sINNOSETUP_SCRIPT).Trim
					End If
					End If
					
					If (sINNOSETUP_SCRIPT = "") Then
					If (Not bSILENT) Then Print "InnoSetup: No InnoSetup Script"
					Return
					End If
					
					If (sFILE_ACS_JSON = "") Or (sFILE_AZURE_JSON = "") Then
					If (Not bSILENT) Then
					Print "InnoSetup: acs.json and azure.json not found in [UserHome]-[.ats-codesign]-[acs|azure.json]" + EndOfLine + _
					"Proceeding without codesigning the windows installer"
					End If
					bAZURE_TRUSTED_SIGNING_AVAILABLE = False
					Else
					bAZURE_TRUSTED_SIGNING_AVAILABLE = True
					End If
					
					'Check Docker
					Var iCHECK_DOCKER_RESULT As Integer
					Var sCHECK_DOCKER_EXE As String = DoShellCommand(sDOCKER_EXE + " --version", 0, iCHECK_DOCKER_RESULT).Trim
					If (iCHECK_DOCKER_RESULT <> 0) Or (Not sCHECK_DOCKER_EXE.Contains("Docker")) Or (Not sCHECK_DOCKER_EXE.Contains("version")) Or (Not sCHECK_DOCKER_EXE.Contains("build "))Then
					If (Not bVERYSILENT) Then Print "InnoSetup: Docker not available"
					Return
					End If
					
					Var sCHECK_DOCKER_PROCESS As String = DoShellCommand(sDOCKER_EXE + " ps", 0, iCHECK_DOCKER_RESULT).Trim
					If (iCHECK_DOCKER_RESULT <> 0) Then
					If (Not bVERYSILENT) Then Print "InnoSetup: Docker not running"
					Return
					End If
					
					Var sPATH_PARTS() As String = sBUILD_LOCATION.Split(sCHAR_FOLDER_SEPARATOR)
					Var sAPP_FOLDERNAME As String = sPATH_PARTS(sPATH_PARTS.LastIndex)
					sPATH_PARTS.RemoveAt(sPATH_PARTS.LastIndex)
					Var sAPP_PARENT_FOLDERNAME As String = sPATH_PARTS(sPATH_PARTS.LastIndex)
					sPATH_PARTS.RemoveAt(sPATH_PARTS.LastIndex)
					Var sFOLDER_BASE As String = String.FromArray(sPATH_PARTS, sCHAR_FOLDER_SEPARATOR)
					Var sISS_RELATIVE_SOURCEPATH As String = sAPP_PARENT_FOLDERNAME + "/" + sAPP_FOLDERNAME
					
					'Run InnoSetup (and CodeSign) in Docker Container
					Var sINNOSETUP_PARAMETERS() As String
					
					If bAZURE_TRUSTED_SIGNING_AVAILABLE Then
					sINNOSETUP_PARAMETERS.Add("""/SATS=Z:/usr/local/bin/ats-codesign.bat $f""")
					sINNOSETUP_PARAMETERS.Add("/DDoCodeSignATS")
					End If
					
					'Parameters for our universal InnoSetup Script
					sINNOSETUP_PARAMETERS.Add("/DcsProductName=""" + sISS_csProductName + """")
					sINNOSETUP_PARAMETERS.Add("/DcsExeName=""" + sISS_csExeName + """")
					sINNOSETUP_PARAMETERS.Add("/DcsAppPublisher=""" + sISS_csAppPublisher + """")
					sINNOSETUP_PARAMETERS.Add("/DcsAppPublisherURL=""" + sISS_csAppPublisherURL + """")
					sINNOSETUP_PARAMETERS.Add("/DcsOutputBaseFilename=""" + sISS_csOutputBaseFilename + """")
					
					'Define Build Target for our universal InnoSetup Script
					Select Case CurrentBuildTarget
					Case 3 'Windows (Intel, 32Bit)
					sINNOSETUP_PARAMETERS.Add("/DBuildTargetWIN32")
					Case 19 'Windows (Intel, 64Bit)
					sINNOSETUP_PARAMETERS.Add("/DBuildTargetWIN64")
					Case 25 'Windows(ARM, 64Bit)
					sINNOSETUP_PARAMETERS.Add("/DBuildTargetARM64")
					End Select
					
					sINNOSETUP_PARAMETERS.Add("/O""Z:/data""") 'Output in Folder
					sINNOSETUP_PARAMETERS.Add("/Dsourcepath=""Z:/data/" + sISS_RELATIVE_SOURCEPATH + """") 'Folder of built App
					sINNOSETUP_PARAMETERS.Add("""Z:/tmp/innosetup-script.iss""") 'we mount the script to this location
					
					Var sINNOSETUP_COMMAND As String = _
					sDOCKER_EXE + " run " + _
					"--rm " + _
					If(sFILE_ACS_JSON <> "", "-v """ + sFILE_ACS_JSON + """:/etc/ats-codesign/acs.json ", "") + _
					If(sFILE_AZURE_JSON <> "", "-v """ + sFILE_AZURE_JSON + """:/etc/ats-codesign/azure.json ", "") + _
					"-v """ + sFOLDER_BASE + """:/data " + _
					"-v """ + sINNOSETUP_SCRIPT + """:/tmp/innosetup-script.iss " + _
					"-w /data " + _
					"--entrypoint iscc.sh " + _
					sDOCKER_IMAGE + " " + _
					"'" + String.FromArray(sINNOSETUP_PARAMETERS, " ").ReplaceAll("$f", "\$f") + "'"
					
					Var iINNOSETUP_RESULT As Integer
					Var sINNOSETUP_OUTPUT As String = DoShellCommand(sINNOSETUP_COMMAND, 0, iINNOSETUP_RESULT)
					
					If (iINNOSETUP_RESULT <> 0) And (Not bVERYSILENT) Then
					Clipboard = sINNOSETUP_OUTPUT
					Print "InnoSetup: iscc.sh Error" + EndOfLine + _
					"[ExitCode: " + iINNOSETUP_RESULT.ToString + "]" + EndOfLine + EndOfLine + _
					"Note: Shell Output is available in Clipboard."
					
					If (iINNOSETUP_RESULT <> 125) Then
					Var iCHECK_DOCKERIMAGE_RESULT As Integer
					Var sCHECK_DOCKERIMAGE_OUTPUT As String = DoShellCommand(sDOCKER_EXE + " image inspect " + sDOCKER_IMAGE, 0, iCHECK_DOCKERIMAGE_RESULT)
					If (iCHECK_DOCKERIMAGE_RESULT <> 0) Then
					Print "InnoSetup: Docker Image '" + sDOCKER_IMAGE + "' not available"
					End If
					End If
					End If
					
				End
			End
#tag EndBuildAutomation
