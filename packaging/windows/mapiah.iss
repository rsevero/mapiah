   [Setup]
   AppName=Mapiah
   AppVersion=0.2.3
   DefaultDirName={commonpf}\Mapiah
   DefaultGroupName=Mapiah
   OutputDir=C:\mapiah\build\windows-installer
   OutputBaseFilename=MapiahSetup
   Compression=lzma
   SolidCompression=yes

   [Files]
   Source: "C:\mapiah\build\windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

   [Icons]
   Name: "{group}\Mapiah"; Filename: "{app}\x64\runner\Release\mapiah.exe"
   Name: "{group}\Uninstall Mapiah"; Filename: "{uninstallexe}"

   [Run]
   Filename: "{app}\x64\runner\Release\mapiah.exe"; Description: "Launch Mapiah"; Flags: nowait postinstall skipifsilent
