unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,strUtils, Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.FileCtrl, Vcl.ComCtrls, Vcl.TitleBarCtrls, Vcl.WinXCtrls, Vcl.WinXPanels,
  Vcl.Buttons, System.Win.TaskbarCore, Vcl.Taskbar,System.JSON, IdHTTP, ShellAPI,
  Vcl.CustomizeDlg, Vcl.Grids,OleAuto,System.Net.HttpClientComponent, WebView2,
  Winapi.ActiveX, Vcl.Edge, Vcl.OleCtrls, SHDocVw;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    login: TMenuItem;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    Style: TMenuItem;
    Settings: TMenuItem;
    PopupMenu1: TPopupMenu;
    DataBase: TMenuItem;
    SplitView1: TSplitView;
    ToggleSwitch1: TToggleSwitch;
    Button1: TButton;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ColorDialog1: TColorDialog;
    Panel2: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel3: TPanel;
    ErrorPanel: TPanel;
    ErrorLabel: TLabel;
    TreeView1: TTreeView;
    Label7: TLabel;
    Spanel: TSplitView;
    CustomizeDlg1: TCustomizeDlg;
    LinkLabel1: TLinkLabel;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    Label11: TLabel;
    StringGrid1: TStringGrid;
    group_name: TLabel;
    SaveDialog1: TSaveDialog;
    Button3: TButton;
    Label12: TLabel;
    Label13: TLabel;
    Panel4: TPanel;
    SearchBox1: TSearchBox;
    ListBox1: TListBox;
    Panel5: TPanel;
    LabeledEdit1: TLabeledEdit;
    Memo1: TMemo;
    WebBrowser1: TWebBrowser;
    Button4: TButton;
    Memo2: TMemo;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure paint(Sender: TObject);
    procedure change_theme(Sender: TObject);
    procedure change_theme_button(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure loginClick(Sender: TObject);
    procedure ChangePanel(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    procedure StyleClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OpenLink(Sender: TObject);
    procedure OpenLink1(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure N2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure test(Sender: TObject; Node: TTreeNode);
    procedure cellselect(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure resize(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Search_student(Sender: TObject);
    procedure wait_enter1(Sender: TObject; var Key: Char);
    procedure Seach_student_by_name(Sender: TObject);
    procedure Seach_student_by_name1(Sender: TObject);
    procedure DataBaseClick(Sender: TObject);
    procedure chekmate(Sender: TObject);
    procedure checkmate_leave(Sender: TObject);
    procedure change_server_name(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure complete_server_checkmate(ASender: TObject;
      const pDisp: IDispatch; const URL: OleVariant);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  theme,dolgs: boolean;
  theme_color: TColor;
  CurrentPanel:TPanel;
  values:array [0..8] of string;
  csv: tstringlist;
  row, col,StringGrid3Width,StringGrid1Width: integer;
  sis,server: string;

implementation

{$R *.dfm}

procedure hide_and_viewPanel(Hide:TPanel;View:TPanel);
begin
  if Hide <> View then begin

   Hide.Visible:=False;
   View.Visible:=true;
    View.Height:=Form1.Height;
    View.Width:=Form1.Width;
    View.Left:=0;
    View.Top:=0;

   Hide.Height:=0;
   Hide.Width:=0;
   Hide.Left:=0;
  end;
end;

function GetUrlContent(s: string): string;
var
  IdHTTP1: TNetHTTPClient;
begin
  IdHTTP1 := TNetHTTPClient.Create(nil);
  try
    Result := IdHTTP1.Get(s).ContentAsString(TEncoding.UTF8);
  finally
    IdHTTP1.Free;
  end;
end;

function getfromjson(url,param:string):string;
var
  json:string;
  obj:TJSONObject;
begin
  try
    json := GetUrlContent(url); // Тут должна быть запущена python реализация
    obj := TJSONObject.ParseJSONValue(json) as TJSONObject;
    if obj = nil then raise Exception.Create('Error parsing JSON');
    try
      result:= obj.Values[param].Value;
    finally
      obj.Free;
    end;
  except
    on E : Exception do
    begin
      result:= ''+sLineBreak + E.ClassName + sLineBreak + E.Message;
    end;
  end;
end;

procedure Datas;
var
  json: string;
  obj: TJSONArray;
  url: string;
  JSONEnum: TJSONObject.TEnumerator;
  FValue, FValueInner: TJSONValue;
  CurNode:TTReeNode;
  count_dolga:integer;
begin

  Form1.TreeView1.Items.BeginUpdate;
  try
    json := GetUrlContent('http://'+server+'/'); // Тут должна быть запущена python реализация
    obj := TJSONObject.ParseJSONValue(json) as TJSONArray;
    if obj = nil then raise Exception.Create('Error parsing JSON');
    try
       for FVALUE in obj do
         if FVALUE.FindValue('group') <> nil then begin
          CurNode := Form1.TreeView1.items.Add(nil,FVALUE.FindValue('group').GetValue<string>);
          count_dolga:=0;
          for FValueInner in (FVALUE.FindValue('students') as TJSONArray) do
            if (dolgs and (strtoint(FValueInner.FindValue('dolgs').GetValue<string>) = 0)) or not dolgs then begin
               Form1.TreeView1.items.AddChild(
                  CurNode,
                  FValueInner.FindValue('name').GetValue<string>
               );
               count_dolga:=count_dolga+1;
            end;
          if count_dolga = 0 then
             Form1.TreeView1.items.Delete(curnode);

         end;
    finally
      obj.Free;
      Form1.TreeView1.Items.EndUpdate;
    end;
  except
    on E : Exception do
    begin
      ShowMessage('Error' + sLineBreak + E.ClassName + sLineBreak + E.Message);
    end;
  end;
end;

procedure ShellOpen(const Url: string; const Params: string = '');
begin
  ShellAPI.ShellExecute(0, 'Open', PChar(Url), PChar(Params), nil, SW_SHOWNORMAL);
end;


procedure TForm1.Button2Click(Sender: TObject);
var login,pass:String;
begin

  login := getfromjson('http://'+server+'/users?user=5','login');
  pass := getfromjson('http://'+server+'/users?user=5','password');

  if (Edit1.Text = login) and (Edit2.Text = pass) then begin
    ErrorPanel.Visible:=False;
    hide_and_viewPanel(CurrentPanel,Panel3);
    CurrentPanel:=Panel3;
    MainMenu1.Items.Find('Панель').Visible:=True;
    MainMenu1.ItemS.Find('Панель').Enabled:=True;
    Datas(); // Выводим с базы данных
  end else begin
    ErrorPanel.Visible:=True;
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Button3.Visible:=false;
  try
    if TreeView1.Selected.Parent.Text <> '' then  // Choose Student
      ShellExecute(0, 'open', PChar('http://'+server+'/panel/'+TreeView1.Selected.Parent.Text), nil, nil, SW_SHOWNORMAL)
    else  // Choose Group
      ShellExecute(0, 'open', PChar('http://'+server+'/panel/'+TreeView1.Selected.Text), nil, nil, SW_SHOWNORMAL);
  except
     ShellExecute(0, 'open', PChar('http://'+server+'/panel/'+TreeView1.Selected.Text), nil, nil, SW_SHOWNORMAL);
  end;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  WebBrowser1.Navigate('http://'+server+'/test');
  Memo2.Visible:=true;
end;

procedure TForm1.cellselect(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  Label11.Caption:= 'Выбран параметр: '+stringgrid3.Cells[ACol,ARow];
end;

procedure TForm1.ChangePanel(Sender: TObject; Source: TMenuItem;
  Rebuild: Boolean);
begin
  with MainMenu1 do begin
    if CurrentPanel = Panel2 then
      login.Checked:=True;


  end;


end;

procedure TForm1.change_server_name(Sender: TObject);
begin
  server:=LabeledEdit1.Text;

end;

procedure TForm1.change_theme(Sender: TObject);
begin
  with ToggleSwitch1 do begin
    if State = tssOn then begin
      ThumbColor:=clWindow;theme_color:=clNone;
      theme:=true;
    end
    else begin
      ThumbColor:=clBlack;theme_color:=clWindow;
      theme:=false;
    end;
    Button1.Click();
  end;
end;

procedure TForm1.change_theme_button(Sender: TObject);
begin
  if theme then begin
    Form1.Font.Color:= clWindow;
  end else begin
    Form1.Font.Color:= clNone;
  end;

  Form1.Color:=theme_color;
  SplitView1.Color:=theme_color;

end;

procedure TForm1.checkmate_leave(Sender: TObject);
begin
   Memo1.Visible:=false;
end;

procedure TForm1.chekmate(Sender: TObject);
begin
  Memo1.Visible:=true;
end;

procedure TForm1.complete_server_checkmate(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
begin
  Memo2.Visible:=false;
  showmessage('Завершена загрузка тестовой страницы');
end;

procedure TForm1.DataBaseClick(Sender: TObject);
begin
// dont show
  hide_and_viewPanel(CurrentPanel,Panel5);
  CurrentPanel:=Panel5;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  server:='localhost';
  CurrentPanel:=Panel1;
  CurrentPanel.Height:=Form1.Height;
  CurrentPanel.Width:=Form1.Width;
  CurrentPanel.Left:=0;
  CurrentPanel.Top:=0;
  CurrentPanel.Visible:=true;
  theme:=false;
  theme_color:=clWindow;

  //Customizedlg1.Show;
  values[0]:='name';
  values[1]:='sum';
  values[2]:='phone';
  values[3]:='vk_link';
  values[4]:='parrent_male';
  values[5]:='parrent_female';
  values[6]:='dolgs';
  values[7]:='note';
  values[8]:='birthday';
  ListBox1.Items.Clear;
  dolgs:=false;

  LabeledEdit1.Text:=server;

  ErrorLabel.Left:=ErrorPanel.Left+3;
  ErrorLabel.Top:=ErrorPanel.Top+3;
  StringGrid3Width:=StringGrid3.Width;
  StringGrid1Width:=StringGrid1.Width;
  Panel4.Left:=(Form1.Width div 2)-(Panel4.Width div 2);


end;

procedure TForm1.loginClick(Sender: TObject);
begin
   hide_and_viewPanel(CurrentPanel,Panel2);
   CurrentPanel:=Panel2;
   Edit1.Text:=getfromjson('http://'+server+'/users?user=5','login');
   Edit2.Text:=getfromjson('http://'+server+'/users?user=5','password');
end;

procedure TForm1.N2Click(Sender: TObject);
begin
   hide_and_viewPanel(CurrentPanel,Panel3);
    CurrentPanel:=Panel3;
end;

procedure TForm1.OpenLink(Sender: TObject);
begin
  ShellOpen('http://'+server+'/');
end;

procedure TForm1.OpenLink1(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellOpen('http://'+server+'/');
end;

procedure TForm1.paint(Sender: TObject);
begin
  (Sender as TSystemTitlebarButton).Canvas.Rectangle(0, 0, 10, 10);
end;

procedure TForm1.resize(Sender: TObject);
begin
  CurrentPanel.Width:=Form1.Width;
  CurrentPanel.Height:=Form1.Height;
  StringGrid3.Width:=CurrentPanel.Width-12-StringGrid3Width;
  StringGrid1.Width:=CurrentPanel.Width-12-StringGrid1Width;
  //Button3.Left:=CurrentPanel.Width-Button3.Left+Button3.Width;
  TreeView1.Height:=Form1.Height;
  if CurrentPanel = Panel2 then begin
    ErrorLabel.Left:=ErrorPanel.Left+3;
    ErrorLabel.Top:=ErrorPanel.Top+3;
    Panel4.Left:=(Form1.Width div 2)-(Panel4.Width div 2);
  end;

end;



procedure TForm1.SettingsClick(Sender: TObject);
var P: TPoint;
begin
    PopUpMenu1.Popup(Mouse.CursorPos.X-6, Mouse.CursorPos.Y);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if MessageDlg('Учтите, что программа рассчитана только на стандартное отображение текста.',mtInformation,[mbYes],1) = mrYes then
    if FontDialog1.Execute then
      Form1.Font:=FontDialog1.Font;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
    theme_color:=ColorDialog1.Color;
    Button1.Click;
end;



procedure TForm1.SpeedButton3Click(Sender: TObject);
var
SList: TStringList;
i:integer;
begin
  SList := TStringList.Create;
  SList.Add('Группа '+group_name.Caption);
  SList.Add('');
  SaveDialog1.Title:='Сохранить файл ведомости.';
  SaveDialog1.Filter:='CSV File|*.csv|Exel File|*xlsx|Exel File|*xls';
  SaveDialog1.DefaultExt:='xlsx';
  SaveDialog1.FileName:=group_name.Caption+'_'+Label10.caption;
  if SaveDialog1.Execute then
    try
      for i := 0 to StringGrid3.RowCount do
        SList.Add(Utf8Encode(StringGrid3.Rows[i].CommaText));
      SList.Add('');
      SList.Add('Статистика по группе '+group_name.Caption);
      SList.Add('');

      for i := 0 to StringGrid2.RowCount do
        SList.Add(Utf8Encode(StringGrid2.Rows[i].CommaText));

      SList.Add('');
      SList.Add('Оценки по группе '+group_name.Caption);
      SList.Add('');

      for i := 0 to StringGrid1.RowCount do
        SList.Add(Utf8Encode(StringGrid1.Rows[i].CommaText));
      SList.SaveToFile(SaveDialog1.FileName);
    finally
      SList.Free;
    end;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  TreeView1.Items.Clear;
  Datas();
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin

  if MessageDlg('Вы уверены, что желаете изменить данные?',mtInformation,[mbYes,mbNo],0) = mrNo then exit;
  showmessage('Нажмите на кнопку "'+Button3.Caption+'" для перехода в панель базы данных.');
  Button3.Visible:=true;
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
  dolgs:= not dolgs;
  if dolgs then
    Label10.Caption:='Без задолжностей' else
    Label10.Caption:= 'С задолжниками';
  SpeedButton4.Click;
end;



procedure TForm1.StyleClick(Sender: TObject);
begin
   hide_and_viewPanel(CurrentPanel,Panel1);
   CurrentPanel:=Panel1;
end;

procedure cleargrid (grid:TStringGrid);
var i,j:integer;
begin
  for i := 0 to grid.RowCount do
    for j := 0 to grid.ColCount do
      grid.Cells[i,j]:='';
end;

procedure mas_grid_upload(s:string);
var
  obj,valuen: TJSONArray;
  i,col,sr_bal_of,second_bar:integer;
  JSONEnum: TJSONObject.TEnumerator;
  FValue, FValueInner: TJSONValue;
  sr_bal,uspeh:real;
  exams_split,session_split,exam:string;
  session: TArray<String>;
  exams: TArray<String>;
  exam_sr: array of integer;
begin
  col:=1;
  cleargrid(Form1.StringGrid3);
  cleargrid(Form1.StringGrid1);
  obj := TJSONObject.ParseJSONValue(s) as TJSONArray;
  Form1.StringGrid3.RowCount:=obj.Count;
  Form1.StringGrid1.RowCount:=obj.Count+1;
  for FVALUE in obj do begin
    for i := 0 to Length(values)-1 do
      if (dolgs and (FVALUE.FindValue('dolgs').GetValue<integer> = 0)) or not dolgs then begin
        Form1.StringGrid3.Cells[i,col]:= FVALUE.FindValue(values[i]).GetValue<string>;

        exams_split:=FVALUE.FindValue('exams_split').GetValue<string> + ',Ср.Балл,Общ. Успев.';
        exams:= exams_split.Split([',']);
        session_split:=FVALUE.FindValue('session_split').GetValue<string>;
        session:= session_split.Split([',']);


        Form1.StringGrid1.ColCount:=Length(exams);

        if values[i] = 'sum' then
          sr_bal:=sr_bal+FVALUE.FindValue(values[i]).GetValue<real> else
        if values[i] = 'name' then begin
          Form1.StringGrid1.Cells[0,col]:= FVALUE.FindValue(values[i]).GetValue<string>;
          for second_bar:=0 to length(exams)-3 do begin
            Form1.StringGrid1.Cells[second_bar+1,0]:= exams[second_bar];
            Form1.StringGrid1.Cells[second_bar+1,col]:=session[second_bar];
          end;


        end;


        SetLength(exam_sr, Length(session)-1);
        for sr_bal_of:= 0 to Length(session)-1 do begin
          if session[sr_bal_of] <> '2' then
            uspeh:=uspeh+strtofloat(session[sr_bal_of]);
          exam_sr[sr_bal_of]:=exam_sr[sr_bal_of]+strtoint(session[sr_bal_of]);

        end;

      end;
    col:=col+1;
  end;
  Form1.StringGrid2.Visible:=true;
  Form1.Label12.Visible:= Form1.StringGrid2.Visible;
  Form1.StringGrid1.Visible:=true;
  Form1.Label13.Visible:= Form1.StringGrid1.Visible;
  col:=0;

  Form1.StringGrid2.RowCount:=Length(exams);
  for exam in exams do begin
    Form1.StringGrid2.Cells[0,col]:=exam;
    Form1.StringGrid2.Cells[1,col]:=floattostr(exam_sr[col] div Length(exam_sr) div obj.Count div 2 );
    col:=col+1;

  end;
  Form1.StringGrid2.cells[1,(col-2)] := floattostr(sr_bal/obj.Count);
  Form1.StringGrid2.cells[1,(col-1)] := floattostr(uspeh/obj.Count/sr_bal);



end;

procedure grid_upload(s:string);
var
  obj:TJSONObject;
  i:integer;
  exams_split,session_split,exam:string;
  session: TArray<String>;
  exams: TArray<String>;
begin
  cleargrid(Form1.StringGrid3);
  cleargrid(Form1.StringGrid1);

   Form1.StringGrid1.Visible:=true;
   obj := TJSONObject.ParseJSONValue(s) as TJSONObject;
   Form1.StringGrid3.RowCount:=2;

   exams_split:=obj.Values['exams_split'].value;
   exams:= exams_split.Split([',']);
   session_split:=obj.Values['session_split'].value;
   session:= session_split.Split([',']);

   for i := 0 to Length(values)-1 do begin
      Form1.StringGrid3.Cells[i,1]:=obj.Values[values[i]].Value;
   end;

   Form1.StringGrid1.ColCount:=Length(exams);
   Form1.StringGrid1.RowCount:=Length(exams);
   Form1.StringGrid1.Cells[0,col]:= obj.Values['name'].value;
   for i:=0 to length(exams) do begin
    Form1.StringGrid1.Cells[i,0]:= exams[i];
    Form1.StringGrid1.Cells[i,1]:=session[i];
   end;
   Form1.StringGrid2.Visible:=false;
   Form1.Label12.Visible:= Form1.StringGrid2.Visible;
   Form1.Label13.Visible:= Form1.StringGrid1.Visible;
end;

procedure TForm1.Search_student(Sender: TObject);
var
cur_name,ai,without:string;
obj_ai,obj:TJSONObject;
begin
 //stop del
 cur_name:=SearchBox1.Text;
 ai:= GetUrlContent('http://'+server+'/search_ai/'+cur_name+'/');
 without := GetUrlContent('http://'+server+'/search/'+cur_name+'/');
 obj_ai := TJSONObject.ParseJSONValue(ai) as TJSONObject;
 obj := TJSONObject.ParseJSONValue(without) as TJSONObject;
 ListBox1.Items.Clear;
 Listbox1.Items.Add(obj_ai.Values['name'].value);
 Listbox1.Items.Add(obj.Values['name'].value);
end;

procedure TForm1.test(Sender: TObject; Node: TTreeNode);
var
  curld:string;
  i: Integer;

begin

  for i := 0 to Length(values)-1 do
    StringGrid3.Cells[i,0]:=values[i];
  try
    if TreeView1.Selected.Parent.Text <> '' then  // Choose Student
      curld:= 'http://'+server+'/get_name/'+(TreeView1.Selected.Parent.Text)+'/'+TreeView1.Selected.Text+'/'
    else  // Choose Group
      curld:= 'http://'+server+'/current?all=true&group='+inttostr(TreeView1.Selected.Index);

  except
     curld:= 'http://'+server+'/current?all=true&group='+inttostr(TreeView1.Selected.Index);
  end;

  if ContainsText(curld,'all=') then begin
    group_name.Caption:= TreeView1.Selected.Text;
    mas_grid_upload(GetUrlContent(curld));
  end else begin
    StringGrid3.RowCount:=2;
    group_name.Caption:= TreeView1.Selected.Parent.Text+' '+TreeView1.Selected.Text;
    grid_upload(GetUrlContent(curld));
  end;

  StringGrid3.Cells[0,0]:='ФИО';
  StringGrid3.Cells[1,0]:='Ср. Балл';
  StringGrid3.Cells[2,0]:='Телефон';
  StringGrid3.Cells[3,0]:='ВК link';
  StringGrid3.Cells[4,0]:='Папа';
  StringGrid3.Cells[5,0]:='Мама';
  StringGrid3.Cells[6,0]:='Долгов';
  StringGrid3.Cells[7,0]:='Замeтка';
  StringGrid3.Cells[8,0]:='День. Рожд.';

end;




procedure TForm1.wait_enter1(Sender: TObject; var Key: Char);
var
cur_name,ai,without,error:string;
obj_ai,obj:TJSONObject;
begin
 //stop del
 if ord(key) = VK_RETURN then begin
   cur_name:=SearchBox1.Text;
   ai:= GetUrlContent('http://'+server+'/search_ai/'+cur_name+'/');
   without := GetUrlContent('http://'+server+'/search/'+cur_name+'/');
   obj_ai := TJSONObject.ParseJSONValue(ai) as TJSONObject;
   obj := TJSONObject.ParseJSONValue(without) as TJSONObject;
   ListBox1.Items.Clear;
   if not obj.TryGetValue('error_msg',error) then
      Listbox1.Items.Add(obj.Values['name'].value);

   Listbox1.Items.Add(obj_ai.Values['name'].value);

 end;
end;

procedure TForm1.Seach_student_by_name(Sender: TObject);
var
cur_name,ai,without,error:string;
obj_ai,obj:TJSONObject;
begin
 //stop del

   cur_name:=SearchBox1.Text;
   ai:= GetUrlContent('http://'+server+'/search_ai/'+cur_name+'/');
   without := GetUrlContent('http://'+server+'/search/'+cur_name+'/');
   obj_ai := TJSONObject.ParseJSONValue(ai) as TJSONObject;
   obj := TJSONObject.ParseJSONValue(without) as TJSONObject;
   ListBox1.Items.Clear;
   if not obj.TryGetValue('error_msg',error) then
      Listbox1.Items.Add(obj.Values['name'].value);

   Listbox1.Items.Add(obj_ai.Values['name'].value);


end;

procedure TForm1.Seach_student_by_name1(Sender: TObject);
var name,e:string;
obj:TJSONObject;
begin
  name:= ListBox1.Items[ListBox1.ItemIndex];
  name :=GetUrlContent('http://'+server+'/go?name='+name);
  obj := TJSONObject.ParseJSONValue(name) as TJSONObject;
  if not obj.TryGetValue('error_msg',e) then
    grid_upload(name);
    group_name.Caption:= obj.Values['group'].Value+' '+obj.Values['name'].Value;

end;

end.
