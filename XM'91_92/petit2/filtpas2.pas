USES Crt, jmpgraph;
type real=extended;
CONST
  np = nps;

PROCEDURE FiltrePassif (x: real; VAR a: tableau; VAR y: real); FAR;

VAR d, temp, x2: real;

BEGIN
  x2 := x*x;
  temp := a[1] - a[2]*x2;
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

VAR nomfichier: string;
    fichier: text;
    a: tableau;
    x, y, rx, sig, x0: real;
    i, nda, npa, nda2: integer;

BEGIN
  Write ('Nom du fichier: ');
  Readln (nomfichier);
  Assign (fichier, nomfichier);
  Rewrite (fichier);
  InputPara (npa, a);
  Write ('Nombre de donnees: ');
  Readln (nda);
  Writeln (fichier, nda);
  x0 := sqrt(a[1]/a[2]);
  x := x0;
  Write ('Pas en frequence: ');
  Readln (rx);
  nda2 := nda DIV 2;
  FOR i := 1 TO nda2 DO BEGIN
    x := x/rx;
  END;
  FOR i := 1 TO nda DO BEGIN
    FiltrePassif (x, a, y);
    sig := 1.0;
    Writeln (fichier, x, y, sig);
    Writeln (x, y, sig);
    x := x*rx;
  END;
  Close (fichier);
  Writeln (a[1], a[2]);
  Readln;
END.