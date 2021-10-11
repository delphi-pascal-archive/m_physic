{
���������: ���� ������
�����������: ������� �.�.
���� ��������: ������ 2004 ����
����� ����������: Delphi 7
}
unit InfoUnit;

interface

uses
  unitFrmResults, Classes, SysUtils, RocketUnit;

type
  TMyThread = class(TThread)
    MyRocket: TRocket;{������ ������ ������}
    procedure Execute;override;
    procedure ShowInfo;
  private
    i, j, k: Extended;
  end;

implementation

procedure TMyThread.ShowInfo;
{����� ���������� � ������ � frmResults.RichEdit1}
begin
  i := MyRocket.fuel[1].mass;
  j := MyRocket.fuel[2].mass;
  k := MyRocket.fuel[3].mass;

  if i < 0 then i := 0;
  if j < 0 then j := 0;
  if k < 0 then k := 0;

  frmResults.txtResult.Text :=
    '����� �����: ' + IntToStr(Round(MyRocket.FlyTime / 1000)) + ' (�)' + #13#10 +
    '������: ' + FloatToStr(MyRocket.H - 32) + ' (�)' + #13#10 +
    '��������: ' + FloatToStr(MyRocket.Speed) + ' (�/c)' + #13#10 +
    '���������: ' + FloatToStr(MyRocket.Acceleration) + ' (�/c^2)' + #13#10 +
    '����� ������� ������ �������: ' + FloatToStr(i) + ' (��)' + #13#10 +
    '����� ������� ������ �������: ' + FloatToStr(j) + ' (��)' + #13#10 +
    '����� ������� ������� �������: ' + FloatToStr(k) + ' (��)';
end;

procedure TMyThread.Execute;
{�������� ���� ������}
begin
  repeat
    Synchronize(ShowInfo);
  until Terminated;
end;

end.
