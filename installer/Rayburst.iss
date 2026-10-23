#define MyAppVersion GetEnv("RAYBURST_VERSION")
#define MyAppOutput GetEnv("RAYBURST_OUTPUT")
#define MyPayloadDir GetEnv("RAYBURST_PAYLOAD_DIR")

#if MyAppVersion == ""
  #error RAYBURST_VERSION must be set.
#endif
#if MyAppOutput == ""
  #error RAYBURST_OUTPUT must be set.
#endif
#if MyPayloadDir == ""
  #error RAYBURST_PAYLOAD_DIR must be set.
#endif

[Setup]
AppId={{52F92BC7-B9AC-43CA-A2F0-B3CCCE2E9F50}
AppName=Rayburst
AppVersion={#MyAppVersion}
AppPublisher=AnInsomniacy
AppPublisherURL=https://github.com/AnInsomniacy/rayburst
AppSupportURL=https://github.com/AnInsomniacy/rayburst/issues
AppUpdatesURL=https://github.com/AnInsomniacy/rayburst/releases
DefaultDirName={localappdata}\Programs\Rayburst
DefaultGroupName=Rayburst
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\icon.ico
SetupIconFile={#MyPayloadDir}\icon.ico
OutputDir=..\artifacts\installer
OutputBaseFilename=Rayburst-{#MyAppVersion}-Setup-{#MyAppOutput}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible arm64
ArchitecturesInstallIn64BitMode=x64compatible arm64
CloseApplications=yes
RestartApplications=no
ChangesAssociations=yes
SetupLogging=yes
Uninstallable=yes
VersionInfoVersion={#MyAppVersion}.0
VersionInfoProductName=Rayburst
VersionInfoCompany=AnInsomniacy

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "{#MyPayloadDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Rayburst"; Filename: "{app}\Rayburst.exe"
Name: "{autodesktop}\Rayburst"; Filename: "{app}\Rayburst.exe"; Tasks: desktopicon

[Registry]
; Register named candidates instead of silently taking over the user's defaults.
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.torrent"; ValueType: string; ValueName: ""; ValueData: "Rayburst torrent"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.torrent\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"",0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.torrent\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"" ""%1"""; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\.torrent\OpenWithProgids"; ValueType: none; ValueName: "dev.aninsomniacy.rayburst.torrent"; Flags: uninsdeletevalue

Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.magnet"; ValueType: string; ValueName: ""; ValueData: "Rayburst magnet URL"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.magnet"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.magnet\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"",0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.magnet\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"" ""%1"""; Flags: uninsdeletekey

Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.ed2k"; ValueType: string; ValueName: ""; ValueData: "Rayburst ed2k URL"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.ed2k"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.ed2k\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"",0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.ed2k\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"" ""%1"""; Flags: uninsdeletekey

Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.thunder"; ValueType: string; ValueName: ""; ValueData: "Rayburst thunder URL"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.thunder"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.thunder\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"",0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.thunder\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"" ""%1"""; Flags: uninsdeletekey

Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.rayburst"; ValueType: string; ValueName: ""; ValueData: "Rayburst URL"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.rayburst"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.rayburst\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"",0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.aninsomniacy.rayburst.rayburst\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\Rayburst.exe"" ""%1"""; Flags: uninsdeletekey

Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities"; ValueType: string; ValueName: "ApplicationName"; ValueData: "Rayburst"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities"; ValueType: string; ValueName: "ApplicationDescription"; ValueData: "Download files and media with Rayburst"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities"; ValueType: string; ValueName: "ApplicationIcon"; ValueData: """{app}\Rayburst.exe"",0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities\FileAssociations"; ValueType: string; ValueName: ".torrent"; ValueData: "dev.aninsomniacy.rayburst.torrent"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities\URLAssociations"; ValueType: string; ValueName: "magnet"; ValueData: "dev.aninsomniacy.rayburst.magnet"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities\URLAssociations"; ValueType: string; ValueName: "ed2k"; ValueData: "dev.aninsomniacy.rayburst.ed2k"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities\URLAssociations"; ValueType: string; ValueName: "thunder"; ValueData: "dev.aninsomniacy.rayburst.thunder"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\dev.aninsomniacy.rayburst\Capabilities\URLAssociations"; ValueType: string; ValueName: "rayburst"; ValueData: "dev.aninsomniacy.rayburst.rayburst"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\RegisteredApplications"; ValueType: string; ValueName: "dev.aninsomniacy.rayburst"; ValueData: "Software\dev.aninsomniacy.rayburst\Capabilities"; Flags: uninsdeletevalue

; Browser native messaging manifests.
Root: HKCU; Subkey: "Software\Google\Chrome\NativeMessagingHosts\dev.aninsomniacy.rayburst.browser"; ValueType: string; ValueName: ""; ValueData: "{app}\native-messaging\manifests\chromium.json"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Edge\NativeMessagingHosts\dev.aninsomniacy.rayburst.browser"; ValueType: string; ValueName: ""; ValueData: "{app}\native-messaging\manifests\chromium.json"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Mozilla\NativeMessagingHosts\dev.aninsomniacy.rayburst.browser"; ValueType: string; ValueName: ""; ValueData: "{app}\native-messaging\manifests\firefox.json"; Flags: uninsdeletekey

[Run]
Filename: "{app}\Rayburst.exe"; Description: "Launch Rayburst"; Flags: postinstall nowait skipifsilent

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  ExePath: String;
  Parameters: String;
begin
  Result := '';
  ExePath := ExpandConstant('{app}\Rayburst.exe');
  Parameters := '--prepare-install "' + ExpandConstant('{app}') + '"';
  if FileExists(ExePath) then begin
    if (not Exec(ExePath, Parameters, ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode)) or (ResultCode <> 0) then
      Result := 'Rayburst could not stop the existing application cleanly. Close Rayburst and run the installer again.';
  end;
end;

function InitializeUninstall(): Boolean;
var
  ResultCode: Integer;
  ExePath: String;
  Parameters: String;
begin
  Result := True;
  ExePath := ExpandConstant('{app}\Rayburst.exe');
  Parameters := '--prepare-install "' + ExpandConstant('{app}') + '"';
  if FileExists(ExePath) then begin
    if (not Exec(ExePath, Parameters, ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode)) or (ResultCode <> 0) then begin
      MsgBox('Rayburst could not stop the existing application cleanly. Close Rayburst and run the uninstaller again.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
