UNIT jmpgraph;

  INTERFACE
    type real=double;

    CONST nps = 200;

    TYPE tableau = array[1..nps] of real;

    PROCEDURE Initialise (Device, DevDir: string);

    PROCEDURE Boite (xmin, xmax, ymin, ymax: real);

    PROCEDURE Environement (n: integer;
                            VAR x, y: tableau);

    PROCEDURE Ligne (n: integer;
                     VAR x, y: tableau);

    PROCEDURE Croix (x, y: real);

    PROCEDURE Marker (n: integer;
                      VAR x, y: tableau);

    PROCEDURE Termine;

  IMPLEMENTATION
    USES Graph;

    VAR jmpxmax, jmpxmin, jmpymax, jmpymin: real;
        scrxmax, scrxmin, scrymax, scrymin: integer;
        deltax, deltay, sizex, sizey: integer;
        slopex, slopey: real;

    PROCEDURE Initialise (Device, DevDir: string);

    VAR GraphDriver, GraphMode, ErrorCode, i, Len: integer;

    BEGIN
      GraphDriver := Detect;
      GraphMode := 1;
      Len := Length (Device);
      FOR i := 1 TO Len DO BEGIN
        Device[i] := UpCase (Device[i]);
      END;
      IF (Device = 'CGA') THEN GraphDriver := CGA;
      IF (Device = 'MCGA') THEN GraphDriver := MCGA;
      IF (Device = 'EGA') THEN GraphDriver := EGA;
      IF (Device = 'EGA64') THEN GraphDriver := EGA64;
      IF (Device = 'EGAMONO') THEN GraphDriver := EGAMono;
      IF (Device = 'IBM8514') THEN GraphDriver := IBM8514;
      IF (Device = 'HERCMONO') THEN GraphDriver := HercMono;
      IF (Device = 'ATT400') THEN GraphDriver := ATT400;
      IF (Device = 'VGA') THEN BEGIN
        GraphDriver := VGA; GraphMode := VGAHi;
      END;
      IF (Device = 'PC3270') THEN GraphDriver := PC3270;
      InitGraph (GraphDriver, GraphMode, DevDir);
      ErrorCode := GraphResult;
      IF (ErrorCode <> grOK) THEN BEGIN
        Writeln ('Erreur graphique: ', GraphErrorMsg(ErrorCode));
        Halt (1);
      END;
      scrxmax := GetMaxX;
      scrymax := GetMaxY;
      scrxmin := scrxmax DIV 20;
      scrymin := scrymax DIV 20;
      scrxmax := scrxmax - scrxmin;
      scrymax := scrymax - scrymin;
      deltay := (scrymax - scrymin) DIV 40;
      deltax := deltay;
      sizex := scrxmax - scrxmin;
      sizey := scrymax - scrymin;
    END;

    PROCEDURE Boite (xmin, xmax, ymin, ymax: real);

    VAR chaine: string[12];
        ix, iy: integer;

    BEGIN
      jmpxmax := xmax;
      jmpxmin := xmin;
      jmpymax := ymax;
      jmpymin := ymin;
      slopex := sizex/(jmpxmax - jmpxmin);
      slopey := sizey/(jmpymin - jmpymax);
      Rectangle (scrxmin, scrymin, scrxmax, scrymax);
      iy := GetMaxY - deltay;
      Str (jmpxmax:10:-4, chaine);
      SetTextJustify (RightText, BottomText);
      OutTextXY (scrxmax, iy, chaine);
      Str (jmpxmin:10:-4, chaine);
      SetTextJustify (LeftText, BottomText);
      OutTextXY (scrxmin, iy, chaine);
      SetTextStyle (DefaultFont, VertDir, 1);
      Str (jmpymin:10:-4, chaine);
      OutTextXY (scrxmin - 10, scrymax, chaine);
      Str (jmpymax:10:-4, chaine);
      SetTextJustify (LeftText, TopText);
      OutTextXY (scrxmin - 10, scrymin, chaine);
      SetTextStyle (DefaultFont, HorizDir, 1);
      SetViewPort (scrxmin, scrymin, scrxmax, scrymax, ClipOn);
    END;

    PROCEDURE Environement (n: integer;
                            VAR x, y: tableau);

    VAR xxmin, xxmax, yymin, yymax: real;
        i: integer;

    BEGIN
      xxmin := x[1];
      xxmax := x[1];
      yymin := y[1];
      yymax := y[1];
      FOR i := 1 TO n DO BEGIN
        if (x[i]<xxmin) then xxmin := x[i];
        if (x[i]>xxmax) then xxmax := x[i];
        if (y[i]<yymin) then yymin := y[i];
        if (y[i]>yymax) then yymax := y[i];
      END;
      xxmin := xxmin - (xxmax - xxmin)/10;
      xxmax := xxmax + (xxmax - xxmin)/11;
      yymin := yymin - (yymax - yymin)/10;
      yymax := yymax + (yymax - yymin)/11;
      Boite (xxmin, xxmax, yymin, yymax);
    END;

    PROCEDURE Ligne (n: integer;
                     VAR x, y: tableau);

    VAR i, ix, iy: integer;

    BEGIN
      ix := Trunc(slopex*(x[1]-jmpxmin));
      iy := Trunc(sizey + slopey*(y[1]-jmpymin));
      MoveTo (ix, iy);
      FOR i := 2 TO n DO BEGIN
        ix := Trunc(slopex*(x[i]-jmpxmin));
        iy := Trunc(sizey + slopey*(y[i]-jmpymin));
        LineTo (ix, iy);
      END;
    END;

    PROCEDURE Croix (x, y: real);

    VAR ixc, iyc, ix, iy: integer;

    BEGIN
      ixc := Trunc(slopex*(x-jmpxmin));
      iyc := Trunc(sizey + slopey*(y-jmpymin));
      ix := ixc - deltax;
      MoveTo (ix, iyc);
      ix := ixc + deltax;
      LineTo (ix, iyc);
      iy := iyc - deltay;
      MoveTo (ixc, iy);
      iy := iyc + deltay;
      LineTo (ixc, iy);
    END;

    PROCEDURE Marker (n: integer;
                      VAR x, y: tableau);

    VAR i: integer;

    BEGIN
      FOR i := 1 TO n DO BEGIN
        Croix (x[i], y[i]);
      END;
    END;

    PROCEDURE Termine;

    BEGIN
      Readln;
      CloseGraph;
    END;

END.