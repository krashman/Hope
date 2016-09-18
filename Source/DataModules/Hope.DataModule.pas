unit Hope.DataModule;

{$I Hope.inc}

interface

uses
  System.SysUtils, System.Classes, Vcl.ImgList, Vcl.Controls,

  SynEdit, SynEditPlugins, SynMacroRecorder, SynCompletionProposal,
  SynEditRegexSearch, SynEditHighlighter, SynHighlighterMulti,
  SynEditMiscClasses, SynEditSearch, SynHighlighterCSS, SynHighlighterHtml,
  SynHighlighterJSON, SynHighlighterJScript, SynHighlighterDWS,

  Hope.Common.History, Hope.Common.Paths, Hope.Common.MonitoredBuffer,
  Hope.Common.Preferences, Hope.Compiler.Internal, Hope.Compiler.Background;

type
  TMacroAction = (maRecord, maStop, maPlay);

  TDataModuleCommon = class(TDataModule)
    ImageList12: TImageList;
    ImageList16: TImageList;
    SynCodeSuggestions: TSynCompletionProposal;
    SynCssSyn: TSynCssSyn;
    SynDWSSyn: TSynDWSSyn;
    SynEditRegexSearch: TSynEditRegexSearch;
    SynEditSearch: TSynEditSearch;
    SynHTMLSyn: TSynHTMLSyn;
    SynJScriptSyn: TSynJScriptSyn;
    SynJSONSyn: TSynJSONSyn;
    SynMacroRecorder: TSynMacroRecorder;
    SynMultiCSS: TSynMultiSyn;
    SynMultiHTML: TSynMultiSyn;
    SynObjectPascal: TSynMultiSyn;
    SynParameters: TSynCompletionProposal;
    procedure SynMacroRecorderStateChange(Sender: TObject);
  private
    FHistory: THopeHistory;
    FPaths: THopePaths;
    FPreferences: THopePreferences;
    FMonitoredBuffer: TMonitoredBuffer;
    FInternalCompiler: THopeInternalCompiler;
    FBackgroundCompiler: THopeBackgroundCompilerThread;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function GetText(FileName: TFileName): string; inline;
    function GetUnit(UnitName: string): string; inline;

    procedure PerformMacro(Editor: TSynEdit; Action: TMacroAction);

    property InternalCompiler: THopeInternalCompiler read FInternalCompiler;
    property BackgroundCompiler: THopeBackgroundCompilerThread read FBackgroundCompiler;
    property History: THopeHistory read FHistory;
    property Paths: THopePaths read FPaths;
    property Preferences: THopePreferences read FPreferences;
    property MonitoredBuffer: TMonitoredBuffer read FMonitoredBuffer;
  end;

var
  DataModuleCommon: TDataModuleCommon;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  ceflib, Hope.Main;

{ TDataModuleCommon }

procedure TDataModuleCommon.AfterConstruction;
begin
  inherited;

  FPaths := THopePaths.Create;

  FPreferences := THopePreferences.Create;
  if FileExists(FPaths.PreferenceFileName) then
    FPreferences.LoadFromFile(FPaths.PreferenceFileName);

  FHistory := THopeHistory.Create;
  if FileExists(FPaths.HistoryFileName) then
    FHistory.LoadFromFile(FPaths.HistoryFileName);

  FMonitoredBuffer := TMonitoredBuffer.Create;
  FMonitoredBuffer.AddPath(ExpandFileName(Paths.Root + '..\Common\APIs\'));

  FInternalCompiler := THopeInternalCompiler.Create;
  FBackgroundCompiler := THopeBackgroundCompilerThread.Create;
end;

procedure TDataModuleCommon.BeforeDestruction;
begin

  FHistory.SaveToFile(FPaths.HistoryFileName);
  FPreferences.SaveToFile(FPaths.PreferenceFileName);

  FBackgroundCompiler.Free;
  FInternalCompiler.Free;
  FMonitoredBuffer.Free;
  FHistory.Free;
  FPreferences.Free;

  inherited;
end;

function TDataModuleCommon.GetText(FileName: TFileName): string;
begin
  Result := FMonitoredBuffer.Text[FileName];
end;

function TDataModuleCommon.GetUnit(UnitName: string): string;
begin
  Result := FMonitoredBuffer.GetSourceCode(UnitName);
end;

procedure TDataModuleCommon.PerformMacro(Editor: TSynEdit;
  Action: TMacroAction);
begin
  SynMacroRecorder.Editor := Editor;
  case Action of
    maRecord:
      SynMacroRecorder.RecordMacro(Editor);
    maStop:
      SynMacroRecorder.Stop;
    maPlay:
      SynMacroRecorder.PlaybackMacro(Editor);
  end;
end;

procedure TDataModuleCommon.SynMacroRecorderStateChange(Sender: TObject);
begin
  with FormMain do
  begin
    ActionMacroStop.Enabled := SynMacroRecorder.State in [msRecording, msPlaying];
    ActionMacroPlay.Enabled := (SynMacroRecorder.State = msStopped) and not SynMacroRecorder.IsEmpty;
    ActionMacroRecord.Enabled := (SynMacroRecorder.State = msStopped);
  end;
end;

procedure BeforeCommandLineProcessing(const processType: ustring;
  const commandLine: ICefCommandLine);
begin
(*
  if not UseProxy then
    commandLine.AppendSwitch('--no-proxy-server');
*)
end;

procedure InitializeCEF;
begin
  CefSingleProcess := False;
  CefRemoteDebuggingPort := 9000;
  CefBrowserSubprocessPath := ExtractFilePath(ParamStr(0)) + 'DCEF3.exe';
  CefNoSandbox := True;
  CefCache := ExtractFilePath(ParamStr(0)) + 'Cache';
  {$IFDEF Debug}
  CefLogSeverity := LOGSEVERITY_ERROR;
  CefLogFile := ExtractFilePath(ParamStr(0)) + 'DCEF3.log';
  {$ENDIF}
  CefRenderProcessHandler := TCefRenderProcessHandlerOwn.Create;
  CefBrowserProcessHandler := TCefBrowserProcessHandlerOwn.Create;
  CefOnBeforeCommandLineProcessing := BeforeCommandLineProcessing;
end;

procedure FinalizeCEF;
begin
  CefRenderProcessHandler := nil;
  CefBrowserProcessHandler := nil;
  CefOnBeforeCommandLineProcessing := nil;
end;

initialization
  InitializeCEF;

finalization
  FinalizeCEF;

end.
