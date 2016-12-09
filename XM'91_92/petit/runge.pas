Procedure Runge (Var n : integer;
                  Var eps, h, t : real;
                  Var x : tableau);

Const erreur : real = 1.066666667;
      coef : array [1..4] of real = (0.1666666667,0.3333333333,0.3333333333,0.1666666667);
      pas : array [1..4] of real = (0., 0.5, 0.5, 1);

Var i, j, k, l : integer;
    dy : tableau;
    tp : array [0..3,1..2] of real;
    hd, rj, var_int, varm, ta, t_int : real;

begin
    ta := t;
    for i := 1 to n do begin
        tp[0,i] := x[i];
        tp[3,i] := x[i];
    end;
    repeat
        varm := 0.;
        for i := 1 to n do begin
            tp[1,i] := tp[3,i];
            tp[2,i] := tp[3,i];
        end;
        rj := 0;
        for j := 1 to 2 do begin
            rj := rj + 1.;
            for i := 1 to n do begin
                x[i] := tp[3,i];
                tp[0,i] := tp[3,i];
                dy[i] := 0.0;
            end;
            t := ta;
            hd := h/rj;
            for k := 1 to j do begin
                for l := 1 to 4 do begin
                    t_int := t + hd*pas[l];
                    for i := 1 to n do begin
                        x[i] := tp[0,i] + pas[l]*hd*dy[i];
                    end;
                    f(n, t_int, x, dy);
                    for i := 1 to n do begin
                        tp[j,i] := tp[j,i] + hd*dy[i]*coef[l];
                    end;
                end;
                t := t + hd;
                for i := 1 to n do begin
                    x[i] := tp[j,i];
                    tp[0,i] := tp[j,i];
                end;
            end;
        end;
        for i := 1 to n do begin
            var_int := erreur*abs(tp[1,i] - tp[2,i])/eps;
            if (var_int > 1e-5) then begin
                var_int := exp(0.2*ln(var_int));
            end;
            if (varm < var_int) then begin
                varm := var_int;
            end;
        end;
        if (varm < 0.1) then begin
            varm := 0.1;
        end;
        h := 2.*h/varm;
        if (varm > 3) then begin
            t := ta;
        end;
    until (varm <= 3);
end;
