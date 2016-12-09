Procedure Rungefix (Var n : integer;
                    Var h, t : real;
                    Var x : tableau);

Const erreur : real = 1.066666667;
      coef : array [1..4] of real = (0.1666666667,0.3333333333,0.3333333333,0.1666666667);
      pas : array [1..4] of real = (0., 0.5, 0.5, 1);

Var i, j, k, l : integer;
    dy : tableau;
    tp : array [0..3,1..2] of real;
    t_int : real;

begin
    for i := 1 to n do begin
        tp[0,i] := x[i];
        tp[1,i] := x[i];
        dy[i] := 0.0;
    end;
    for l := 1 to 4 do begin
        t_int := t + h*pas[l];
        for i := 1 to n do begin
            x[i] := tp[0,i] + pas[l]*h*dy[i];
        end;
        f(n, t_int, x, dy);
        for i := 1 to n do begin
            tp[1,i] := tp[1,i] + h*dy[i]*coef[l];
        end;
    end;
    t := t + h;
    for i := 1 to n do begin
        x[i] := tp[1,i];
    end;
end;
