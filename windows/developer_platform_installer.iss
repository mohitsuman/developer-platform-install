; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define AppName "Red Hat Developer Platform"
#define AppVersion "1.0"
#define AppPublisher "Red Hat"
#define AppURL "http://www.redhat.com/"

#include <idp.iss>

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{C72362A0-26F3-49D6-8ED1-8214644255DD}
AppName={#AppName}
AppVersion={#AppVersion}
;AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
CreateAppDir=yes
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
OutputBaseFilename=developer_platform
Compression=lzma
SolidCompression=yes
;WizardSmallImageFile=blank.bmp
BackColor=clWhite
BackSolid=yes
DisableWelcomePage=yes
DisableDirPage=no
DisableReadyPage=no
ExtraDiskSpaceRequired=1048576

[Files]

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Registry]
Root: HKLM; Subkey: "Software\Red Hat";            Flags: uninsdeletekeyifempty
Root: HKLM; Subkey: "Software\Red Hat\{#AppName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Red Hat\{#AppName}"; ValueType: string; ValueName: "InstallDir"; ValueData: "{app}"

[Code]

type
  ComponentEntry = record
    Container: TPanel;
    Content: TPanel;
  end;
  BcLabelArray = array[1..4] of TLabel;

var 
  // Page IDs
  AuthPageID, ComponentPageID, DownloadPageID, GetStartedPageID, InstallPageID : Integer; 

  AuthLabel: TNewStaticText;

  // "Standard" blue color used throughout the installer
  StdColor: TColor;  

  // Breadcrumb image
  Breadcrumbs: TBitmapImage; 

  // Breadcrumb labels, we store references to these in an array for convenience
  BreadcrumbLabel: BcLabelArray; 

  // Flag indicating whether the user has authenticated successfully
  IsAuthenticated: Boolean;

// Converts a color String in the format '$rrggbb' to a TColor value
function StringToColor(Color: String): TColor;
var
    RR, GG, BB: String;
    Dec: Integer;
begin
    { Change string Color from $RRGGBB to $BBGGRR and then convert to TColor }
    if((Length(Color) <> 7) or (Color[1] <> '$')) then
        Result := $000000
    else
    begin
        RR := Color[2] + Color[3];
        GG := Color[4] + Color[5];
        BB := Color[6] + Color[7];
        Dec := StrToInt('$' + BB + GG + RR);
        Result := TColor(Dec);
    end;
end;

procedure LoginButtonOnClick(Sender: TObject);
var
  Page: TWizardPage;
  Button: TNewButton;
begin
  Page := PageFromID(AuthPageID);

  // Set the flag to true for now
  IsAuthenticated := True;

  // Display the 'authentication successful' message
  AuthLabel.Visible := IsAuthenticated;

  // Simulate a click of the Next button
  WizardForm.NextButton.OnClick(nil);
end;

procedure ForgotLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', 'http://www.redhat.com/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

// Create the welcome page - this page allows the user to log in to their Red Hat account
function createWelcomePage: TWizardPage;
var
  Page: TWizardPage;
  LoginLabel: TNewStaticText;
  ForgotLabel: TNewStaticText;
  Button: TNewButton;
  Edit: TNewEdit;
  PasswordEdit: TPasswordEdit;
begin
  Page := CreateCustomPage(wpWelcome, '', '');

  // The page has a unique id, we store it in the AuthPageID variable here so that we can refer to it elsewhere
  AuthPageID := Page.ID;

  // Create the label for the user's login name
  LoginLabel := TNewStaticText.Create(Page);
  LoginLabel.Caption := 'Log in to your Red Hat account';
  LoginLabel.Parent := Page.Surface;
  LoginLabel.Color := clWhite;
  LoginLabel.Font.Style := LoginLabel.Font.Style + [fsBold];
  LoginLabel.Font.Size := 10;
  
  // Create an edit control for the user's login name
  Edit := TNewEdit.Create(Page);
  Edit.Top := LoginLabel.Top + LoginLabel.Height + ScaleY(8);
  Edit.Width := Page.SurfaceWidth div 2 - ScaleX(8);
  Edit.Text := 'Red Hat Login';
  Edit.Parent := Page.Surface;

  // Create a password control for the user's password
  PasswordEdit := TPasswordEdit.Create(Page);
  PasswordEdit.Top := Edit.Top + Edit.Height + ScaleY(8);
  PasswordEdit.Width := Edit.Width;
  PasswordEdit.Text := 'Password';
  PasswordEdit.Parent := Page.Surface;

  // Create the 'LOG IN' button
  Button := TNewButton.Create(Page);
  Button.Width := ScaleX(75);
  Button.Height := ScaleY(23);
  Button.Caption := 'LOG IN';
  Button.Top := PasswordEdit.Top + PasswordEdit.Height + ScaleY(8);
  Button.OnClick := @LoginButtonOnClick;
  Button.Parent := Page.Surface;

  // Create the 'forgot password' link
  ForgotLabel := TNewStaticText.Create(Page);
  ForgotLabel.Caption := 'Forgot your login or password?';
  ForgotLabel.Cursor := crHand;
  ForgotLabel.OnClick := @ForgotLabelOnClick;
  ForgotLabel.Parent := Page.Surface;
  ForgotLabel.Color := clWhite;
  { Alter Font *after* setting Parent so the correct defaults are inherited first }
  //ForgotLabel.Font.Style := URLLabel.Font.Style + [fsUnderline];
  ForgotLabel.Font.Style := ForgotLabel.Font.Style + [fsBold];
  ForgotLabel.Font.Color := StdColor;
  ForgotLabel.Top := Button.Top + ((Button.Height - ForgotLabel.Height) / 2) + ScaleY(0);
  ForgotLabel.Left := Button.Left + Button.Width + ScaleX(20);

  // Create the 'auth successful' label.  We set its visibility to false at first, then display it later when 
  // auth is successful
  AuthLabel := TNewStaticText.Create(Page);
  AuthLabel.Caption := 'Authentication Successful';
  AuthLabel.Parent := Page.Surface;
  AuthLabel.Color := clWhite;
  AuthLabel.Font.Color := clGreen;
  AuthLabel.Visible := False;
  AuthLabel.Top := Button.Top + Button.Height + ScaleY(8);

  result := Page;
end;

function createComponentEntry(Page: TWizardPage; Top: integer; ComponentName: String; ComponentVersion: String; 
    ComponentDescription: String; ContentHeight: integer): ComponentEntry;
var
  Panel, PanelHeader, PanelContent: TPanel;
  NameLabel, VersionLabel, DescriptionLabel: TNewStaticText;
begin
  Panel := TPanel.Create(Page);
  Panel.Parent := Page.Surface;
  Panel.Top := Top;
  Panel.BorderStyle := bsNone;
  Panel.Color := StringToColor('$d3d3d3');
  Panel.Width := 840;
  Panel.Height := ContentHeight + 40;
  Panel.BevelInner := bvNone;
  Panel.BevelOuter := bvNone;
  
  PanelHeader := TPanel.Create(Page);
  PanelHeader.Parent := Panel;
  PanelHeader.Top := 1;
  PanelHeader.Left := 1;
  PanelHeader.BorderStyle := bsNone;
  PanelHeader.Color := StringToColor('$f6f6f6');
  PanelHeader.Width := 838;
  PanelHeader.Height := 39;
  PanelHeader.BevelInner := bvNone;
  PanelHeader.BevelOuter := bvNone;

  NameLabel := TNewStaticText.Create(Page);
  NameLabel.Caption := ComponentName;
  NameLabel.Parent := PanelHeader;
  NameLabel.Left := 12;
  NameLabel.Top := 2;
  NameLabel.Font.Size := 11;
  NameLabel.Font.Color := StringToColor('$cc0000');
  NameLabel.Font.Style := NameLabel.Font.Style + [fsBold];

  VersionLabel := TNewStaticText.Create(Page);
  VersionLabel.Caption := ComponentVersion;
  VersionLabel.Parent := PanelHeader;
  VersionLabel.Left := NameLabel.Left + NameLabel.Width + ScaleX(4);
  VersionLabel.Top := 8;
  VersionLabel.Font.Size := 7;
  VersionLabel.Font.Color := StringToColor('$797979');

  DescriptionLabel := TNewStaticText.Create(Page);
  DescriptionLabel.Caption := ComponentDescription;
  DescriptionLabel.Parent := PanelHeader;
  DescriptionLabel.Left := 12;
  DescriptionLabel.Top := NameLabel.Top + NameLabel.Height + ScaleY(2);
  DescriptionLabel.Font.Size := 7;
  DescriptionLabel.Font.Color := StringToColor('$797979');

  PanelContent := TPanel.Create(Page);
  PanelContent.Parent := Panel;
  PanelContent.Top := 41;
  PanelContent.Left := 1;
  PanelContent.BorderStyle := bsNone;
  PanelContent.Color := clWhite;
  PanelContent.Width := 838;
  PanelContent.Height := ContentHeight - 2;
  PanelContent.BevelInner := bvNone;
  PanelContent.BevelOuter := bvNone;  

  Result.Container := Panel;
  Result.Content := PanelContent;
end;

// Create the welcome page - this page allows the user to log in to their Red Hat account
function createComponentPage: TWizardPage;
var
  Page: TWizardPage;
  HeadingLabel: TNewStaticText;
  Entry: ComponentEntry;
begin
  Page := CreateCustomPage(AuthPageID, '', '');

  // The page has a unique id, we store it in the AuthPageID variable here so that we can refer to it elsewhere
  ComponentPageID := Page.ID;

  // Create the heading label for the component selection list
  HeadingLabel := TNewStaticText.Create(Page);
  HeadingLabel.Caption := 'Select the products and tools you want to install.';
  HeadingLabel.Parent := Page.Surface;
  HeadingLabel.Font.Size := 8;

  Entry := createComponentEntry(Page, HeadingLabel.Top + HeadingLabel.Height + ScaleY(8), 
    'RED HAT ENTERPRISE LINUX ATOMIC PLATFORM', 'v2.0', 
    'Host Linux containers in a minimal version of Red Hat Enterprise Linux.', 80);

  Entry := createComponentEntry(Page, Entry.Container.Top + Entry.Container.Height + ScaleY(8), 
    'RED HAT JBOSS DEVELOPER STUDIO', 'v9.0', 
    'An IDE with tooling that will help you easily code, test, and deploy your projects.', 60);

  Entry := createComponentEntry(Page, Entry.Container.Top + Entry.Container.Height + ScaleY(8), 
    'RED HAT OPENSHIFT ENTERPRISE', 'v3.0', 
    'DevOps tooling that helps you easily build and deploy your projects in a PaaS environment.', 40);
end;

// Create the Get Started page
function createGetStartedPage: TWizardPage;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(ComponentPageID, '', '');

  // The page has a unique id, we store it in the AuthPageID variable here so that we can refer to it elsewhere
  GetStartedPageID := Page.ID;
end;

procedure CreateWizardPages;
begin
  createWelcomePage;
  createComponentPage;
  createGetStartedPage;       
end;

procedure activateDownloadForm(Page: TWizardPage);
begin
   idpFormActivate(Page);
   MsgBox('Downloads complete', mbInformation, MB_OK);

   // TODO perform installs next
end;

function createDownloadForm(PreviousPageId: Integer): Integer;
begin
    IDPForm.Page := CreateCustomPage(PreviousPageId, ExpandConstant('{cm:IDP_FormCaption}'), ExpandConstant('{cm:IDP_FormDescription}'));

    IDPForm.TotalProgressBar := TNewProgressBar.Create(IDPForm.Page);
    with IDPForm.TotalProgressBar do
    begin
        Parent := IDPForm.Page.Surface;
        Left := ScaleX(0);
        Top := ScaleY(16);
        Width := ScaleX(410);
        Height := ScaleY(20);
        Min := 0;
        Max := 100;
    end;

    IDPForm.TotalProgressLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.TotalProgressLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_TotalProgress}');
        Left := ScaleX(0);
        Top := ScaleY(0);
        Width := ScaleX(200);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 1;
    end;

    IDPForm.CurrentFileLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.CurrentFileLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_CurrentFile}');
        Left := ScaleX(0);
        Top := ScaleY(48);
        Width := ScaleX(200);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 2;
    end;

    IDPForm.FileProgressBar := TNewProgressBar.Create(IDPForm.Page);
    with IDPForm.FileProgressBar do
    begin
        Parent := IDPForm.Page.Surface;
        Left := ScaleX(0);
        Top := ScaleY(64);
        Width := ScaleX(410);
        Height := ScaleY(20);
        Min := 0;
        Max := 100;
    end;

    IDPForm.TotalDownloaded := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.TotalDownloaded do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(290);
        Top := ScaleY(0);
        Width := ScaleX(120);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 4;
    end;

    IDPForm.FileDownloaded := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.FileDownloaded do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(290);
        Top := ScaleY(48);
        Width := ScaleX(120);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 5;
    end;

    IDPForm.FileNameLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.FileNameLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_File}');
        Left := ScaleX(0);
        Top := ScaleY(100);
        Width := ScaleX(116);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 6;
    end;

    IDPForm.SpeedLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.SpeedLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_Speed}');
        Left := ScaleX(0);
        Top := ScaleY(116);
        Width := ScaleX(116);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 7;
    end;

    IDPForm.StatusLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.StatusLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_Status}');
        Left := ScaleX(0);
        Top := ScaleY(132);
        Width := ScaleX(116);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 8;
    end;

    IDPForm.ElapsedTimeLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.ElapsedTimeLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_ElapsedTime}');
        Left := ScaleX(0);
        Top := ScaleY(148);
        Width := ScaleX(116);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 9;
    end;

    IDPForm.RemainingTimeLabel := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.RemainingTimeLabel do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_RemainingTime}');
        Left := ScaleX(0);
        Top := ScaleY(164);
        Width := ScaleX(116);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 10;
    end;

    IDPForm.FileName := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.FileName do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(120);
        Top := ScaleY(100);
        Width := ScaleX(280);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 11;
    end;

    IDPForm.Speed := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.Speed do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(120);
        Top := ScaleY(116);
        Width := ScaleX(280);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 12;
    end;

    IDPForm.Status := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.Status do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(120);
        Top := ScaleY(132);
        Width := ScaleX(280);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 13;
    end;

    IDPForm.ElapsedTime := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.ElapsedTime do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(120);
        Top := ScaleY(148);
        Width := ScaleX(280);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 14;
    end;

    IDPForm.RemainingTime := TNewStaticText.Create(IDPForm.Page);
    with IDPForm.RemainingTime do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := '';
        Left := ScaleX(120);
        Top := ScaleY(164);
        Width := ScaleX(280);
        Height := ScaleY(14);
        AutoSize := False;
        TabOrder := 15;
    end;

    IDPForm.DetailsButton := TNewButton.Create(IDPForm.Page);
    with IDPForm.DetailsButton do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('{cm:IDP_DetailsButton}');
        Left := ScaleX(336);
        Top := ScaleY(184);
        Width := ScaleX(75);
        Height := ScaleY(23);
        TabOrder := 16;
        OnClick := @idpDetailsButtonClick;
    end;        
    
    IDPForm.InvisibleButton := TNewButton.Create(IDPForm.Page);
    with IDPForm.InvisibleButton do
    begin
        Parent := IDPForm.Page.Surface;
        Caption := ExpandConstant('You must not see this button');
        Left := ScaleX(0);
        Top := ScaleY(0);
        Width := ScaleX(10);
        Height := ScaleY(10);
        TabOrder := 17;
        Visible := False;
        OnClick := @idpReportErrorHelper;
    end;
  
    with IDPForm.Page do
    begin
        OnActivate          := @idpFormActivate;
        OnShouldSkipPage    := @idpShouldSkipPage;
        OnBackButtonClick   := @idpBackButtonClick;
        OnNextButtonClick   := @idpNextButtonClick;
        OnCancelButtonClick := @idpCancelButtonClick;
    end;
  
    Result := IDPForm.Page.ID;
end;

procedure CustomWpInstallingPage;
begin
  InstallPageID := CreateCustomPage(wpReady, '', '');


  // Render the page

  InstallPage.Surface.Show;
  InstallPage.Surface.Update;
end;

procedure SelectBreadcrumb(Index: Integer);
var
  I: Integer;
  ItemColor: TColor;
begin
  for I := 1 to 4 do
  begin
    if (I = Index) then
      begin     
        ItemColor := StdColor;
        BreadcrumbLabel[I].Font.Style := BreadcrumbLabel[I].Font.Style + [fsBold];
      end
    else
      begin
        ItemColor := StringToColor('$cccccc');
        BreadcrumbLabel[I].Font.Style := BreadcrumbLabel[I].Font.Style - [fsBold];
      end;

    BreadcrumbLabel[I].Font.Color := ItemColor;
    BreadcrumbLabel[I].Width := 120;
    BreadcrumbLabel[I].Alignment := taCenter;

    with Breadcrumbs.Bitmap.Canvas do
    begin
      Brush.Color := ItemColor;
      Brush.Style := bsSolid;
      Pen.Color := ItemColor;;
      Ellipse(BreadcrumbLabel[I].Left + 54, 22, BreadcrumbLabel[I].Left + 64, 12);
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = AuthPageID) then 
  begin
    SelectBreadcrumb(1);
    WizardForm.NextButton.Visible := False;
  end else if (CurPageID = ComponentPageID) then
  begin
    SelectBreadcrumb(2);    
  end else if (CurPageID = DownloadPageID) then
  begin
    SelectBreadcrumb(3);
    WizardForm.NextButton.Visible := False;
  end else if (CurPageID = GetStartedPageID) then
  begin
    SelectBreadcrumb(4);
    WizardForm.NextButton.Visible := False;
    WizardForm.BackButton.Visible := False;
  end;

  if (CurPageID = wpInstalling) then
  begin
    CustomWpInstallingPage();
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ErrorCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    ShellExec('', 'msiexec', ExpandConstant('/i {tmp}\zulu1.8.0_51-8.8.0.3-win64.msi /passive /norestart /log {app}\cache\zulu_install_log.txt'), 
        '', SW_SHOW, ewNoWait, ErrorCode);
  end;

end;

procedure CreateBreadcrumbLabel(Index: Integer; Caption: String);
begin
  BreadcrumbLabel[Index] := TLabel.Create(WizardForm.MainPanel);
  BreadcrumbLabel[Index].Caption := Caption;
  BreadcrumbLabel[Index].Parent := WizardForm.MainPanel;
  BreadcrumbLabel[Index].Font.Color := StringToColor('$cccccc');
  BreadcrumbLabel[Index].Font.Size := 8;
  BreadcrumbLabel[Index].Top := 24;
  BreadcrumbLabel[Index].Left := 36 + ((Index - 1) * 120);
  BreadcrumbLabel[Index].Width := 120;
  BreadcrumbLabel[Index].Alignment := taCenter;
end;             

procedure InitializeWizard();
var
  BackgroundBitmapImage: TBitmapImage;
  BackgroundBitmapText: TNewStaticText;
  BitmapFileName: String;
begin
  StdColor := StringToColor('$0093d9');

  { Custom wizard pages }

  WizardForm.PageNameLabel.Visible := False;
  WizardForm.PageDescriptionLabel.Visible := False;

  WizardForm.OuterNotebook.Width := 880;
  WizardForm.OuterNotebook.Height := 460;

  WizardForm.InnerNotebook.Width := 880;
  WizardForm.InnerNotebook.Height := 460;

  // Set the width of the top panel
  WizardForm.MainPanel.Width := 920;

  WizardForm.WizardSmallBitmapImage.Visible := false;

  Breadcrumbs := TBitmapImage.Create(WizardForm.MainPanel);
  Breadcrumbs.Parent := WizardForm.MainPanel;
  Breadcrumbs.Top := 0;
  Breadcrumbs.Left := 0;
  Breadcrumbs.Width := 600;
  Breadcrumbs.Height := 50;
  Breadcrumbs.AutoSize := True;

  Breadcrumbs.Bitmap.Height := 50;
  Breadcrumbs.Bitmap.Width := 600;

  with Breadcrumbs.Bitmap.Canvas do
  begin
    Pen.Color := StringToColor('$cccccc');
    MoveTo(1, 16);
    LineTo(460,16);
  end;

  // Create the breadcrumb labels
  CreateBreadcrumbLabel(1, 'Install Setup');
  CreateBreadcrumbLabel(2, 'Confirmation');
  CreateBreadcrumbLabel(3, 'Download && Install');
  CreateBreadcrumbLabel(4, 'Get Started');

  WizardForm.BorderStyle := bsSingle;
  WizardForm.Color := clWhite;

  // These lines change the width and height of the wizard window, but components need to be repositioned
  WizardForm.Width := 940;
  WizardForm.Height := 565;
  WizardForm.Position := poScreenCenter;

  // Let's just hide the cancel button, if the user wishes to cancel they can just close the installer window
  WizardForm.CancelButton.Visible := False;
  //WizardForm.CancelButton.Top := 500;
  //WizardForm.CancelButton.Left := 32;

  WizardForm.NextButton.Top := 500;
  WizardForm.NextButton.Left := 840;

  WizardForm.BackButton.Top := 500;
  WizardForm.BackButton.Left := 32;

  WizardForm.Bevel.Visible := False;
  WizardForm.Bevel1.Visible := False;

  // Sets the background color of the inner panel to white
  WizardForm.InnerPage.Color := clWhite;

  CreateWizardPages;

  // Show details by default
  idpSetOption('DetailedMode', '1');

  // Hide the 'Details' button
  idpSetOption('DetailsButton', '0');

  idpSetOption('Referer', 'http://www.azulsystems.com/products/zulu/downloads');
  idpAddFile('http://cdn.azulsystems.com/zulu/2015-07-8.8-bin/zulu1.8.0_51-8.8.0.3-win64.msi', ExpandConstant('{tmp}\zulu1.8.0_51-8.8.0.3-win64.msi'));

  //idpAddFile('http://download.virtualbox.org/virtualbox/5.0.2/VirtualBox-5.0.2-102096-Win.exe', 'VirtualBox');
  //idpAddFile('https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.msi', 'Vagrant');

  idpDownloadAfter(ComponentPageID);



  DownloadPageID := createDownloadForm(ComponentPageID);

  idpConnectControls;
  idpInitMessages;
end;


