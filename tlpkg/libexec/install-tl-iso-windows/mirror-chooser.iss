[Setup]
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
AppName=TeX Live
AppVerName=TeX Live 2042
AppPublisherURL=https://tug.org/texlive
WizardStyle=modern
DefaultDirName={autopf}
DisableDirPage=yes
Uninstallable=no
OutputBaseFilename=texlive2042
Compression=zip/9
SolidCompression=yes

[CustomMessages]
TLCaption=TeX Live ISO Installer Launcher
TLDescription=Gateway to the installation of TeX Live
TLMessage=This setup wizard will launch the TeX Live installer from the bundled official ISO image file. Follow the instructions in the installer.%n%nNo Internet access is needed during installation.

[Files] 
Source: "{tmp}\texlive2042.iso.md5"; Flags: dontcopy external
Source: "start-installer.ps1"; DestDir: "{tmp}"

[Run]
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -File ""{tmp}\start-installer.ps1"" {tmp}\texlive2042.iso"; \
  WorkingDir: {tmp}; Flags: runhidden

[Code] 
var
  OutputMsgWizardPage: TOutputMsgWizardPage;
  DownloadPage: TDownloadWizardPage;
  MirrorPage: TInputOptionWizardPage;
  Url: String;
 
procedure InitializeWizard();
begin
  OutputMsgWizardPage := CreateOutputMsgPage(wpWelcome, ExpandConstant('{cm:TLCaption}'), ExpandConstant('{cm:TLDescription}'), ExpandConstant('{cm:TLMessage}'));
  
  MirrorPage := CreateInputOptionPage(OutputMsgWizardPage.ID,
    'Repository for the ISO image file', 'Closer is better!',
    'Please select a nearby repository to download the ISO image from, then click Next.',
    True, True);
  MirrorPage.Add('Automatic (mirrors.ctan.org)');
  MirrorPage.Add('South Africa (mirror.ufs.ac.za)');
  MirrorPage.Add('South Africa (za.mirrors.cicku.me)');
    
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
  DownloadPage.ShowBaseNameInsteadOfUrl := False;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Error: String;
begin
  if CurPageID = MirrorPage.ID then
  begin
    case MirrorPage.SelectedValueIndex of
      0: Url := 'https://mirrors.ctan.org';
      1: Url := 'https://mirror.ufs.ac.za/ctan';
      2: Url := 'https://za.mirrors.cicku.me/ctan';
    end;
  end;
  if CurPageID = wpReady then
  begin
    DownloadPage.Clear;
    DownloadPage.Add(
      Url + '/systems/texlive/Images/texlive2026.iso.md5',
      'texlive2026.iso.md5', '');
    DownloadPage.Show;
    try
      try
        DownloadPage.Download; // This downloads the files to {tmp}
        Result := True;
      except
        if DownloadPage.AbortedByUser then
          Log('Aborted by user.')
        else begin
          Error := Format('%s: %s', [DownloadPage.LastBaseNameOrUrl, GetExceptionMessage]);
          SuppressibleMsgBox(AddPeriod(Error), mbCriticalError, MB_OK, IDOK);
        end;
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end;
  Result := True;
end;
