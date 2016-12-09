program _Cholesky_;

{ René DEVICHI année scolaire 91-92, novembre ou décembre 1991 }
{ décomposition de Cholesky }

uses Matrices;

function pow(x:real;n:integer):real;
var
  i:integer;
  a:real;
begin
  a:=1.0;
  for i:=1 to abs(n) do a:=a*x;
  if n<0 then a:=1/a;
  pow:=a;
end;


procedure Cholesky(var A,L:matrice; var possible:boolean);
var
  i,j,k,n:word;
  racine:real;
  A2:matrice;  { copie de A pour travaux internes }
begin
  if (A.estcarre=false) or (A.existe=false) or (A.estsymetrique=false) then
  begin
    writeln('Cholesky ne travaille que sur des matrices carrées symétriques');
    possible:=false;
    exit;
  end;
  A2.init_dup(A);
  n:=A2.l;
{  if L.existe then L.done; }
  L.init(n,n);
  { recherche de L telle que L*t(L)=A }
  k:=0;
  possible:=true;
  while possible and (k<n) do
  begin
    inc(k);
    if A2.rcoef(k,k)<epsilon then
    begin
      possible:=false;
      L.done; { efface la matrice L de la mémoire }
    end
    else begin
      { nouvelle colonne de L obtenue à la k-ième étape }
      racine:=sqrt(A2.rcoef(k,k));
      for i:=1 to k-1 do L.scoef(i,k,0.0);
      L.scoef(k,k,racine);
      for i:=k+1 to n do L.scoef(i,k,A2.rcoef(i,k)/racine);

      { nouvelle matrice A obtenue à la k-ième étape }
      { 1. manipulation sur les lignes }
      for j:=k to n do A2.scoef(k,j,A2.rcoef(k,j)/racine);
      for i:=k+1 to n do
        for j:=k to n do
          A2.scoef(i,j,A2.rcoef(i,j)-L.rcoef(i,k)*A2.rcoef(k,j));

      { 2. manipulation sur les colonnes }
      for i:=k to n do A2.scoef(i,k,A2.rcoef(i,k)/racine);
      for j:=k+1 to n do
        for i:=k to n do
          A2.scoef(i,j,A2.rcoef(i,j)-L.rcoef(j,k)*A2.rcoef(i,k));
    end;
  end;
  A2.done;
end;

{$f+} function lyon89(li,co:word):real;  {$f-}
begin
  lyon89:=(pow(2,li)*pow(3,co));
end;

{$f+} function symposi(x,y:word):real; {$f-}
begin
  if x=y then symposi:=pow((random+1),x)
  else symposi:=pow(0.8,x+y);
end;


procedure test_cholesky;
var
  A,B,C:matrice;
  L,tL:matrice;
  possible:boolean;

begin
  writeln;
  A.init(5,5);
  A.loi(symposi);
  writeln('Matrice de départ :');
  A.affiche(8,2);
  Cholesky(A,L,possible);
  if possible then
  begin
    writeln('La décomposition de Cholesky est possible. Voici la matrice L :');
    L.affiche(8,2);
    tL.init_dup(L);
    tL.transpose;
    writeln;

    B.init_prod(L,tL);
    writeln;
    C.init(5,5);
    C.difference(A,B);
    writeln('norme sup de A-L.tL : ',C.normesup);
    C.done;
    B.done;
    tL.done;
  end;
  A.done;
  L.done;
end;


begin
  test_cholesky;
end.