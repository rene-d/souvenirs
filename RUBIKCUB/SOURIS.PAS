{ SOURIS.PAS }

unit SOURIS;

interface

var
  ok_souris     : boolean;     {true si souris détectée, false sinon }
  action_souris : boolean;     {true si action mémorisable sur la souris, false sinon}


procedure LIRE_ETAT_SOURIS(var b,x,y:Word);
procedure LIRE_ETAT_SOURIS_APRES_ACTION(var b,x,y:word);
procedure montrer_SOURIS;
procedure cacher_SOURIS;
procedure POSITIONNER_CURSEUR_SOURIS(x,y:Word);
procedure FIXER_DEPLACEMENT_CURSEUR_SOURIS(x_nw,y_nw,x_se,y_se:word);


{****************************************************************************************************************}

implementation

uses Dos;

var
  exitold:pointer;

var
  bouton_souris : Word;
  x_souris : Word;
  y_souris : Word;
  curseur : Integer;


procedure LIRE_ETAT_SOURIS;
var regs:registers;
begin
  regs.AX:=3;
  Intr($33,regs);
  b:=regs.BX;
  x:=regs.CX;
  y:=regs.DX;
end;


procedure LIRE_ETAT_SOURIS_APRES_ACTION;
begin
  if action_souris then
    begin
      b:=bouton_souris;
      x:=x_souris;
      y:=y_souris;
      action_souris:=False;
    end;
end;


procedure montrer_SOURIS;
var
  r : registers;
begin
  if curseur = -1 then
    begin
      curseur := 0;
      r.AX := 1;
      Intr($33, r);
    end;
end;


procedure cacher_SOURIS;
var
  r : registers;
begin
  if curseur=0 then
    begin
      curseur:=-1;
      r.AX := 2;
      Intr($33, r);
    end;
end;


procedure POSITIONNER_CURSEUR_SOURIS;
var
  r : registers;
begin
  r.AX:=4;
  r.CX:=x;
  r.DX:=y;
  Intr($33,r);
end;


procedure FIXER_DEPLACEMENT_CURSEUR_SOURIS;
var
  r:registers;
begin
  r.AX:=7;
  r.CX:=x_nw;
  r.DX:=x_se;
  Intr($33, r);
  r.AX:=8;
  r.CX:=y_nw;
  r.DX:=y_se;
  Intr($33,r);
end;


function INITIALISER_SOURIS : Boolean;
var
  r:registers;
begin
  r.AX:=0;
  Intr($33, r);
  INITIALISER_SOURIS:=(r.AX<>0) and (r.BX=2);
end;


procedure INSTALLER_INTERRUPTION_SOURIS(masque:Word;adresse:Pointer);               {adresse de la procédure d'interruption}
var
  r:registers;
begin
  r.AX:=12;
  r.CX:=masque;
  r.DX:=Ofs(adresse^);
  r.ES:=Seg(adresse^);
  intr($33,r);
end;

{$f+}
{$L e:SOURIS.OBJ}
procedure MEMORISER_DATA_SEGMENT; external;
procedure INTERRUPTION_SOURIS; external;

procedure fin_souris;
begin
  cacher_souris;
  inline($31/$c0/$cd/$33);   { xor ax,ax }{ int 33h }
  exitproc:=exitold;
end;



{$f-}




{****************************************************************************************************************}

{initialisation}

begin
  MEMORISER_DATA_SEGMENT;
  ok_souris := INITIALISER_SOURIS;
  action_souris := False;
  if ok_souris then
    begin
      curseur:=-1;
      INSTALLER_INTERRUPTION_SOURIS($000A, @INTERRUPTION_SOURIS);
      POSITIONNER_CURSEUR_SOURIS(0, 0);
    end;
  exitold:=exitproc;
  exitproc:=@fin_souris;
end.




{-----------------------------------------------------}
; SOURIS.ASM

data segment

     extrn bouton_souris:word, x_souris:word, y_souris:word, action_souris : byte

data ends

code segment

     assume cs:code,ds:data

     public MEMORISER_DATA_SEGMENT , INTERRUPTION_SOURIS

     data_segment dw ?                 ; Variable de sauvegarde de Dseg

     MEMORISER_DATA_SEGMENT proc near  ; Sauvegarde de Dseg
         mov ax,ds                     ; data_segment := DS
         mov data_segment,ax
         ret
     MEMORISER_DATA_SEGMENT endp

     INTERRUPTION_SOURIS proc far      ; Procédure interruption souris
         push ds                       ; Sauvegarde des registres
         push ax
         mov ax, data_segment          ; DS := data_segment
         mov ds,ax
         mov bouton_souris,bx          ; bouton_souris := état des boutons
         mov x_souris,cx               ; x_souris := abscisse du curseur
         mov y_souris,dx               ; y_souris := ordonnée du curseur
         mov action_souris,1           ; action_souris := true
         pop ax                        ; Restitution des registres
         pop ds
         ret
     INTERRUPTION_SOURIS endp

code ends
end
