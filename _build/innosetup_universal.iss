; ************************************************************************
; Parameters for calling this universal InnoSetup Script
; ************************************************************************
; App / Product Information
; ------------------------------------------------------------------------
; /DcsProductName="My Application"
; /DcsProductNameWithStageCode="My Application [BETA]"
; /DcsExeName="MyExecutable.exe"
; /DcsAppPublisher="My App Publisher"
; /DcsAppPublisherURL="https://www.mycompany.org/"
; /DcsOutputBaseFilename="Setup_MyApplication"
; ************************************************************************
; Build Target (for Installation Requirements)
; ------------------------------------------------------------------------
; one of the following
; /DcsBuildTargetWIN32 | /DcsBuildTargetWIN64 | /DcsBuildTargetARM64
; ------------------------------------------------------------------------
; Minimum Version of Windows (for Installation Requirements)
; ------------------------------------------------------------------------
; /DcsMinVersion="My App Publisher"
; Xojo 2025r1.1: Require Windows 10 Version 1903 (May 2019 Update)
; /DcsMinVersion="10.0.18362"
; Xojo 2024r4.2: Require Windows 8.1 with Update 1
; /DcsMinVersion="6.3.9600"
; ************************************************************************
; Enable CodeSigning using Azure Trusted Signing (or .pfx)
; Note: ATS here doesn't mean to support Azure Trusted Signing only.
;       The Parameter just enables that this .iss will use the
;       Signtool command, which we label "ATS" here.
;       So calling the .iss will need the CodeSign Script "ATS" defined.
;       And that might sign with either Azure Trusted Signing or .pfx
; ------------------------------------------------------------------------
; /DcsCodeSignATS
;
; If CodeSigning is enabled: Set CodeSign Tool with label 'ATS'
; which does the actual codesigning (either with Azure Trusted
; Signing or a .pfx)
; "/SATS=Z:/usr/local/bin/[ats|pfx]-codesign.bat $f"
; ************************************************************************


#ifndef csProductName
  #define csProductName "My Application"
#endif
#ifndef csProductNameWithStageCode
  #define csProductNameWithStageCode "My Application [BETA]"
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
#ifndef csMinVersion
  #define csMinVersion "10.0.18362"
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
AppVerName={#csProductNameWithStageCode} {#ApplicationVersion}
AppVersion={#ApplicationVersion}
AppPublisher={#csAppPublisher}
AppPublisherURL={#csAppPublisherURL}

WizardStyle=modern

; Installation Settings
; Note: Remove 'not arm64' if you want to allow WIN32 or WIN64 apps to run on Windows ARM
;       This example will only allow installing the ARM64 build on Windows ARM
#if defined(csBuildTargetWIN32)
; never allow a WIN32 to be installed on ARM64
  ArchitecturesAllowed=not arm64
#elif defined(csBuildTargetWIN64)
  ArchitecturesInstallIn64BitMode=x64compatible
; if you want to prevent installing the WIN64 Intel Build on ARM64 (even if it works)
; ArchitecturesAllowed=x64compatible and not arm64
; allow installing the WIN64 Intel Build on ARM64
  ArchitecturesAllowed=x64compatible
#elif defined(csBuildTargetARM64)
; require ARM64 - the application won't run on Intel
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

MinVersion={#csMinVersion}

; Set Signtool only if called with Parameter /DcsCodeSignATS
#ifdef csCodeSignATS
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
