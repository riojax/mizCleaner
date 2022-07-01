{ mizCleaner

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

unit UnitMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, Zipper, Process, UnitAbout, DCSUtils;

type

  { TFormMain }

  TFormMain = class(TForm)
    BitBtn1:     TBitBtn;
    btClean:     TBitBtn;
    btExit:      TBitBtn;
    btAbout:     TBitBtn;
    teFilename:  TEdit;
    Memo1:       TMemo;
    OpenDialog1: TOpenDialog;

    procedure    BitBtn1Click(Sender: TObject);
    procedure    btAboutClick(Sender: TObject);
    procedure    btCleanClick(Sender: TObject);
    procedure    btExitClick(Sender: TObject);

  private
    UnZipper   : TUnZipper;
    OurZipper  : TZipper;
    extProc    : TProcess;
    pathtmp    : String;
    pathorg    : String;
    dirInfo    : TSearchRec;
    FindResult : Integer;
    sfnd       : String;
    slin       : AnsiString;
    sfin       : AnsiString;
    slst       : TStringList;
    tok        : Boolean;
    fdRead     : TextFile;
    fdWrite    : TextFile;

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.btCleanClick(Sender: TObject);
begin
  btClean.Enabled := false;

  sfnd := 'DictKey_';
  {$IFDEF WINDOWS}
  pathtmp := 'C:/WINDOWS/TEMP/';
  {$ELSE}
  pathtmp := '/tmp/';
  {$ENDIF}
  pathorg := teFilename.Text;

  Memo1.Lines.Add('[*] Unpacking mission file');

  UnZipper := TUnZipper.Create;
  UnZipper.FileName   := pathorg;
  UnZipper.OutputPath := pathtmp + '/MIZCLEANER';
  UnZipper.Examine;
  UnZipper.UnZipAllFiles();

  Memo1.Lines.Add('[*] Get mission DictKey');
  FileMode := fmOpenRead + fmShareDenyNone;
  AssignFile(fdRead, pathtmp + '/MIZCLEANER/mission');
  Reset(fdRead);

  Setlength(slin, 16384);
  Setlength(sfin, 16384);

  slst := TStringList.Create();
  slst.CaseSensitive := false;
  slst.Duplicates := dupIgnore; // do not add duplicates
  slst.Sorted := true;

  while not eof(fdRead) do
  begin
    readln(fdRead, slin);
    slin := StringReplace(Trim(slin), '\', '',  [rfReplaceAll]);
    slin := StringReplace(Trim(slin), '"', ' ', [rfReplaceAll]);

    for sfin in slin.Split(' ') do
    begin
      if pos(sfnd, sfin) > 0 then
      begin
         Memo1.Lines.Add('[D] Reading key: ' + sfin);
         slst.Add(sfin);
      end;
    end;
  end;
  CloseFile(fdRead);

  Memo1.Lines.Add('[*] Removing old DictKey entries');

  FileMode := fmOpenRead + fmShareDenyNone;
  AssignFile(fdRead,  pathtmp + '/MIZCLEANER/l10n/DEFAULT/dictionary');
  Reset(fdRead);

  AssignFile(fdWrite, pathtmp + '/MIZCLEANER/l10n/DEFAULT/dictionary.tmp');
  Rewrite(fdWrite);

  tok := true;
  while not eof(fdRead) do
  begin
    readln(fdRead, slin);
    if pos('DictKey_', slin) > 0 then
    begin
      tok  := true;
      sfin := Trim(slin.Split('"')[1]);
      if slst.indexOf(sfin) = -1 then
      begin
        Memo1.Lines.Add('[D] Remove old key: ' + sfin);
        tok := false;
      end;
    end;

    if (tok) and (slin <> '') and (slin <> '} -- end of dictionary') then
      WriteLn(fdWrite, slin);
  end;

  WriteLn(fdWrite, '} -- end of dictionary');

  CloseFile(fdRead);
  CloseFile(fdWrite);

  try
    FileCopy(pathtmp + '/MIZCLEANER/l10n/DEFAULT/dictionary.tmp',
             pathtmp + '/MIZCLEANER/l10n/DEFAULT/dictionary');
    DeleteFile(pathtmp + '/MIZCLEANER/l10n/DEFAULT/dictionary.tmp');
  except
  end;

  Memo1.Lines.Add('[*] Optimize PNGs');
  ChDir(pathtmp + '/MIZCLEANER/l10n/DEFAULT/');
  FindResult := FindFirst('*.png', faArchive, dirInfo);
  while FindResult = 0 do
  begin
    try
      extProc := TProcess.Create(nil);
      extProc.Executable := 'optipng';
      extProc.Parameters.Add(dirInfo.Name);
      extProc.Options := extProc.Options + [poNoConsole, poWaitOnExit];
      extProc.Execute;
      extProc.Free;
    except
    end;
    FindResult := FindNext(dirInfo);
  end;
  FindClose(dirInfo);
  ChDir(pathtmp + '/MIZCLEANER');

  Memo1.Lines.Add('[*] Packing mission file');
  OurZipper := TZipper.Create;
  OurZipper.Entries  := UnZipper.Entries;
  OurZipper.FileName := pathorg;
  ChDir(pathtmp + '/MIZCLEANER');
  try
     OurZipper.ZipAllFiles();
  except
  end;

  Memo1.Lines.Add('[*] Delete temporal files');
  ChDir(pathtmp + '/MIZCLEANER/l10n/DEFAULT/');
  FindResult := FindFirst('*', faArchive, dirInfo);
  while FindResult = 0 do
  begin
    try
      DeleteFile(dirInfo.Name);
    except
    end;
    FindResult := FindNext(dirInfo);
  end;
  FindClose(dirInfo);

  ChDir(pathtmp + '/MIZCLEANER');
  FindResult := FindFirst('*', faArchive, dirInfo);
  while FindResult = 0 do
  begin
    try
      DeleteFile(dirInfo.Name);
    except
    end;
    FindResult := FindNext(dirInfo);
  end;
  FindClose(dirInfo);

  Memo1.Lines.Add('[*] Mission cleaning finished!');

  slst.Free();
  btClean.Enabled := true;
end;

procedure TFormMain.BitBtn1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    teFilename.Text    := OpenDialog1.Filename;
    teFilename.Enabled := true;
    btClean.Enabled    := true;
    Memo1.Clear;
  end;
end;

procedure TFormMain.btAboutClick(Sender: TObject);
begin
  FormAbout.ShowModal;
end;

procedure TFormMain.btExitClick(Sender: TObject);
begin
  Application.terminate;
end;
end.

