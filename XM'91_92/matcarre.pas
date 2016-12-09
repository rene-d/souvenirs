unit matcarre;

{---------------------------------------------------------------}
{ Unité de gestion de matrices carrées                          }
{ Turbo Pascal 6.0                                              }
{ (c) Copyright 12-1991 René Devichi                            }
{---------------------------------------------------------------}

interface


const
  mmax=15;
  epsilon:real=1e-7;


type
  vecteur=array[1..mmax] of real;
  matrice=array[1..mmax] of vecteur;


var
  dim:integer;


procedure defdim(n:integer);
procedure identite(var M:matrice);
procedure somme(var A,B,C:matrice);
procedure produit(var A,B,C:matrice);
procedure scalprod(x:real; var A,B:matrice);
procedure difference(var A,B,C:matrice);
function normesup(var A:matrice):real;
function norme2(var A:matrice):real;
procedure ecrire_matrice(var A:matrice; d1,d2:integer);
procedure entrer_matrice(var A:matrice);
procedure sauver_matrice(var A:matrice; nomfic:string);
procedure charger_matrice(var A:matrice; nomfic:string);
function trace(var A:matrice):real;
procedure transpose(var A,B:matrice);

procedure inversion(A:matrice; var B:matrice; var det:real);
procedure householder(var A,Q,R:matrice);


implementation


procedure swapr(var r1,r2:real);
var r:real;
begin
  r:=r1;
  r1:=r2;
  r2:=r;
end;



procedure defdim(n:integer);
begin
  if n<1 then
  begin
    writeln('La taille doit au moins être 1.');
    dim:=1;
  end
  else if n>mmax then
  begin
    writeln('Taille trop grande. Augmentez la constante MMAX.');
    dim:=mmax;
  end
  else dim:=n;
end;



procedure identite(var M:matrice);
var
  i,j:integer;
begin
  for i:=1 to dim do
    for j:=1 to dim do
      if i=j then M[i,j]:=1.0
      else M[i,j]:=0.0;
end;



procedure somme(var A,B,C:matrice);
var
  i,j:integer;
begin
  for i:=1 to dim do
    for j:=1 to dim do
      C[i,j]:=A[i,j]+B[i,j];
end;



procedure produit(var A,B,C:matrice);
var
  i,j,k:integer;
  x:real;
begin
  for i:=1 to dim do
    for j:=1 to dim do
    begin
      x:=0.0;
      for k:=1 to dim do x:=x+A[i,k]*B[k,j];
      C[i,j]:=x;
    end;
end;



procedure scalprod(x:real; var A,B:matrice);
var
  i,j:integer;
begin
  for i:=1 to dim do
    for j:=1 to dim do
      B[i,j]:=x*A[i,j];
end;



procedure difference(var A,B,C:matrice);
var
  i,j:integer;
begin
  for i:=1 to dim do
    for j:=1 to dim do
      C[i,j]:=A[i,j]-B[i,j];
end;



function normesup(var A:matrice):real;
var
  i,j:integer;
  x:real;
begin
  x:=0.0;
  for i:=1 to dim do
    for j:=1 to dim do
      if abs(A[i,j])>x then x:=abs(A[i,j]);
  normesup:=x;
end;



function norme2(var A:matrice):real;
var
  i,j:integer;
  x:real;
begin
  x:=0.0;
  for i:=1 to dim do
    for j:=1 to dim do
      x:=x+sqr(A[i,j]);
  norme2:=sqrt(x);
end;



procedure ecrire_matrice(var A:matrice; d1,d2:integer);
var
  i,j:integer;
begin
  for i:=1 to dim do
  begin
    for j:=1 to dim-1 do write(A[i,j]:d1:d2);
    writeln(A[i,dim]:d1:d2);
  end;
end;



procedure entrer_matrice(var A:matrice);
var
  i,j:integer;
begin
  writeln('Saisie d''une matrice carrée ',dim,'x',dim,' :');
  for i:=1 to dim do
  begin
    for j:=1 to dim do
    begin
      write('Ligne',i:3,'  colonne',j:3,' : ');
      readln(A[i,j]);
    end;
    writeln;
  end;
end;



function trace(var A:matrice):real;
var
  i,j:integer;
  x:real;
begin
  x:=0.0;
  for i:=1 to dim do x:=x+A[i,j];
  trace:=x;
end;



procedure transpose(var A,B:matrice);
var
  i,j:integer;
  x:real;
begin
  for i:=1 to dim do
    for j:=1 to dim do
      B[i,j]:=A[j,i];
end;


procedure sauver_matrice(var A:matrice; nomfic:string);
var
  f:text;
  i,j:integer;
begin
  assign(f,nomfic);
  {$i-} rewrite(f); {$i+}
  if ioresult<>0 then
    writeln('Erreur d''entrée/sortie avec le disque.')
  else begin
    for i:=1 to dim do
    begin
      for j:=1 to dim do write(f,A[i,j],' ');
      writeln(f);
    end;
    close(f);
  end;
end;



procedure charger_matrice(var A:matrice; nomfic:string);
var
  f:text;
  i,j:integer;
begin
  assign(f,nomfic);
  {$i-} reset(f); {$i+}
  if ioresult<>0 then
    writeln('Erreur d''entrée/sortie avec le disque.')
  else begin
    for i:=1 to dim do
    begin
      for j:=1 to dim do
      begin
        if eoln(f) and (j<dim) then
        begin
          close(f);
          writeln('Le fichier ',nomfic,' contient une matrice trop petite.');
          exit;
        end;
        read(f,A[i,j]);
      end;
      readln(f);
    end;
    close(f);
  end;
end;



{ algorithme du pivot partiel de Gauss-Jordan appliqué à l'inversion  }
{ d'une matrice carrée. Si la matrice n'est pas inversible, det vaut  }
{ zéro, dans le cas contraire le déterminant de A (pas de B=A^(-1) !) }

procedure inversion(A:matrice; var B:matrice; var det:real);
var
  k,lpiv,li,co:integer;
  x,pivot,pivpart:real;

begin
  identite(B);
  det:=1.0;
  k:=1;

  repeat
   x:=0; lpiv:=k;
    for li:=k to dim do        { recherche du pivot }
      if abs(A[li,k])>x then
      begin
        lpiv:=li;                 { mémorise la position du pivot }
        x:=abs(A[li,k]);  { nouveau pivot }
      end;

    if k<>lpiv then
    begin
      det:=-det;
      for co:=1 to dim do swapr(A[k,co],A[lpiv,co]);
      for co:=1 to dim do swapr(B[k,co],B[lpiv,co]);
    end;

    pivot:=A[k,k];
    if abs(pivot)<=epsilon then
    begin
      det:=0.0;
      exit;
    end;
    det:=det*pivot;

    { division de la k-ième ligne par pivot }
    for co:=1 to dim do A[k,co]:=A[k,co]/pivot;
    for co:=1 to dim do B[k,co]:=B[k,co]/pivot;

{ pour toutes les lignes différentes de celle du pivot, enlève pivpart * la ligne du pivot }
    for li:=1 to dim do
      if li<>k then
      begin
        pivpart:=A[li,k];
        for co:=1 to dim do A[li,co]:=A[li,co]-pivpart*A[k,co];
        for co:=1 to dim do B[li,co]:=B[li,co]-pivpart*B[k,co];
      end;

    inc(k);
  until k>dim;

end;



{ méthode de Householder pour la décomposition QR d'une matrice }
{ Q est orthogonale                                             }
{ R est triangulaire à diagonale positive                       }

procedure HouseHolder(var A,Q,R:matrice);
var
  co,i,j,k:word;
  x,y,norm2:real;
  M:matrice;
  B:vecteur;
begin
  identite(Q);
  R:=A; { on va travailler sur R au lieu de A }

  for co:=1 to dim-1 do
  begin
    i:=co+1;
    while (i<=dim) and (abs(R[i,co])<=epsilon) do inc(i);
    if i<=dim then  { le vecteur dim'est pas colinéaire au premier vecteur de base }
    begin
      x:=0;
      for i:=co to dim do
      begin
        B[i]:=R[i,co];
        x:=x+sqr(B[i]);
      end;
      x:=sqrt(x); y:=x;  { y contient la norme 2 du premier vecteur }
      B[co]:=B[co]-x;
      norm2:=-x*B[co]; { norme 2 de B au carré divisée par 2 }

      for i:=co to dim do
        for j:=co+1 to dim do
        begin
          x:=0.0;
          for k:=co to dim do
            x:=x+B[i]*B[k]*R[k,j];
          M[i,j]:=x;
        end;
      for i:=co to dim do
        for j:=co+1 to dim do
          R[i,j]:=R[i,j]-M[i,j]/norm2;
      R[co,co]:=y;
      for i:=co+1 to dim do R[i,co]:=0.0;

      for i:=1 to dim do
        for j:=co to dim do
        begin
          x:=0.0;
          for k:=co to dim do
            x:=x+Q[i,k]* B[k]*B[j];
          M[i,j]:=x;
        end;
      for i:=1 to dim do
        for j:=co to dim do
          Q[i,j]:=Q[i,j]-M[i,j]/norm2;

    end;
  end;

  { rend les éléments diagonaux de R positifs }
  for i:=1 to dim do
    if R[i,i]<0 then
      for j:=1 to dim do
      begin
        R[i,j]:=-R[i,j];
        Q[j,i]:=-Q[j,i];
      end;

end;



begin
  dim:=1;
end.