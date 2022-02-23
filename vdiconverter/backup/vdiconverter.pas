program vdiconverter;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  SysUtils,
  Dialogs, convert_trd;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='VDI-Converter v0.2';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
