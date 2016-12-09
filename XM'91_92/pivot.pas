program _pivot;

{ programme utilisant le pivot de gauss-jordan pour inverser et }
{ calculer le détermiant d'une matrice }
{ utilise la bibliothèque matrices.pas }

uses matrices;


{ pivot de Gauss Jordan partiel: on permute les lignes }

procedure inversion(M:matrice; var B:matrice; var det:real);
var
  A:matrice;
  k,n,lm,li,co:word;
  x,pivot,pivpart:real;

begin
  B.done;  { efface éventuellement B de la mémoire }
  if M.estcarre=false then
  begin
    writeln('Mauvaise utilisation de Pivot_GaussJordan ');
    exit;
  end;
  A.init_dup(M);
  n:=A.l;
  B.init_id(n);
  det:=1.0;
  k:=1;

  repeat
   x:=0; lm:=k;
    for li:=k to n do        { recherche du pivot }
      if abs(A.rcoef(li,k))>x then
      begin
        lm:=li;                 { mémorise la position du pivot }
        x:=abs(A.rcoef(li,k));  { nouveau pivot }
      end;

    if k<>lm then
    begin
      det:=-det;
      with A do
        for li:=1 to n do
          swapr(coef^[(k-1)*c+li],coef^[(lm-1)*c+li]);
      with B do
        for li:=1 to n do
          swapr(coef^[(k-1)*c+li],coef^[(lm-1)*c+li]);
    end;

    pivot:=A.rcoef(k,k);
    if abs(pivot)<=epsilon then
    begin
      det:=0.0;
      A.done;
      B.done;
      exit;
    end;
    det:=det*pivot;

    { division de la k-ième ligne par pivot }
    for co:=1 to n do A.scoef(k,co,A.rcoef(k,co)/pivot);
    for co:=1 to n do B.scoef(k,co,B.rcoef(k,co)/pivot);

{ pour toutes les lignes différentes de celle du pivot, enlève pivpart * la ligne du pivot }
    for li:=1 to n do
      if li<>k then
      begin
        pivpart:=A.rcoef(li,k);
        for co:=1 to n do A.scoef(li,co,A.rcoef(li,co)-pivpart*A.rcoef(k,co));
        for co:=1 to n do B.scoef(li,co,B.rcoef(li,co)-pivpart*B.rcoef(k,co));
      end;

    inc(k);
  until k>n;

  A.done;  { efface la copie de M de la mémoire }
end;


var
  A,B,C:matrice;
  i,j:word;
  n:word;
  det:real;
begin
  n:=9;
  A.init(n,n);
  for i:=1 to n do
    for j:=1 to n do
      A.scoef(i,j,integer(random(20))-10);
  writeln('matrice originale : ');
  A.affiche(8,2);
  writeln;
  inversion(A,B,det);
  writeln('det : ',det:10:4);
  C.init_prod(B,A);
  for i:=1 to n do C.scoef(i,i,C.rcoef(i,i)-1);
  writeln('norme sup de A * A^(-1) - I: ',C.normesup);
  C.done;
  B.done;
  A.done;
  readln;
end.