
unit matjacobi;

interface

type
  vecteur=array[1..15] of real;
  matrice=array[1..15] of vecteur;

var
  ordre:word;

procedure entree(var m:matrice;l,c:word);
procedure entree_symetrique(var m:matrice;n:word);
procedure affiche(var m:matrice;l,c:word);
procedure addition(a,b:matrice;var c:matrice;m,n:word);
procedure produit(a,b:matrice;var c:matrice;m,n,p:word);
procedure produit_scalaire(a:matrice;r:real;var b:matrice;l,c:word);
procedure transpose(a:matrice;var b:matrice;m,n:word);
function norme_sup(var m:matrice;l,c:word):real;
procedure nulle(var m:matrice;l,c:word);
procedure identite(var m:matrice;n:word);

procedure entree_carree(var m:matrice);
procedure affiche_carree(var m:matrice);
procedure entree_carree_symetrique(var m:matrice);
procedure transpose_carree(a:matrice;var b:matrice);
procedure produit_carree(a,b:matrice;var c:matrice);
procedure identite_carree(var m:matrice);
procedure nulle_carree(var m:matrice);

implementation

procedure entree;
var i,j:word;
begin
  writeln('Entrez la matrice ligne par ligne.');
  for i:=1 to l do
  begin
    writeln(#13#10,'ligne n°',i:2,' :');
    for j:=1 to c do
    begin
      write('(ligne ',i:2,') colonne ',j:2,' : ');
      readln(m[i,j]);
    end;
  end;
end;


procedure entree_symetrique;
var i,j:word;
begin
  writeln('Entrez la matrice symétrique ligne par ligne.');
  for i:=1 to n do
  begin
    writeln(#13#10,'ligne n°',i,'  (',n+1-i,' colonnes)');
    for j:=i to n do
    begin
      write('(ligne ',i:2,') colonne ',j:2,' : ');
      readln(m[i,j]);
      m[j,i]:=m[i,j];
    end;
  end;
end;

procedure affiche(var m:matrice;l,c:word);
var i,j:word;
begin
  for i:=1 to l do
  begin
    for j:=1 to c do write(m[i,j]:10:2);
    writeln;
  end;
end;


function norme_sup(var m:matrice;l,c:word):real;
var
  i,j:word;
  r:real;
begin
  r:=0;
  for i:=1 to l do for j:=1 to c do if r<abs(m[i,j]) then r:=m[i,j];
  norme_sup:=r;
end;


procedure produit;
var
  i,j,k:word;
  r:real;
begin
  for i:=1 to m do
    for j:=1 to p do
    begin
      r:=0;
      for k:=1 to n do r:=r+a[i,k]*b[k,j];
      c[i,j]:=r;
    end;
end;

procedure addition;
var i,j:word;
begin
  for i:=1 to m do for j:=1 to n do c[i,j]:=a[i,j]+b[i,j];
end;

procedure transpose;
var i,j:word;
begin
  for i:=1 to m do for j:=1 to n do b[j,i]:=a[i,j];
end;


procedure entree_carree(var m:matrice);
begin
  entree(m,ordre,ordre);
end;

procedure affiche_carree(var m:matrice);
begin
  affiche(m,ordre,ordre);
end;

procedure entree_carree_symetrique(var m:matrice);
begin
  entree_symetrique(m,ordre);
end;

procedure transpose_carree;
begin
  transpose(a,b,ordre,ordre);
end;

procedure produit_carree;
begin
  produit(a,b,c,ordre,ordre,ordre);
end;

procedure nulle(var m:matrice;l,c:word);
var i,j:word;
begin
  for i:=1 to l do for j:=1 to c do m[i,j]:=0;
end;

procedure identite(var m:matrice;n:word);
var i,j:word;
begin
  for i:=1 to n do for j:=1 to n do if i=j then m[i,j]:=1 else m[i,j]:=0;
end;

procedure nulle_carree(var m:matrice);
begin
  nulle(m,ordre,ordre);
end;

procedure identite_carree(var m:matrice);
begin
  identite(m,ordre);
end;

procedure produit_scalaire(a:matrice;r:real;var b:matrice;l,c:word);
var
  i,j:word;
begin
  for i:=1 to l do for j:=1 to c do b[i,j]:=l*a[i,j];
end;


end.
