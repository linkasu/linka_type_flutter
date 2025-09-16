[Setup]
AppName=LINKa напиши
AppVersion=4.0.0
AppPublisher=linka.su
AppPublisherURL=https://linka.su
AppSupportURL=https://linka.su
AppUpdatesURL=https://linka.su
DefaultDirName={autopf}\LINKa
DefaultGroupName=LINKa
AllowNoIcons=yes
OutputDir=dist
OutputBaseFilename=LINKa-napishi-4.0.0-setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\LINKa напиши"; Filename: "{app}\linka_type_flutter.exe"
Name: "{group}\{cm:UninstallProgram,LINKa напиши}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\LINKa напиши"; Filename: "{app}\linka_type_flutter.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\LINKa напиши"; Filename: "{app}\linka_type_flutter.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Installing Visual C++ Redistributable..."; Check: not IsVCRedistInstalled
Filename: "{app}\linka_type_flutter.exe"; Description: "{cm:LaunchProgram,LINKa напиши}"; Flags: nowait postinstall skipifsilent

[Code]
function IsVCRedistInstalled: Boolean;
var
  Version: String;
begin
  Result := RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) and
            (Version >= '14.30.30704.0');
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
