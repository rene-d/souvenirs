uses crt,graph,premiers;

var
  carte,mode,c:integer;
  p,n:longint;
  i,j,x,y:integer;


procedure prem;
begin
  if premier(n) then begin putpixel(x,y,c); inc(p); end;
  inc(n);
end;



begin
  carte:=ega; mode:=1;
  initgraph(carte,mode,'');
  c:=white;
  x:=getmaxx div 2;
  y:=getmaxy div 2;
  p:=0; n:=2; i:=1;   { on commence par n=2 : premier nombre premier }
{ putpixel(x-1,y,2);  { point où serait le nombre 1 (i.e. : centre)  }
  repeat
    for j:=1 to i do begin prem; dec(y); end;
    inc(i);
    for j:=1 to i do begin prem; dec(x); end;
    for j:=1 to i do begin prem; inc(y); end;
    inc(i,1);
    for j:=1 to i do begin prem; inc(x); end;
  until y>(getmaxy-5);

  readln;
  closegraph;
  writeln('nombres ',n);
  writeln('points  ',p);
end.