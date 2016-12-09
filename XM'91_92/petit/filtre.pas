type gldarray = array [1..258] of real;
     tableau = array [1..2] of real;

{$I four1.pas}
{$I realft.pas}

procedure f (Var n : integer;
             Var t : real;
             Var x, dy : tableau);

begin
    dy[1] := 6.28318530718*cos(6.28318530718*t) - x[1];
end;

{$I rungefix.pas}

Var y1, y2, y3, y4, y5 : gldarray;
    i, ii, isign, nt, nv : integer;
    x : tableau;
    fact, h, ri, t : real;

begin
    nv := 1;
    nt := 128;
    t := 0.0;
    x[1] := 1.0/(6.28318530718 + 1.0/6.28318530718);
    h := 1.0/128.0;
    for i := 1 to 2*nt do begin
        for ii := 1 to 8 do begin
            rungefix (nv, h, t, x);
        end;
        y2[i] := x[1];
        y1[i] := sin(6.28318530718*t);
    end;
    isign := 1;
    realft (y1, nt, isign);
    ri := 0.0;
    y4[1] := abs(y1[1]);
    y5[1] := y4[1];
    y3[1] := y1[1];
    for i := 2 to nt do begin
        ii := i + i;
        ri := ri + 1.0;
        fact := 1.0/(1.0 + 1.0/(0.154212568767*ri*ri));
        y3[ii-1] := (y1[ii-1] - y1[ii]/(0.392699081699*ri))*fact;
        y3[ii] := (y1[ii] + y1[ii-1]/(0.392699081699*ri))*fact;
        y4[i] := sqrt(y1[ii-1]*y1[ii-1] + y1[ii]*y1[ii]);
        y5[i] := sqrt(y3[ii-1]*y3[ii-1] + y3[ii]*y3[ii]);
    end;
    y4[129] := abs(y1[2]);
    ri := 128.0;
    y3[2] := y1[2]/(1.0 + 1.0/(0.154212568767*ri*ri));
    y5[129] := abs(y3[2]);
    isign := -1;
    realft (y3, nt, isign);
    realft (y1, nt, isign);
    for ii := 1 to 8 do begin
        for i := 1 to 16 do begin
            writeln (i, y2[i], y3[i]/128.0, y1[i]/128.0, y5[i]);
        end;
        write ('Tapez RETURN pour continuer.');
        readln;
    end;
end.