program geradorcodigo;

{$mode objfpc}{$H+}

uses
      {$IFDEF UNIX}{$IFDEF UseCThreads}
      cthreads,
      {$ENDIF}{$ENDIF}
      Interfaces, // this includes the LCL widgetset
      Forms, zcomponent, uprincipal
      { you can add units after this };

{$R *.res}

begin
      RequireDerivedFormResource:=True;
			Application.Title:='Gerador de Código';
      Application.Scaled:=True;
      Application.Initialize;
			Application.CreateForm(TfrmPrincipal, frmPrincipal);
      Application.Run;
end.

