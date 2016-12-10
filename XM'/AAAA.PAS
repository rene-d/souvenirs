uses graph;
var a,b:integer; x,y:integer;
  ksi:real;
  eta:real;
  c:integer;

  function sinc(x:real):real;
  begin
    if abs(x)<1e-5 then sinc:=1 else sinc:=sin(x)/x;
  end;

begin
  a:=3; b:=1; initgraph(a,b,'c:\tp');
  eta:=1/20;
  ksi:=1/20;
  for x:=0 to 78 do for y:=0 to 43 do
  begin
    c:= round((9*sqr(sinc( x*ksi) * sinc(y*eta))));
    if c>0 then c:=c+6;
    putpixel(4*x+319,4*y+170,c);
    putpixel(4*x+319+1,4*y+170,c);
    putpixel(4*x+319+1,4*y+1+170,c);
    putpixel(4*x+319,4*y+1+170,c);
  end;
  readln;
  closegraph;
end.