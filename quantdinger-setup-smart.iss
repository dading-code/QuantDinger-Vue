; ============================================================
; QuantDinger Desktop - Inno Setup Installer Configuration
; Smart PostgreSQL Detection: Reuse existing database if available
; Optimized for faster installation speed
; ============================================================

[Setup]
AppName=QuantDinger Desktop
AppVersion=1.0.0
AppPublisher=QuantDinger Team
DefaultDirName={autopf}\QuantDinger-Desktop
DefaultGroupName=QuantDinger Desktop
OutputDir=output
OutputBaseFilename=QuantDinger-Desktop-1.0.0
; 优化：使用 ultra64 代替 max，解压速度提升 2-3 倍，安装包只增大 5-10MB
Compression=lzma2/ultra64
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; 自定义页面设置
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "installpostgres"; Description: "安装新的 PostgreSQL 数据库（推荐）"; GroupDescription: "数据库配置:"; Flags: exclusive
Name: "useexistingpostgres"; Description: "使用系统中已安装的 PostgreSQL"; GroupDescription: "数据库配置:"; Flags: exclusive

[Files]
; Backend files (Python environment + code)
Source: "d:\www\workai\QuantDinger-Desktop\backend\*"; DestDir: "{app}\backend"; Flags: recursesubdirs ignoreversion

; Frontend files (built Vue app)
Source: "d:\www\workai\QuantDinger-Desktop\frontend\*"; DestDir: "{app}\frontend"; Flags: recursesubdirs ignoreversion

; Launcher scripts
Source: "d:\www\workai\QuantDinger-Desktop\launcher\*"; DestDir: "{app}\launcher"; Flags: ignoreversion

; Resources (icons, etc.)
Source: "d:\www\workai\QuantDinger-Desktop\resources\*"; DestDir: "{app}\resources"; Flags: ignoreversion

; PostgreSQL installer (bundled for best UX)
Source: "d:\www\workai\QuantDinger-Desktop\database\postgresql\postgresql-installer.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Tasks: installpostgres

; Database configuration script
Source: "d:\www\workai\QuantDinger-Desktop\launcher\configure-db.bat"; DestDir: "{app}\launcher"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\QuantDinger Desktop"; Filename: "{app}\launcher\QuantDinger.bat"
Name: "{autodesktop}\QuantDinger Desktop"; Filename: "{app}\launcher\QuantDinger.bat"; Tasks: desktopicon
Name: "{autoprograms}\QuantDinger Desktop\Uninstall"; Filename: "{uninstallexe}"

[Run]
; Install PostgreSQL silently (only if user chose to install)
Filename: "{tmp}\postgresql-installer.exe"; Parameters: "--mode unattended --prefix ""{app}\database\postgresql"" --datadir ""{app}\database\postgresql\data"" --superpassword quantdinger123"; Flags: runhidden waituntilterminated; Tasks: installpostgres

; Initialize database (only if installed new PostgreSQL)
Filename: "{app}\database\postgresql\bin\createdb.exe"; Parameters: "-U postgres -h localhost quantdinger"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated; Tasks: installpostgres

; Configure database connection based on user choice
Filename: "{app}\launcher\configure-db.bat"; Parameters: "auto-detect"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated

; Create desktop shortcut
Filename: "{app}\launcher\QuantDinger.bat"; Description: "{cm:LaunchProgram,QuantDinger Desktop}"; Flags: nowait postinstall skipifsilent

[Code]
// ============================================================
// Custom Pascal Script for PostgreSQL Detection and Configuration
// ============================================================

var
  PostgresPage: TInputQueryWizardPage;
  HasPostgresInstalled: Boolean;
  DetectedPgPath: String;
  UseExistingPostgres: Boolean;

// Check if PostgreSQL is installed on the system
function IsPostgresInstalled(): Boolean;
var
  RegKey: String;
  PgPath: String;
  ResultCode: Integer;
begin
  Result := False;
  
  // Method 1: Check Windows Registry for official PostgreSQL installation
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\PostgreSQL\Installations\postgresql-x64', 'Base Directory', PgPath) then
  begin
    if FileExists(PgPath + '\bin\psql.exe') then
    begin
      DetectedPgPath := PgPath;
      Result := True;
      Log('PostgreSQL detected in registry: ' + PgPath);
      Exit;
    end;
  end;
  
  // Method 2: Check if psql is in PATH
  if Exec('where', 'psql', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode = 0 then
    begin
      DetectedPgPath := ''; // Will use PATH
      Result := True;
      Log('PostgreSQL detected in PATH');
      Exit;
    end;
  end;
  
  // Method 3: Check common installation directories
  if DirExists('C:\Program Files\PostgreSQL') then
  begin
    // Try to find versioned directory
    if DirExists('C:\Program Files\PostgreSQL\15') then
    begin
      if FileExists('C:\Program Files\PostgreSQL\15\bin\psql.exe') then
      begin
        DetectedPgPath := 'C:\Program Files\PostgreSQL\15';
        Result := True;
        Log('PostgreSQL detected in C:\Program Files\PostgreSQL\15');
        Exit;
      end;
    end;
    if DirExists('C:\Program Files\PostgreSQL\14') then
    begin
      if FileExists('C:\Program Files\PostgreSQL\14\bin\psql.exe') then
      begin
        DetectedPgPath := 'C:\Program Files\PostgreSQL\14';
        Result := True;
        Log('PostgreSQL detected in C:\Program Files\PostgreSQL\14');
        Exit;
      end;
    end;
  end;
end;

procedure InitializeWizard;
begin
  // Detect PostgreSQL during initialization
  HasPostgresInstalled := IsPostgresInstalled();
  
  if HasPostgresInstalled then
    Log('PostgreSQL detected on system')
  else
    Log('PostgreSQL not detected');
  
  // If PostgreSQL is detected, create a custom page for connection info
  if HasPostgresInstalled then
  begin
    PostgresPage := CreateInputQueryPage(wpSelectTasks,
      'PostgreSQL 数据库配置',
      '检测到系统中已安装 PostgreSQL，请配置连接信息',
      '请输入数据库连接参数。如果使用默认值，请直接点击下一步。');
    
    PostgresPage.Add('主机地址:', False);
    PostgresPage.Add('端口:', False);
    PostgresPage.Add('用户名:', False);
    PostgresPage.Add('密码:', True);
    PostgresPage.Add('数据库名:', False);
    
    // Set default values
    PostgresPage.Values[0] := 'localhost';
    PostgresPage.Values[1] := '5432';
    PostgresPage.Values[2] := 'postgres';
    PostgresPage.Values[3] := '';
    PostgresPage.Values[4] := 'quantdinger';
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  // Validate password if using existing PostgreSQL
  if HasPostgresInstalled and (CurPageID = PostgresPage.ID) then
  begin
    if PostgresPage.Values[3] = '' then
    begin
      MsgBox('请输入数据库密码！' + #13#10 + '如果不确定密码，请联系数据库管理员。', mbError, MB_OK);
      Result := False;
      Exit;
    end;
    
    // Save configuration to file for later use by launcher
    SaveStringToFile(ExpandConstant('{app}\launcher\db-config.ini'),
      '[database]' + #13#10 +
      'host=' + PostgresPage.Values[0] + #13#10 +
      'port=' + PostgresPage.Values[1] + #13#10 +
      'user=' + PostgresPage.Values[2] + #13#10 +
      'password=' + PostgresPage.Values[3] + #13#10 +
      'dbname=' + PostgresPage.Values[4] + #13#10 +
      'type=external' + #13#10,
      False);
    
    Log('Database configuration saved for external PostgreSQL');
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  
  // Skip PostgreSQL config page if not detected or if user chose to install new one
  if HasPostgresInstalled and (PageID = PostgresPage.ID) then
  begin
    // Show the page only if user selected "use existing"
    if not WizardIsTaskSelected('useexistingpostgres') then
    begin
      Result := True;
      Log('Skipping PostgreSQL config page - user chose to install new database');
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  // Auto-select task based on detection
  if CurPageID = wpSelectTasks then
  begin
    if HasPostgresInstalled then
    begin
      // If PostgreSQL exists, default to using it
      WizardSelectTasks('useexistingpostgres');
      Log('Auto-selected: Use existing PostgreSQL');
    end
    else
    begin
      // If no PostgreSQL, must install new one
      WizardSelectTasks('installpostgres');
      Log('Auto-selected: Install new PostgreSQL');
    end;
  end;
end;
