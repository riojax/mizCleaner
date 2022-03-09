{ DCSUtils

  Copyright (C) 2019 riojax AT protonmail.com

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit DCSUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dos;
  
procedure FileCopy(strfin, strfout :String);

implementation

procedure FileCopy(strfin, strfout :String);
var
  fin, fout: File;
  numRead, numWritten: Word;
  buf: Array[1..2048] of byte;
  total: Longint;

begin
  {$I-}
  FileMode := fmOpenRead + fmShareDenyNone;
  Assign  (fin, strfin);
  FileMode := fmOpenRead + fmShareDenyNone;
  Reset   (fin, 1);

  FileMode := fmOpenWrite + fmShareDenyNone;
  Assign  (fout,strfout);
  FileMode := fmOpenWrite + fmShareDenyNone;
  Rewrite (fout,1);

  numRead := 0;
  numWritten := 0;
  total := 0;

  Repeat
	  BlockRead (fin,  {%H-}buf, Sizeof(buf), numRead);
	  BlockWrite(fout, {%H-}buf, numRead, numWritten);
	  inc(total, numWritten);
  Until (numRead=0) or (numWritten<>numRead);

  close(fin);
  close(fout);
  {$I+}
end;

end.

