program test_pivot;

{ programme de test pour la routine inversion de matcarre.pas }

uses matcarre;

var
  A,B,C:matrice;
  i,j:word;
  n:word;
  det:real;
begin
  dim:=4;
  for i:=1 to dim do
    for j:=1 to dim do
      A[i,j]:=integer(random(20))-10;
  writeln('matrice originale : ');
  ecrire_matrice(A,8,2);
  writeln;
  inversion(A,B,det);
  writeln('det : ',det:10:4);
  produit(A,B,C);
  for i:=1 to dim do c[i,i]:=c[i,i]-1.0;
  writeln('norme sup de A * A^(-1) - I: ',normesup(C));
  readln;
end.