#define MyAppName "Rayburst Avalonia"
#ifndef MyAppVersion
  #define MyAppVersion "0.1.0"
#endif
#ifndef MyAppArchitecture
  #define MyAppArchitecture "x64compatible"
#endif
#ifndef MyAppOutputName
  #define MyAppOutputName "x64"
#endif
#define MyAppPublisher "PCUser2021"
#define MyAppExeName "RayburstReach.exe"

[Setup]
AppId={{A94C438A-E73B-4C98-BB21-2BA0C0F5D991}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\Rayburst Avalonia
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed={#MyAppArchitecture}
ArchitecturesInstallIn64BitMode={#MyAppArchitecture}
OutputDir=..\artifacts\installer
OutputBaseFilename=RayburstReach-Setup-{#MyAppOutputName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}
CloseApplications=yes
RestartApplications=no

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "..\artifacts\publish\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Rayburst Avalonia"; Flags: postinstall nowait skipifsilent
