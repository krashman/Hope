unit Hope.MessageWindow.Compiler;

interface

{$I Hope.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Hope.MessageWindow,
  JvComponentBase, JvDockControlForm, Vcl.Menus, VirtualTrees;

type
  TFormCompilerMessages = class(TFormMessageWindow)
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

end.
