Procedure weight (Var nps : integer;
                  Var pts, wght : tableau);

Var i, j, m : integer;
    eps, p1, p2, p3, pp, z, z1 : real;

begin
    eps := 3.e-9;
    m := (nps + 1) div 2;
    for i := 1 to m do begin
        z := cos(3.1415926535898*(i-0.25)/(nps+0.5));
        z1 := 2.0;
        while (abs(z1-z)>eps) do begin
            p1 := 1.0;
            p2 := 0.0;
            for j := 1 to nps do begin
                p3 := p2;
                p2 := p1;
                p1 := ((j+j-1)*z*p2 - (j-1)*p3)/j;
            end;
            pp := nps*(z*p1 - p2)/(z*z - 1.0);
            z1 := z;
            z := z1 - p1/pp;
        end;
        pts[i] := -z;
        pts[nps+1-i] := z;
        wght[i] := 2.0/((1.0 - z*z)*pp*pp);
        wght[nps+1-i] := wght[i];
    end;
end;
