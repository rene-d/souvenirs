function gauss (Var nps :integer;
                Var min, max :real;
                Var pts, wght : tableau) : real;

Var i : integer;
    int, offset, slope, v : real;

begin
    int := 0.0;
    slope := (max - min)*0.5;
    offset := (max + min)*0.5;
    for i := 1 to nps do begin
        v := offset + slope*pts[i];
        int := int + f(v)*wght[i];
    end;
    gauss := int*slope;
end;