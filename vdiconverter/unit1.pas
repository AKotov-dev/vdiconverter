unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Menus, Process, DefaultTranslator,
  Buttons, IniPropStorage;

type

  { TMainForm }

  TMainForm = class(TForm)
    AddBtn1: TSpeedButton;
    Button1: TButton;
    Button6: TButton;
    Label3: TLabel;
    MainFormStorage: TIniPropStorage;
    Label1: TLabel;
    Label2: TLabel;
    LogMemo: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    AddBtn: TSpeedButton;
    SaveDialog1: TSaveDialog;
    TARBtn: TSpeedButton;
    SQFSBtn: TSpeedButton;
    StaticText1: TStaticText;
    procedure AddBtn1Click(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SQFSBtnClick(Sender: TObject);
    procedure TARBtnClick(Sender: TObject);
    procedure KillAll;

  private

  public

  end;

var
  MainForm: TMainForm;

var
  command: string;

implementation

uses convert_trd;

{$R *.lfm}

{ TMainForm }

//Общая процедура запуска команд
procedure TMainForm.KillAll;
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';  //bash или terminal (sakura)
    //   ExProcess.Options := [poWaitOnExit]; //Ждать терминал
    ExProcess.Parameters.Add('-c');  //Не ждать терминал

    ExProcess.Parameters.Add('killall mksquashfs tar');

    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  KillAll;
end;

//Выбор файла vdi
procedure TMainForm.AddBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Label2.Caption := OpenDialog1.FileName;
    TARBtn.Enabled := True;
    SQFSBtn.Enabled := True;
  end;
end;

procedure TMainForm.AddBtn1Click(Sender: TObject);
begin
  KillAll;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  //For Plasma
  MainFormStorage.Restore;
  MainForm.Caption := Application.Title;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Проверяем/создаём рабочий каталог (root)
  if not DirectoryExists(GetUserDir + '.config') then
    MkDir(GetUserDir + '.config');

  //Настройки
  MainFormStorage.IniFileName := GetUserDir + '.config/vdiconverter.conf';
  MainForm.Caption := Application.Title;
end;

procedure TMainForm.SQFSBtnClick(Sender: TObject);
var
  FStartConvert: TThread;
begin
  SaveDialog1.DefaultExt := '*';
  SaveDialog1.Filter := 'Archive (*.sqfs)|*.sqfs';

  if SaveDialog1.Execute then
  begin
    LogMemo.Clear;
    Command := '"' + ExtractFilePath(ParamStr(0)) + 'vdi-converter.sh" "' +
      OpenDialog1.FileName + '" "' + SaveDialog1.FileName + '" ' + 'sqfs';

    FStartConvert := StartConvert.Create(False);
    FStartConvert.Priority := tpNormal;

 {   //Запускаем sfx-creator.sh
    StartProcess('"' + ExtractFilePath(ParamStr(0)) + 'vdi-converter.sh" ' +
      '"' + OpenDialog1.FileName + '" "' + SaveDialog1.FileName +
      '" ' + 'sqfs', 'sakura');

  //Сбрасываем незаконченные процессы tar, mksquashfs и т.д.
  KillAll;}
  end;
end;

procedure TMainForm.TARBtnClick(Sender: TObject);
var
  FStartConvert: TThread;
begin
  SaveDialog1.DefaultExt := '*.tar';
  SaveDialog1.Filter := 'Archive (*.tar)|*.tar';

  if SaveDialog1.Execute then
  begin
    LogMemo.Clear;
    Command := '"' + ExtractFilePath(ParamStr(0)) + 'vdi-converter.sh" "' +
      OpenDialog1.FileName + '" "' + SaveDialog1.FileName + '" ' + 'tar';

    FStartConvert := StartConvert.Create(False);
    FStartConvert.Priority := tpNormal;

    //Запускаем sfx-creator.sh
 {   StartProcess('"' + ExtractFilePath(ParamStr(0)) + 'vdi-converter.sh" ' +
      '"' + OpenDialog1.FileName + '" "' + SaveDialog1.FileName +
      '" ' + 'tar', 'sakura');}

    //Сбрасываем незаконченные процессы tar, mksquashfs и т.д.
    // KillAll;
  end;
end;

end.
