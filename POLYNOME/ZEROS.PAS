{$R+,S+,I+,D+,F+,V+,B+,N-,L+ }
{$M 16384,0,655360 }
uses polynm;

const
  epsilon:real=1E-10;

var
  zd_erreur:boolean;

function zero_dicho(p:polynome;x1,x2:real):real;
var
  m,v:real;
  n:byte;
begin
  zd_erreur:=false;
  if valeur(p,x1)>valeur(p,x2)
  then begin
    m:=x1; x1:=x2; x2:=m;
  end;
  n:=0;
  repeat
    m:=(x2+x1)/2;
    v:=valeur(p,m);
    if v<0 then x1:=m else x2:=m;
    inc(n);
  until (abs(v)<epsilon) or (n=60);
  if n=60
  then begin
    writeln(' ** Le calcul par dichotomie diverge ** ');
    zd_erreur:=true;
    exit;
  end;
  zero_dicho:=m;
end;

var p:polynome;
begin
  chaine('1 -5 1 -3',p);
  writeln(zero_dicho(p,-100,100));
end.