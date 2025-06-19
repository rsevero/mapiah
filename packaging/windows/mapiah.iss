   #define AppVersion GetStringFileInfo("C:\mapiah\build\windows\x64\runner\Release\mapiah.exe", "ProductVersion")
   
   [Setup]
   AppName=Mapiah
   AppVersion={#AppVersion}
   DefaultDirName={commonpf}\Mapiah
   DefaultGroupName=Mapiah
   OutputDir=C:\mapiah\build\windows-installer
   OutputBaseFilename=Mapiah-v{#AppVersion}-windows-x64
   Compression=lzma
   SolidCompression=yes

   [Files]
   Source: "C:\mapiah\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

   [Icons]
   Name: "{group}\Mapiah"; Filename: "{app}\mapiah.exe"
   Name: "{group}\Uninstall Mapiah"; Filename: "{uninstallexe}"

   [Run]
   Filename: "{app}\mapiah.exe"; Description: "Launch Mapiah"; Flags: nowait postinstall skipifsilent
