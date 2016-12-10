UNIT MODE;

{ version 2.0 - René DEVICHI  (c) 1991                     }
{ -------------------------------------------------------- }
{ unité de conversion de réels selon les modes d'affichage }
{ STD,FIX,SCI,ENG de la HP 28S                             }

INTERFACE

VAR
  aa_Mode : WORD;

FUNCTION  Mant(x:REAL):STRING;
FUNCTION  Xpon(x:REAL):STRING;

PROCEDURE FIX(n:BYTE);
PROCEDURE STD;
PROCEDURE SCI(n:BYTE);
PROCEDURE ENG(n:BYTE);
FUNCTION  Form(x:REAL):STRING;
FUNCTION  RND(x:REAL):REAL;

FUNCTION  StrC(r,i:REAL):STRING;

PROCEDURE EcritR(r:REAL);
PROCEDURE EcritC(r,i:REAL);
PROCEDURE EcritRLn(r:REAL);
PROCEDURE EcritCLn(r,i:REAL);

IMPLEMENTATION

{$ifopt n-}
CONST
  RealLength=12;
{$else}
TYPE
  REAL=EXTENDED;
CONST
  RealLength=16;
{$endif}

{ retourne la mantisse de x sous forme de chaine }
FUNCTION Mant(x:REAL):STRING;
VAR
  s:STRING[30];
BEGIN
  Str(x,s);
  s:=Copy(s,1,Pos('E',s)-1);
  WHILE Copy(s,Length(s),1)='0' DO s:=Copy(s,1,Length(s)-1);
  Mant:=s;
END;


{ retourne l'exposant de x sous forme de chaine }
FUNCTION Xpon(x:REAL):STRING;
VAR
  s:STRING[30];
BEGIN
  Str(x,s);
  s:=Copy(s,Pos('E',s)+1,255);
  WHILE Copy(s,2,1)='0' DO Delete(s,2,1);
  IF Copy(s,1,1)='+' THEN Delete(s,1,1);
  IF s='' THEN s:='0';
  Xpon:=s;
END;

{ force le mode d'affichage STD }
PROCEDURE STD;
BEGIN
  aa_Mode:=0;
END;

{ force le mode d'affichage en n FIX }
PROCEDURE FIX(n:BYTE);
BEGIN
  aa_Mode:=$100+n;
END;

{ force le mode d'affichage en n SCI }
PROCEDURE SCI(n:BYTE);
BEGIN
  aa_Mode:=$200+n;
END;


{ force le mode d'affichage en n ENG }
PROCEDURE ENG(n:BYTE);
BEGIN
  aa_Mode:=$300+n;
END;


  FUNCTION ElmD(s:STRING):STRING;  { elimine les zéros ou espaces à droite }
  VAR i:BYTE;
  BEGIN
    i:=Length(s);
    WHILE (s[i]='0') OR (s[i]=' ') DO Dec(i);
    ElmD:=Copy(s,1,i);
  END;

  FUNCTION ElmG(s:STRING):STRING;  { elimine les zéros ou espaces à gauche }
  BEGIN
    WHILE (Copy(s,1,1)='0') OR (Copy(s,1,1)=' ') DO Delete(s,1,1);
    ElmG:=s;
  END;

  FUNCTION Zeros(n:BYTE):STRING;
  VAR i:BYTE; s:STRING;
  BEGIN
    s:='';
    FOR i:=1 TO n DO s:=s+'0';
    Zeros:=s;
  END;

{ retourne une chaine contenant le réel "formaté" selon le mode courant }
FUNCTION Form(x:REAL):STRING;
VAR
  v:REAL;
  e:INTEGER;
  Mantx,Xponx,s,s1,s2:STRING[30];
  Expx:INTEGER;
  Signe:BOOLEAN;

  FUNCTION aSTD:STRING;
  BEGIN
    IF x=0 THEN aSTD:='0'
    ELSE BEGIN
      s:=Mantx;
      IF Expx=0 THEN
      BEGIN
        IF Copy(s,Length(s),1)='.' THEN Delete(s,Length(s),1);
      END
      ELSE BEGIN
        Delete(s,2,1);    { enlève le point décimal }
        IF Expx<0 THEN s:='.'+Zeros(-1-Expx)+s
        ELSE BEGIN
          s:=s+Zeros(Expx);
          s:=ElmD(Copy(s,1,Expx+1)+'.'+Copy(s,Expx+2,Length(Mantx)));
        END;
        IF Length(s)>RealLength THEN s:=Mantx+'E'+Xponx
        ELSE IF Copy(s,Length(s),1)='.' THEN Delete(s,Length(s),1);
      END;
      aSTD:=s
    END;
  END;

  FUNCTION aSCI:STRING;
  VAR
    i:INTEGER;
  BEGIN
    IF x=0
    THEN BEGIN { cas particulier : x=0 }
      aSCI:='0.'+Copy('000000000000000000000',1,Lo(aa_Mode))+'E0';
      Exit;
    END;
    Val(Mantx,v,e);
    FOR i:=1 TO Lo(aa_Mode) DO v:=v*10;
    v:=Int(v+0.5);
    FOR i:=1 TO Lo(aa_Mode) DO v:=v/10;
    s:=ElmG(Copy(Mantx+'000000000000000000000',1,3+Lo(aa_Mode)));
    Val(Xponx,v,e);
    Str(v:0:0,s1);
    aSCI:=Concat(s,'E',s1)
  END;

BEGIN
  Signe:=(x<0);
  x:=Abs(x);

  Str(x,s);
  Xponx:=Copy(s,Pos('E',s)+1,255);
  WHILE Copy(Xponx,2,1)='0' DO Delete(Xponx,2,1);
  IF Copy(Xponx,1,1)='+' THEN Delete(Xponx,1,1);
  IF Xponx='' THEN Xponx:='0';
  Val(Xponx,Expx,e); IF e<>0 THEN Halt(100);
  Mantx:=ElmD(Copy(s,2,Pos('E',s)-2));

  CASE Hi(aa_Mode) OF
    0 : s:=aSTD;
{    1 : s:=aFIX;}
    2 : s:=aSCI;
{    3 : s:=aENG;}
  ELSE
    Str(x,s);
  END;
  IF Signe THEN s:='-'+s;
  Form:=s;
END;


{ arrondis le réel x selon le format d'affichage en cours }
FUNCTION RND(x:REAL):REAL;
VAR
  e:INTEGER;
  y:REAL;
BEGIN
  Val('0'+Form(Abs(x)),y,e);
  IF e<>0 THEN RND:=x
  ELSE IF (x<0) THEN RND:=-y ELSE RND:=y
END;


{ convertit un complexe en une chaîne de caractère pour affichage }
FUNCTION StrC(r,i:REAL):STRING;
VAR s:STRING;
BEGIN
  s:='';
  IF (r=0) AND (i=0) THEN s:='0'
  ELSE BEGIN
    IF r<>0 THEN s:=s+Form(r);
    IF i<>0
    THEN BEGIN
      IF i<0 THEN s:=s+'-'
      ELSE IF r<>0 THEN s:=s+'+';
      s:=s+'i*'+Form(Abs(i));
    END;
  END;
  StrC:=s;
END;


{ routines d'affichage de réels ou complexes }

PROCEDURE EcritR(r:REAL);
BEGIN
  Write(Form(r));
END;

PROCEDURE EcritC(r,i:REAL);
BEGIN
  Write(StrC(r,i));
END;

PROCEDURE EcritRLn(r:REAL);
BEGIN
  WriteLn(Form(r));
END;

PROCEDURE EcritCLn(r,i:REAL);
BEGIN
  WriteLn(StrC(r,i));
END;

{ initialisation du module d'affichage } { mode standart STD }
BEGIN
(*  x:=pi;str(real(x),s); RealLength:=length(copy(s,2,pos('E',s)))-2; *)
  STD;
END.
