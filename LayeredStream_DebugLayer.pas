{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Debug layer

    Custom debugging layer used for testing of LayeredStream library.

    Not intended for general use.

  Version 1.0 beta 2 (2021-03-14)

  Last change 2021-03-14

  ©2020-2021 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/LayeredStream

  Dependencies:
    AuxTypes          - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses        - github.com/TheLazyTomcat/Lib.AuxClasses
    SimpleNamedValues - github.com/TheLazyTomcat/Lib.SimpleNamedValues

  Dependencies required by implemented layers:
    Adler32            - github.com/TheLazyTomcat/Lib.Adler32
    CRC32              - github.com/TheLazyTomcat/Lib.CRC32
    MD2                - github.com/TheLazyTomcat/Lib.MD2
    MD4                - github.com/TheLazyTomcat/Lib.MD4
    MD5                - github.com/TheLazyTomcat/Lib.MD5
    SHA0               - github.com/TheLazyTomcat/Lib.SHA0
    SHA1               - github.com/TheLazyTomcat/Lib.SHA1
    SHA2               - github.com/TheLazyTomcat/Lib.SHA2
    SHA3               - github.com/TheLazyTomcat/Lib.SHA3
    CityHash           - github.com/TheLazyTomcat/Lib.CityHash
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID
    BitOps             - github.com/TheLazyTomcat/Lib.BitOps
    UInt64Utils        - github.com/TheLazyTomcat/Lib.UInt64Utils
    MemoryBuffer       - github.com/TheLazyTomcat/Lib.MemoryBuffer
    ZLibUtils          - github.com/TheLazyTomcat/Lib.ZLibUtils
    DynLibUtils        - github.com/TheLazyTomcat/Lib.DynLibUtils
    ZLib               - github.com/TheLazyTomcat/Bnd.ZLib

  SimpleCPUID might not be needed, see BitOps and CRC32 libraries for details.

===============================================================================}
unit LayeredStream_DebugLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream_Layers;

{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerReader - class declaration
===============================================================================}
type
  TDebugLayerReader = class(TLSLayerReader)
  protected
    fDebugging: Boolean;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    procedure DebugStart; virtual;
    procedure DebugStop; virtual;
    property Debugging: Boolean read fDebugging;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerWriter - class declaration
===============================================================================}
type
  TDebugLayerWriter = class(TLSLayerWriter)
  protected
    fDebugging: Boolean;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    procedure DebugStart; virtual;
    procedure DebugStop; virtual;
    property Debugging: Boolean read fDebugging;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerReader - class declaration
===============================================================================}
type
  TDebugLowLayerReader = class(TDebugLayerReader)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerReader - class declaration
===============================================================================}
type
  TDebugHighLayerReader = class(TDebugLayerReader)
  private
    fMemory:  Pointer;
    fSize:    LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure DebugStop; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerWriter                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerWriter - class declaration
===============================================================================}
type
  TDebugLowLayerWriter = class(TDebugLayerWriter)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerWriter - class declaration
===============================================================================}
type
  TDebugHighLayerWriter = class(TDebugLayerWriter)
  private
    fMemory:  Pointer;
    fSize:    LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
  end;

implementation

uses
  LayeredStream;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

const
  DEBUGLAYER_SIZE_DEFAULT = 1024;  // 1KiB

{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TDebugLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fDebugging := False;
end;

{-------------------------------------------------------------------------------
    TDebugLayerReader - public methods
-------------------------------------------------------------------------------}

procedure TDebugLayerReader.DebugStart;
begin
fDebugging := True;
end;

//------------------------------------------------------------------------------

procedure TDebugLayerReader.DebugStop;
begin
fDebugging := False;
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TDebugLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fDebugging := False;
end;

{-------------------------------------------------------------------------------
    TDebugLayerWriter - public methods
-------------------------------------------------------------------------------}

procedure TDebugLayerWriter.DebugStart;
begin
fDebugging := True;
end;

//------------------------------------------------------------------------------

procedure TDebugLayerWriter.DebugStop;
begin
fDebugging := False;
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLowLayerReader - protected methods    
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugLowLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := Random(DEBUGLAYER_SIZE_DEFAULT + 1);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TDebugLowLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
If fDebugging then
  begin
    // decide whether to fill entire buffer, its part, or return nothing at all
    case Random(5) of // 0..4
      0:  Result := 0;
      4:  Result := Size;
    else
      Result := Random(Size) + 1;
    end;
    // fill the output
    If Result > 0 then
      begin
        BuffPtr := @Buffer;
        For i := 1 to Result do
          begin
            BuffPtr^ := Byte(Random(256));
            Inc(BuffPtr);
          end;
      end;
    // do not propagate reading to next layer
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

procedure TDebugLowLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
end;

{-------------------------------------------------------------------------------
    TDebugLowLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TDebugLowLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugHighLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TDebugHighLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugHighLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
{
  buffer and size are ignored, internal buffer is used and size is randomized,
  return value is a true return value from a call to ReadOut

  note that buffer can be nil^ since it is not accessed in any way
}
If fDebugging then
  begin
    FillChar(fMemory^,fSize,0);
    // decide whether to read full buffer, nothing, or something in between
    case Random(5) of // 0..4
      0:  Size := 0;
      4:  Size := fSize;
    else
      Size := Random(fSize) + 1;
    end;
    // do reading
    Result := ReadOut(fMemory^,Size);
  end
else Result := ReadOut(fMemory^,fSize);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TDebugHighLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
fSize := DEBUGLAYER_SIZE_DEFAULT;
GetIntegerNamedValue(Params,'TDebugHighLayerReader.Size',fSize);
GetMem(fMemory,fSize);
end;

//------------------------------------------------------------------------------

procedure TDebugHighLayerReader.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TDebugHighLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TDebugHighLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;

//------------------------------------------------------------------------------

class Function TDebugHighLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TDebugHighLayerReader.Size',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TDebugHighLayerReader.DebugStop;
begin
fDebugging := False;
while ReadOut(fMemory^,fSize) <> 0 do;
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerWriter                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerWriter - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLowLayerWriter - protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugLowLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := Random(DEBUGLAYER_SIZE_DEFAULT + 1);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugLowLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
{
  decide whether to write entire buffer, its part, or nothing at all
  do not propagate writing to next layer, discard the actual data
}
If fDebugging then
  case Random(5) of // 0..4
    0:  Result := 0;
    4:  Result := Size;
  else
    Result := Random(Size) + 1;
  end
else Result := Size;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TDebugLowLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
end;

{-------------------------------------------------------------------------------
    TDebugLowLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TDebugLowLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugHighLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TDebugHighLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugHighLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
If fDebugging then
  begin
    FillChar(fMemory^,fSize,0);
    // decide whether to pass entire buffer, its part, or nothing
    case Random(5) of // 0..4
      0:  Size := 0;
      4:  Size := fSize;
    else
      Size := Random(fSize) + 1;
    end;
    // fill buffer
    If Size > 0 then
      begin
        BuffPtr := fMemory;
        For i := 1 to Size do
          begin
            BuffPtr^ := Byte(Random(256));
            Inc(BuffPtr);
          end;
      end;
    // pass it to the next layer for writing
    Result := WriteOut(fMemory^,Size);
  end
else Result := WriteOut(fMemory^,0);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TDebugHighLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
fSize := DEBUGLAYER_SIZE_DEFAULT;
GetIntegerNamedValue(Params,'TDebugHighLayerWriter.Size',fSize);
GetMem(fMemory,fSize);
end;

//------------------------------------------------------------------------------

procedure TDebugHighLayerWriter.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TDebugHighLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TDebugHighLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;

//------------------------------------------------------------------------------

class Function TDebugHighLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TDebugHighLayerWriter.Size',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_DebugLow',TDebugLowLayerReader,TDebugLowLayerWriter);
  RegisterLayer('LSRL_DebugHigh',TDebugHighLayerReader,TDebugHighLayerWriter);

end.
