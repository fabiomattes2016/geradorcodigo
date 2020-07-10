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
						Image1: TImage;
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
						procedure btnGerarClassesClick(Sender: TObject);
						procedure btnGerarMetodosClick(Sender: TObject);
            procedure btnSairClick(Sender: TObject);
						procedure dblkbBancoDadosExit(Sender: TObject);
						procedure dblkpTabelaExit(Sender: TObject);
						procedure FormShow(Sender: TObject);
						procedure synCodigoChange(Sender: TObject);
      private
        function RetornaTipoCampo:String;
        function RetornaTipoCampoWithAs:String;
        procedure WhereAndParamsPK;
        procedure AddTransaction;
      public

      end;

var
      frmPrincipal: TfrmPrincipal;

implementation

{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.AddTransaction;
begin
  with synCodigo.Lines do begin
    Add('');
    Add('    try');
    Add('      ConexaoDB.StartTransaction;');
    Add('      Qry.ExecSQL;');
    Add('      ConexaoDB.Commit;');
    Add('    except');
    Add('      ConexaoDB.Rollback;');
    Add('      Result:=False;');
    Add('    end;');
	end;
end;

function TfrmPrincipal.RetornaTipoCampo:String;
begin
  if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='int' then
    result:='Integer'
  else if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bigint' then
    result:='int64'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='varchar') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='longtext') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='char') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='text') then
    result:='String'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='date') then
    result:='TDate'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='timestamp') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='datetime') then
    result:='TDateTime'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='double') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='deciaml') then
    result:='Double'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='tinyint') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bit') then
    result:='Boolean'
  else
    result:='Implentar';
end;

function TfrmPrincipal.RetornaTipoCampoWithAs:String;
begin
  if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='int' then
    result:='AsInteger'
  else if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bigint' then
    result:='AsInteger'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='varchar') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='longtext') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='char') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='text') then
    result:='AsString'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='date') then
    result:='AsDateTime'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='timestamp') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='datetime') then
    result:='AsDateTime'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='double') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='deciaml') then
    result:='AsFloat'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='tinyint') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bit') then
    result:='AsBoolean'
  else
    result:='Implentar';
end;

procedure TfrmPrincipal.WhereAndParamsPK;
var i:Integer;
begin
  with synCodigo.Lines do begin
    i:=0;
    bufTemp.First;

    while not bufTemp.Eof do begin
      if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean) then begin
        if (i=0) then
          Add('        ''    WHERE ' + bufTemp.FieldByName('NOMECAMPO').AsString + '=:' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '');')
        else
          Add('        ''    AND ' + bufTemp.FieldByName('NOMECAMPO').AsString + '=:' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '');');

        inc(i);
			end;

      bufTemp.Next;
		end;

    bufTemp.First;

    while not bufTemp.Eof do begin
      if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean) then begin
        Add('    Qry.ParamsByName(' + QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString) + ').' + RetornaTipoCampoWithAs + ' := Self.F_' + bufTemp.FieldByName('NOMECAMPO').AsString + ';');
			end;

      bufTemp.Next;
		end;
	end;
end;

procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.btnGerarClassesClick(Sender: TObject);
var i:Integer;
begin
  if bufTemp.State in [dsEdit, dsInsert] then
    bufTemp.Post;

  if bufTemp.IsEmpty then begin
    MessageDlg('Não existe campos de tabela definido para a classe', mtWarning, [mbOK], 0);
    edtNomeDaClasse.SetFocus;
    exit;
	end;

  if edtNomeDaClasse.Text=EmptyStr then begin
    MessageDlg('Não existe o nome da classe definida', mtWarning, [mbOK], 0);
    edtNomeDaClasse.SetFocus;
    exit;
	end;

  if edtTipoDaClasse.Text=EmptyStr then begin
    MessageDlg('Não existe o tipo da classe definida', mtWarning, [mbOK], 0);
    edtTipoDaClasse.SetFocus;
    exit;
	end;

  synCodigo.Lines.Clear;

  with synCodigo.Lines do begin
    Add('unit c' + edtNomeDaClasse.Text + ';');
    Add('');
    Add('{$mode objfpc}{$H+}');
    Add('');
    Add('interface');
    Add('');
    Add('uses Classes, ');
    Add('     Controls, ');
    Add('     ExtCtrls, ');
    Add('     Dialogs, ');
    Add('     cBase, ');
    Add('     ZAbstractConnection, ');
    Add('     ZConnection, ');
    Add('     ZAbstractRODataSet, ');
    Add('     ZAbstractDataSet, ');
    Add('     ZDataSet, ');
    Add('     SysUtils, ');
    Add('     uUtils ');
    Add('');
    Add('type ');
    Add('  T' + Copy(edtTipoDaClasse.Text, 1 ,50) + ' = class(TBase)');
    Add('');
    Add('  private');

    bufTemp.First;

    while not bufTemp.Eof do begin
      synCodigo.Lines.Add('    F_' + bufTemp.FieldByName('NomeCampo').AsString + ':' + RetornaTipoCampo + ';');
      bufTemp.Next;
		end;

    Add('  public');
    Add('    constructor Create(aConexao:TZConnection);');
    Add('    destructor Destroy; override;');
    Add('    function Inserir:Boolean;');
    Add('    function Atualizar:Boolean;');
    Add('    function Apagar:Boolean;');
    Add('    function Selecionar(id:String):Boolean;');
    Add('');
    Add('  published');

    bufTemp.First;

    while not bufTemp.Eof do begin
      Add('    property ' + bufTemp.FieldByName('NomeCampo').AsString + ':'
          + RetornaTipoCampo + ' read F_' + bufTemp.FieldByName('NomeCampo').AsString
          + ' write F_' + bufTemp.FieldByName('NomeCampo').AsString + ';');
      bufTemp.Next;
		end;

    Add('');

    with synCodigo.Lines do begin
      Add('');
      Add('end;');
      Add('implementation ');
      Add('');
      Add('{T'+edtTipoDaClasse.Text+'}');

      Add('');
      Add('{$region ''Constructor and Destructor''} ');
      Add('constructor T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Create(aConexao:TZConnection);');
      Add('begin');
      Add('  ConexaoDB:=aConexao;');
      Add('end;');
      Add('');
      Add('destructor T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Destroy;');
      Add('begin');
      Add('  inherited;');
      Add('end;');
      Add('{$endRegion}');
      Add('');

      // Método @Apagar
      Add('{$region ''CRUD''}');

      Add('function T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Apagar: Boolean;');
      Add('var Qry:TZQuery;');
      Add('begin');
      Add('  if MessageNoYes(''Apagar o Registro? '', mtConfirmation) = mrNo then begin');
      Add('    Result:=false');
      Add('    Abort;');
      Add('  end;');
      Add('');
      Add('  try');
      Add('    Result:=true;');
      Add('    Qry:=TZQuery.Create(Nil);');
      Add('    Qry.Connection:=ConexaoDB;');
      Add('    Qry.SQL.Clear;');
      Add('    Qry.SQL.Add(''DELETE FROM ' + dblkpTabela.Text + ''' + ');
      WhereAndParamsPK;
      AddTransaction;
      Add('  finally');
      Add('    if Assigned(Qry) then');
      Add('      FreeAndNil(Qry);');
      Add('  end;');
      Add('end;');

      Add('');

      // Método @Atualizar
      Add('function T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Atualizar: Boolean;');
      Add('var Qry:TZQuery;');
      Add('begin');
      Add('  try');
      Add('    Result:=True');
      Add('    Qry:=TZQuery.Create(Nil);');
      Add('    Qry.Connection:=ConexaoDB');
      Add('    Qry.SQL.Clear');
      Add('    Qry.SQL.Add(''UPDATE ' + dblkpTabela.Text + ''' + ');

      i:=0;

      bufTemp.First;

      while not bufTemp.Eof do begin
        if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean) then begin
          bufTemp.next;
          continue;
				end;

        if (i=0) then
          Add('        ''    SET ' + bufTemp.FieldByName('NOMECAMPO').AsString + '=:' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '' + ')
        else
          Add('        ''       ,' + bufTemp.FieldByName('NOMECAMPO').AsString + '=:' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '');');

        inc(i);

        bufTemp.Next;
			end;

      WhereAndParamsPK;

      bufTemp.First;

      while not bufTemp.Eof do begin
        if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean) then begin
          buftemp.Next;
          continue;
				end;

         Add('    Qry.ParamsByName(' + QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString) + ').' + RetornaTipoCampoWithAs + ' := Self.F_' + bufTemp.FieldByName('NOMECAMPO').AsString + ';');

         bufTemp.Next;
			end;

      AddTransaction;
      Add('  finally');
      Add('    if Assigned(Qry) then');
      Add('      FreeAndNil(Qry);');
      Add('  end;');

      Add('end;');

      Add('');

      // Método @Inserir
      Add('function T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Inserir: Boolean;');
      Add('var Qry:TZQuery;');
      Add('begin');
      Add('  try');
      Add('    Result:=True');
      Add('    Qry:=TZQuery.Create(Nil);');
      Add('    Qry.Connection:=ConexaoDB;');
      Add('    Qry.SQL.Clear;');
      Add('    Qry.SQL.Add(''INSERT INTO ' + dblkpTabela.Text + ' ('' + ');

      i:=0;

      bufTemp.First;

      while not bufTemp.Eof do begin
        if (i=0) then begin
          Add('        ''    ' + bufTemp.FieldByName('NOMECAMPO').AsString + ''' + ');
				end
        else
          Add('        ''   ,' + bufTemp.FieldByName('NOMECAMPO').AsString + ''' + ');

        inc(i);

        bufTemp.Next;
			end;

      Add('        ' + ' '')'');');
      Add('    Qry.SQL.Add('' VALUES ('' + ');

      i:=0;
      bufTemp.First;

      while not bufTemp.Eof do begin
        if (i=0) then begin
          Add('        ''  :' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '' + ');
				end
        else
          Add('        ''  ,:' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '' + ');

        inc(i);

        bufTemp.Next;
			end;
      Add('        ' + ' '')'');');

      bufTemp.First;

      while not bufTemp.Eof do begin
        Add('    Qry.ParamsByName(' + QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString) + ').' + RetornaTipoCampoWithAs + ' := Self.F_' + bufTemp.FieldByName('NOMECAMPO').AsString + ';');
        bufTemp.Next;
			end;

      AddTransaction;
      Add('  finaly');
      Add('    if Assigned(Qry) then');
      Add('      FreeAndNil(Qry);');
      Add('  end;');

      Add('end;');

      Add('');

      // Método @Selecionar
      Add('function T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Selecionar: Boolean;');
      Add('var Qry:TZQuery;');
      Add('begin');
      Add('  try');
      Add('    Qry:=TZQuery.Create(Nil);');
      Add('    Qry.Connection:=ConexaoDB;');
      Add('    Qry.SQL.Clear;');
      Add('    Qry.SQL.Add(''SELECT '' + ');

      i:=0;
      bufTemp.First;

      while not bufTemp.Eof do begin
        if (i=0) then begin
          Add('        ''  ' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '' + ');
				end
        else
          Add('        ''  ,' + bufTemp.FieldByName('NOMECAMPO').AsString + ' '' + ');

        inc(i);

        bufTemp.Next;
			end;

      Add('        '' FROM ' + dblkpTabela.Text + ''' + ');

      WhereAndParamsPK;

      Add('    Qry.Open;');

      bufTemp.First;

      while not bufTemp.Eof do begin
        Add('    Self.F_' + bufTemp.FieldByName('NOMECAMPO').AsString + ' := ' + 'Qry.FieldByName(' + QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString) + ').' + RetornaTipoCampoWithAs + ';');
        bufTemp.Next;
			end;

      Add('  finaly');
      Add('    if Assigned(Qry) then');
      Add('      FreeAndNil(Qry);');
      Add('  end;');
      Add('end;');

      Add('{$endRegion}');
      Add('end.');
		end;
	end;
end;

procedure TfrmPrincipal.btnGerarMetodosClick(Sender: TObject);
var i:Integer;
begin
  if bufTemp.State in [dsEdit, dsInsert] then
    bufTemp.Post;

  if bufTemp.IsEmpty then begin
    MessageDlg('Não existe campos de tabela definido para a classe', mtWarning, [mbOK], 0);
    edtNomeDaClasse.SetFocus;
    exit;
	end;

  if edtNomeDaClasse.Text=EmptyStr then begin
    MessageDlg('Não existe o nome da classe definida', mtWarning, [mbOK], 0);
    edtNomeDaClasse.SetFocus;
    exit;
	end;

  if edtTipoDaClasse.Text=EmptyStr then begin
    MessageDlg('Não existe o tipo da classe definida', mtWarning, [mbOK], 0);
    edtTipoDaClasse.SetFocus;
    exit;
	end;

  synCodigo.Lines.Clear;

  with synCodigo.Lines do begin
    Add('  public');
    Add('    o' + edtTipoDaClasse.text + ':T' + edtTipoDaClasse.Text + ';');
    Add('    function Gravar(aEstadoDoCadastro:TEstadoDoCadastro): Boolean; override;');
    Add('    function Apagar:Boolean; override;');
    Add('    procedure ConfigurarCampos; override;');
    Add('  end;');
    Add('');
    Add('');

    // Método @Configurar Campos
    Add('{$region ''Metodos Override''}');
    Add('procedure T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.ConfigurarCampos');
    Add('begin');

    i:=0;

    bufTemp.First;

    while not bufTemp.Eof do begin
      if (bufTemp.FieldByName('CAMPONOGRID').AsBoolean) then begin
        Add('  qrylistagem.Fields[' + i.ToString() + '].Displaylabel:=' + QuotedStr(bufTemp.FieldByName('TRADUCAOCAMPO').AsString) + ';');
        inc(i);
			end;
      bufTemp.Next;
		end;
    Add('');

    i:=0;

    bufTemp.First;

    while not bufTemp.Eof do begin
      if (bufTemp.FieldByName('CAMPONOGRID').AsBoolean) then begin
        Add('  grdListagem.Columns.Add();');
        Add('  grdListagem.Columns[' + i.ToString() + '].FieldName:=' + QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString) + ';');
        Add('  grdListagem.Columns[' + i.ToString() + '].Width:=' + QuotedStr(bufTemp.FieldByName('TAMANHO').AsString) + ';');

        inc(i);
			end;

      bufTemp.Next;
		end;

    Add('end;');

    // Método @Gravar
    Add('function T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Gravar(aEstadoDoCadastro: TEstadoDoCadastro): boolean;');
    Add('begin');
    Add('  if EstadoDoCadastro=ecInserir then');
    Add('    Result:= ' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Inserir');
    Add('  else if EstadoDoCadastro=ecAlterar then');
    Add('    Result:= o' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Atualizar;');
    Add('end;');
    Add('');

    // Método @Apagar
    Add('function T' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Apagar: Boolean;');
    Add('begin');

    bufTemp.First;

    while not bufTemp.Eof do begin
      if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean) then begin
        Add('  if o' +  Copy(edtTipoDaClasse.Text, 1, 50) + '.Selecionar(QryListagem.FieldByName(' + QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString) + ').AsString) then');
        Add('    Result:=o' + Copy(edtTipoDaClasse.Text, 1, 50) + '.Apagar);');
        Break;
      end;
		end;

    Add('end;');

    Add('{$endRegion}');
	end;
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
    qryTabelas.Close;
	end;
end;

procedure TfrmPrincipal.dblkpTabelaExit(Sender: TObject);
begin
  if (TDBLookupComboBox(Sender).KeyValue=Null) or (TDBLookupComboBox(Sender).KeyValue='') then
    exit;

  try
    qryCampos.Close;
    qryCampos.SQL.Clear;
    qryCampos.SQL.Add('SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema=' + QuotedStr(dblkbBancoDados.KeyValue)
                      + ' AND table_name=' + QuotedStr(TDBLookupComboBox(Sender).KeyValue));
    qryCampos.Open;
    qryCampos.First;

    bufTemp.First;

    while not bufTemp.Eof do
      bufTemp.Delete;

    while not qryCampos.Eof do begin
      bufTemp.Append;
      bufTemp.FieldByName('NOMECAMPO').AsString := qryCampos.FieldByName('COLUMN_NAME').AsString;
      bufTemp.FieldByName('TIPOCAMPO').AsString := qryCampos.FieldByName('DATA_TYPE').AsString;
      bufTemp.FieldByName('TAMANHO').AsInteger := qryCampos.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsInteger;
      bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean := False;
      bufTemp.FieldByName('CAMPONOGRID').AsBoolean := False;
      bufTemp.FieldByName('TRADUCAOCAMPO').AsString := qryCampos.FieldByName('COLUMN_NAME').AsString;
      bufTemp.Post;
      qryCampos.Next;
		end;
	except

	end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  synCodigo.Lines.Clear;

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

  dblkpTabela.ListSource:=dsTabelas;
  dblkpTabela.ListField:='table_name';
  dblkpTabela.KeyField:='table_name';
  dblkpTabela.KeyValue:=Nil;

  chkDbChavePrimaria.DataSource:=dsBufTemp;
  chkDbChavePrimaria.DataField:='CHAVEPRIMARIA';

  chkDbCampoGrid.DataSource:=dsBufTemp;
  chkDbCampoGrid.DataField:='CAMPONOGRID';

  edtTraducao.DataSource:=dsBufTemp;
  edtTraducao.DataField:='TRADUCAOCAMPO';

  grdCampos.DataSource:=dsBufTemp;
  dbnControle.DataSource:=dsBufTemp;
end;

procedure TfrmPrincipal.synCodigoChange(Sender: TObject);
begin

end;

end.

