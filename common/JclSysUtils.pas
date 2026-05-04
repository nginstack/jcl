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
{ The Original Code is JclSysUtils.pas.                                                            }
{                                                                                                  }
{ The Initial Developer of the Original Code is Marcel van Brakel.                                 }
{ Portions created by Marcel van Brakel are Copyright (C) Marcel van Brakel. All rights reserved.  }
{                                                                                                  }
{ Contributors:                                                                                    }
{   Alexander Radchenko,                                                                           }
{   Andreas Hausladen (ahuser)                                                                     }
{   Anthony Steele                                                                                 }
{   Bernhard Berger                                                                                }
{   Heri Bender                                                                                    }
{   Jean-Fabien Connault (cycocrew)                                                                }
{   Jens Fudickar                                                                                  }
{   Jeroen Speldekamp                                                                              }
{   Marcel van Brakel                                                                              }
{   Peter Friese                                                                                   }
{   Petr Vones (pvones)                                                                            }
{   Python                                                                                         }
{   Robert Marquardt (marquardt)                                                                   }
{   Robert R. Marsh                                                                                }
{   Robert Rossmair (rrossmair)                                                                    }
{   Rudy Velthuis                                                                                  }
{   Uwe Schuster (uschuster)                                                                       }
{   Wayne Sherman                                                                                  }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Description: Various pointer and class related routines.                                         }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date::                                                                         $ }
{ Revision:      $Rev::                                                                          $ }
{ Author:        $Author::                                                                       $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclSysUtils;

{$I jcl.inc}

interface

uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Classes, System.TypInfo, System.SyncObjs,
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes, TypInfo, SyncObjs,
  {$ENDIF ~HAS_UNITSCOPE}
  JclBase, JclSynch;

// memory initialization
// first parameter is "out" to make FPC happy with uninitialized values
procedure ResetMemory(out P; Size: Longint);

// Pointer manipulation
procedure GetAndFillMem(var P: Pointer; const Size: Integer; const Value: Byte);
procedure FreeMemAndNil(var P: Pointer);
function PCharOrNil(const S: string): PChar;
function PAnsiCharOrNil(const S: AnsiString): PAnsiChar;
{$IFDEF SUPPORTS_WIDESTRING}
function PWideCharOrNil(const W: WideString): PWideChar;
{$ENDIF SUPPORTS_WIDESTRING}

{$IFDEF MSWINDOWS}
function SizeOfMem(const APointer: Pointer): Integer;

function WriteProtectedMemory(BaseAddress, Buffer: Pointer; Size: Cardinal;
  out WrittenBytes: Cardinal): Boolean;
{$ENDIF}


{ Shared memory between processes functions }

// Functions for the shared memory owner
type
  ESharedMemError = class(EJclError);

// Binary search
function SearchSortedList(List: TList; SortFunc: TListSortCompare; Item: Pointer;
  Nearest: Boolean = False): Integer;

type
  TUntypedSearchCompare = function(Param: Pointer; ItemIndex: Integer; const Value): Integer;

function SearchSortedUntyped(Param: Pointer; ItemCount: Integer; SearchFunc: TUntypedSearchCompare;
  const Value; Nearest: Boolean = False): Integer;

// Dynamic array sort and search routines
type
  TDynArraySortCompare = function (Item1, Item2: Pointer): Integer;

procedure SortDynArray(const ArrayPtr: Pointer; ElementSize: Cardinal; SortFunc: TDynArraySortCompare);
// Usage: SortDynArray(Array, SizeOf(Array[0]), SortFunction);
function SearchDynArray(const ArrayPtr: Pointer; ElementSize: Cardinal; SortFunc: TDynArraySortCompare;
  ValuePtr: Pointer; Nearest: Boolean = False): SizeInt;
// Usage: SearchDynArray(Array, SizeOf(Array[0]), SortFunction, @SearchedValue);

{ Various compare functions for basic types }

function DynArrayCompareByte(Item1, Item2: Pointer): Integer;
function DynArrayCompareShortInt(Item1, Item2: Pointer): Integer;
function DynArrayCompareWord(Item1, Item2: Pointer): Integer;
function DynArrayCompareSmallInt(Item1, Item2: Pointer): Integer;
function DynArrayCompareInteger(Item1, Item2: Pointer): Integer;
function DynArrayCompareCardinal(Item1, Item2: Pointer): Integer;
function DynArrayCompareInt64(Item1, Item2: Pointer): Integer;

function DynArrayCompareSingle(Item1, Item2: Pointer): Integer;
function DynArrayCompareDouble(Item1, Item2: Pointer): Integer;
function DynArrayCompareExtended(Item1, Item2: Pointer): Integer;
function DynArrayCompareFloat(Item1, Item2: Pointer): Integer;

function DynArrayCompareAnsiString(Item1, Item2: Pointer): Integer;
function DynArrayCompareAnsiText(Item1, Item2: Pointer): Integer;
function DynArrayCompareWideString(Item1, Item2: Pointer): Integer;
function DynArrayCompareWideText(Item1, Item2: Pointer): Integer;
function DynArrayCompareString(Item1, Item2: Pointer): Integer;
function DynArrayCompareText(Item1, Item2: Pointer): Integer;

// Object lists
procedure ClearObjectList(List: TList);
procedure FreeObjectList(var List: TList);

// Reference memory stream
type
  TJclReferenceMemoryStream = class(TCustomMemoryStream)
  public
    constructor Create(const Ptr: Pointer; Size: Longint);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

// AutoPtr
type
  IAutoPtr = interface
    { Returns the object as pointer, so it is easier to assign it to a variable }
    function AsPointer: Pointer;
    { Returns the AutoPtr handled object }
    function AsObject: TObject;
    { Releases the object from the AutoPtr. The AutoPtr looses the control over
      the object. }
    function ReleaseObject: TObject;
  end;

  TJclAutoPtr = class(TInterfacedObject, IAutoPtr)
  private
    FValue: TObject;
  public
    constructor Create(AValue: TObject);
    destructor Destroy; override;
    { IAutoPtr }
    function AsPointer: Pointer;
    function AsObject: TObject;
    function ReleaseObject: TObject;
  end;

function CreateAutoPtr(Value: TObject): IAutoPtr;

// Replacement for the C ternary conditional operator ? :
function Iff(const Condition: Boolean; const TruePart, FalsePart: string): string; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Char): Char; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Byte): Byte; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Integer): Integer; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Cardinal): Cardinal; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Float): Float; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Boolean): Boolean; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Pointer): Pointer; overload;
function Iff(const Condition: Boolean; const TruePart, FalsePart: Int64): Int64; overload;
{$IFDEF SUPPORTS_VARIANT}
function Iff(const Condition: Boolean; const TruePart, FalsePart: Variant): Variant; overload;
{$ENDIF SUPPORTS_VARIANT}

// Classes information and manipulation
type
  EJclVMTError = class(EJclError);

// Virtual Methods
{$IFNDEF FPC}
function GetVirtualMethodCount(AClass: TClass): Integer;
{$ENDIF ~FPC}
function GetVirtualMethod(AClass: TClass; const Index: Integer): Pointer;
{$IFDEF MSWINDOWS}
procedure SetVirtualMethod(AClass: TClass; const Index: Integer; const Method: Pointer);
{$ENDIF}

// Dynamic Methods
type
  TDynamicIndexList = array [0..MaxInt div 16] of Word;
  PDynamicIndexList = ^TDynamicIndexList;
  TDynamicAddressList = array [0..MaxInt div 16] of Pointer;
  PDynamicAddressList = ^TDynamicAddressList;

function GetDynamicMethodCount(AClass: TClass): Integer;
function GetDynamicIndexList(AClass: TClass): PDynamicIndexList;
function GetDynamicAddressList(AClass: TClass): PDynamicAddressList;
function HasDynamicMethod(AClass: TClass; Index: Integer): Boolean;
{$IFNDEF FPC}
function GetDynamicMethod(AClass: TClass; Index: Integer): Pointer;
{$ENDIF ~FPC}

{ init table methods }

function GetInitTable(AClass: TClass): PTypeInfo;

{ field table methods }

type
  PFieldEntry = ^TFieldEntry;
  TFieldEntry = packed record
    OffSet: Integer;
    IDX: Word;
    Name: ShortString;
  end;

  PFieldClassTable = ^TFieldClassTable;
  TFieldClassTable = packed record
    Count: Smallint;
    Classes: array [0..8191] of ^TPersistentClass;
  end;

  PFieldTable = ^TFieldTable;
  TFieldTable = packed record
    EntryCount: Word;
    FieldClassTable: PFieldClassTable;
    FirstEntry: TFieldEntry;
   {Entries: array [1..65534] of TFieldEntry;}
  end;

function GetFieldTable(AClass: TClass): PFieldTable;

{ method table }

type
  PMethodEntry = ^TMethodEntry;
  TMethodEntry = packed record
    EntrySize: Word;
    Address: Pointer;
    Name: ShortString;
  end;

  PMethodTable = ^TMethodTable;
  TMethodTable = packed record
    Count: Word;
    FirstEntry: TMethodEntry;
   {Entries: array [1..65534] of TMethodEntry;}
  end;

function GetMethodTable(AClass: TClass): PMethodTable;
function GetMethodEntry(MethodTable: PMethodTable; Index: Integer): PMethodEntry;

// Function to compare if two methods/event handlers are equal
function MethodEquals(aMethod1, aMethod2: TMethod): boolean;
function NotifyEventEquals(aMethod1, aMethod2: TNotifyEvent): boolean;

// Class Parent
{$IFDEF MSWINDOWS}
procedure SetClassParent(AClass: TClass; NewClassParent: TClass);
{$ENDIF}
function GetClassParent(AClass: TClass): TClass;

{$IFNDEF FPC}
function IsClass(Address: Pointer): Boolean;
function IsObject(Address: Pointer): Boolean;
{$ENDIF ~FPC}

function InheritsFromByName(AClass: TClass; const AClassName: string): Boolean;

// Interface information
function GetImplementorOfInterface(const I: IInterface): TObject;

// Loading of modules (DLLs)
type
{$IFDEF MSWINDOWS}
  TModuleHandle = HINST;
{$ENDIF MSWINDOWS}
{$IFDEF LINUX}
  TModuleHandle = Pointer;
{$ENDIF LINUX}

const
  INVALID_MODULEHANDLE_VALUE = TModuleHandle(0);

function LoadModule(var Module: TModuleHandle; FileName: string): Boolean;
function LoadModuleEx(var Module: TModuleHandle; FileName: string; Flags: Cardinal): Boolean;
procedure UnloadModule(var Module: TModuleHandle);
function GetModuleSymbol(Module: TModuleHandle; SymbolName: string): Pointer;
function GetModuleSymbolEx(Module: TModuleHandle; SymbolName: string; var Accu: Boolean): Pointer;
function ReadModuleData(Module: TModuleHandle; SymbolName: string; var Buffer; Size: Cardinal): Boolean;
function WriteModuleData(Module: TModuleHandle; SymbolName: string; var Buffer; Size: Cardinal): Boolean;

// Conversion Utilities
type
  EJclConversionError = class(EJclError);

function StrToBoolean(const S: string): Boolean;
function BooleanToStr(B: Boolean): string;
function IntToBool(I: Integer): Boolean;
function BoolToInt(B: Boolean): Integer;

function TryStrToUInt(const Value: string; out Res: Cardinal): Boolean;
function StrToUIntDef(const Value: string; const Default: Cardinal): Cardinal;
function StrToUInt(const Value: string): Cardinal;

const
  {$IFDEF MSWINDOWS}
  ListSeparator = ';';
  {$ENDIF MSWINDOWS}
  {$IFDEF LINUX}
  ListSeparator = ':';
  {$ENDIF LINUX}

// functions to handle items in a separated list of items
// add items at the end
procedure ListAddItems(var List: string; const Separator, Items: string);
// add items at the end if they are not present
procedure ListIncludeItems(var List: string; const Separator, Items: string);
// delete multiple items
procedure ListRemoveItems(var List: string; const Separator, Items: string);
// delete one item
procedure ListDelItem(var List: string; const Separator: string;
  const Index: Integer);
// return the number of item
function ListItemCount(const List, Separator: string): Integer;
// return the Nth item
function ListGetItem(const List, Separator: string;
  const Index: Integer): string;
// set the Nth item
procedure ListSetItem(var List: string; const Separator: string;
  const Index: Integer; const Value: string);
// return the index of an item
function ListItemIndex(const List, Separator, Item: string): Integer;

// RTL package information
{$IFDEF MSWINDOWS}
function SystemTObjectInstance: TJclAddr;
function IsCompiledWithPackages: Boolean;
{$ENDIF MSWINDOWS}

// GUID
function JclGUIDToString(const GUID: TGUID): string;
function JclStringToGUID(const S: string): TGUID;
function GUIDEquals(const GUID1, GUID2: TGUID): Boolean;

// thread safe support

type
  TJclIntfCriticalSection = class(TInterfacedObject, IInterface)
  private
    FCriticalSection: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    { IInterface }
    // function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; {$IFNDEF MSWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release: Integer; {$IFNDEF MSWINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
  end;

implementation

uses
  {$IFDEF HAS_UNIT_LIBC}
  Libc,
  {$ENDIF HAS_UNIT_LIBC}
  {$IFDEF HAS_UNITSCOPE}
  System.Variants, System.Types, System.Contnrs,
  {$IFDEF HAS_UNIT_ANSISTRINGS}
  System.AnsiStrings,
  {$ENDIF HAS_UNIT_ANSISTRINGS}
  {$ELSE ~HAS_UNITSCOPE}
  Variants, Types, Contnrs,
  {$IFDEF HAS_UNIT_ANSISTRINGS}
  AnsiStrings,
  {$ENDIF HAS_UNIT_ANSISTRINGS}
  {$ENDIF ~HAS_UNITSCOPE}
  JclFileUtils, JclMath, JclResources, JclStrings,
  {$IFDEF MSWINDOWS}
  JclWin32,
  {$ENDIF}
  {$IFDEF UNIX}
  baseunix, dl,
  {$ENDIF UNIX}
  JclStringConversions, JclSysInfo;

// memory initialization
procedure ResetMemory(out P; Size: Longint);
begin
  if Size > 0 then
  begin
    Byte(P) := 0;
    FillChar(P, Size, 0);
  end;
end;

// Pointer manipulation
procedure GetAndFillMem(var P: Pointer; const Size: Integer; const Value: Byte);
begin
  GetMem(P, Size);
  FillChar(P^, Size, Value);
end;

procedure FreeMemAndNil(var P: Pointer);
var
  Q: Pointer;
begin
  Q := P;
  P := nil;
  FreeMem(Q);
end;

function PCharOrNil(const S: string): PChar;
begin
  Result := Pointer(S);
end;

function PAnsiCharOrNil(const S: AnsiString): PAnsiChar;
begin
  Result := Pointer(S);
end;

{$IFDEF SUPPORTS_WIDESTRING}

function PWideCharOrNil(const W: WideString): PWideChar;
begin
  Result := Pointer(W);
end;

{$ENDIF SUPPORTS_WIDESTRING}

{$IFDEF MSWINDOWS}
type
  PUsed = ^TUsed;
  TUsed = record
    SizeFlags: Integer;
  end;

const
  cThisUsedFlag = 2;
  cPrevFreeFlag = 1;
  cFillerFlag   = Integer($80000000);
  cFlags        = cThisUsedFlag or cPrevFreeFlag or cFillerFlag;

function SizeOfMem(const APointer: Pointer): Integer;
var
  U: PUsed;
begin
  if IsMemoryManagerSet then
    Result:= -1
  else
  begin
    Result := 0;
    if APointer <> nil then
    begin
      U := APointer;
      U := PUsed(TJclAddr(U) - SizeOf(TUsed));
      if (U.SizeFlags and cThisUsedFlag) <> 0 then
        Result := (U.SizeFlags) and (not cFlags - SizeOf(TUsed));
    end;
  end;
end;
{$ENDIF MSWINDOWS}

{$IFDEF HAS_UNIT_LIBC}
function SizeOfMem(const APointer: Pointer): Integer;
begin
  if IsMemoryManagerSet then
    Result:= -1
  else
  begin
    if APointer <> nil then
      Result := malloc_usable_size(APointer)
    else
      Result := 0;
  end;
end;
{$ENDIF HAS_UNIT_LIBC}

{$IFDEF MSWINDOWS}
function WriteProtectedMemory(BaseAddress, Buffer: Pointer;
  Size: Cardinal; out WrittenBytes: Cardinal): Boolean;
var
  OldProtect, Dummy: Cardinal;
begin
  WrittenBytes := 0;
  if Size > 0 then
  begin
    // (outchy) VirtualProtect for DEP issues
    OldProtect := 0;
    Result := VirtualProtect(BaseAddress, Size, PAGE_EXECUTE_READWRITE, OldProtect);
    if Result then
    try
      Move(Buffer^, BaseAddress^, Size);
      WrittenBytes := Size;
      if OldProtect in [PAGE_EXECUTE, PAGE_EXECUTE_READ, PAGE_EXECUTE_READWRITE, PAGE_EXECUTE_WRITECOPY] then
        FlushInstructionCache(GetCurrentProcess, BaseAddress, Size);
    finally
      Dummy := 0;
      VirtualProtect(BaseAddress, Size, OldProtect, Dummy);
    end;
  end;
  Result := WrittenBytes = Size;
end;
{$ENDIF MSWINDOWS}
{$IFDEF HAS_UNIT_LIBC}
function WriteProtectedMemory(BaseAddress, Buffer: Pointer;
  Size: Cardinal; out WrittenBytes: Cardinal): Boolean;
{ TODO -cHelp : Author: Andreas Hausladen }
{ TODO : Works so far, but causes app to hang on termination }
var
  AlignedAddress: Cardinal;
  PageSize, ProtectSize: Cardinal;
begin
  Result := False;
  WrittenBytes := 0;

  PageSize := Cardinal(getpagesize);
  AlignedAddress := Cardinal(BaseAddress) and not (PageSize - 1); // start memory page
  // get the number of needed memory pages
  ProtectSize := PageSize;
  while Cardinal(BaseAddress) + Size > AlignedAddress + ProtectSize do
    Inc(ProtectSize, PageSize);

  if mprotect(Pointer(AlignedAddress), ProtectSize,
    PROT_READ or PROT_WRITE or PROT_EXEC) = 0 then // obtain write access
  begin
    try
      Move(Buffer^, BaseAddress^, Size); // replace code
      Result := True;
      WrittenBytes := Size;
    finally
      // Is there any function that returns the current page protection?
//    mprotect(p, ProtectSize, PROT_READ or PROT_EXEC); // lock memory page
    end;
  end;
end;

procedure FlushInstructionCache;
{ TODO -cHelp : Author: Andreas Hausladen }
begin
  // do nothing
end;

{$ENDIF HAS_UNIT_LIBC}

//=== Binary search ==========================================================

function SearchSortedList(List: TList; SortFunc: TListSortCompare; Item: Pointer; Nearest: Boolean): Integer;
var
  L, H, I, C: Integer;
  B: Boolean;
begin
  Result := -1;
  if List <> nil then
  begin
    L := 0;
    H := List.Count - 1;
    B := False;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := SortFunc(List.List{$IFNDEF RTL230_UP}^{$ENDIF !RTL230_UP}[I], Item);
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          B := True;
          L := I;
        end;
      end;
    end;
    if B then
      Result := L
    else
    if Nearest and (H >= 0) then
      Result := H;
  end;
end;

function SearchSortedUntyped(Param: Pointer; ItemCount: Integer; SearchFunc: TUntypedSearchCompare;
  const Value; Nearest: Boolean): Integer;
var
  L, H, I, C: Integer;
  B: Boolean;
begin
  Result := -1;
  if ItemCount > 0 then
  begin
    L := 0;
    H := ItemCount - 1;
    B := False;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := SearchFunc(Param, I, Value);
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          B := True;
          L := I;
        end;
      end;
    end;
    if B then
      Result := L
    else
    if Nearest and (H >= 0) then
      Result := H;
  end;
end;

//=== Dynamic array sort and search routines =================================

procedure SortDynArray(const ArrayPtr: Pointer; ElementSize: Cardinal; SortFunc: TDynArraySortCompare);
var
  TempBuf: TDynByteArray;

  procedure QuickSort(L, R: SizeInt);
  var
    I, J, T: SizeInt;
    P, IPtr, JPtr: Pointer;
    ElSize: Integer;
  begin
    ElSize := ElementSize;
    repeat
      I := L;
      J := R;
      P := Pointer(TJclAddr(ArrayPtr) + TJclAddr(((L + R) shr 1) * SizeInt(ElementSize)));
      repeat
        IPtr := Pointer(TJclAddr(ArrayPtr) + TJclAddr(I * SizeInt(ElementSize)));
        JPtr := Pointer(TJclAddr(ArrayPtr) + TJclAddr(J * SizeInt(ElementSize)));
        while SortFunc(IPtr, P) < 0 do
        begin
          Inc(I);
          Inc(PByte(IPtr), ElSize);
        end;
        while SortFunc(JPtr, P) > 0 do
        begin
          Dec(J);
          Dec(PByte(JPtr), ElSize);
        end;
        if I <= J then
        begin
          if I <> J then
          begin
            case ElementSize of
              SizeOf(Byte):
                begin
                  T := PByte(IPtr)^;
                  PByte(IPtr)^ := PByte(JPtr)^;
                  PByte(JPtr)^ := T;
                end;
              SizeOf(Word):
                begin
                  T := PWord(IPtr)^;
                  PWord(IPtr)^ := PWord(JPtr)^;
                  PWord(JPtr)^ := T;
                end;
              SizeOf(Integer):
                begin
                  T := PInteger(IPtr)^;
                  PInteger(IPtr)^ := PInteger(JPtr)^;
                  PInteger(JPtr)^ := T;
                end;
            else
              Move(IPtr^, TempBuf[0], ElementSize);
              Move(JPtr^, IPtr^, ElementSize);
              Move(TempBuf[0], JPtr^, ElementSize);
            end;
          end;
          if P = IPtr then
            P := JPtr
          else
          if P = JPtr then
            P := IPtr;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        QuickSort(L, J);
      L := I;
    until I >= R;
  end;

begin
  if ArrayPtr <> nil then
  begin
    SetLength(TempBuf, ElementSize);
    QuickSort(0, PSizeInt(TJclAddr(ArrayPtr) - SizeOf(SizeInt))^ - 1);
  end;
end;

function SearchDynArray(const ArrayPtr: Pointer; ElementSize: Cardinal; SortFunc: TDynArraySortCompare;
  ValuePtr: Pointer; Nearest: Boolean): SizeInt;
var
  L, H, I, C: SizeInt;
  B: Boolean;
begin
  Result := -1;
  if ArrayPtr <> nil then
  begin
    L := 0;
    H := PSizeInt(TJclAddr(ArrayPtr) - SizeOf(SizeInt))^ - 1;
    B := False;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := SortFunc(Pointer(TJclAddr(ArrayPtr) + TJclAddr(I * SizeInt(ElementSize))), ValuePtr);
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          B := True;
          L := I;
        end;
      end;
    end;
    if B then
      Result := L
    else
    if Nearest and (H >= 0) then
      Result := H;
  end;
end;

{ Various compare functions for basic types }

function DynArrayCompareByte(Item1, Item2: Pointer): Integer;
begin
  Result := PByte(Item1)^ - PByte(Item2)^;
end;

function DynArrayCompareShortInt(Item1, Item2: Pointer): Integer;
begin
  Result := PShortInt(Item1)^ - PShortInt(Item2)^;
end;

function DynArrayCompareWord(Item1, Item2: Pointer): Integer;
begin
  Result := PWord(Item1)^ - PWord(Item2)^;
end;

function DynArrayCompareSmallInt(Item1, Item2: Pointer): Integer;
begin
  Result := PSmallInt(Item1)^ - PSmallInt(Item2)^;
end;

function DynArrayCompareInteger(Item1, Item2: Pointer): Integer;
begin
  if PInteger(Item1)^ < PInteger(Item2)^ then
    Result := -1
  else
  if PInteger(Item1)^ > PInteger(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareCardinal(Item1, Item2: Pointer): Integer;
begin
  if PCardinal(Item1)^ < PCardinal(Item2)^ then
    Result := -1
  else
  if PCardinal(Item1)^ > PCardinal(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareInt64(Item1, Item2: Pointer): Integer;
begin
  if PInt64(Item1)^ < PInt64(Item2)^ then
    Result := -1
  else
  if PInt64(Item1)^ > PInt64(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareSingle(Item1, Item2: Pointer): Integer;
begin
  if PSingle(Item1)^ < PSingle(Item2)^ then
    Result := -1
  else
  if PSingle(Item1)^ > PSingle(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareDouble(Item1, Item2: Pointer): Integer;
begin
  if PDouble(Item1)^ < PDouble(Item2)^ then
    Result := -1
  else
  if PDouble(Item1)^ > PDouble(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareExtended(Item1, Item2: Pointer): Integer;
begin
  if PExtended(Item1)^ < PExtended(Item2)^ then
    Result := -1
  else
  if PExtended(Item1)^ > PExtended(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareFloat(Item1, Item2: Pointer): Integer;
begin
  if PFloat(Item1)^ < PFloat(Item2)^ then
    Result := -1
  else
  if PFloat(Item1)^ > PFloat(Item2)^ then
    Result := 1
  else
    Result := 0;
end;

function DynArrayCompareAnsiString(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareStr(PAnsiString(Item1)^, PAnsiString(Item2)^);
end;

function DynArrayCompareAnsiText(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareText(PAnsiString(Item1)^, PAnsiString(Item2)^);
end;

function DynArrayCompareWideString(Item1, Item2: Pointer): Integer;
begin
  Result := WideCompareStr(PWideString(Item1)^, PWideString(Item2)^);
end;

function DynArrayCompareWideText(Item1, Item2: Pointer): Integer;
begin
  Result := WideCompareText(PWideString(Item1)^, PWideString(Item2)^);
end;

function DynArrayCompareString(Item1, Item2: Pointer): Integer;
begin
  Result := CompareStr(PString(Item1)^, PString(Item2)^);
end;

function DynArrayCompareText(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(PString(Item1)^, PString(Item2)^);
end;

//=== Object lists ===========================================================

procedure ClearObjectList(List: TList);
var
  I: Integer;
begin
  if List <> nil then
  begin
    for I := List.Count - 1 downto 0 do
    begin
      if List[I] <> nil then
      begin
        if TObject(List[I]) is TList then
        begin
          // recursively delete TList sublists
          ClearObjectList(TList(List[I]));
        end;
        TObject(List[I]).Free;
        if (not (List is TComponentList))
          and ((not(List is TObjectList)) or not TObjectList(List).OwnsObjects) then
          List[I] := nil;
      end;
    end;
    List.Clear;
  end;
end;

procedure FreeObjectList(var List: TList);
begin
  if List <> nil then
  begin
    ClearObjectList(List);
    FreeAndNil(List);
  end;
end;

//=== { TJclReferenceMemoryStream } ==========================================

constructor TJclReferenceMemoryStream.Create(const Ptr: Pointer; Size: Longint);
begin
  {$IFDEF MSWINDOWS}
  Assert(not IsBadReadPtr(Ptr, Size));
  {$ENDIF MSWINDOWS}
  inherited Create;
  SetPointer(Ptr, Size);
end;

function TJclReferenceMemoryStream.Write(const Buffer; Count: Longint): Longint;
begin
  raise EJclError.CreateRes(@RsCannotWriteRefStream);
end;

//=== { TJclAutoPtr } ========================================================

constructor TJclAutoPtr.Create(AValue: TObject);
begin
  inherited Create;
  FValue := AValue;
end;

destructor TJclAutoPtr.Destroy;
begin
  FValue.Free;
  inherited Destroy;
end;

function TJclAutoPtr.AsObject: TObject;
begin
  Result := FValue;
end;

function TJclAutoPtr.AsPointer: Pointer;
begin
  Result := FValue;
end;

function TJclAutoPtr.ReleaseObject: TObject;
begin
  Result := FValue;
  FValue := nil;
end;

function CreateAutoPtr(Value: TObject): IAutoPtr;
begin
  Result := TJclAutoPtr.Create(Value);
end;

//=== replacement for the C distfix operator ? : =============================

function Iff(const Condition: Boolean; const TruePart, FalsePart: string): string;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Char): Char;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Byte): Byte;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Integer): Integer;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Cardinal): Cardinal;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Float): Float;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Boolean): Boolean;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Pointer): Pointer;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

function Iff(const Condition: Boolean; const TruePart, FalsePart: Int64): Int64;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

{$IFDEF SUPPORTS_VARIANT}
function Iff(const Condition: Boolean; const TruePart, FalsePart: Variant): Variant; overload;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;
{$ENDIF SUPPORTS_VARIANT}

//=== Classes information and manipulation ===================================
// Virtual Methods
// Helper method

{$IFDEF MSWINDOWS}
procedure SetVMTPointer(AClass: TClass; Offset: Integer; Value: Pointer);
var
  WrittenBytes: DWORD;
  PatchAddress: PPointer;
begin
  {$OVERFLOWCHECKS OFF}
  PatchAddress := Pointer(TJclAddr(AClass) + TJclAddr(Offset));
  {$IFDEF OVERFLOWCHECKS_ON}
  {$OVERFLOWCHECKS ON}
  {$ENDIF OVERFLOWCHECKS_ON}
  if not WriteProtectedMemory(PatchAddress, @Value, SizeOf(Value), WrittenBytes) then
    raise EJclVMTError.CreateResFmt(@RsVMTMemoryWriteError,
      [SysErrorMessage({$IFDEF FPC}GetLastOSError{$ELSE}GetLastError{$ENDIF})]);

  if WrittenBytes <> SizeOf(Pointer) then
    raise EJclVMTError.CreateResFmt(@RsVMTMemoryWriteError, [IntToStr(WrittenBytes)]);

  // make sure that everything keeps working in a dual processor setting
  // (outchy) done by WriteProtectedMemory
  // FlushInstructionCache{$IFDEF MSWINDOWS}(GetCurrentProcess, PatchAddress, SizeOf(Pointer)){$ENDIF};
end;
{$ENDIF}

{$IFNDEF FPC}
function GetVirtualMethodCount(AClass: TClass): Integer;
type
  PINT_PTR = ^INT_PTR;
var
  BeginVMT: INT_PTR;
  EndVMT: INT_PTR;
  TablePointer: INT_PTR;
  I: Integer;
begin
  BeginVMT := INT_PTR(AClass);

  // Scan the offset entries in the class table for the various fields,
  // namely vmtIntfTable, vmtAutoTable, ..., vmtDynamicTable
  // The last entry is always the vmtClassName, so stop once we got there
  // After the last virtual method there is one of these entries.

  EndVMT := PINT_PTR(INT_PTR(AClass) + vmtClassName)^;
  // Set iterator to first item behind VMT table pointer
  I := vmtSelfPtr + SizeOf(Pointer);
  repeat
    TablePointer := PINT_PTR(INT_PTR(AClass) + I)^;
    if (TablePointer <> 0) and (TablePointer >= BeginVMT) and
       (TablePointer < EndVMT) then
      EndVMT := INT_PTR(TablePointer);
    Inc(I, SizeOf(Pointer));
  until I >= vmtClassName;

  Result := (EndVMT - BeginVMT) div SizeOf(Pointer);
end;
{$ENDIF ~FPC}

function GetVirtualMethod(AClass: TClass; const Index: Integer): Pointer;
begin
  {$OVERFLOWCHECKS OFF}
  Result := PPointer(TJclAddr(AClass) + TJclAddr(Index * SizeOf(Pointer)))^;
  {$IFDEF OVERFLOWCHECKS_ON}
  {$OVERFLOWCHECKS ON}
  {$ENDIF OVERFLOWCHECKS_ON}
end;

{$IFDEF MSWINDOWS}
procedure SetVirtualMethod(AClass: TClass; const Index: Integer; const Method: Pointer);
begin
  SetVMTPointer(AClass, Index * SizeOf(Pointer), Method);
end;
{$ENDIF}

function GetDynamicMethodCount(AClass: TClass): Integer; assembler;
asm
        {$IFDEF CPU32}
        // --> RAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtDynamicTable
        TEST    EAX, EAX
        JE      @@Exit
        MOVZX   EAX, WORD PTR [EAX]
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- EAX Result
        MOV     RAX, [RCX].vmtDynamicTable
        TEST    RAX, RAX
        JE      @@Exit
        MOVZX   RAX, WORD PTR [RAX]
        {$ENDIF CPU64}
@@Exit:
end;

function GetDynamicIndexList(AClass: TClass): PDynamicIndexList; assembler;
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtDynamicTable
        ADD     EAX, 2
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- RAX Result
        MOV     RAX, [RCX].vmtDynamicTable
        ADD     RAX, 2
        {$ENDIF CPU64}
end;

function GetDynamicAddressList(AClass: TClass): PDynamicAddressList; assembler;
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtDynamicTable
        MOVZX   EDX, Word ptr [EAX]
        ADD     EAX, EDX
        ADD     EAX, EDX
        ADD     EAX, 2
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- RAX Result
        MOV     RAX, [RCX].vmtDynamicTable
        MOVZX   RDX, Word ptr [RAX]
        ADD     RAX, RDX
        ADD     RAX, RDX
        ADD     RAX, 2
        {$ENDIF CPU64}
end;

function HasDynamicMethod(AClass: TClass; Index: Integer): Boolean; assembler;
// Mainly copied from System.GetDynaMethod
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        //     EDX Index
        // <-- AL  Result
        PUSH    EDI
        XCHG    EAX, EDX
        JMP     @@HaveVMT
@@OuterLoop:
        MOV     EDX, [EDX]
@@HaveVMT:
        MOV     EDI, [EDX].vmtDynamicTable
        TEST    EDI, EDI
        JE      @@Parent
        MOVZX   ECX, WORD PTR [EDI]
        PUSH    ECX
        ADD     EDI,2
        REPNE   SCASW
        JE      @@Found
        POP     ECX
@@Parent:
        MOV     EDX,[EDX].vmtParent
        TEST    EDX,EDX
        JNE     @@OuterLoop
        MOV     EAX, 0
        JMP     @@Exit
@@Found:
        POP     EAX
        MOV     EAX, 1
@@Exit:
        POP     EDI
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        //     EDX Index
        // <-- AL  Result
        MOV     EAX, EDX
        MOV     RDX, RCX
        JMP     @@HaveVMT
@@OuterLoop:
        MOV     RDX, [RDX]
@@HaveVMT:
        MOV     RDI, [RDX].vmtDynamicTable
        TEST    RDI, RDI
        JE      @@Parent
        MOVZX   RCX, WORD PTR [RDI]
        PUSH    RCX
        ADD     RDI,2
        REPNE   SCASW
        JE      @@Found
        POP     RCX
@@Parent:
        MOV     RDX,[RDX].vmtParent
        TEST    RDX,RDX
        JNE     @@OuterLoop
        MOV     RAX, 0
        JMP     @@Exit
@@Found:
        POP     RAX
        MOV     RAX, 1
@@Exit:
        {$ENDIF CPU64}
end;

{$IFNDEF FPC}
function GetDynamicMethod(AClass: TClass; Index: Integer): Pointer; assembler;
asm
        CALL    System.@FindDynaClass
end;
{$ENDIF ~FPC}

//=== Interface Table ========================================================

function GetInitTable(AClass: TClass): PTypeInfo; assembler;
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtInitTable
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- RAX Result
        MOV     RAX, [RCX].vmtInitTable
        {$ENDIF CPU64}
end;

function GetFieldTable(AClass: TClass): PFieldTable; assembler;
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtFieldTable
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- RAX Result
        MOV     RAX, [RCX].vmtFieldTable
        {$ENDIF CPU64}
end;

function GetMethodTable(AClass: TClass): PMethodTable; assembler;
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtMethodTable
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- RAX Result
        MOV     RAX, [RCX].vmtMethodTable
        {$ENDIF CPU64}
end;

function GetMethodEntry(MethodTable: PMethodTable; Index: Integer): PMethodEntry;
begin
  Result := Pointer(TJclAddr(MethodTable) + 2);
  for Index := Index downto 1 do
    Inc(TJclAddr(Result), Result^.EntrySize);
end;

function MethodEquals(aMethod1, aMethod2: TMethod): boolean;
begin
  Result := (aMethod1.Code = aMethod2.Code) and
            (aMethod1.Data = aMethod2.Data);
end;
function NotifyEventEquals(aMethod1, aMethod2: TNotifyEvent): boolean;
begin
  Result := MethodEquals(TMethod(aMethod1),TMethod(aMethod2));
end;

//=== Class Parent methods ===================================================

{$IFDEF MSWINDOWS}
procedure SetClassParent(AClass: TClass; NewClassParent: TClass);
var
  WrittenBytes: DWORD;
  PatchAddress: Pointer;
begin
  {$OVERFLOWCHECKS OFF}
  PatchAddress := PPointer(TJclAddr(AClass) + TJclAddr(vmtParent))^;
  {$IFDEF OVERFLOWCHECKS_ON}
  {$OVERFLOWCHECKS ON}
  {$ENDIF OVERFLOWCHECKS_ON}
  if not WriteProtectedMemory(PatchAddress, @NewClassParent, SizeOf(Pointer), WrittenBytes) then
    raise EJclVMTError.CreateResFmt(@RsVMTMemoryWriteError,
      [SysErrorMessage({$IFDEF FPC}GetLastOSError{$ELSE}GetLastError{$ENDIF})]);
  if WrittenBytes <> SizeOf(Pointer) then
    raise EJclVMTError.CreateResFmt(@RsVMTMemoryWriteError, [IntToStr(WrittenBytes)]);
  // make sure that everything keeps working in a dual processor setting
  // (outchy) done by WriteProtectedMemory
  // FlushInstructionCache{$IFDEF MSWINDOWS}(GetCurrentProcess, PatchAddress, SizeOf(Pointer)){$ENDIF};
end;
{$ENDIF}

function GetClassParent(AClass: TClass): TClass; assembler;
asm
        {$IFDEF CPU32}
        // --> EAX AClass
        // <-- EAX Result
        MOV     EAX, [EAX].vmtParent
        TEST    EAX, EAX
        JE      @@Exit
        MOV     EAX, [EAX]
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX AClass
        // <-- RAX Result
        MOV     RAX, [RCX].vmtParent
        TEST    RAX, RAX
        JE      @@Exit
        MOV     RAX, [RAX]
        {$ENDIF CPU64}
@@Exit:
end;

{$IFDEF BORLAND}
function IsClass(Address: Pointer): Boolean; assembler;
asm
        CMP     Address, Address.vmtSelfPtr
        JNZ     @False
        MOV     Result, True
        JMP     @Exit
@False:
        MOV     Result, False
@Exit:
end;
{$ENDIF BORLAND}

{$IFDEF BORLAND}
function IsObject(Address: Pointer): Boolean; assembler;
asm
// or IsClass(Pointer(Address^));
        MOV     EAX, [Address]
        CMP     EAX, EAX.vmtSelfPtr
        JNZ     @False
        MOV     Result, True
        JMP     @Exit
@False:
        MOV     Result, False
@Exit:
end;
{$ENDIF BORLAND}

function InheritsFromByName(AClass: TClass; const AClassName: string): Boolean;
begin
  while (AClass <> nil) and not AClass.ClassNameIs(AClassName) do
    AClass := AClass.ClassParent;
  Result := AClass <> nil;
end;

//=== Interface information ==================================================

function GetImplementorOfInterface(const I: IInterface): TObject;
{ TODO -cDOC : Original code by Hallvard Vassbotn }
{ TODO -cTesting : Check the implemetation for any further version of compiler }
const
  AddByte = $04244483; // opcode for ADD DWORD PTR [ESP+4], Shortint
  AddLong = $04244481; // opcode for ADD DWORD PTR [ESP+4], Longint
type
  PAdjustSelfThunk = ^TAdjustSelfThunk;
  TAdjustSelfThunk = packed record
    case AddInstruction: Longint of
      AddByte: (AdjustmentByte: ShortInt);
      AddLong: (AdjustmentLong: Longint);
  end;
  PInterfaceMT = ^TInterfaceMT;
  TInterfaceMT = packed record
    QueryInterfaceThunk: PAdjustSelfThunk;
  end;
  TInterfaceRef = ^PInterfaceMT;
var
  QueryInterfaceThunk: PAdjustSelfThunk;
begin
  try
    Result := Pointer(I);
    if Assigned(Result) then
    begin
      QueryInterfaceThunk := TInterfaceRef(I)^.QueryInterfaceThunk;
      case QueryInterfaceThunk.AddInstruction of
        AddByte:
          Inc(PByte(Result), QueryInterfaceThunk.AdjustmentByte);
        AddLong:
          Inc(PByte(Result), QueryInterfaceThunk.AdjustmentLong);
      else
        Result := nil;
      end;
    end;
  except
    Result := nil;
  end;
end;

//=== Loading of modules (DLLs) ==============================================

function LoadModule(var Module: TModuleHandle; FileName: string): Boolean;
{$IFDEF MSWINDOWS}
begin
  if Module = INVALID_MODULEHANDLE_VALUE then
    Module := SafeLoadLibrary(FileName);
  Result := Module <> INVALID_MODULEHANDLE_VALUE;
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
begin
  if Module = INVALID_MODULEHANDLE_VALUE then
    Module := dlopen(PChar(FileName), RTLD_NOW);
  Result := Module <> INVALID_MODULEHANDLE_VALUE;
end;
{$ENDIF UNIX}

function LoadModuleEx(var Module: TModuleHandle; FileName: string; Flags: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
begin
  if Module = INVALID_MODULEHANDLE_VALUE then
    Module := LoadLibraryEx(PChar(FileName), 0, Flags); // SafeLoadLibrary?
  Result := Module <> INVALID_MODULEHANDLE_VALUE;
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
begin
  if Module = INVALID_MODULEHANDLE_VALUE then
    Module := dlopen(PChar(FileName), Flags);
  Result := Module <> INVALID_MODULEHANDLE_VALUE;
end;
{$ENDIF UNIX}

procedure UnloadModule(var Module: TModuleHandle);
{$IFDEF MSWINDOWS}
begin
  if Module <> INVALID_MODULEHANDLE_VALUE then
    FreeLibrary(Module);
  Module := INVALID_MODULEHANDLE_VALUE;
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
begin
  if Module <> INVALID_MODULEHANDLE_VALUE then
    dlclose(Pointer(Module));
  Module := INVALID_MODULEHANDLE_VALUE;
end;
{$ENDIF UNIX}

function GetModuleSymbol(Module: TModuleHandle; SymbolName: string): Pointer;
{$IFDEF MSWINDOWS}
begin
  Result := nil;
  if Module <> INVALID_MODULEHANDLE_VALUE then
    Result := GetProcAddress(Module, PChar(SymbolName));
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
begin
  Result := nil;
  if Module <> INVALID_MODULEHANDLE_VALUE then
    Result := dlsym(Module, PChar(SymbolName));
end;
{$ENDIF UNIX}

function GetModuleSymbolEx(Module: TModuleHandle; SymbolName: string; var Accu: Boolean): Pointer;
{$IFDEF MSWINDOWS}
begin
  Result := nil;
  if Module <> INVALID_MODULEHANDLE_VALUE then
    Result := GetProcAddress(Module, PChar(SymbolName));
  Accu := Accu and (Result <> nil);
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
begin
  Result := nil;
  if Module <> INVALID_MODULEHANDLE_VALUE then
    Result := dlsym(Module, PChar(SymbolName));
  Accu := Accu and (Result <> nil);
end;
{$ENDIF UNIX}

function ReadModuleData(Module: TModuleHandle; SymbolName: string; var Buffer; Size: Cardinal): Boolean;
var
  Sym: Pointer;
begin
  Result := True;
  Sym := GetModuleSymbolEx(Module, SymbolName, Result);
  if Result then
    Move(Sym^, Buffer, Size);
end;

function WriteModuleData(Module: TModuleHandle; SymbolName: string; var Buffer; Size: Cardinal): Boolean;
var
  Sym: Pointer;
begin
  Result := True;
  Sym := GetModuleSymbolEx(Module, SymbolName, Result);
  if Result then
    Move(Buffer, Sym^, Size);
end;

//=== Conversion Utilities ===================================================

const
  DefaultTrueBoolStr  = 'True';  // DO NOT LOCALIZE
  DefaultFalseBoolStr = 'False'; // DO NOT LOCALIZE

  DefaultYesBoolStr   = 'Yes';   // DO NOT LOCALIZE
  DefaultNoBoolStr    = 'No';    // DO NOT LOCALIZE

function StrToBoolean(const S: string): Boolean;
var
  LowerCasedText: string;
begin
  { TODO : Possibility to add localized strings, like in Delphi 7 }
  { TODO : Lower case constants }
  LowerCasedText := LowerCase(S);
  Result := ((S = '1') or
    (LowerCasedText = LowerCase(DefaultTrueBoolStr)) or (LowerCasedText = LowerCase(DefaultYesBoolStr))) or
    (LowerCasedText = LowerCase(DefaultTrueBoolStr[1])) or (LowerCasedText = LowerCase(DefaultYesBoolStr[1]));
  if not Result then
  begin
    Result := not ((S = '0') or
      (LowerCasedText = LowerCase(DefaultFalseBoolStr)) or (LowerCasedText = LowerCase(DefaultNoBoolStr)) or
      (LowerCasedText = LowerCase(DefaultFalseBoolStr[1])) or (LowerCasedText = LowerCase(DefaultNoBoolStr[1])));
    if Result then
      raise EJclConversionError.CreateResFmt(@RsStringToBoolean, [S]);
  end;
end;

function BooleanToStr(B: Boolean): string;
begin
  if B then
    Result := DefaultTrueBoolStr
  else
    Result := DefaultFalseBoolStr;
end;

function IntToBool(I: Integer): Boolean;
begin
  Result := I <> 0;
end;

function BoolToInt(B: Boolean): Integer;
begin
  Result := Ord(B);
end;

function TryStrToUInt(const Value: string; out Res: Cardinal): Boolean;
var i6: Int64;
begin
  Result := false;
  if not TryStrToInt64(Value, i6) then exit;
  if ( i6 < Low(Res)) or ( i6 > High(Res)) then exit;

  Result := true;
  Res := i6;
end;

function StrToUIntDef(const Value: string; const Default: Cardinal): Cardinal;
begin
  if not TryStrToUInt(Value, Result)
     then Result := Default;
end;

function StrToUInt(const Value: string): Cardinal;
begin
  if not TryStrToUInt(Value, Result)
     then raise EConvertError.Create('"'+Value+'" is not within range of Cardinal data type');
end;

//=== RTL package information ================================================

{$IFDEF MSWINDOWS}
function SystemTObjectInstance: TJclAddr;
begin
  Result := ModuleFromAddr(Pointer(System.TObject));
end;

function IsCompiledWithPackages: Boolean;
begin
  Result := SystemTObjectInstance <> HInstance;
end;
{$ENDIF MSWINDOWS}

//=== GUID ===================================================================

function JclGUIDToString(const GUID: TGUID): string;
begin
  Result := Format('{%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x}',
    [GUID.D1, GUID.D2, GUID.D3, GUID.D4[0], GUID.D4[1], GUID.D4[2],
     GUID.D4[3], GUID.D4[4], GUID.D4[5], GUID.D4[6], GUID.D4[7]]);
end;

function JclStringToGUID(const S: string): TGUID;
begin
  if (Length(S) <> 38) or (S[1] <> '{') or (S[10] <> '-') or (S[15] <> '-') or
    (S[20] <> '-') or (S[25] <> '-') or (S[38] <> '}') then
    raise EJclConversionError.CreateResFmt(@RsInvalidGUIDString, [S]);

  Result.D1 := StrToInt('$' + Copy(S, 2, 8));
  Result.D2 := StrToInt('$' + Copy(S, 11, 4));
  Result.D3 := StrToInt('$' + Copy(S, 16, 4));
  Result.D4[0] := StrToInt('$' + Copy(S, 21, 2));
  Result.D4[1] := StrToInt('$' + Copy(S, 23, 2));
  Result.D4[2] := StrToInt('$' + Copy(S, 26, 2));
  Result.D4[3] := StrToInt('$' + Copy(S, 28, 2));
  Result.D4[4] := StrToInt('$' + Copy(S, 30, 2));
  Result.D4[5] := StrToInt('$' + Copy(S, 32, 2));
  Result.D4[6] := StrToInt('$' + Copy(S, 34, 2));
  Result.D4[7] := StrToInt('$' + Copy(S, 36, 2));
end;

function GUIDEquals(const GUID1, GUID2: TGUID): Boolean;
begin
  Result := (GUID1.D1 = GUID2.D1) and (GUID1.D2 = GUID2.D2) and (GUID1.D3 = GUID2.D3) and
    (GUID1.D4[0] = GUID2.D4[0]) and (GUID1.D4[1] = GUID2.D4[1]) and
    (GUID1.D4[2] = GUID2.D4[2]) and (GUID1.D4[3] = GUID2.D4[3]) and
    (GUID1.D4[4] = GUID2.D4[4]) and (GUID1.D4[5] = GUID2.D4[5]) and
    (GUID1.D4[6] = GUID2.D4[6]) and (GUID1.D4[7] = GUID2.D4[7]);
end;

// add items at the end
procedure ListAddItems(var List: string; const Separator, Items: string);
var
  StrList, NewItems: TStringList;
  Index: Integer;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    NewItems := TStringList.Create;
    try
      StrToStrings(Items, Separator, NewItems);

      for Index := 0 to NewItems.Count - 1 do
        StrList.Add(NewItems.Strings[Index]);

      List := StringsToStr(StrList, Separator);
    finally
      NewItems.Free;
    end;
  finally
    StrList.Free;
  end;
end;

// add items at the end if they are not present
procedure ListIncludeItems(var List: string; const Separator, Items: string);
var
  StrList, NewItems: TStringList;
  Index: Integer;
  Item: string;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    NewItems := TStringList.Create;
    try
      StrToStrings(Items, Separator, NewItems);

      for Index := 0 to NewItems.Count - 1 do
      begin
        Item := NewItems.Strings[Index];
        if StrList.IndexOf(Item) = -1 then
          StrList.Add(Item);
      end;

      List := StringsToStr(StrList, Separator);
    finally
      NewItems.Free;
    end;
  finally
    StrList.Free;
  end;
end;

// delete multiple items
procedure ListRemoveItems(var List: string; const Separator, Items: string);
var
  StrList, RemItems: TStringList;
  Index, Position: Integer;
  Item: string;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    RemItems := TStringList.Create;
    try
      StrToStrings(Items, Separator, RemItems, False);

      for Index := 0 to RemItems.Count - 1 do
      begin
        Item := RemItems.Strings[Index];
        repeat
          Position := StrList.IndexOf(Item);
          if Position >= 0 then
            StrList.Delete(Position);
        until Position < 0;
      end;

      List := StringsToStr(StrList, Separator);
    finally
      RemItems.Free;
    end;
  finally
    StrList.Free;
  end;
end;

// delete one item
procedure ListDelItem(var List: string; const Separator: string; const Index: Integer);
var
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    StrList.Delete(Index);

    List := StringsToStr(StrList, Separator);
  finally
    StrList.Free;
  end;
end;

// return the number of item
function ListItemCount(const List, Separator: string): Integer;
var
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    Result := StrList.Count;
  finally
    StrList.Free;
  end;
end;

// return the Nth item
function ListGetItem(const List, Separator: string; const Index: Integer): string;
var
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    Result := StrList.Strings[Index];
  finally
    StrList.Free;
  end;
end;

// set the Nth item
procedure ListSetItem(var List: string; const Separator: string;
  const Index: Integer; const Value: string);
var
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    StrList.Strings[Index] := Value;

    List := StringsToStr(StrList, Separator);
  finally
    StrList.Free;
  end;
end;

// return the index of an item
function ListItemIndex(const List, Separator, Item: string): Integer;
var
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrToStrings(List, Separator, StrList, False);

    Result := StrList.IndexOf(Item);
  finally
    StrList.Free;
  end;
end;

//=== { TJclIntfCriticalSection } ============================================

constructor TJclIntfCriticalSection.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TJclIntfCriticalSection.Destroy;
begin
  FCriticalSection.Free;
  inherited Destroy;
end;

function TJclIntfCriticalSection._AddRef: Integer;
begin
  FCriticalSection.Acquire;
  Result := -1;
end;

function TJclIntfCriticalSection._Release: Integer;
begin
  FCriticalSection.Release;
  Result := -1;
end;

end.
