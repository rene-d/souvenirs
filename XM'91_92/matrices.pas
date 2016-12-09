unit Matrices;

{ René DEVICHI année scolaire 91-92, novembre ou décembre 1991 }
{ bibliothèque de gestion de matrices par la programmation orientée objet }

interface

{ définition des types et des constantes }

const
  ERRFIC=1;
  epsilon:real=1E-7;
  sysversion:word=$0000;

type
  loi_coef=function(li,co:word):real;
  coef__=array[1..5000] of real;
  matrice=object
    l,c:word;
    octets:word; { taille en octets du tableau coef^, pour contrôle d'existence }
    version:word;
    coef:^coef__;
    constructor init(li,co:word); { crée une matrice (li,co) }
    constructor init_id(n:word); { crée la matrice-identité (n,n) }
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
    function normesup:real;
    function norme2:real;
    function norme1:real;
    procedure sauve(nom:string);
    procedure charge(nom:string);
  end;

  procedure swapr(var x,y:real);
  function maxr(x,y:real):real;

  var errno:integer;

implementation


procedure swapr(var x,y:real);
var z:real;
begin
  z:=y;
  y:=x;
  x:=z;
end;


function maxr(x,y:real):real;
begin
  if x>y then maxr:=x else maxr:=y;
end;



constructor matrice.init(li,co:word);
begin
  if existe then done;
  if li*co=0 then
  begin
    l:=0;
    c:=0;
    octets:=0;
    version:=0;
    coef:=nil;
  end
  else begin
    if li*co*sizeof(real)>maxavail then fail;
    l:=li;
    c:=co;
    version:=sysversion;
    octets:=l*c*sizeof(real);
    getmem(coef,octets);
    for li:=1 to l do
      for co:=1 to c do
        coef^[(li-1)*c+co]:=0.0;
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
  if existe then done;
  if source.existe=false then { si la source n'existe pas, on met la matrice à zéro }
  begin
    l:=0;
    c:=0;
    octets:=0;
    coef:=nil;
    version:=0;
  end
  else begin
    self:=source; { copie les instances l, c, octets, version }
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
    version:=0;
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
  existe:=  (coef<>nil)
        and (l*c*sizeof(real)=octets)
        and (octets>0)
        and (version=sysversion);
end;


procedure matrice.produit(var A,B:matrice);
var
  i,j,k:word;
  x:real;
begin
  if (A.c<>B.l) or (l<>A.l) or (c<>B.c) then
  begin
    writeln('Mauvaise utilisation de Matrice.Produit');
    exit;
  end;
  if existe=false then
  begin
    init(A.l,B.c);
    writeln('Initialisation forcée.');
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
  if (l<>A.l) or (c<>A.c) or (A.l<>B.l) or (A.c<>B.c) then
  begin
    writeln('Mauvaise utilisation de Matrice.Somme.');
    exit;
  end;
  if existe=false then
  begin
    init(A.l,A.c);
    writeln('Initialisation forcée.');
  end;
  for i:=1 to A.l do
    for j:=1 to A.c do
      coef^[(i-1)*c+j]:=A.coef^[(i-1)*c+j]+B.coef^[(i-1)*c+j];
end;



procedure matrice.difference(var A,B:matrice);  { ce n'est pas un constructeur }
var i,j:word;
begin
  if (l<>A.l) or (c<>A.c) or (A.l<>B.l) or (A.c<>B.c) then
  begin
    writeln('Mauvaise utilisation de Matrice.Difference.');
    exit;
  end;
  if existe=false then
  begin
    init(A.l,A.c);
    writeln('Initialisation forcée.');
  end;
  for i:=1 to A.l do
    for j:=1 to A.c do
      coef^[(i-1)*c+j]:=A.coef^[(i-1)*c+j]-B.coef^[(i-1)*c+j];
end;



procedure matrice.affiche(x,y:integer);
var i,j:word;
begin
  if existe then
  begin
    for i:=1 to l do
    begin
      for j:=1 to c do write(coef^[(i-1)*c+j]:x:y);
      writeln;
    end;
  end
  else writeln('Matrice non initialisée.');
end;



procedure matrice.loi(f:loi_coef);
var i,j:word;
begin
  if existe=false then writeln('Matrice non initialisée.')
  else
    for i:=1 to l do
      for j:=1 to c do
        coef^[(i-1)*c+j]:=f(i,j);
end;



procedure matrice.transpose;
var i,j:word;
begin
  if existe=false then begin writeln('Matrice non initialisée.'); exit; end;
  if l=c then
    for i:=2 to l do
      for j:=1 to i-1 do
        swapr(coef^[(i-1)*c+j],coef^[(j-1)*c+i])
  else begin
    i:=l;
    l:=c;
    c:=i;
    writeln('pas encore écrit... ');
  end;
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
  end
  else writeln('Matrice non initialisée.');
end;



function matrice.normesup:real;
var
  x:real;
  i:word;
begin
  x:=0;
  for i:=1 to l*c do x:=maxr(x,abs(coef^[i]));
  normesup:=x;
end;



function matrice.norme2:real;
var
  x:real;
  i:word;
begin
  x:=0;
  for i:=1 to l*c do x:=x+sqr(coef^[i]);
  norme2:=sqrt(x);
end;



function matrice.norme1:real;
var
  x:real;
  i:word;
begin
  x:=0;
  for i:=1 to l*c do x:=x+abs(coef^[i]);
  norme1:=x;
end;



procedure matrice.sauve(nom:string);
var
  i,j:word;
  f:text;
begin
  assign(f,nom);
  {$i-} rewrite(f); {$i+}
  if ioresult<>0 then
  begin
    writeln('Erreur d''accès au fichier.');
    exit;
  end;

  writeln(f,'[',l,',',c,']');
  for i:=1 to l do
  begin
    for j:=1 to c-1 do write(f,rcoef(i,j),' ');
    writeln(f,rcoef(i,c));
  end;
  close(f);
end;


procedure matrice.charge(nom:string);
var
  i,j:word;
  e:integer;
  x:real;
  f:text;
  s:string;
begin
  assign(f,nom);
  {$i-} reset(f); {$i+}
  if ioresult<>0 then
  begin
    writeln('Erreur d''accès au fichier.');
    done;
    errno:=ERRFIC;
    exit;
  end;

  readln(f,s);
  while copy(s,1,1)=' ' do delete(s,1,1);
  if (copy(s,1,1)='(') or (copy(s,1,1)='[') then
  begin
    done;
    delete(s,1,1);
    j:=pos(',',s)-1; if j=0 then j:=pos(' ',s)-1;
    val(copy(s,1,j),i,e);
    if e<>0 then exit;
    delete(s,1,j+1);
    while (copy(s,length(s),1)=' ') or (copy(s,length(s),1)=')')
      or (copy(s,length(s),1)=']') do dec(s[0]);
    val(s,j,e);
    if e<>0 then exit;
    init(i,j);
  end
  else reset(f); { relit le fichier du début }

  for i:=1 to l do
  begin
    for j:=1 to c do
    begin
      {$i-} read(f,x); {$i+}
      if ioresult<>0 then
      begin
        writeln('Erreur d''accès au fichier.');
        done;
        exit;
      end;
      scoef(i,j,x);
    end;
    if not seekeoln(f) then {$i-} readln(f); {$i+}
    if ioresult<>0 then
    begin
      writeln('Erreur d''accès au fichier.');
      done;
      exit;
    end;
  end;
  close(f);
end;





begin
  asm
    mov    ah,00
    int    $1A
    mov    sysversion,dx
  end;
  if sysversion=0 then inc(sysversion);
end.