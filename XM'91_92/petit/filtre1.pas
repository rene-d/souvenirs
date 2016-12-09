uses graph,modubase;


type gldarray=array [1..258] of real;
     tableau=array [1..2] of real;

const o1=3.14159265359;
      o2=6.28318530718;
      o3=12.56637061436;

Var choice: integer;
  fact1,fact2,R,L,C:real;

{$I a:\petit\four1.pas}
{$I a:\petit\realft.pas}

procedure v (var n : integer;
             var t : real;
             var x : tableau);

begin
    if (choice=2) then begin
        x[1]:=sin(o1*t) + sin(o2*t) + sin(o3*t);
    end
    else if (choice=1) then begin
        x[1]:=sin(o2*t);
    end
    else begin
        x[1]:=t - trunc(t);
        if (x[1] < 0.5) then begin
            x[1]:=1.0;
        end
        else begin
            x[1]:=0.0;
        end;
    end;
end;

procedure f (var n : integer;
             var t : real;
             var x, dy : tableau);

begin
    if (choice=2) then begin
      dy[2]:=(o1*cos(o1*t)+o2*cos(o2*t)+o3*cos(o3*t))/(r*c);
    end
    else if (choice=1) then begin
      dy[2]:=o2*cos(o2*o2*t)/(r*c);
    end;
    dy[2]:=dy[2]+x[1]/(r*l)-x[2]/(r*c);
    dy[1]:=x[2];
end;

{$I a:\petit\rungefix.pas}

var
  y2, y3, y4 : gldarray;
  i, ih, ii, isign, j, nt, nv, ri: integer;
  x, y : tableau;
  delta, fact, h, om, t: real;

begin
    nv:=1;
    nt:=128;
    delta:=1.0/16.0;
    ih:=8;
    write('valeur de R : '); readln(R);
    write('valeur de L : '); readln(L);
    write('valeur de C : '); readln(C);
    repeat
        writeln ('Quel signal d''entr‚e voulez-vous ?');
        writeln ('Ve=sin(2úpiút) ---------------------------- 1');
        writeln ('Ve=sin(piút) + sin(2úpiút) + sin(4úpiút) -- 2');
                writeln ('Ve=signal carr‚ sym‚trique de p‚riode 1 --- 3');
        write ('Choix : ');
        readln (choice);
    until ((choice > 0) and (choice < 4));
    if (choice=2) then
    begin end
    else if (choice=1) then
    begin end;
    h:=delta/ih;
    if (choice <> 3) then begin
        x[1]:=0;
        x[2]:=
        t:=0.0;
        for i:=1 to 2*nt do begin
            for ii:=1 to ih do begin
                rungefix (nv, h, t, x);
            end;
            y2[i]:=x[1];
        end;
    end;
    t:=0.0;
    for i:=1 to 2*nt do begin
        t:=t + delta;
        v (nv, t, y);
        y3[i]:=y[1];
    end;
    writeln ('Fin de g‚n‚ration des donn‚es.');
    isign:=1;
    realft (y3, nt, isign);
    ri:=0;
    y4[1]:=0.0;
    for i:=2 to nt do
    begin
        ii:=i shl 1;
        inc(ri);
        om:=ri*pi/(nt*delta);
        fact1:=om;
        fact2:=R*(1/L-C*om*om);
        fact:=om/(fact1*fact1+fact2*fact2);
        Y4[ii-1]:=fact*(fact1*Y3[ii-1]-fact2*Y3[ii]);
        Y4[ii]:=fact*(fact1*Y3[ii]+fact2*Y3[ii-1]);

    end;
    inc(ri);
    om:=ri*3.1415926535897932384626433/(nt*delta);
    isign:=-1;
    realft (y4, nt, isign);
    InitGraphique; forcegraphique(ega,2);
    Fenetre (0,nt,-3,3);
    X_axe (0,0,1);
    Y_axe (0,0,1);
    if (choice < 3) then begin
        Deplace (0,y2[1]);
        for i:=2 to nt do begin
            Trace (i-1,y2[i]);
        end;
    end;
    Deplace (0,y4[1]/nt);
    for i:=2 to nt do Trace (i-1,y4[i]/nt);
    PauseGraphique;
end.