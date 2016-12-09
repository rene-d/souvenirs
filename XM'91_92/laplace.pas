uses crt,modubase;

const
  condx=1;
  condy=5;

Const nxmax = 20;
      nymax = 20;

Type potarray = array[-nxmax..nxmax,-nymax..nymax] of real;


Procedure Initialization (Var pot: potarray;
                          Var nx, ny: integer);

Var i, j: integer;

Begin
    For i := -nx to nx do Begin
        For j := -ny to ny do Begin
            pot[i,j] := 0.0;
        End;
    End;
End;

Procedure CondLimites (Var pot: potarray;
                       Var nx, ny: integer);

Var i, j: integer;

Begin
    for i:=-nx to nx do pot[i,-ny]:=0.0;
    for i:=-nx to nx do pot[i,ny]:=0.0;
    for j:=-ny to ny do pot[-nx,j]:=0.0;
    for j:=-ny to ny do pot[nx,j]:=0.0;

    For i := -condy to condy do Begin
        pot[-condx,2] := -10.0;
        pot[condx,i] := 10.0;
    End;
End;

Procedure Test (Var pot, pot1: potarray;
                Var nx, ny: integer;
                Var eps: real;
                Var arret: boolean);

Var i, j: integer;
    fintest: boolean;

Begin
    fintest := FALSE;
    j := -ny+1;
    Repeat
        i := -nx+1;
        Repeat
            If (ABS(pot1[i,j]-pot[i,j]) > eps) then Begin
                fintest := TRUE
            End;
            i := i + 1;
        Until (fintest OR (i > nx-1));
        j := j + 1;
    Until (fintest OR (j > ny-1));
End;

Procedure Iteration (Var pot, pot1: potarray;
                     Var nx, ny: integer);

Var i, j: integer;

Begin
    pot1 := pot;
    For i := -nx+1 to nx-1 do Begin
        For j := -ny+1 to ny-1 do Begin
            pot[i,j] := (pot1[i+1,j] + pot1[i-1,j]
                      + pot1[i,j+1] + pot1[i,j-1])*0.25;
        End;
    End;
    CondLimites (pot, nx, ny);
End;

Procedure CalculPotentiel (Var pot, pot1: potarray;
                           Var nx, ny: integer;
                           Var eps: real;
                           Var NbIterMax: integer);

Var arret: boolean;
    NbIter: integer;

Begin
    arret := FALSE;
    NbIter := 0;
    Repeat
        NbIter := NbIter + 1;
        Iteration (pot, pot1, nx, ny);
        Test (pot, pot1, nx, ny, eps, arret);
        writeln ('Nombre d''iterations: ', NbIter);
    Until (arret OR (NbIter > NbIterMax));
End;

Procedure FindLocation (Var nx, ny: integer;
                        Var hx, hy, x, y: real;
                        Var x1, x2, y1, y2: integer);

Begin
    If (x >= 0.0) then Begin
        x1 := trunc(x/hx);
    End Else Begin
        x1 := trunc(x/hx) - 1;
    End;
    If (y >= 0.0) then Begin
        y1 := trunc(y/hy);
    End Else Begin
        y1 := trunc(y/hy) - 1;
    End;
    If (x1 >= nx) then Begin
        x1 := nx - 1;
    End Else If (x1 < -nx) then Begin
        x1 := -nx;
    End;
    x2 := x1 + 1;
    If (y1 >= ny) then Begin
        y1 := ny - 1;
    End Else If (y1 < -ny) then Begin
        y1 := -ny;
    End;
    y2 := y1 + 1;
End;

Procedure Interpolation (Var pot: potarray;
                         Var nx, ny: integer;
                         Var hx, hy, x, y, v: real);

Var x1, x2, y1, y2: integer;
    dx1, dx2, dy1, dy2: real;

Begin
    FindLocation (nx, ny, hx, hy, x, y, x1, x2, y1, y2);
    dx1 := x - x1*hx;
    dx2 := x - x2*hx;
    dy1 := y - y1*hy;
    dy2 := y - y2*hy;
    v := (dy1*dx1*pot[x2,y2] - dy1*dx2*pot[x1,y2]
       - dy2*dx1*pot[x2,y1] + dy2*dx2*pot[x1,y1])/(hx*hy);
End;

Procedure GradInterpolation (Var pot: potarray;
                             Var nx, ny: integer;
                             Var hx, hy, x, y, ex, ey: real);

Var x1, x2, y1, y2: integer;

Begin
    FindLocation (nx, ny, hx, hy, x, y, x1, x2, y1, y2);
    ex := ((y-y1*hy)*(pot[x2,y2]-pot[x1,y2])
        - (y-y2*hy)*(pot[x2,y1]-pot[x1,y1]))/(hx*hy);
    ey := ((x-x1*hx)*(pot[x2,y2]-pot[x2,y1])
        - (x-x2*hx)*(pot[x1,y2]-pot[x1,y1]))/(hx*hy);
End;

Procedure Equipotentielle (Var pot: potarray;
                           Var nx, ny: integer;
                           Var hx, hy, x, y, h: real);

Var xl, yl, xn, yn, dx1, dx2, dx3, dx4, dy1, dy2, dy3, dy4, ds, s: real;
    i: integer;
    fin: boolean;
    c:char;

Begin
    If (KeyPressed) then Begin
       asm
          xor ax,ax
          int 16h
       end;
    End;
    fin := FALSE;
    xl := x;
    yl := y;
    deplace (xl, yl);
    ds := sqrt(hx*hx + hy*hy)*h;
    Repeat
        GradInterpolation (pot, nx, ny, hx, hy, xl, yl, dx1, dy1);
        s := ds/sqrt(dx1*dx1 + dy1*dy1);
        xn := xl + dy1*s*0.5;
        yn := yl - dx1*s*0.5;
        GradInterpolation (pot, nx, ny, hx, hy, xn, yn, dx2, dy2);
        s := ds/sqrt(dx2*dx2 + dy2*dy2);
        xn := xl + dy2*s*0.5;
        yn := yl - dx2*s*0.5;
        GradInterpolation (pot, nx, ny, hx, hy, xn, yn, dx3, dy3);
        s := ds/sqrt(dx3*dx3 + dy3*dy3);
        xn := xl + dy3*s;
        yn := yl - dx3*s;
        GradInterpolation (pot, nx, ny, hx, hy, xn, yn, dx4, dy4);
        xl := xl + s/6.0*(dy1+dy2+dy2+dy3+dy3+dy4);
        yl := yl - s/6.0*(dx1+dx2+dx2+dx3+dx3+dx4);
        If ((xl > nx*hx) OR (xl < -nx*hx) OR (yl > ny*hy) OR (yl < -ny*hy)
            OR KeyPressed) then Begin
            fin := TRUE;
        End Else Begin
            trace (xl, yl);
        End;
    Until (fin);
End;

Procedure LigneChamp (Var pot: potarray;
                      Var nx, ny: integer;
                      Var hx, hy, x, y, h: real);

Var xl, yl, xn, yn, dx1, dx2, dx3, dx4, dy1, dy2, dy3, dy4, ds, s: real;
    fin: boolean;
    c:char;

Begin
    If (KeyPressed) then Begin
        c:=readkey;
        if c=#0 then c:=readkey;
    End;
    fin := FALSE;
    xl := x;
    yl := y;
    deplace (xl, yl);
    ds := sqrt(hx*hx + hy*hy)*h;
    Repeat
        GradInterpolation (pot, nx, ny, hx, hy, xl, yl, dx1, dy1);
        s := ds/sqrt(dx1*dx1 + dy1*dy1);
        xn := xl - dx1*s*0.5;
        yn := yl - dy1*s*0.5;
        GradInterpolation (pot, nx, ny, hx, hy, xn, yn, dx2, dy2);
        s := ds/sqrt(dx2*dx2 + dy2*dy2);
        xn := xl - dx2*s*0.5;
        yn := yl - dy2*s*0.5;
        GradInterpolation (pot, nx, ny, hx, hy, xn, yn, dx3, dy3);
        s := ds/sqrt(dx3*dx3 + dy3*dy3);
        xn := xl - dx3*s;
        yn := yl - dy3*s;
        GradInterpolation (pot, nx, ny, hx, hy, xn, yn, dx4, dy4);
        xl := xl - s/6.0*(dx1+dx2+dx2+dx3+dx3+dx4);
        yl := yl - s/6.0*(dy1+dy2+dy2+dy3+dy3+dy4);
        If ((xl > nx*hx) OR (xl < -nx*hx) OR (yl > ny*hy) OR (yl < -ny*hy)
            OR KeyPressed) then Begin
            fin := TRUE;
        End Else Begin
            trace (xl, yl);
        End;
    Until (fin);
End;

Var pot, pot1: potarray;
    i, nx, ny, NbIterMax: integer;
    eps, hx, hy, ex, ey, v, x, y, hinit, h: real;

Begin
    nx := 10;
    ny := 10;
    hx := 0.01;
    hy := 0.01;
    NbIterMax := 100;
    eps := 0.01;
    Initialization (pot, nx, ny);
    CondLimites (pot, nx, ny);
    CalculPotentiel (pot, pot1, nx, ny, eps, NbIterMax);
    write ('Pas d''integration: ');
    readln (hinit);
    initgraphique;
    fenetre (-nx*hx, nx*hx, -ny*hy, ny*hy);
    x_axe (0.0, 0.0, hx);
    y_axe (0.0, 0.0, hy);
    couleur(bleu);
    deplace(-condx*hx,-condy*hy); trace(-condx*hx,condy*hy);
    deplace(condx*hx,-condy*hy); trace(condx*hx,condy*hy);
    h := hinit;
    couleur(vert);
    For i := -nx+1 to nx-1 do
      if (i<>-condx) and (i<>condx) and (i<>0) then
      Begin
        x := i*hx;
        y := 0;
        Equipotentielle (pot, nx, ny, hx, hy, x, y, h);
      End;

      couleur(rouge);
    h:=-h;
    For i := -ny to ny do Begin
        y := i*hy;
        x := nx*hx;
        LigneChamp (pot, nx, ny, hx, hy, x, y,h);
    End;
    readln;
    modetexte;
End.