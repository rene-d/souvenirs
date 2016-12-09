program _HouseHolder_;

{ méthode Housholder pour la décomposition  Q∙R d'une matrice }

uses Matrices;


procedure HouseHolder(var A,Q,R:matrice);
var
  n,co,i,j,k:word;
  x,y,norm2:real;
  B,M:matrice;
begin
  if A.estcarre=false then
  begin
    writeln('Mauvaise utilisation de Householder.');
    exit;
  end;
  n:=A.l;
  Q.init_id(n);  { a priori, Q est l'identité }
  R.init_dup(A); { on va travailler sur R au lieu de A }

  B.init(n,1); { vecteur de travail, les procédures standard ne sont pas utilisées }
  M.init(n,n); { matrice de travail, les procédures standard ne sont pas utilisées }
  for co:=1 to n-1 do
  begin
    i:=co+1;
    while (i<=n) and (abs(R.rcoef(i,co))<=epsilon) do inc(i);
    if i<=n then  { le vecteur n'est pas colinéaire au premier vecteur de base }
    begin
      x:=0;
      for i:=co to n do
      begin
        B.scoef(i,1,R.rcoef(i,co));
        x:=x+sqr(B.rcoef(i,1));
      end;
      x:=sqrt(x); y:=x;  { y contient la norme 2 du premier vecteur }
      B.scoef(co,1,B.rcoef(co,1)-x);
      norm2:=-x*B.rcoef(co,1); { norme 2 de B au carré divisée par 2 }

      for i:=co to n do
        for j:=co+1 to n do
        begin
          x:=0.0;
          for k:=co to n do
            x:=x+B.rcoef(i,1)*B.rcoef(k,1)*R.rcoef(k,j);
          M.scoef(i,j,x);
        end;
      for i:=co to n do
        for j:=co+1 to n do
          R.scoef(i,j,R.rcoef(i,j)-M.rcoef(i,j)/norm2);
      R.scoef(co,co,y);
      for i:=co+1 to n do R.scoef(i,co,0);

      for i:=1 to n do
        for j:=co to n do
        begin
          x:=0.0;
          for k:=co to n do
            x:=x+Q.rcoef(i,k)* B.rcoef(k,1)*B.rcoef(j,1);
          M.scoef(i,j,x);
        end;
      for i:=1 to n do
        for j:=co to n do
          Q.scoef(i,j,Q.rcoef(i,j)-M.rcoef(i,j)/norm2);

    end;
  end;
  for i:=1 to n do
    if R.rcoef(i,i)<0 then
      for j:=1 to n do
      begin
        R.scoef(i,j,-R.rcoef(i,j));
        Q.scoef(j,i,-Q.rcoef(j,i));
      end;

  B.done;  { récupère l'espace mémoire dans le tas }
  M.done;
end;



procedure ortho_test(var Q:matrice);
var
  i,j,k:word;
  x,y:real;
begin
  if not Q.estcarre then exit;
  y:=0;
  for k:=1 to Q.c do
  begin
    x:=0.0;
    for j:=1 to Q.l do
      x:=x+sqr(Q.rcoef(j,k));
{$ifdef print}
    writeln(sqrt(x));
{$endif}
    if abs(x-1)>y then y:=abs(x-1);
  end;
  writeln('Plus grande erreur de normalité : ',y);

  y:=0;
  for k:=1 to Q.l do
  begin
    for i:=1 to Q.l do
    begin
      if i<>k then
      begin
        x:=0.0;
        for j:=1 to Q.l do
          x:=x+Q.rcoef(j,i)*Q.rcoef(j,k);
{$ifdef print}
        writeln(x);
{$endif}
        if abs(x)>y then y:=abs(x);
      end;
    end;
{$ifdef print}
    writeln;
    readln;
{$endif}
  end;
  writeln('Plus grande erreur d''orthogonalité : ',y);
end;


procedure test_householder(var A,Q,R:matrice);
var
  A1:matrice;
begin
  A1.init_prod(Q,R);
  A1.difference(A,A1);
  writeln('Différence entre A et QR : ',A1.normesup);
  A1.done;
end;


var
  A,Q,R:matrice;
begin
  A.charge('matr.000');
  if errno<>0 then halt;
  householder(A,Q,R);
  ortho_test(Q);
  test_householder(A,Q,R);
  Q.done;
  R.done;
  A.done;
end.