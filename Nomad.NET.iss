; Inno Setup installer script for Nomad.NET file manager
; Author: Bill Stewart (bstewart AT iname.com)
;
; Additional features added by [Code] section:
; * Automatic uninstall if installed version too old
; * Disallow downgrading
; * Disallow uninstall if program is running
; * Remove desktop icon if corresponding task deselected
; * Installed programs list indicates if installed for all users
;
; DLLs required:
; * UninsIS.dll - https://github.com/Bill-Stewart/UninsIS/
; * ProcessCheck.dll - https://github.com/Bill-Stewart/ProcessCheck/

#if Ver < EncodeVer(6,3,1,0)
#error This script requires Inno Setup 6.3.1 or later
#endif

#define UninstallIfVersionOlderThan "3.2.0.2890"
#define AppId "{BEB7EC63-A8EF-424E-9BB6-1267A67F0B34}"
#define AppName "Nomad.NET"
#define AppPublisher "Eugene Sickhar"
#define AppURL "https://github.com/Bill-Stewart/Nomad.NET-setup"
#define AppVersion GetStringFileInfo("redist\Nomad.exe", PRODUCT_VERSION)
#define IconFileName "Nomad.NET.ico"
#define SetupCompany "Bill Stewart (bstewart AT iname.com)"

[Setup]
AllowNoIcons=yes
AppId={{#AppId}
AppName={#AppName}
AppVerName={#AppName} [{#AppVersion}]
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppVersion={#AppVersion}
ArchitecturesInstallIn64BitMode=x64compatible
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
DisableWelcomePage=yes
MinVersion=6.1sp1
OutputBaseFilename=Setup-{#AppName}-{#AppVersion}
OutputDir=.
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
SolidCompression=yes
UninstallDisplayName={code:GetUninstallDisplayName}
UninstallDisplayIcon={app}\{#IconFileName}
UninstallFilesDir={app}\uninstall
UsePreviousTasks=yes
VersionInfoCompany={#SetupCompany}
VersionInfoProductVersion={#AppVersion}
VersionInfoVersion={#AppVersion}
WizardResizable=no
WizardStyle=modern

[Languages]
Name: en; MessagesFile: compiler:Default.isl,messages-en.isl; InfoBeforeFile: readme-en.rtf; LicenseFile: license-en.rtf

[Files]
; Setup and uninstall DLLs
Source: ProcessCheck.dll; DestDir: {app}; Flags: uninsneveruninstall
Source: UninsIS.dll; Flags: dontcopy
; Updated files
Source: defaultUser.config; DestDir: {app}
Source: Nomad.exe.config; DestDir: {app}
Source: Nomad.NET.js; DestDir: {app}
Source: Nomad.NET.ico; DestDir: {app}
; Stock files, both architectures
Source: redist\*; DestDir: {app}; Flags: recursesubdirs
; x86 stock files (all architectures)
Source: redist_x86\*; DestDir: {app}; Flags: recursesubdirs
; x64 stock files (x64compatible)
Source: redist_x64\*; DestDir: {app}; Flags: recursesubdirs solidbreak; Check: IsX64Compatible()
; Nomad.exe.config -> Nomad_x86.exe.config (x64compatible)
Source: Nomad.exe.config; DestDir: {app}; DestName: Nomad_x86.exe.config; Check: IsX64Compatible()

[Icons]
Name: {autostartmenu}\{#AppName}; Filename: {sys}\wscript.exe; Parameters: """{app}\Nomad.NET.js"""; Comment: {cm:IconComment}; IconFilename: {app}\{#IconFilename}; WorkingDir: {app}
Name: {autodesktop}\{#AppName}; Filename: {sys}\wscript.exe; Parameters: """{app}\Nomad.NET.js"""; Comment: {cm:IconComment}; IconFilename: {app}\{#IconFilename}; WorkingDir: {app}; Tasks: desktopicon

[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; Flags: unchecked

[Run]
Filename: {sys}\wscript.exe; Parameters: """{app}\Nomad.NET.js"""; Description: {cm:LaunchProgram,{#AppName}}; Flags: nowait postinstall skipifsilent unchecked; Check: not IsApplicationRunning(true)

[Code]
const
  RESTART_MANAGER_SLEEP_MSECS = 1000;

var
  ApplicationUninstalled: Boolean;

// UninsIS.dll - https://github.com/Bill-Stewart/UninsIS/
function DLLIsISPackageInstalled(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'IsISPackageInstalled@files:UninsIS.dll stdcall setuponly';

function DLLGetISPackageVersion(AppId, Version: string; NumChars, Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'GetISPackageVersion@files:UninsIS.dll stdcall setuponly';

function DLLCompareVersionStrings(Version1, Version2: string): Integer;
  external 'CompareVersionStrings@files:UninsIS.dll stdcall setuponly';

function DLLUninstallISPackage(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'UninstallISPackage@files:UninsIS.dll stdcall setuponly';

// ProcessCheck.dll - https://github.com/Bill-Stewart/ProcessCheck/
function DLLFindProcessSetup(PathName: string; var Found: DWORD): DWORD;
  external 'FindProcess@files:ProcessCheck.dll stdcall setuponly';

function DLLFindProcessUninstall(PathName: string; var Found: DWORD): DWORD;
  external 'FindProcess@{app}\ProcessCheck.dll stdcall uninstallonly';

function IsISPackageInstalled(): Boolean;
begin
  result := DLLIsISPackageInstalled('{#AppId}',  // AppId
    DWORD(Is64BitInstallMode()),                 // Is64BitInstallMode
    DWORD(IsAdminInstallMode())) = 1;            // IsAdminInstallMode
  if result then
    Log(CustomMessage('CodePackageInstalled'))
  else
    Log(CustomMessage('CodePackageNotInstalled'));
end;

function GetISPackageVersion(): string;
var
  NumChars: DWORD;
  OutStr: string;
begin
  result := '';
  // Get # of characters needed for string
  NumChars := DLLGetISPackageVersion('{#AppId}',  // AppId
    '',                                           // Version
    0,                                            // NumChars
    DWORD(Is64BitInstallMode()),                  // Is64BitInstallMode
    DWORD(IsAdminInstallMode()));                 // IsAdminInstallMode
  // Allocate and retrieve string
  SetLength(OutStr, NumChars);
  if DLLGetISPackageVersion('{#AppId}',    // AppId
    OutStr,                                // Version
    NumChars,                              // NumChars
    DWORD(Is64BitInstallMode()),           // Is64BitInstallMode
    DWORD(IsAdminInstallMode())) > 0 then  // IsAdminInstallMode
  begin
    result := OutStr;
    Log(FmtMessage(CustomMessage('CodePackageVersion'), [result]));
  end;
end;

function CompareVersionStrings(const Version1, Version2: string): Integer;
begin
  result := DLLCompareVersionStrings(Version1, Version2);
end;

function UninstallISPackage(): DWORD;
begin
  result := DLLUninstallISPackage('{#AppId}',  // AppId
    DWORD(Is64BitInstallMode()),               // Is64BitInstallMode
    DWORD(IsAdminInstallMode()));              // IsAdminInstallMode
  if result = 0 then
    Log(CustomMessage('CodePackageUninstallSucceeded'))
  else
    Log(FmtMessage(CustomMessage('CodePackageUninstallFailedLog'), [IntToStr(result)]));
end;

// Param parameter is required
function GetUninstallDisplayName(Param: string): string;
begin
  result := ExpandConstant('{#AppName}');
  if IsAdminInstallMode() then
    result := result + ' (All users)';
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  InstalledVersion: string;
begin
  result := '';
  if IsISPackageInstalled() then
  begin
    InstalledVersion := GetISPackageVersion();
    // Uninstall if installed version older than #UninstallIfVersionOlderThan
    if CompareVersionStrings(InstalledVersion, '{#UninstallIfVersionOlderThan}') < 0 then
    begin
      if UninstallISPackage() <> 0 then
      begin
        result := CustomMessage('CodePackageUninstallFailedUser');
        exit;
      end;
      Sleep(RESTART_MANAGER_SLEEP_MSECS);
    end;
    // Disallow downgrading
    if CompareVersionStrings(InstalledVersion, '{#AppVersion}') > 0 then
    begin
      result := FmtMessage(CustomMessage('CodeCannotDowngrade'), [InstalledVersion, '{#AppVersion}']);
      exit;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  FileName: string;
begin
  if CurStep = ssPostInstall then
  begin
    // Delete desktop icon if wizard task is not selected
    if not WizardIsTaskSelected('desktopicon') then
    begin
      FileName := ExpandConstant('{autodesktop}\{#AppName}.lnk');
      if FileExists(FileName) then
      begin
        if DeleteFile(FileName) then
          Log(FmtMessage(CustomMessage('CodeDeletedDesktopIconSucceeded'), [FileName]))
        else
          Log(FmtMessage(CustomMessage('CodeDeletedDesktopIconFailed'), [FileName]));
      end;
    end;
  end;
end;

// DuringSetup parameter: use true during setup, or false during uninstall
// (This is necessary due to two different DLL imports)
function IsApplicationRunning(const DuringSetup: Boolean): Boolean;
var
  Executables: TArrayOfString;
  I: Integer;
  PathName: string;
  DLLResult, Found: DWORD;
begin
  if DuringSetup then
    Sleep(RESTART_MANAGER_SLEEP_MSECS);
  result := false;
  SetArrayLength(Executables, 2);
  Executables[0] := 'nomad.exe';
  Executables[1] := 'nomad_x86.exe';
  for I := 0 to GetArrayLength(Executables) - 1 do
  begin
    PathName := ExpandConstant('{app}\') + Executables[I];
    if DuringSetup then
      DLLResult := DLLFindProcessSetup(PathName, Found)
    else  // during uninstall
      DLLResult := DLLFindProcessUninstall(PathName, Found);
    if DLLResult = 0 then
    begin
      result := Found = 1;
      if result then
      begin
        Log(FmtMessage(CustomMessage('CodeApplicationRunningLog'), [PathName]));
        break;
      end;
    end;
  end;
end;

function InitializeUninstall(): Boolean;
var
  Message: string;
begin
  // Abort uninstall if application is running
  result := not IsApplicationRunning(false);  // false = during uninstall
  if not result then
  begin
    Message := CustomMessage('CodeApplicationRunning');
    if UninstallSilent() then
      Log(Message)
    else
      MsgBox(Message, mbCriticalError, MB_OK);
  end;
  ApplicationUninstalled := false;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
if CurUninstallStep = usPostUninstall then
    ApplicationUninstalled := true;
end;

procedure DeinitializeUninstall();
begin
  if ApplicationUninstalled then
  begin
    // ProcessCheck.dll installed with 'uninsneveruninstall' flag
    UnloadDLL(ExpandConstant('{app}\ProcessCheck.dll'));
    DeleteFile(ExpandConstant('{app}\ProcessCheck.dll'));
    RemoveDir(ExpandConstant('{app}'));
  end;
end;
