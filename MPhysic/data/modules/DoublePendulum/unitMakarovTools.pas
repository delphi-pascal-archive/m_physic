unit unitMakarovTools;

interface

uses
  Windows,
  Forms;

procedure SetWindowParams(x, y, width, height: Integer; window: TForm); external 'data\engine\MakarovTools.dll';
procedure About(prog, date, dateupdate, version: ShortString; parent: TForm); external 'data\engine\MakarovTools.dll';

implementation

end.
