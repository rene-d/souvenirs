procedure four1 (Var data: gldarray;
                 nn, isign: integer);

Var ii, jj, n, mmax, m, j, istep, i: integer;
    wtemp, wr, wpr, wpi, wi, theta: real;
    tempr, tempi: real;

begin
    n := 2*nn;
    j := 1;
    for ii := 1 to nn do begin
        i := 2*ii - 1;
        if (j > i) then begin
            tempr := data[j];
            tempi := data[j+1];
            data[j] := data[i];
            data[j+1] := data[i+1];
            data[i] := tempr;
            data[i+1] := tempi;
        end;
        m := n div 2;
        while ((m >= 2) and (j > m)) do begin
            j := j - m;
            m := m div 2;
        end;
        j := j + m;
    end;
    mmax := 2;
    while (n > mmax) do begin
        istep := 2*mmax;
        theta := 6.28318530717959/(isign*mmax);
        wpr := -2.0*sqr(sin(0.5*theta));
        wpi := sin(theta);
        wr := 1.0;
        wi := 0.0;
        for ii := 1 to (mmax div 2) do begin
            m := 2*ii - 1;
            for jj := 0 to ((n-m) div istep) do begin
                i := m + jj*istep;
                j := i + mmax;
                tempr := wr*data[j] - wi*data[j+1];
                tempi := wr*data[j+1] + wi*data[j];
                data[j] := data[i] - tempr;
                data[j+1] := data[i+1] - tempi;
                data[i] := data[i] + tempr;
                data[i+1] := data[i+1] + tempi;
            end;
            wtemp := wr;
            wr := wr*wpr - wi*wpi + wr;
            wi := wi*wpr + wtemp*wpi + wi;
        end;
        mmax := istep;
    end;
end;