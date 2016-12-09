USES Crt, jmpgraph;

const ntrunc=2;  { nombres de chiffres après la virgule en sortie }

type real=double;

CONST
  np = nps;

PROCEDURE FiltrePassif (x: real; VAR a: tableau; VAR y: real); FAR;

VAR d, temp, x2: real;

BEGIN
  x2 := x*x;
  temp := a[3]/a[2] - a[3]*a[1]*x2;
  d := sqrt(temp*temp + x2);
  y := x/d;
END;

PROCEDURE InputPara (VAR npa: integer; VAR a: tableau);

VAR
  i: integer;

BEGIN
  ClrScr;
  Writeln ('Valeur initiale des parametres.');
  REPEAT
    GotoXY (1, 2); Write ('Nombre de parametres : '); Readln (npa);
  UNTIL ((npa > 0) AND (npa <= np));
  FOR i := 1 TO npa DO BEGIN
    Write ('parametre (', i, ') : '); Readln (a[i]);
  END;
END;


function strtr(x:real;n:byte):string;
var
  s:string;
  i:byte;
begin
  str(x,s);
  i:=pos('E',s)-pos('.',s)+1-n-2;
  if i>0 then
    delete(s,pos('.',s)+1,i);
  strtr:=s;
end;


VAR nomfichier: string;
    fichier: text;
    a: tableau;
    x, y, rx, sig, x0: real;
    i, nda, npa, nda2: integer;

BEGIN
  Write ('Nom du fichier: ');
  Readln (nomfichier);
  if pos('.',nomFichier)=0 then nomFichier:=nomFichier+'.dat';
  Assign (fichier, nomfichier);
  Rewrite (fichier);
  InputPara (npa, a);
  Write ('Nombre de données: ');
  Readln (nda);
  Writeln (fichier, nda);
  x0 := sqrt(1.0/(a[1]*a[2]));
  x := x0;
  Write ('Pas en fréquence: ');
  Readln (rx);
  FOR i := 1 TO nda DO BEGIN
    FiltrePassif (x, a, y);
    sig := x/x0;
    Writeln (fichier,strtr(x,ntrunc), strtr(y,ntrunc), strtr(sig,ntrunc) );
    Writeln (strtr(x,ntrunc), strtr(y,ntrunc), strtr(sig,ntrunc) );
    x := x*rx;
  END;
  Close (fichier);
  Writeln (strtr(a[1],ntrunc), strtr(a[2],ntrunc), strtr(a[3],ntrunc));
  Readln;
END.