program spirale_bis;   { même chose que spirale, mais en résolution 800x600 }

uses crt,dos,premiers;

const
  getmaxx=799;
  getmaxy=599;


var
  regs:registers;
  p,n:longint;
  i,j,x,y:integer;

const
  masque:array[0..7] of byte=(128,64,32,16,8,4,2,1);

procedure prem;
begin
  if premier(n) then
  begin
    mem[$A000:x div 8+y*100]:=mem[$A000:x div 8+y*100] or masque[x mod 8];
    inc(p);
  end;
  inc(n);
end;


begin
  regs.ax:=88; intr($10,regs);
  x:=getmaxx div 2; y:=getmaxy div 2;

  p:=0; n:=2; i:=1;   { on commence par n=2 : premier nombre premier    }
                      { (x-1,y) : nombre 1 (i.e : centre de la spirale) }
  repeat
    for j:=1 to i do begin prem; dec(y); end;
    inc(i);
    for j:=1 to i do begin prem; dec(x); end;
    for j:=1 to i do begin prem; inc(y); end;
    inc(i,1);
    for j:=1 to i do begin prem; inc(x); end;
  until y>(getmaxy-3);

  readln;
  regs.ax:=$3; intr($10,regs);
  writeln('nombres testés : ',n);
  writeln('points (nombres premiers) : ',p);
end.
