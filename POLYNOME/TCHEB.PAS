
program TCHEBICHEV;

{ René DEVICHI - 22/12/89 - Le LUC }

uses POLYNM;


{ calcule le polynôme de Tchebichev d'espèce E et de rang N }
procedure tcheb(var p:polynome;n,e:integer);
var
  p0,p1,p2x:polynome;
begin
  if (e<>1) and (e<>2)
  then nul(p)
  else begin
     constante(p0,1);
     with p1
     do begin
       deg:=1;
       coef[0]:=e;
       coef[1]:=0;
     end;
     chaine('2 0',p2x);   { p2x contient le polynôme P(X)=2X }
     if n<=0
     then p:=p0
     else
       if n=1
       then p:=p1
       else begin
         repeat
           produit(p2x,p1,p);
           oppose(p0);
           addition(p0,p,p);
           p0:=p1;
           p1:=p;
           dec(n);
         until n<2;
       end;
  end;
end;


{ exemple d'utilisation des polynômes de Tchebichev }
procedure exemple_tcheb;
var
  a,n:integer;
  p:polynome;
begin
  write('SIN ou COS  (1 ou 2) ? '); readln(a);
  write('Degré : '); readln(n);
  if a=2
  then begin
    tcheb(p,n,1);
    write('cos(',n:0,'*t) = '); affiche(p,'cos(t)'); writeln;
  end
  else begin
    if odd(n)
    then begin
      tcheb(p,n,1);
      if odd((n-1) div 2) then oppose(p);
      write('sin(',n:0,'*t) = '); affiche(p,'sin(t)'); writeln;
    end
    else begin
      if n=0 then nul(p) else tcheb(p,n-1,2);
      if odd(n div 2+1) then oppose(p);
      write('sin(',n:0,'*t) = cos(t)*('); affiche(p,'sin(t)'); writeln(')');
    end;
  end;
end;


begin
  exemple_tcheb;
end.
