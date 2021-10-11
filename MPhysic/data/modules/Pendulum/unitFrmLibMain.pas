{
���������: �������������� �������
�����������: ������� �.�.
���� ��������: 25 ������ 2004
����� ����������: Delphi7
}
unit unitFrmLibMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, unitFrmOptions, unitFrmResults, unitFrmGraph, OpenGL, Math;

type
  TfrmLibMain = class(TForm)
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    CallerForm: THandle;{���������� �����}
    DC: HDC;{�������� ����������}
    HRC: HGLRC;{�������� ��������������� OpenGL}
    ps: TPaintStruct;
    pfd: TPixelFormatDescriptor;
    QuadObj: GLUquadricObj;{quadric-������}
    procedure SetDefaultWindowPosition;
    procedure SetDCPixelFormat;
    procedure DrawGrid;
    procedure Calculate;
    procedure DrawGraphic;
  public
    IsRun: Boolean;{������� �� �������}
    Angle,{����}
    preSpeed,Speed,{������� ��������}
    Accel,{������� ���������}
    Len,{�����}
    g: Extended;{��������� ���������� �������}
    AngleArray,{������ �����}
    SpeedArray,{������ ���������}
    AccelArray: Array[1..250] of Extended;{������ ���������}
    MyTime: Integer;{����������� � ����� �������}
    Period: Extended;{������ ���������}
    infotimer: Integer;
  end;

var
  frmLibMain: TfrmLibMain;

procedure InitLibrary(App,CallForm:THandle);

implementation

uses unitFrmPhaseTraectory;

{$R *.dfm}

procedure InitLibrary(App,CallForm:THandle);
{������������� ����������}
begin
  Application.Handle := App;
  frmLibMain := TfrmLibMain.Create(Application);
  frmLibMain.CallerForm := CallForm;

  frmOptions := TfrmOptions.Create(Application);
  frmResults := TfrmResults.Create(Application);
  frmGraph := TfrmGraph.Create(Application);
  frmPhaseTraectory := TfrmPhaseTraectory.Create(Application);

  frmLibMain.Show;
  frmOptions.Show;
  frmResults.Show;
  frmGraph.Show;
end;

procedure TfrmLibMain.DrawGraphic;
{������ � ���������� ��������}
var
  i: Integer;
begin
  {���������� �������� �����, ��������� � ���������}
  for i := 1 to 249 do
  begin
    AngleArray[i] := AngleArray[i+1];
    SpeedArray[i] := SpeedArray[i+1];
    AccelArray[i] := AccelArray[i+1];
  end;

  AngleArray[250] := Angle;
  SpeedArray[250] := Speed;
  AccelArray[250] := Accel;

  {���������� ��������}
  frmGraph.Chart.Series[0].Clear;
  case frmGraph.tabs.TabIndex of
    0: begin
         frmGraph.Chart.Title.Text.Text := '���� (����)';
         for i := 1 to 250 do
           frmGraph.Chart.Series[0].Add(AngleArray[i]);
       end;

    1: begin
         frmGraph.Chart.Title.Text.Text := '������� �������� (����/�)';
         for i := 1 to 250 do
           frmGraph.Chart.Series[0].Add(SpeedArray[i]);
       end;

    2: begin
         frmGraph.Chart.Title.Text.Text := '������� ��������� (����/�^2)';
         for i := 1 to 250 do
           frmGraph.Chart.Series[0].Add(AccelArray[i]);
       end;
  end;

  frmPhaseTraectory.chartPhaseTraectory.Series[0].Clear;
  for i := 1 to 250 do
    frmPhaseTraectory.chartPhaseTraectory.Series[0].AddXY(AngleArray[i], SpeedArray[i]);
end;

procedure ShowInfo;
begin
  frmResults.txtResult.Text :=
    '����: ' + FloatToStr(frmLibMain.Angle) + ' (����)' + #13#10 +
    '������� ��������: ' + FloatToStr(frmLibMain.Speed) + ' (����/�)' + #13#10 +
    '������� ���������: ' + FloatToStr(frmLibMain.Accel) + ' (����/�^2)' + #13#10 +
    '������ ���������: ' + FloatToStr(frmLibMain.Period / 1000) + ' (�)' + #13#10 +
    '������� ���������: ' + FloatToStr(1 / (frmLibMain.Period / 1000)) + ' (��)';
end;

procedure TfrmLibMain.DrawGrid;
{���������� �����}
var
  i: Integer;
begin
  glDisable(GL_LIGHTING);
  glColor3f(0.3, 0.3, 0.3);

  glBegin(GL_LINES);
  for i := -50 to 50 do
  begin
    glVertex3f(i / 5, -10, 0);
    glVertex3f(i / 5, 10, 0);
    glVertex3f(-10, i / 5, 0);
    glVertex3f(10, i / 5, 0);
  end;
  glEnd;

  glEnable(GL_LIGHTING);
end;

procedure TfrmLibMain.SetDCPixelFormat;
{��������� ������� �������}
var
  nPixelFormat: Integer;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  pfd.dwFlags := PFD_SUPPORT_OPENGL or
                 PFD_DRAW_TO_WINDOW or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

procedure TfrmLibMain.SetDefaultWindowPosition;
{��������� ������������ ����}
const
  w = 209;
  h = 0.7;
begin
  with frmLibMain do
  begin
    Left := w;
    Top := 0;
    Width := Screen.Width - w;
    Height := Round(Screen.Height * h);
  end;

  with frmOptions do
  begin
    Left := 0;
    Top := 0;
    Width := w;
    Height := Round(Screen.Height * h);
    Show;
  end;

  with frmResults do
  begin
    Left := 0;
    Top := frmLibMain.Height;
    Width := Round(Screen.Width / 3);
    Height := Screen.Height - frmLibMain.Height;
    Show;
  end;

  with frmGraph do
  begin
    Left := frmResults.Width;
    Top := frmLibMain.Height;
    Width := Round(Screen.Width / 3);
    Height := Screen.Height - frmLibMain.Height;
    Show;
  end;

  with frmPhaseTraectory do
  begin
    Left := frmGraph.Left + frmGraph.Width;
    Top := frmGraph.Top;
    Width := Screen.Width - frmResults.Width - frmGraph.Width;
    Height := frmGraph.Height;
    Show;
  end;
end;

procedure TfrmLibMain.FormShow(Sender: TObject);
begin
  SetDefaultWindowPosition;
end;

procedure TfrmLibMain.FormDestroy(Sender: TObject);
begin
  frmOptions.Destroy;
  frmResults.Destroy;
  frmGraph.Destroy;
  frmPhaseTraectory.Destroy;
end;

procedure TfrmLibMain.Calculate;
{������ �������� ��������}
const
  dt = 0.00025;
  interval = 160;
var
  i: Integer;
  preAccel: Extended;
begin
  preSpeed := Speed;
  MyTime := MyTime + interval;

  for i := 1 to interval do
  begin
    preAccel := Accel;
    Accel := sin(DegToRad(Angle)) * g * (180 / (pi * Len));
    Angle := Angle + Speed * dt + preAccel * sqr(dt) / 2;
    Speed := Speed - (Accel + preAccel) * dt / 2;
  end;

  if (preSpeed * Speed <= 0) then
  begin
    Period := MyTime / 2;
    MyTime := 0;
  end;

  DrawGraphic;
end;

procedure Render;
{���������}
begin
  wglMakeCurrent(frmLibMain.DC,frmLibMain.HRC);

  with frmLibMain do
  begin
    BeginPaint(Handle, ps);
    glClear(GL_COLOR_BUFFER_BIT or
            GL_DEPTH_BUFFER_BIT);
    glLoadIdentity;
    glTranslatef(0, 0, -10);

    {���������� �����}
    if frmOptions.cbShowGrid.Checked then
      DrawGrid;

    {������ ��������}
    if IsRun then
      frmLibMain.Calculate;

    {���������� ����� � ����� ��������� ��������}
    glPushMatrix;
    glTranslatef(0, 2.2, 0);
    gluSphere(QuadObj, 0.1, 20, 20);
    glPopMatrix;

    {���������� ����� ��������}
    glPushMatrix;
    glTranslatef(Len * sin(DegToRad(Angle)),
                 -Len * cos(DegToRad(Angle)) + 2.2, 0);
    gluSphere(QuadObj, 0.1, 20, 20);
    glPopMatrix;

    {���������� ���� �������}
    glDisable(GL_LIGHTING);
    glColor3f(1, 1, 1);
    glBegin(GL_LINES);
      glVertex3f(0, 2.2, 0.05);
      glVertex3f(Len * sin(DegToRad(Angle)), -Len * cos(DegToRad(Angle)) + 2.2, 0.05);
    glEnd;
    glEnable(GL_LIGHTING);

    {����� ����������}
    inc(infotimer);
    if infotimer > 5 then
    begin
      infotimer := 0;
      ShowInfo;
    end;

    EndPaint(Handle, ps);
    SwapBuffers(DC);
  end;
end;

procedure TfrmLibMain.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if frmOptions.Visible then Resize := False;
end;

procedure TfrmLibMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  wglMakeCurrent(DC,HRC);

  {������� �������}
  KillTimer(Handle, 100);

  {�������� quadric-��������}
  gluDeleteQuadric(QuadObj);

  {���������� ������ � OpenGL}
  wglMakeCurrent(0, 0);
  wglDeleteContext(HRC);
  ReleaseDC(Handle, DC);
  DeleteDC(DC);
  SendMessage(CallerForm, WM_USER, 0, 0);
  Destroy;
end;

procedure TfrmLibMain.FormCreate(Sender: TObject);
begin
  IsRun := False;
  Len := 3;
  Angle := 30;
  MyTime := 0;
  Period := 1;

  {������������� OpenGL}
  DC := GetDC(Handle);
  SetDCPixelFormat;
  HRC := wglCreateContext(DC);
  wglMakeCurrent(DC, HRC);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);

  {�������� quadric-��������}
  QuadObj := gluNewQuadric;
  gluQuadricDrawStyle(QuadObj, GLU_FILL);
  gluQuadricOrientation(QuadObj, GLU_OUTSIDE);

  {������ �������}
  SetTimer(Handle, 100, 40, @Render);
end;

procedure TfrmLibMain.FormResize(Sender: TObject);
begin
  wglMakeCurrent(DC, HRC);
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30, ClientWidth / ClientHeight, 1, 1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

end.
