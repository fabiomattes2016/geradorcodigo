unit uprincipal;

{$mode objfpc}{$H+}

interface

uses
      Classes, SysUtils, db, BufDataset, Forms, Controls, Graphics, Dialogs,
			ExtCtrls, Buttons, StdCtrls, DBGrids, DBCtrls, ZConnection, ZDataset,
			SynEdit, SynHighlighterPas;

type

			{ TfrmPrincipal }

      TfrmPrincipal = class(TForm)
						btnGerarClasses: TBitBtn;
						btnGerarMetodos: TBitBtn;
						btnSair: TBitBtn;
						bufTemp: TBufDataset;
						chkDbChavePrimaria: TDBCheckBox;
						chkDbCampoGrid: TDBCheckBox;
						dsBufTemp: TDataSource;
						dsBancos: TDataSource;
						dsTabelas: TDataSource;
						dsCampos: TDataSource;
						edtTraducao: TDBEdit;
						dblkbBancoDados: TDBLookupComboBox;
						dblkpTabela: TDBLookupComboBox;
						dbnControle: TDBNavigator;
						grdCampos: TDBGrid;
						edtNomeDaClasse: TEdit;
						edtTipoDaClasse: TEdit;
						Label1: TLabel;
						Label2: TLabel;
						lblSelecioneBanco: TLabel;
						lblSelecioneTabela: TLabel;
						lblNomeClasse: TLabel;
						lblSelecioneTabela1: TLabel;
						lblTipoDaClasse: TLabel;
						pnlGrid: TPanel;
						pnlControles: TPanel;
						pnlCentro: TPanel;
						pnlEsquerdo: TPanel;
						pnlBotoes: TPanel;
						synCodigo: TSynEdit;
						synPascal: TSynPasSyn;
						conDatabase: TZConnection;
						qryBancos: TZQuery;
						qryTabelas: TZQuery;
						qryCampos: TZQuery;
						procedure btnSairClick(Sender: TObject);
						procedure dblkbBancoDadosExit(Sender: TObject);
						procedure FormShow(Sender: TObject);
      private

      public

      end;

var
      frmPrincipal: TfrmPrincipal;

implementation

{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.dblkbBancoDadosExit(Sender: TObject);
begin
  if (TDBLookupComboBox(Sender).KeyValue=Null) or (TDBLookupComboBox(Sender).KeyValue='') then
    Exit;

  try
    qryTabelas.Close;
    qryTabelas.SQL.Clear;
    qryTabelas.SQL.Add('SELECT table_name FROM information_schema.tables WHERE table_schema='+QuotedStr(TDBLookupComboBox(Sender).KeyValue));
    qryTabelas.Open;
    dblkpTabela.KeyValue:=Nil;
  except
	end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  bufTemp.FieldDefs.Add('NOMECAMPO', ftString, 50);
  bufTemp.FieldDefs.Add('TRADUCAOCAMPO', ftString, 50);
  bufTemp.FieldDefs.Add('TIPOCAMPO', ftString, 50);
  bufTemp.FieldDefs.Add('TAMANHO', ftInteger, 0);
  bufTemp.FieldDefs.Add('CHAVEPRIMARIA', ftBoolean);
  bufTemp.FieldDefs.Add('CAMPONOGRID', ftBoolean);

  bufTemp.CreateDataset;

  conDatabase.Connected:=True;

  qryBancos.SQL.Clear;
  qryBancos.SQL.Add('SHOW databases');
  qryBancos.Open;

  dblkbBancoDados.ListSource:=dsBancos;
  dblkbBancoDados.ListField:='DataBase';
  dblkbBancoDados.KeyField:='DataBase';

  dblkbBancoDados.KeyValue:=qryBancos.FieldByName('Database').AsString;

  chkDbChavePrimaria.DataSource:=dsBufTemp;
  chkDbChavePrimaria.DataField:='CHAVEPRIMARIA';

  chkDbCampoGrid.DataSource:=dsBufTemp;
  chkDbCampoGrid.DataField:='CAMPONOGRID';

  edtTraducao.DataSource:=dsBufTemp;
  edtTraducao.DataField:='TRADUCAOCAMPO';


end;

end.

