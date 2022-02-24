unit convert_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms;

type
  StartConvert = class(TThread)
  private

    { Private declarations }
  protected
  var
    Result: TStringList;

    procedure Execute; override;

    procedure ShowLog;
    procedure StartProgress;
    procedure StopProgress;

  end;

implementation

uses Unit1;

{ TRD }

procedure StartConvert.Execute;
var
  ExProcess: TProcess;
begin
  try //Вывод лога и прогресса
    Synchronize(@StartProgress);

    FreeOnTerminate := True; //Уничтожить по завершении
    Result := TStringList.Create;

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);

    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);

    ExProcess.Options := [poUsePipes, poStderrToOutPut];
    //, poWaitOnExit (синхронный вывод)

    ExProcess.Execute;

    //Выводим лог динамически
    while ExProcess.Running do
    begin
      Result.LoadFromStream(ExProcess.Output);

      //Выводим лог
      Result.Text := Trim(Result.Text);

      if Result.Count <> 0 then
        Synchronize(@ShowLog);
    end;

  finally
    Synchronize(@StopProgress);
    //Для взаимного исключения выполнения команд и отображения списков Images/Containers/DockerCmd
    Result.Free;
    ExProcess.Free;
    Terminate;
  end;
end;

{ БЛОК ОТОБРАЖЕНИЯ ЛОГА }

//Старт индикатора
procedure StartConvert.StartProgress;
begin
  with MainForm do
  begin
    Application.ProcessMessages;
    TARBtn.Enabled := False;
    SQFSBtn.Enabled := False;
  end;
end;

//Стоп индикатора
procedure StartConvert.StopProgress;
begin
  with MainForm do
  begin
    Application.ProcessMessages;
    TARBtn.Enabled := True;
    SQFSBtn.Enabled := True;
  end;
end;

//Вывод лога
procedure StartConvert.ShowLog;
var
  i: integer;
begin
  //Вывод построчно
  for i := 0 to Result.Count - 1 do
    MainForm.LogMemo.Lines.Append(Result[i]);

  //Вывод пачками
  // MainForm.LogMemo.Lines.Assign(Result);

  //Курсор в конец LogMemo
  MainForm.LogMemo.SelStart := Length(MainForm.LogMemo.Lines.Text);
end;

end.
