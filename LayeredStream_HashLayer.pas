unit LayeredStream_HashLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, HashBase,
  LayeredStream_Layers;

{===============================================================================
    Local exceptions
===============================================================================}
type
{
  ELSHasherNotAssigned is raised when no hasher object is passed to creation of
  TCustomHashLayerReader/Writer object.
}
  ELSHasherNotAssigned = class(ELSException);

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerReader - class declaration
===============================================================================}
type
  THashLayerReader = class(TLSLayerReader)
  protected
    fHashing: Boolean;
    fHasher:  THashBase;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Hashing: Boolean read fHashing;
    property Hasher: THashBase read fHasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerWriter - class declaration
===============================================================================}
type
  THashLayerWriter = class(TLSLayerWriter)
  protected
    fHashing: Boolean;
    fHasher:  THashBase;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Hashing: Boolean read fHashing;
    property Hasher: THashBase read fHasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TStreamHashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStreamHashLayerReader - class declaration
===============================================================================}
type
  TStreamHashLayerReader = class(THashLayerReader);

{===============================================================================
--------------------------------------------------------------------------------
                             TStreamHashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStreamHashLayerWriter - class declaration
===============================================================================}
type
  TStreamHashLayerWriter = class(THashLayerWriter);

{===============================================================================
--------------------------------------------------------------------------------
                             TBlockHashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBlockHashLayerReader - class declaration
===============================================================================}
type
  TBlockHashLayerReader = class(THashLayerReader)
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBlockHashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBlockHashLayerWriter - class declaration
===============================================================================}
type
  TBlockHashLayerWriter = class(THashLayerWriter)
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBufferHashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferHashLayerReader - class declaration
===============================================================================}
type
  TBufferHashLayerReader = class(THashLayerReader)
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBufferHashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferHashLayerWriter - class declaration
===============================================================================}
type
  TBufferHashLayerWriter = class(THashLayerWriter)
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCustomHashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCustomHashLayerReader - class declaration
===============================================================================}
type
  TCustomHashLayerReader = class(THashLayerReader)
  private
    fOwnsHasher:  Boolean;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    property OwnsHasher: Boolean read fOwnsHasher write fOwnsHasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCustomHashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCustomHashLayerWriter - class declaration
===============================================================================}
type
  TCustomHashLayerWriter = class(THashLayerWriter)
  private
    fOwnsHasher:  Boolean;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    property OwnsHasher: Boolean read fOwnsHasher write fOwnsHasher;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    THashLayerReader - protected methods
-------------------------------------------------------------------------------}

Function THashLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function THashLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := ReadOut(Buffer,Size);
If (Result >= 0) and fHashing then
  fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHashing := False;
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Finalize;
begin
If Assigned(fHasher) then
  fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    THashLayerReader - public methods
-------------------------------------------------------------------------------}

class Function THashLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Init(Params: TSimpleNamedValues);
begin
If not fHashing then
  begin
    inherited;
    fHashing := True;
    fHasher.Init;
  end;
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Final;
begin
If fHashing then
  begin
    fHasher.Final;
    fHashing := False;
    inherited;
  end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    THashLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function THashLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function THashLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
Result := WriteOut(Buffer,Size);
If (Result >= 0) and fHashing then
  fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHashing := False;
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Finalize;
begin
If Assigned(fHasher) then
  fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function THashLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Init(Params: TSimpleNamedValues);
begin
If not fHashing then
  begin
    inherited;
    fHashing := True;
    fHasher.Init;
  end;
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Final;
begin
If fHashing then
  begin
    fHasher.Final;
    fHashing := False;
    inherited;
  end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBlockHashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBlockHashLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBlockHashLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TBlockHashLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := inherited LayerObjectProperties + [lopAccumulator];
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBlockHashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBlockHashLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBlockHashLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TBlockHashLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := inherited LayerObjectProperties + [lopAccumulator];
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBufferHashLayerReader                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferHashLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferHashLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TBufferHashLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := inherited LayerObjectProperties + [lopAccumulator];
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TBufferHashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferHashLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferHashLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TBufferHashLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := inherited LayerObjectProperties + [lopAccumulator];
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCustomHashLayerReader                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCustomHashLayerReader - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TCustomHashLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCustomHashLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := nil;
fOwnsHasher := False;
GetNamedValue(Params,'TCustomHashLayerReader.Hasher',Pointer(fHasher));
GetNamedValue(Params,'TCustomHashLayerReader.OwnsHasher',fOwnsHasher);
If not Assigned(fHasher) then
  raise ELSHasherNotAssigned.Create('TCustomHashLayerReader.Initialize: No hasher object provided.');
end;

//------------------------------------------------------------------------------

procedure TCustomHashLayerReader.Finalize;
begin
{
  The inherited code automatically frees the fHasher, but if it is not owned,
  the freeing cannot be allowed.
  The inherited code checks for assignment, so we just put nil to fHasher field
  and the inherited code will not free it. But the hasher object must be freed
  externally. 
}
If not fOwnsHasher then
  fHasher := nil;
inherited;  // frees the hasher
end;

{-------------------------------------------------------------------------------
    TCustomHashLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCustomHashLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := inherited LayerObjectProperties + [lopCustom];
end;

//------------------------------------------------------------------------------

class Function TCustomHashLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TCustomHashLayerReader.Hasher',nvtPointer,[loprConstructor]);
Result[1] := LayerObjectParam('TCustomHashLayerReader.OwnsHasher',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TCustomHashLayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TCustomHashLayerReader.OwnsHasher',fOwnsHasher);
end;

//------------------------------------------------------------------------------

procedure TCustomHashLayerReader.Update(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TCustomHashLayerReader.OwnsHasher',fOwnsHasher);
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCustomHashLayerWriter                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCustomHashLayerWriter - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TCustomHashLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCustomHashLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := nil;
fOwnsHasher := False;
GetNamedValue(Params,'TCustomHashLayerWriter.Hasher',Pointer(fHasher));
GetNamedValue(Params,'TCustomHashLayerWriter.OwnsHasher',fOwnsHasher);
If not Assigned(fHasher) then
  raise ELSHasherNotAssigned.Create('TCustomHashLayerWriter.Initialize: No hasher object provided.');
end;

//------------------------------------------------------------------------------

procedure TCustomHashLayerWriter.Finalize;
begin
If not fOwnsHasher then
  fHasher := nil;
inherited;  // frees the hasher
end;

{-------------------------------------------------------------------------------
    TCustomHashLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCustomHashLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := inherited LayerObjectProperties + [lopCustom];
end;

//------------------------------------------------------------------------------

class Function TCustomHashLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TCustomHashLayerWriter.Hasher',nvtPointer,[loprConstructor]);
Result[1] := LayerObjectParam('TCustomHashLayerWriter.OwnsHasher',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TCustomHashLayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TCustomHashLayerWriter.OwnsHasher',fOwnsHasher);
end;

//------------------------------------------------------------------------------

procedure TCustomHashLayerWriter.Update(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TCustomHashLayerWriter.OwnsHasher',fOwnsHasher);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_CustomHash',TCustomHashLayerReader,TCustomHashLayerWriter);

end.