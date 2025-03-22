; ******************************************************
; Parameters for calling this universal InnoSetup Script
; ******************************************************
; App / Product Information
; ------------------------------------------------------
; /DcsProductName="My Application"
; /DcsExeName="MyExecutable.exe"
; /DcsAppPublisher="My App Publisher"
; /DcsAppPublisherURL="https://www.mycompany.org/"
; /DcsOutputBaseFilename="Setup_MyApplication"
; ******************************************************
; Build Target (for Installation Requirements)
; ------------------------------------------------------
; one of the following
; /DBuildTargetWIN32 | /DBuildTargetWIN64 | /DBuildTargetARM64
; ******************************************************
; Enable CodeSigning using Azure Trusted Signing
; ------------------------------------------------------
; /DDoCodeSignATS
;
; If CodeSigning is enabled: Set CodeSignTool 'ATS'
; "/SATS=Z:/usr/local/bin/ats-codesign.bat $f"
; ******************************************************

#ifndef csProductName
  #define csProductName "My Application"
#endif
#ifndef csExeName
  #define csExeName "MyExecutable.exe"
#endif
#ifndef csAppPublisher
  #define csAppPublisher "My App Publisher"
#endif
#ifndef csAppPublisherURL
  #define csAppPublisherURL "https://www.mycompany.org/"
#endif
#ifndef csOutputBaseFilename
  #define csOutputBaseFilename "Setup_MyApplication"
#endif


#define ApplicationVersion	GetFileProductVersion(AddBackslash(SourcePath) + csExeName)

//
// GetStringFileInfo standard names
//
#define COMPANY_NAME       "CompanyName"
#define FILE_DESCRIPTION   "FileDescription"
#define FILE_VERSION       "FileVersion"
#define INTERNAL_NAME      "InternalName"
#define LEGAL_COPYRIGHT    "LegalCopyright"
#define ORIGINAL_FILENAME  "OriginalFilename"
#define PRODUCT_NAME       "ProductName"
#define PRODUCT_VERSION    "ProductVersion"
//
// GetStringFileInfo helpers
//
#define GetFileCompany(str FileName) GetStringFileInfo(FileName, COMPANY_NAME)
#define GetFileCopyright(str FileName) GetStringFileInfo(FileName, LEGAL_COPYRIGHT)
#define GetFileDescription(str FileName) GetStringFileInfo(FileName, FILE_DESCRIPTION)
#define GetFileProductVersion(str FileName) GetStringFileInfo(FileName, PRODUCT_VERSION)
#define GetFileVersionString(str FileName) GetStringFileInfo(FileName, FILE_VERSION)


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID from the menu.) 
AppId={#csProductName}
AppName={#csProductName}
AppVerName={#csProductName}
AppVersion={#ApplicationVersion}
AppPublisher={#csAppPublisher}
AppPublisherURL={#csAppPublisherURL}

WizardStyle=modern

; Installation Settings
; Note: Remove 'not arm64' if you want to allow WIN32 or WIN64 apps to run on Windows ARM
;       This example will only allow installing the ARM64 build on Windows ARM
#if defined(BuildTargetWIN32)
  ArchitecturesAllowed=not arm64
#elif defined(BuildTargetWIN64)
  ArchitecturesInstallIn64BitMode=x64
  ArchitecturesAllowed=x64compatible and not arm64
#elif defined(BuildTargetARM64)
  ArchitecturesInstallIn64BitMode=arm64
  ArchitecturesAllowed=arm64
#endif

DefaultDirName={autopf}\{#csProductName}
;since no icons will be created in "{group}", we don't need the wizard to ask for a group name:
DefaultGroupName=
DisableProgramGroupPage=yes

SourceDir={#sourcepath}
OutputDir=.  
OutputBaseFilename={#csOutputBaseFilename}

Compression=lzma
SolidCompression=yes
ChangesAssociations=yes

; Require Windows 8.1 with Update 1
MinVersion=6.3.9600


; Set Signtool only if called with Parameter /DDoCodeSignATS
#ifdef DoCodeSignATS
  Signtool=ATS
#endif
; We don't set SignedUninstaller, but use it's Default value: yes if a SignTool is set, no otherwise
; SignedUninstaller=yes

UninstallDisplayIcon={app}\{#csExeName}


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "*"; DestDir: "{app}"; Flags: overwritereadonly recursesubdirs uninsremovereadonly createallsubdirs ignoreversion

[Icons]
Name: "{commondesktop}\{#csProductName}"; Filename: "{app}\{#csExeName}"; Tasks: desktopicon
Name: "{commonprograms}\{#csProductName}"; Filename: "{app}\{#csExeName}"

[Run]
Filename: "{app}\{#csExeName}"; Description: "{cm:LaunchProgram,{#csProductName}}"; Flags: nowait postinstall skipifsilent
