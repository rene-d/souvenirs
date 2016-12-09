CONST
  np = 20;

TYPE
  glinp = array [1..np] of integer;
  glnpbynp = array [1..np,1..np] of real;
  FoncGrad = PROCEDURE (x: real; VAR a: tableau; VAR y: real;
                        VAR dyda: tableau; np: integer);

VAR
  glochisq: real;
  glbeta: tableau;

PROCEDURE Gaussj (VAR a: glnpbynp; n, np: integer;
                  VAR b: glnpbynp; m: integer);

VAR
  big, dum, pivinv: real;
  i, icol, irow, j, k, l, ll: integer;
  indxc, indxr, ipiv: glinp;

BEGIN
  FOR j := 1 TO n DO BEGIN
    ipiv[j] := 0;
  END;
  FOR i := 1 TO n DO BEGIN
    big := 0.0;
    FOR j := 1 TO n DO BEGIN
      IF (ipiv[j] <> 1) THEN BEGIN
        FOR k := 1 TO n DO BEGIN
          IF (ipiv[k] = 0) THEN BEGIN
            IF (abs(a[j,k]) >= big) THEN BEGIN
              big := abs(a[j,k]); irow := j; icol := k;
            END;
          END
          ELSE IF (ipiv[k] > 1) THEN BEGIN
            Writeln('pause 1 in GAUSSJ - singular matrix');
            Readln;
          END;
        END;
      END;
    END;
    ipiv[icol] := ipiv[icol] + 1;
    IF (irow <> icol) THEN BEGIN
      FOR l := 1 TO n DO BEGIN
        dum := a[irow,l]; a[irow,l] := a[icol,l]; a[icol,l] := dum;
      END;
      FOR l := 1 TO m DO BEGIN
        dum := b[irow,l]; b[irow,l] := b[icol,l]; b[icol,l] := dum;
      END;
    END;
    indxr[i] := irow; indxc[i] := icol;
    IF (a[icol,icol] = 0.0) THEN BEGIN
      Writeln('pause 2 in GAUSSJ - singular matrix'); Readln;
    END;
    pivinv := 1.0/a[icol,icol]; a[icol,icol] := 1.0;
    FOR l := 1 TO n DO BEGIN
      a[icol,l] := a[icol,l]*pivinv;
    END;
    FOR l := 1 TO m DO BEGIN
      b[icol,l] := b[icol,l]*pivinv;
    END;
    FOR ll := 1 TO n DO BEGIN
      IF (ll <> icol) THEN BEGIN
        dum := a[ll,icol]; a[ll,icol] := 0.0;
        FOR l := 1 TO n DO BEGIN
          a[ll,l] := a[ll,l] - a[icol,l]*dum;
        END;
        FOR l := 1 TO m DO BEGIN
          b[ll,l] := b[ll,l] - b[icol,l]*dum;
        END;
      END;
    END;
  END;
  FOR i := n DOWNTO 1 DO BEGIN
    IF (indxr[l] <> indxc[l]) THEN BEGIN
      FOR k := 1 TO n DO BEGIN
        dum := a[k,indxr[l]]; a[k,indxr[l]] := a[k,indxc[l]];
        a[k,indxc[l]] := dum;
      END;
    END;
  END;
END;

PROCEDURE Mrqcof (VAR x, y, sig: tableau; nd: integer;
                  VAR a: tableau; np: integer;VAR lista: glinp;
                  mfit: integer; VAR alpha:glnpbynp;
                  VAR beta: tableau; nalp: integer; VAR chisq: real;
                  Func: FoncGrad);

VAR
  k, j, i: integer;
  ymod, wt, sig2i, dy: real;
  dyda: tableau;

BEGIN
  FOR j := 1 TO mfit DO BEGIN
    FOR k := 1 TO j DO BEGIN
      alpha[j,k] := 0.0;
    END;
    beta[j] := 0.0;
  END;
  chisq := 0.0;
  FOR i := 1 TO nd DO BEGIN
    Func(x[i], a, ymod, dyda, np); sig2i := 1.0/(sig[i]*sig[i]);
    dy := y[i] - ymod;
    FOR j := 1 TO mfit DO BEGIN
      wt := dyda[lista[j]]*sig2i;
      FOR k := 1 TO j DO BEGIN
        alpha[j,k] := alpha[j,k] + wt*dyda[lista[k]];
      END;
      beta[j] := beta[j] + dy*wt;
    END;
    chisq := chisq + dy*dy*sig2i;
  END;
  FOR j := 2 TO mfit DO BEGIN
    FOR k := 1 TO j-1 DO BEGIN
      alpha[k,j] := alpha[j,k];
    END;
  END;
END;

PROCEDURE Mrqmin (VAR x, y, sig: tableau; nd: integer;
                  VAR a: tableau; np: integer; VAR lista:glinp;
                  mfit: integer; VAR covar, alpha: glnpbynp;
                  nca: integer; VAR chisq, alamda: real; Func: FoncGrad);

VAR
  k, kk, j, ihit: integer;
  atry, da: tableau;
  oneda: glnpbynp;

BEGIN
  IF (alamda < 0.0) THEN BEGIN
    kk := mfit + 1;
    FOR j := 1 TO np DO BEGIN
      ihit := 0;
      FOR k := 1 TO mfit DO BEGIN
        IF (lista[k] = j) THEN ihit := ihit + 1;
      END;
      IF (ihit = 0) THEN BEGIN
        lista[kk] := j; kk := kk + 1;
      END
      ELSE IF (ihit > 1) THEN BEGIN
        Writeln ('pause 1 in routine MRQMIN');
        Writeln ('Improper permutation in LISTA'); Readln;
      END;
    END;
    IF (kk <> (np+1)) THEN BEGIN
      Writeln ('pause 2 in routine MRQMIN');
      Writeln ('Improper permutation in LISTA'); Readln;
    END;
    alamda := 0.001;
    Mrqcof (x, y, sig, nd, a, np, lista, mfit, alpha, glbeta, nca, chisq, Func);
    glochisq := chisq;
    FOR j := 1 TO np DO BEGIN
      atry[j] := a[j];
    END;
  END;
  FOR j := 1 TO mfit DO BEGIN
    FOR k := 1 TO mfit DO BEGIN
      covar[j,k] := alpha[j,k];
    END;
    covar[j,j] := alpha[j,j]*(1.0+alamda); oneda[j,1] := glbeta[j];
  END;
  Gaussj (covar, mfit, nca, oneda, 1);
  FOR j := 1 TO mfit DO da[j] := oneda[j,1];
  IF (alamda <> 0.0) THEN BEGIN
    FOR j := 1 TO mfit DO BEGIN
      atry[lista[j]] := a[lista[j]] + da[j];
    END;
    Mrqcof (x, y, sig, nd, atry, np, lista, mfit, covar, da, nca, chisq, Func);
    IF (chisq < glochisq) THEN BEGIN
      IF (alamda > 1.0e-30) THEN alamda := 0.1*alamda;
      glochisq := chisq;
      FOR j := 1 TO mfit DO BEGIN
        FOR k := 1 TO mfit DO BEGIN
          alpha[j,k] := covar[j,k];
        END;
        glbeta[j] := da[j]; a[lista[j]] := atry[lista[j]];
      END;
    END
    ELSE BEGIN
      alamda := 10.0*alamda; chisq := glochisq;
    END;
  END;
END;