procedure realft (Var data: gldarray;
                  n, isign: integer);

Var wr, wi, wpr, wpi, wtemp, theta: real;
    i, i1, i2, i3, i4: integer;
    c1, c2, h1r, h1i, h2r, h2i, wrs, wis: real;

begin
    theta := 6.28318530717959/(2.0*n);
    c1 := 0.5;
    if (isign = 1) then begin
        c2 := -0.5;
        four1(data, n, 1);
    end
    else begin
        c2 := 0.5;
        theta := -theta;
    end;
    wpr := -2.0*sqr(sin(0.5*theta));
    wpi := sin(theta);
    wr := 1.0 + wpr;
    wi := wpi;
    for i := 2 to (n div 2) do begin
        i1 := i + i - 1;
        i2 := i1 + 1;
        i3 := n + n + 3 - i2;
        i4 := i3 + 1;
        wrs := wr;
        wis := wi;
        h1r := c1*(data[i1] + data[i3]);
        h1i := c1*(data[i2] - data[i4]);
        h2r := -c2*(data[i2] + data[i4]);
        h2i := c2*(data[i1] - data[i3]);
        data[i1] := h1r + wrs*h2r - wis*h2i;
        data[i2] := h1i + wrs*h2i + wis*h2r;
        data[i3] := h1r - wrs*h2r + wis*h2i;
        data[i4] := -h1i + wrs*h2i + wis*h2r;
        wtemp := wr;
        wr := wr*wpr - wi*wpi + wr;
        wi := wi*wpr + wtemp*wpi + wi;
    end;
    if (isign = 1) then begin
        h1r := data[1];
        data[1] := h1r + data[2];
        data[2] := h1r - data[2];
    end
    else begin
        h1r := data[1];
        data[1] := c1*(h1r + data[2]);
        data[2] := c1*(h1r - data[2]);
        four1(data, n, -1);
    end
end;