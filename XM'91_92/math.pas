const
  maxn=12;

type
  matrice=array[1..maxn,1..maxn] of longint;

var
  n:word;
  m:matrice;
  p:longint;


procedure cree_tab;
var i,j:word;
begin
  m[1,1]:=1;
  for i:=1 to n do
    for j:=1 to n do
      if j>1 then m[i,j]:=m[i,j-1]*3
      else
        if i>1 then m[i,j]:=m[i-1,j]*2;
end;

procedure aff_tab;
var i,j:word;
begin
  for i:=1 to n do
  begin
    for j:=1 to n do write(m[i,j]:9);
    writeln;
  end;
  writeln;
end;


function elem(j,i:word):longint;
var
  k:word;
  n:longint;
begin
  n:=1;
  if i<j then
  begin
    for k:=2 to i do n:=n*6;
    for k:=i+1 to j do n:=n*3;
  end
  else
  begin
    for k:=2 to j do n:=n*6;
    for k:=j+1 to i do n:=n*2;
  end;
  elem:=n;
end;


procedure minmax(var min,max:longint);
var
  i,j:word;
begin
  max:=elem(n,n);
  min:=1;
  for i:=1 to n do
    for j:=1 to n do
    begin
       if (m[i,j]<=p) and (m[i,j]>min) then min:=m[i,j];
       if (m[i,j]>=p) and (m[i,j]<max) then max:=m[i,j];
    end;
end;


procedure min_opt;
var
  a,b,c:word;
begin
  a:=1;
  b:=n;
  repeat
    c:=(a+b) div 2;
    if m[c,c]<p then a:=c else b:=c;
  until (b-a)<=3;
  c:=(a+b) div 2;
  if m[c,c]<p then a:=c else b:=c;
writeln(a,' ',b,'    ',m[a,a],'  ',m[b,b]);

end;


var
  min,max:longint;

begin
  n:=12;
  cree_tab; {aff_tab; } writeln(elem(n,n));
  readln;
  repeat
  p:=10000;                   { entre 1 et 2^i*3^j }
  readln(p);
{  writeln('nombre p=',p);}
minmax(min,max);
writeln(min,'   ',max);

  until false;
end.
