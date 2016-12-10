{$I g640c350.ega}
{$I graphe.lib}
{$I imprime.pas}

type tableau = array [1..21] of real;

Var a, b, s, s1, s2, sig, sig1, sig2,sig0,deltasig,D,D0,Ki : real;
    int1d, int2d, int3d, offset1d, offset2d, offset3d : real;
    slope1d, slope2d, slope3d, x, x1, x2, f1, f2, xe1, xe2, dxe : real;
    pts, wght : tableau;
    res, xe : array [0..200] of real;
    i, j, k, l, nps : integer;

function f (Var x, s, sig :real) : real;

Var t, y, z : real;

begin
    y := 3.1415926535898*(x -D*s/D0)*sig/D;
    z := y*a;
    y := y*b;
    if (abs(z) <  1.e-8) then begin
        t := cos(y);
    end
    else begin
        t := sin(z)/z*cos(y);
    end;
    f := t*t;
end;

{$I weight.pas}

type str255=string[255];

procedure ask(s:str255;var r:real);
var t:str255; r2:real; y,e:integer;
begin
  writeln;
  y:=wherey;
  repeat
    gotoxy(1,y); clreol;
    write(upcase(s[1]),copy(s,2,255),' <',r:10:5,'> : ');
    readln(t);
    if t='' then e:=0 else begin val(t,r2,e); if e=0 then r:=r2; end;
  until e=0;
  gotoxy(1,y); clreol;
  write(upcase(s[1]),copy(s,2,255),'  :  ',r:10:5);
end;


begin clrscr;
{ Initialisation de D0, D, a, b, f1, f2, xe2 (abscisse extreme droite de
l'ecran), sig0 et deltasig}

d:=1.0; a:=5e-5; d0:=1.0; b:=2e-4; f1:=5e-5; f2:=1e-4; xe2:=0.03;sig0:=2e6;
deltasig:=2e4; Ki:=1e5;

ask('largeur fente d''Young',a);
ask('distance entre les fentes d''Young',b);
ask('distance focale de la lentille d''observation',D);
ask('distance focale de la lentille collimatrice',D0);
ask('largeur de la fente source',f1);
ask('largeur de la fente r‚ceptrice',f2);
ask('abscisse extrˆme droite de la fente r‚ceptrice',xe2);
ask('nombre d''onde (1/lambda)',sig0);
ask('deltasig',deltasig);
ask('facteur d''intensit‚',Ki);

    nps := 6;
    weight (nps, pts, wght);
    xe1:= -xe2;
    s1 := -0.5*f1;
    s2 := 0.5*f1;
    sig2:=sig0+0.5*deltasig;
    sig1:=sig0-0.5*deltasig;
    initgraphique;
    couleur (15);
    fenetre (xe1, xe2, 0.0, 10.0);
    x_axe (0.0, 0.0, 1.0);
    y_axe (0.0, 0.0, 0.5);
    deplace (xe1, 0.0);
    dxe := (xe2 - xe1)/200.0;
    for l := 0 to 100 do begin
        xe[l] := xe1 + dxe*l;
        x1 := xe[l] - 0.5*f2;
        x2 := xe[l] + 0.5*f2;
        int3d := 0;
        slope3d := (x2 - x1)*0.5;
        offset3d := (x2 + x1)*0.5;
        for i := 1 to nps do begin
            x := offset3d + slope3d*pts[i];
            int2d := 0;
            slope2d := (s2 - s1)*0.5;
            offset2d := (s2 + s1)*0.5;
            for j := 1 to nps do begin
                s := offset2d + slope2d*pts[j];
                int1d := 0;
                slope1d := (sig2 - sig1)*0.5;
                offset1d := (sig2 + sig1)*0.5;
                for k := 1 to nps do begin
                    sig := offset1d + slope1d*pts[k];
                    int1d := int1d + f(x,s,sig)*wght[k];
                end;
                int2d := int2d + int1d*slope1d*wght[j];
            end;
            int3d := int3d + int2d*slope2d*wght[i];
        end;
        res[l] := int3d*slope3d*Ki;
        trace (xe[l], res[l]);
    end;
    for l := 100 downto 0 do begin
        trace (-xe[l], res[l]);
    end;
    pausegraphique;
    writeln ('res en x=0 est:',res[100]);
    writeln ('D0  =',D0:9:5);
    writeln ('D   =',D:9:5);
    writeln ('a   =',a:9:5);
    writeln ('b   =',b:9:5);
    writeln ('f1  =',f1:9:5);
    writeln ('f2  =',f2:9:5);
    writeln ('xe2 =',xe2:9:5);
    writeln ('sig0=',sig0:9:1);
    writeln ('deltasig=',deltasig:9:1);
    writeln ('Ki  =',Ki:9:1);
    write ('Voulez vous une hardcopy (1) : ');
    readln (l);
    if (l = 1) then begin
        hardcopy (false);
    end;
end.