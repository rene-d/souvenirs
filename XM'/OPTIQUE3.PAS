program optique31;

{$I g640c350.ega}
{$I graphe.lib}
{$I imprime.pas}



type tableau = array [1..21] of real;
Var a, b, s, s1, s2, sig, sig1, sig2,sig01,sig02,L01,L02,c1,c2,D,D0,Ki : real;
    sig0,deltasig,int1d, int2d, int3d, offset1d, offset2d, offset3d : real;
    slope1d, slope2d, slope3d, x, x1, x2, f1, f2, xe1, xe2, dxe : real;
    pts, wght : tableau;
    res, xe,sigm,Lu : array [0..400] of real;
    i, j, k, l,m, nps : integer;

function Lum(var sig :real):real;
   begin
   Lum:=L01*exp(-sqr((sig-sig01)/c1))+ L02*exp(-sqr((sig-sig02)/c2)) ;
   end;
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
    f := t*t*Lum(sig);
end;

{$I weight.pas}

begin
    write ('distance focale de la lentille collimatrice :');
    readln (D0);
    write ('distance focale de la lentille d''observation:');
    readln (D);
    write ('Largeur des fentes d Young : ');
    readln (a);
    write ('Distance entre les fentes d Young : ');
    readln (b);
    nps := 6;
    weight (nps, pts, wght);
    write('Largeur de la fente source:');
    readln (f1);
    write('Largeur de la fente de cellule:');
    readln (f2);
    write ('abscisse extreme droite de l''Šcran:');
    readln (xe2);
    xe1:=-xe2 ;
    s1 := -0.5*f1;
    s2 := 0.5*f1;
    write ('limite maximale du nombre d''onde:');
    readln (sig2);
    write ('limite minimale du nombre d''onde:');
    readln (sig1);
    write ('facteur d''intensitŠ:');
    readln (Ki);
    write('sig01=');
    readln (sig01);
    write('sig02=');
    readln (sig02);
    write('L01=');
    readln(L01);
    write ('L02=');
    readln (L02);
    write ('largeur premiŠre raie =');
    readln (c1);
    write ('largeur deuxiŠme raie =');
    readln (c2);

    initgraphique;
    couleur (15);
    fenetre (xe1, xe2, 0.0, 10.0);
    x_axe (0.0, 0.0, 1.0);
    y_axe (0.0, 0.0, 0.5);
    deplace (xe1, 0.0);
    dxe := (xe2 - xe1)/400.0;
    for l := 0 to 200 do begin
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
    for l := 200 downto 0 do begin
        trace (-xe[l], res[l]);
    end;
    pausegraphique;
    writeln ('res en x = 0  =',res[200]);
    writeln ('D0  =',D0:9:5);
    writeln ('D   =',D:9:5);
    writeln ('a   =',a:9:5);
    writeln ('b   =',b:9:5);
    writeln ('f1  =',f1:9:5);
    writeln ('f2  =',f2:9:5);
    writeln ('xe1 =',xe1:9:5);
    writeln ('xe2 =',xe2:9:5);
    writeln ('Ki  =',Ki:9:1);
    writeln ('sig2=',sig2:9:1);
    writeln ('sig1=',sig1:9:1);
    writeln ('sig01=',sig01:9:1);
    writeln ('sig02=',sig02:9:1);
    writeln ('c1=',c1:9:1);
    writeln ('c2=',c2:9:1);
    write ('Voulez vous une hardcopy (1) : ');
    readln (l);
    if (l = 1) then begin
        hardcopy (false);
    end;
end.