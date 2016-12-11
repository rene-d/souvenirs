program Matrices_de_Jacobi;
{$n+}

uses
  crt,matrices;      { inclut la gestion de l'écran et l'unité Matrices }

type
  real=extended;

const
  epsilon=1e-12;


procedure Jacobi(a:matrice;var b:vecteur;var vect_prop:matrice;var it:word);

{ trouve la norme sup. en dehors de la diagonale }
procedure norme(var m:matrice;var n:real;var l,c:word);
var
  i,j:word;
begin
  n:=0;
  for i:=1 to ordre do
    for j:=1 to ordre do
      if i<j then
        if abs(m[i,j])>=n then
        begin
          n:=abs(m[i,j]);
          l:=i;
          c:=j;
        end;
end;

{ norme sup. de la différence de deux matrices }
function norme_bis(var a,b:matrice):real;
var i,j:word; n:real;
begin
  n:=0;
  for i:=1 to ordre do
    for j:=1 to ordre do
      if abs(a[i,j]-b[i,j])>=n then
        n:=abs(a[i,j]-b[i,j]);
  norme_bis:=n;
end;

var
  p,q,w:word;
  n:real;
  theta:real;
  omega,tmp:matrice;
begin
  it:=0;
  identite_carree(vect_prop);
  repeat
    inc(it);
    norme(a,n,p,q);
    if a[p,p]=a[q,q] then theta:=pi/4
    else theta:=arctan(2*a[p,q]/(a[q,q]-a[p,p]))/2;
    identite_carree(omega);
    omega[p,p]:=cos(theta);
    omega[q,q]:=cos(theta);
    omega[p,q]:=sin(theta);
    omega[q,p]:=-sin(theta);
    produit_carree(vect_prop,omega,vect_prop);
    produit_carree(a,omega,tmp);  { tmp=a.omega }
    omega[p,q]:=-sin(theta);   { on transpose omega }
    omega[q,p]:=sin(theta);
    produit_carree(omega,tmp,tmp);  {omega est en fait la transposée  }
                                    { tmp=t_omega.tmp=t_omega.a.omega }
    n:=norme_bis(a,tmp);
    a:=tmp;
  until n<=epsilon;
  for w:=1 to ordre do b[w]:=a[w,w];
end;



procedure matrice_symetrique_aleatoire(var m:matrice);
var
  i,j:word;
begin
  for i:=1 to ordre do
    for j:=1 to i do
    begin
      m[i,j]:=integer(random(20))-10;
      m[j,i]:=m[i,j];
    end;
end;


var
  a,c,tmp:matrice;
  b:vecteur;
  i,j,it:word;
  rnd:char;
  f:text;

begin
  clrscr;
  repeat
    write('ordre des matrices carrées : '); readln(ordre);
    if ordre<=0 then exit;  { fin du programme }
    write('matrice aléatoire (o/n) ? '); readln(rnd);
    if upcase(rnd)='O' then matrice_symetrique_aleatoire(a)
    else entree_carree_symetrique(a);
    assigncrt(f);
    { assign(f,'prn'); { pour envoyer le résultat à l'imprimante }
    rewrite(f);
    { write(f,#27#15); { si imprimante : 136 colonnes }
    writeln(f,'Matrice A :');
    for i:=1 to ordre do
    begin
      for j:=1 to ordre do write(f,a[i,j]:16:11); writeln(f);
    end;
    Jacobi(a,b,c,it);
    writeln(f,#13#10,'Valeurs propres :');
    for i:=1 to ordre do write(f,b[i]:16:11); writeln(f);
    writeln(f,#13#10,'Vecteurs propres :');
    for i:=1 to ordre do
    begin
      write(f,'(');
      for j:=1 to ordre do
        if j<>ordre then write(f,c[j,i]:16:11,',')
        else writeln(f,c[j,i]:16:11,')');
    end;
    writeln(f,#13#10,'nombre d''itérations : ',it);
    writeln(f);
    for i:=1 to ordre do
    begin
      for j:=1 to ordre do tmp[j,1]:=c[j,i];  { tmp=vecteur propre no i }
      produit(a,tmp,tmp,ordre,ordre,1);
      for j:=1 to ordre do tmp[j,1]:=tmp[j,1]-b[i]*c[j,i]; { tmp=AV-l∙V }
      writeln(f,'Vérification valeur propre n°',i,'  ',norme_sup(tmp,ordre,1));
    end;
    writeln(f,'                 * * * * * * * * * * * * * * * * * * * * * *');
    close(f);
  until false;
end.