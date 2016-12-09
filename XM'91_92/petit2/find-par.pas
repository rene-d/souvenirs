USES Crt, jmpgraph;

type real=double;

CONST
  nd = nps;

{$I gradient.pas}

PROCEDURE Funcs (x: real; VAR a: tableau; VAR y: real;
                 VAR dyda: tableau; np: integer); FAR;

BEGIN
  y := exp(-x/a[3]);
  dyda[1] := 1.0 - y;
  dyda[2] := y;
  dyda[3] := (a[2] - a[1])*x/(a[3]*a[3])*y;
  y := a[1] + (a[2] - a[1])*y;
END;

PROCEDURE FiltrePassif (x: real; VAR a: tableau; VAR y: real;
                        VAR dyda: tableau; np: integer); FAR;

VAR d, temp, x2: real;

BEGIN
  x2 := x*x;
  temp := a[3]/a[2] - a[3]*a[1]*x2;
  d := temp*temp + x2;
  y := x/sqrt(d);
  temp := y*temp/d;
  dyda[1] := temp*a[3]*x2;
  dyda[2] := temp*a[3]/(a[2]*a[2]);
  dyda[3] := -temp*(1.0/a[2] - a[1]*x2);
END;

PROCEDURE FiltrePassif2 (x: real; VAR a: tableau; VAR y: real;
                         VAR dyda: tableau; np: integer); FAR;

VAR d, temp, x2: real;

BEGIN
  x2 := x*x;
  temp := a[1] - a[2]*x2;
  d := temp*temp + x2;
  y := x/sqrt(d);
  temp := y*temp/d;
  dyda[1] := -temp;
  dyda[2] := temp*x2;
END;

PROCEDURE FiltrePassifFQ (x: real; VAR a: tableau; VAR y: real;
                          VAR dyda: tableau; np: integer); FAR;

VAR d, temp1, temp, x2: real;

BEGIN
  x2 := x*x;
  temp := a[2]*a[2] - x2;
  d := a[1]*a[1]*temp*temp + x2;
  y := x/sqrt(d);
  temp1 := -y*temp*a[1]/d;
  dyda[1] := temp1*temp;
  dyda[2] := temp1*2.0*a[1]*a[2];
END;

PROCEDURE FiltrePassifPh (x: real; VAR a: tableau; VAR y: real;
                          VAR dyda: tableau; np: integer); FAR;

VAR d, temp1, temp: real;

BEGIN
  temp := -a[1]/x + a[2]*x;
  y := ArcTan(temp);
  d := 1.0/(1.0 + temp*temp);
  dyda[1] := -d/x;
  dyda[2] := d*x;
END;

PROCEDURE InputData (Var nda: integer; Var x, y, sig: tableau; Var bsig: boolean);

VAR
  i, j: integer;

BEGIN
  ClrScr;
  REPEAT
    GotoXY (1, 1); Write ('Nombre de donnees : '); Readln (nda);
  UNTIL ((nda > 0) AND (nda <= nd));
  FOR i := 1 TO nda DO BEGIN
    j := i + 1;
    IF (j > 24) THEN j := 25;
    Write ('exitation : '); Read (x[i]);
    GotoXY (25, j); Write ('reponse : ');
    IF (bsig) THEN BEGIN
      Read (y[i]);
      GotoXY (50, j); Write ('incertitude : '); Readln (sig[i]);
    END
    ELSE BEGIN
      Readln (y[i]); sig[i] := 1.0;
    END;
  END;
END;

PROCEDURE InputPara (VAR npa: integer; VAR a: tableau);

VAR
  i: integer;

BEGIN
  ClrScr;
  Writeln ('Valeur initiale des paramŠtres.');
  REPEAT
    GotoXY (1, 2); Write ('Nombre de paramŠtres : '); Readln (npa);
  UNTIL ((npa > 0) AND (npa <= np));
  FOR i := 1 TO npa DO BEGIN
    Write ('paramŠtre (', i, ') : '); Readln (a[i]);
  END;
END;

PROCEDURE PrintPara (VAR npa: integer; VAR a: tableau);

VAR
  i: integer;

BEGIN
  ClrScr;
  FOR i := 1 TO npa DO BEGIN
    Writeln ('paramŠtre (', i, ') : ', a[i]);
  END;
END;

PROCEDURE DrawFunc (VAR x, y, a: tableau; VAR nda, npa: integer; Func: FoncGrad);

VAR
  dyda, yy: tableau;
  i: integer;
  xmin, xmax, ymin, ymax: real;

BEGIN
  Initialise ('EGA', 'C:\TP\BGI');
  xmax := -1.0e10; xmin := 1.0e10; ymax := xmax; ymin := xmin;
  FOR i := 1 TO nda DO BEGIN
    IF (x[i] > xmax) THEN xmax := x[i];
    IF (x[i] < xmin) THEN xmin := x[i];
    IF (y[i] > ymax) THEN ymax := y[i];
    IF (y[i] < ymin) THEN ymin := y[i];
    Func (x[i], a, yy[i], dyda, npa);
  END;
  Boite (xmin, xmax, ymin, ymax);
  Marker (nda, x, y);
  Ligne (nda, x, yy);
  Termine;
END;

VAR
  iconv, niter, i, nda, npa, nca, mfit, nfunc: integer;
  a, x, y, sig: tableau;
  lista: glinp;
  chisq, alamda, olchisq, eps, ratio: real;
  covar, alpha: glnpbynp;
  bsig, fini, arret: boolean;
  rep: char;
  nomfichier: string;
  fichier: text;
  FoncTab: array [1..10] of FoncGrad;

BEGIN
  FoncTab[1] := Funcs;
  FoncTab[2] := FiltrePassif;
  FoncTab[3] := FiltrePassif2;
  FoncTab[4] := FiltrePassifFQ;
  FoncTab[5] := FiltrePassifPh;
  ClrScr;
  Writeln ('Fonctions disponibles:');
  Writeln ('Charge de capacit‚ ---------- 1,');
  Writeln ('Filtre passif 2Šme ordre ---- 2,');
  Writeln ('Filtre passif 2 paramŠtres -- 3,');
  Writeln ('Filtre passif F0/Q ---------- 4,');
  Writeln ('Filtre passif phase --------- 5.');
  Write ('Option: '); Readln (nfunc);
  IF (nfunc < 1) THEN nfunc := 1;
  IF (nfunc > 5) THEN nfunc := 5;
  ClrScr;
  Write ('Voulez vous lire un fichier (O/N) ? ');
  Readln (rep);
  IF ((rep = 'O') OR (rep = 'o')) THEN BEGIN
    Write ('Nom du fichier: ');
    Readln (nomfichier);
    if pos('.',nomFichier)=0 then nomFichier:=nomFichier+'.dat';
    Assign (fichier, nomfichier);
    Reset (fichier);
    Readln (fichier, nda);
    FOR i := 1 TO nda DO BEGIN
      Readln (fichier, x[i], y[i], sig[i]);
    END;
    Close (fichier);
  END
  ELSE BEGIN
    Write ('Avez vous des donnees avec barre d''erreur (O/N) ? ');
    Readln (rep);
    bsig := ((rep = 'O') OR (rep = 'o'));
    InputData (nda, x, y, sig, bsig);
  END;
  REPEAT
    InputPara (npa, a);
    mfit := npa;
    FOR i := 1 TO mfit DO BEGIN
      lista[i] := i;
    END;
    nca := npa;
    alamda := -1.0;
    Mrqmin (x, y, sig, nda, a, npa, lista, mfit, covar, alpha, nca, chisq, alamda, FoncTab[nfunc]);
    olchisq := chisq;
    fini := false;
    i := 0;
    Write ('Epsilon : '); Readln (eps);
    Write ('Ratio : '); Readln (ratio);
    Write ('Nombre d''iterations : '); Readln (niter);
    iconv := 0;
    REPEAT
      Mrqmin (x, y, sig, nda, a, npa, lista, mfit, covar, alpha, nca, chisq, alamda, FoncTab[nfunc]);
      i := i + 1;
      IF (chisq < olchisq) THEN BEGIN
        fini := ((olchisq-chisq) < (olchisq+ratio)*eps);
        IF (fini) THEN BEGIN
          iconv := iconv + 1;
          fini := (iconv = 2);
        END;
      END;
      olchisq := chisq;
      IF (i > niter) THEN BEGIN
        Write ('convergence : ', fini, ' iterations : ', i); Readln;
        fini := true;
      END;
    UNTIL (fini);
    PrintPara (npa, a);
    Write ('Voulez vous un dessin (O/N) ? '); Readln (rep);
    IF ((rep = 'o') OR (rep = 'O')) THEN DrawFunc (x, y, a, nda, npa, FoncTab[nfunc]);
    Write ('Voulez vous continuer ? '); Readln (rep);
    arret := ((rep = 'n') OR (rep = 'N'));
  UNTIL (arret);
END.