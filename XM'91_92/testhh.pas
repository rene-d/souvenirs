program test_householder;

{ programme de test pour la routine householder de matcarre.pas }

uses matcarre;

procedure ortho_test(var Q:matrice);
var
  i,j,k:word;
  x,y:real;
begin
  y:=0;
  for k:=1 to dim do
  begin
    x:=0.0;
    for j:=1 to dim do
      x:=x+sqr(Q[j,k]);
    if abs(x-1)>y then y:=abs(x-1);
  end;
  writeln('Plus grande erreur de normalité : ',y);

  y:=0;
  for k:=1 to dim do
  begin
    for i:=1 to dim do
    begin
      if i<>k then
      begin
        x:=0.0;
        for j:=1 to dim do
          x:=x+Q[j,i]*Q[j,k];
        if abs(x)>y then y:=abs(x);
      end;
    end;
  end;
  writeln('Plus grande erreur d''orthogonalité : ',y);
end;


procedure test_householder(var A,Q,R:matrice);
var
  A1:matrice;
begin
  produit(Q,R,A1);
  difference(A,A1,A1);
  writeln('Différence entre A et QR : ',normesup(A1));
end;


var
  A,Q,R:matrice;
  i,j:integer;
begin
  defdim(4);
  writeln('Test de la méthode de Householder.');
  writeln('Matrices de dimension ',dim,'x',dim);
{  for i:=1 to dim do
    for j:=1 to dim do
      A[i,j]:=integer(random(20))-10; }
      entrer_matrice(a);
  householder(A,Q,R);
  ortho_test(Q);
  test_householder(A,Q,R);
end.