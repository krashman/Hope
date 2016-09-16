unit Hope.Dialogs.Preferences;

{$I Hope.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, VirtualTrees, Hope.Dialog, Hope.DataModule,
  System.Actions, Vcl.ActnList;

type
  TTabSheetItem = record
    TabSheet: TTabSheet;
  end;
  PTabSheetItem = ^TTabSheetItem;

  TFormPreferences = class(TFormDialog)
    ActionLibraryPathAdd: TAction;
    ActionLibraryPathCleanUp: TAction;
    ActionLibraryPathDelete: TAction;
    ActionLibraryPathDown: TAction;
    ActionLibraryPathPick: TAction;
    ActionLibraryPathReplace: TAction;
    ActionLibraryPathUp: TAction;
    ActionList: TActionList;
    Bevel: TBevel;
    ButtonAdd: TButton;
    ButtonCleanUp: TButton;
    ButtonDelete: TButton;
    ButtonDown: TButton;
    ButtonPick: TButton;
    ButtonProjectPath: TButton;
    ButtonReplace: TButton;
    ButtonUp: TButton;
    ComboBoxProjectPath: TComboBox;
    Edit: TEdit;
    GroupBoxLibraryPaths: TGroupBox;
    GroupBoxPaths: TGroupBox;
    LabelProjectPath: TLabel;
    ListBoxLibraryPaths: TListBox;
    PageControl: TPageControl;
    TabSheetCodeInsight: TTabSheet;
    TabSheetDeployment: TTabSheet;
    TabSheetDesigner: TTabSheet;
    TabSheetEditorOptions: TTabSheet;
    TabSheetEnvironment: TTabSheet;
    TabSheetFormating: TTabSheet;
    TabSheetHighlighterOptions: TTabSheet;
    TabSheetLibraryPaths: TTabSheet;
    TabSheetRecentFiles: TTabSheet;
    TabSheetVersionControl: TTabSheet;
    TreeCategory: TVirtualStringTree;
    procedure TreeCategoryChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeCategoryGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeCategoryGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure TreeCategoryIncrementalSearch(Sender: TBaseVirtualTree;
      Node: PVirtualNode; const SearchText: string; var Result: Integer);
    procedure ButtonProjectPathClick(Sender: TObject);
  private
    procedure UpdateTree;
  public
    procedure AfterConstruction; override;

    procedure Save;
    procedure Load;
  end;

implementation

uses
  System.Math, Vcl.FileCtrl, Hope.Common.Preferences;

{$R *.dfm}

{ TFormPreferences }

procedure TFormPreferences.AfterConstruction;
begin
  inherited;

  UpdateTree;
end;

procedure TFormPreferences.ButtonProjectPathClick(Sender: TObject);
var
  Directory: string;
begin
  inherited;

  // default to current directory
  Directory := ComboBoxProjectPath.Text;
  if Directory = '' then
    Directory := DataModuleCommon.Paths.Root;

  // show select directory dialog
  if SelectDirectory('Default Project Path', '', Directory) then
    ComboBoxProjectPath.Text := Directory;
end;

procedure TFormPreferences.TreeCategoryChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  NodeData: PTabSheetItem;
begin
  if Assigned(Node) then
  begin
    NodeData := Sender.GetNodeData(Node);
    PageControl.ActivePage := NodeData^.TabSheet;
  end;
end;

procedure TFormPreferences.TreeCategoryGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PTabSheetItem;
begin
  if Kind in [ikNormal, ikSelected] then
  begin
    NodeData := Sender.GetNodeData(Node);
    ImageIndex := NodeData^.TabSheet.ImageIndex;
  end;
end;

procedure TFormPreferences.TreeCategoryGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData: PTabSheetItem;
begin
  NodeData := Sender.GetNodeData(Node);
  CellText := NodeData^.TabSheet.Caption;
end;

procedure TFormPreferences.TreeCategoryIncrementalSearch(
  Sender: TBaseVirtualTree; Node: PVirtualNode; const SearchText: string;
  var Result: Integer);
var
  NodeData: PTabSheetItem;
  S: array [0 .. 1] of string;
begin
  NodeData := Sender.GetNodeData(Node);
  S[0] := LowerCase(SearchText);
  S[1] := LowerCase(NodeData^.TabSheet.Caption);

  Result := StrLIComp(PChar(S[0]), PChar(S[1]), Min(Length(S[0]), Length(S[1])));
end;

procedure TFormPreferences.UpdateTree;
var
  ParentNode, Node: PVirtualNode;
  NodeData: PTabSheetItem;
  Index: Integer;
begin
  TreeCategory.BeginUpdate;
  try
    TreeCategory.Clear;

    ParentNode := TreeCategory.AddChild(TreeCategory.RootNode);
    NodeData := TreeCategory.GetNodeData(ParentNode);
    NodeData^.TabSheet := TabSheetEnvironment;

    Node := TreeCategory.AddChild(ParentNode);
    NodeData := TreeCategory.GetNodeData(Node);
    NodeData^.TabSheet := TabSheetLibraryPaths;
    TreeCategory.Expanded[ParentNode] := True;

    ParentNode := TreeCategory.AddChild(TreeCategory.RootNode);
    NodeData := TreeCategory.GetNodeData(ParentNode);
    NodeData^.TabSheet := TabSheetEditorOptions;

    Node := TreeCategory.AddChild(ParentNode);
    NodeData := TreeCategory.GetNodeData(Node);
    NodeData^.TabSheet := TabSheetHighlighterOptions;
    TreeCategory.Expanded[ParentNode] := True;
  finally
    TreeCategory.EndUpdate;
  end;

  // disable tabs
  for Index := 0 to PageControl.PageCount - 1 do
    PageControl.Pages[Index].TabVisible := False;
end;

procedure TFormPreferences.Load;
begin

end;

procedure TFormPreferences.Save;
begin

end;

end.
