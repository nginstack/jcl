{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclMiscel.pas.                                                              }
{                                                                                                  }
{ The Initial Developers of the Original Code are Members of Team JCL. Portions created by these   }
{ individuals are Copyright (C) of these individuals. All Rights Reserved                          }
{                                                                                                  }
{ Contributors:                                                                                    }
{   Jeroen Speldekamp                                                                              }
{   Peter Friese                                                                                   }
{   Marcel van Brakel                                                                              }
{   Robert Marquardt (marquardt)                                                                   }
{   John C Molyneux                                                                                }
{   Matthias Thoma (mthoma)                                                                        }
{   Petr Vones (pvones)                                                                            }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Various miscellaneous routines that do not (yet) fit nicely into other units                     }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date::                                                                         $ }
{ Revision:      $Rev::                                                                          $ }
{ Author:        $Author::                                                                       $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclMiscel;

{$I jcl.inc}
{$I windowsonly.inc}

interface

uses
  {$IFDEF MSWINDOWS}
  {$IFDEF HAS_UNITSCOPE}
  Winapi.Windows,
  {$ELSE ~HAS_UNITSCOPE}
  Windows,
  {$ENDIF ~HAS_UNITSCOPE}
  JclWin32,
  {$ENDIF MSWINDOWS}
  JclBase;

// StrLstLoadSave
function SetDisplayResolution(const XRes, YRes: DWORD): Longint;

function WinExec32(Cmd: string; const CmdShow: Integer): Boolean;
function WinExec32AndWait(Cmd: string; const CmdShow: Integer): Cardinal;
function WinExec32AndRedirectOutput(const Cmd: string; var Output: string; RawOutput: Boolean = False): Cardinal;

implementation

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  {$ELSE ~HAS_UNITSCOPE}
  SysUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  JclResources, JclStrings, JclSysUtils, JclSysInfo;

function SetDisplayResolution(const XRes, YRes: DWORD): Longint;
var
  DevMode: TDeviceMode;
begin
  Result := DISP_CHANGE_FAILED;
  ResetMemory(DevMode, SizeOf(DevMode));
  DevMode.dmSize := SizeOf(DevMode);
  if EnumDisplaySettings(nil, 0, DevMode) then
  begin
    DevMode.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
    DevMode.dmPelsWidth := XRes;
    DevMode.dmPelsHeight := YRes;
    Result := ChangeDisplaySettings(DevMode, 0);
  end;
end;

function WinExec32(Cmd: string; const CmdShow: Integer): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  ResetMemory(StartupInfo, SizeOf(TStartupInfo));
  ResetMemory(ProcessInfo, SizeOf(ProcessInfo));
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := CmdShow;
  UniqueString(Cmd);//in the Unicode version the parameter lpCommandLine needs to be writable
  Result := CreateProcess(nil, PChar(Cmd), nil, nil, False,
    NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
  if Result then
  begin
    WaitForInputIdle(ProcessInfo.hProcess, INFINITE);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
  end;
end;

function WinExec32AndWait(Cmd: string; const CmdShow: Integer): Cardinal;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  Result := Cardinal($FFFFFFFF);
  ResetMemory(StartupInfo, SizeOf(TStartupInfo));
  ResetMemory(ProcessInfo, SizeOf(ProcessInfo));
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := CmdShow;
  UniqueString(Cmd);//in the Unicode version the parameter lpCommandLine needs to be writable
  if CreateProcess(nil, PChar(Cmd), nil, nil, False, NORMAL_PRIORITY_CLASS,
    nil, nil, StartupInfo, ProcessInfo) then
  begin
    WaitForInputIdle(ProcessInfo.hProcess, INFINITE);
    if WaitForSingleObject(ProcessInfo.hProcess, INFINITE) = WAIT_OBJECT_0 then
    begin
      if not GetExitCodeProcess(ProcessInfo.hProcess, Result) then
        Result := Cardinal($FFFFFFFF);
    end;
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
  end;
end;

function WinExec32AndRedirectOutput(const Cmd: string; var Output: string; RawOutput: Boolean): Cardinal;
begin
  Result := Execute(Cmd, Output, RawOutput);
end;

end.
