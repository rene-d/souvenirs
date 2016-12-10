{ d‚finition des types }

{$i math}

const
  epsilon:real=1E-7;

type
  loi_coef=function(li,co:word):real;
  coef__=array[1..5000] of real;
  matrice=object
    l,c:word;
    octets:word; { taille en octets du tableau coef^, pour contr“le d'existence }
    coef:^coef__;
    constructor init(li,co:word); { cr‚e une matrice (li,co) }
    constructor init_id(n:word); { cr‚e la matrice-identit‚ (n,n) }
    constructor init_dup(var source:matrice);
    constructor init_prod(var A,B:matrice);
    constructor init_somme(var A,B:matrice);
    destructor done;
    function existe:boolean;
    function rcoef(li,co:word):real;
    procedure scoef(li,co:word;a:real);
    function estcarre:boolean;
    procedure produit(var A,B:matrice);
    procedure somme(var A,B:matrice);
    procedure difference(var A,B:matrice);
    procedure affiche(x,y:integer);
    procedure loi(f:loi_coef);
    procedure transpose;
    function estsymetrique:boolean;
  end;



constructor matrice.init(li,co:word);
begin
  if li*co=0 then
  begin
    l:=0;
    c:=0;
    octets:=0;
    coef:=nil;
  end
  else begin
    if li*co*sizeof(real)>maxavail then fail;
    l:=li;
    c:=co;
    octets:=l*c*sizeof(real);
    getmem(coef,octets);
    for li:=1 to l do
      for co:=1 to c do
        coef^[(li-1)*c+co]:=0;
  end;
end;


constructor matrice.init_id(n:word);
var i:word;
begin
  init(n,n);
  for i:=1 to l do coef^[(i-1)*c+i]:=1.0;
end;


constructor matrice.init_dup(var source:matrice);
begin
  if (source.coef=nil) or (source.l*source.c=0) then
  begin
    l:=0;
    c:=0;
    octets:=0;
    coef:=nil;
  end
  else begin
    self:=source; { copie les champs l, c, octets }
    getmem(coef,octets);
    move(source.coef^,coef^,octets);
  end;
end;


constructor matrice.init_prod(var A,B:matrice);
begin
  if A.c<>B.l then fail;
  init(A.l,B.c);
  produit(A,B);
end;


constructor matrice.init_somme(var A,B:matrice);
begin
  if (A.l<>B.l) or (A.c<>B.c) then fail;
  init(A.l,A.c);
  somme(A,B);
end;


destructor matrice.done;
begin
  if existe then
  begin
    freemem(coef,octets);
    coef:=nil;
    l:=0;
    c:=0;
    octets:=0;
  end;
end;


function matrice.rcoef(li,co:word):real;
begin
  rcoef:=coef^[(li-1)*c+co];
end;


procedure matrice.scoef(li,co:word;a:real);
begin
  coef^[(li-1)*c+co]:=a;
end;


function matrice.estcarre:boolean;
begin
  estcarre:=existe and (l=c);
end;


function matrice.existe:boolean;
begin
  existe:=(coef<>nil) and (l*c*sizeof(real)=octets) and (octets>0);
end;


procedure matrice.produit(var A,B:matrice);
var
  i,j,k:word;
  x:real;
begin
  if existe=false then exit;
  if (A.c<>B.l) or (l<>A.l) or (c<>B.c) then
  begin
    writeln('mauvaise utilisation de matrice.produit');
    exit;
  end;
  for i:=1 to l do
    for j:=1 to c do
    begin
      x:=0.0;
      for k:=1 to A.c do
        x:=x+A.coef^[(i-1)*A.c+k]*B.coef^[(k-1)*B.c+j];
      coef^[(i-1)*c+j]:=x;
   end;
end;


procedure matrice.somme(var A,B:matrice);  { ce n'est pas un constructeur }
var i,j:word;
begin
  if existe=false then exit;
  if (l<>A.l) or (c<>A.c) or (A.l<>B.l) or (A.c<>B.c) then
  begin
    writeln('mauvaise utilisation de matrice.somme');
    exit;
  end;
  for i:=1 to A.l do
    for j:=1 to A.c do
      coef^[(i-1)*c+j]:=A.coef^[(i-1)*c+j]+B.coef^[(i-1)*c+j];
end;


procedure matrice.difference(var A,B:matrice);  { ce n'est pas un constructeur }
var i,j:word;
begin
  if existe=false then exit;
  if (l<>A.l) or (c<>A.c) or (A.l<>B.l) or (A.c<>B.c) then
  begin
    writeln('mauvaise utilisation de matrice.somme');
    exit;
  end;
  for i:=1 to A.l do
    for j:=1 to A.c do
      coef^[(i-1)*c+j]:=A.coef^[(i-1)*c+j]-B.coef^[(i-1)*c+j];
end;


procedure matrice.affiche(x,y:integer);
var i,j:word;
begin
  if existe then
    for i:=1 to l do
    begin
      for j:=1 to c do write(coef^[(i-1)*c+j]:x:y);
      writeln;
    end;
end;


procedure matrice.loi(f:loi_coef);
var i,j:word;
begin
  if existe=false then exit;
  for i:=1 to l do
    for j:=1 to c do
      coef^[(i-1)*c+j]:=f(i,j);
end;


procedure matrice.transpose;
var i,j:word;
begin
  if existe=false then exit;
  for i:=2 to l do
    for j:=1 to i-1 do
      swapr(coef^[(i-1)*c+j],coef^[(j-1)*c+i]);
end;


function matrice.estsymetrique:boolean;
var
  i,j:word;
begin
  if existe then
  begin
    for i:=2 to l do
      for j:=1 to i-1 do
        if abs(coef^[(i-1)*c+j]-coef^[(j-1)*c+i])>epsilon then
        begin
          estsymetrique:=false;
          exit;
        end;
    estsymetrique:=true;
  end;
end;



{------------------------------------------------------------}

procedure Cholesky(var A,L:matrice; var possible:boolean);
var
  i,j,k,n:word;
  racine:real;
  A2:matrice;  { copie de A pour travaux internes }
begin
  if (A.estcarre=false) or (A.existe=false) or (A.estsymetrique=false) then
  begin
    writeln('Cholesky ne travaille que sur des matrices carr‚es sym‚triques');
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
      L.done; { efface la matrice L de la m‚moire }
    end
    else begin
      { nouvelle colonne de L obtenue … la k-iŠme ‚tape }
      racine:=sqrt(A2.rcoef(k,k));
      for i:=1 to k-1 do L.scoef(i,k,0.0);
      L.scoef(k,k,racine);
      for i:=k+1 to n do L.scoef(i,k,A2.rcoef(i,k)/racine);

      { nouvelle matrice A obtenue … la k-iŠme ‚tape }
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



var
  A,B,C:matrice;
  L,tL:matrice;
  possible:boolean;

begin
  writeln;
  A.init(5,5);
  A.loi(symposi);
  A.affiche(8,2);
  Cholesky(A,L,possible);
  if possible then
  begin
    writeln;
    L.affiche(8,2);
    tL.init_dup(L);
    tL.transpose;
    writeln;

    B.init_prod(L,tL);
    B.affiche(8,2); writeln;
    C.init(5,5);
    C.difference(A,B);
    C.affiche(10,5);

    B.done;
    tL.done;
  end;
end.
