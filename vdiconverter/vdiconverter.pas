program vdiconverter;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX}
  cthreads, {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  SysUtils,
  Dialogs, convert_trd;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='VDIConverter v0.3';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
