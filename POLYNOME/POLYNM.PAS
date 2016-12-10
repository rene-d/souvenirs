UNIT POLYNM;

{ calcul sur les polynômes - version 2.07 M           }
{ utilisation de Modulog                              }
{ TURBO PASCAL 4.0 et 5.0                             }
{ René DEVICHI , 21 - 22 décembre 1989 , Le LUC       }
{                ... année 1990 pour le développement }

(* Notice: rappel du type POLYNOME
Ce type est un enregistrement qui contient DEG (integer) qui
est le degré du polynôme (-1=polynôme nul); COEF
(array[0..MaxPoly] of real), COEF[0] est le coefficient de plus
haut degré. ELIMINE(p) met à jour DEG et COEF.
Autres rappels: Θ (chr(233)) est le polynôme nul
*)


INTERFACE

uses
  CRT, Modub1, Mode;


{$IFOPT N+}
type
  real=extended;
{$ENDIF}


const
  MaxPoly     = 30;          { degré maximal des polynômes                   }
  zero : real = 5E-8;        { valeur "pratique" du zéro (par exemple: 1E-8) }
  code_nul    = #233;        { chaîne de caractères pour le polynôme nul     }


type
  coefficients=array[0..MaxPoly] of real;
  polynome=record
                 coef:coefficients;
                 deg:integer;
           end;


var
  pn_Erreur      : integer;        { variable d'erreur spécifique de l'unité }
  pn_coefsnuls   : boolean;
  pn_espace      : boolean;
  pn_star        : boolean;


{-------- gestion du polynôme }

procedure Nul(var p:polynome);
procedure Elimine(var p:polynome);
function  Valuation(p:polynome):integer;
function  Egalite(p,q:polynome):boolean;


{-------- calcul sur les polynômes }

{ schéma de Hörner pour le calcul de l'image d'un réel }
function  Valeur(p:polynome;x:real):real;

{ opérations "unaires" }
procedure Unitaire(var p:polynome);
procedure Oppose(var p:polynome);

{ lois de composition interne }
procedure Addition(p,q:polynome;var r:polynome);
procedure Soustraction(p,q:polynome;var r:polynome);
procedure Produit(p,q:polynome;var r:polynome);
procedure Compose(p,q:polynome;var r:polynome);

{ lois externes de R[X] }
procedure ProdR(var p:polynome;a:real);
procedure AddR(var p:polynome;a:real);

{ lois de composition interne secondaires }
procedure Puissance(var p:polynome;n:integer);
procedure Translate(var p:polynome;a:real);
procedure ProdX(var p:polynome;n:integer);

{ dérivation et intégration }
procedure Derive(var p:polynome);
procedure Integre(var p:polynome);
function  Integrale(p:polynome;a,b:real):real;

{ arithmétique de R[X] }
procedure Divise(p,q:polynome;var s,r:polynome);
procedure DivCrois(p,q:polynome;n:word;var s,r:polynome);
procedure PGCD(p,q:polynome;var r:polynome);
procedure PPCM(p,q:polynome;var r:polynome);

{ polynômes simples }
procedure Constante(var p:polynome;x:real);
procedure Deg1(var p:polynome;a,b:real);
procedure Deg2(var p:polynome;a,b,c:real);

{ polynômes particuliers }
procedure Binome(var p:polynome;n:integer;a:real);
procedure Tcheb(var p:polynome;n,e:integer);
procedure Hasard(var p:polynome;d:integer;min,max:real;entier:boolean);

{ brève extension à des valeurs complexes de l'indéterminée uniquement }
procedure ValeurC(p:polynome;rx,ix:real;var r,i:real);


{-------- gestion polynôme en tant que chaîne de caractères }

procedure Chaine(s:string;var p:polynome);
procedure Saisie(var p:polynome);

procedure Mode_Affichage(cn,es,st:byte);
function  StrP(p:polynome;ind:string):string;
procedure Affiche(p:polynome;ind:string);
procedure AfficheLn(p:polynome;ind:string);

procedure Sauve(var t:text;p:polynome);
procedure Lit(var t:text;var p:polynome);
procedure Sauve1(nom:string;p:polynome);
procedure Lit1(nom:string;var p:polynome);


{-------- fonctions mathématiques particulières }

procedure SqrtC(var r,i:real);
function  Cnp(n,p : word) : longint;
function  Fact(n : word) : longint;


{-------- gestion des erreurs }

function  MessErreur:string;


IMPLEMENTATION


{ nouvelles procédures DebutModule et SignalerErreur spéciales
  à cette unité (rajoute au nom de la procédure 'Polynm.';
  utilise a priori MessErreur pour le message;                 }

procedure DebutModule(E:integer; S:string);
begin
  pn_Erreur:=0;
  S:='Polynm.'+S;
  Modub1.DebutModule(E,S)
end;

procedure SignalerErreur(E:integer; S:string);
begin
  pn_Erreur:=E;
  if S = '' then S:=MessErreur;
  Modub1.SignalerErreur(E,S)
end;


{ donne à un polynôme la valeur "polynôme nul" }
procedure Nul(var p:polynome);
begin
  p.coef[0]:=0.0;
  p.deg:=-1
end;


{ élimine les éventuels zèros d'un polynôme "à gauche" }
{ et met à jour le degré du polynôme                   }
procedure Elimine(var p:polynome);
var
  i,j:integer;
begin
  with p do
    if deg < 0
    then deg:=-1
    else begin
      i:=0;
      while (abs(coef[i])<=zero) and (i<deg) do inc(i);
      if (i=deg) and (abs(coef[i])<=zero)
      then nul(p)
      else begin
        for j:=i to deg
        do coef[j-i]:=coef[j];
        dec(deg,i)
      end;
    end;
end;


{ renverse les coefficients du polynôme }
procedure Renverse(var p:polynome);
var
  t:real;
  i:word;
begin
  with p do
    for i:=0 to deg div 2
    do begin
      t:=coef[deg-i];
      coef[deg-i]:=coef[i];
      coef[i]:=t
    end;
end;


{ convertit une chaîne de caractère en un polynôme (sans indéterminée) }
{ force pn_ERREUR à 10 si erreur détectée... sinon pn_ERREUR=0         }
procedure Chaine(s:string;var p:polynome);
  procedure enleve_espaces;
  begin
    while copy(s,1,1)=' ' do delete(s,1,1);
  end;
var
  i,k,e:integer;
  num:string[30];
begin
  DebutModule(330,'Chaine');
  with p
  do begin
    nul(p);
    s:=s+' ';
    enleve_espaces;
    if (length(s)>0) and (copy(s,1,1)<>code_nul)
    then begin
      i:=1; k:=0;
      e:=0;     { pour que ça boucle au moins une fois }
      while (i<=length(s)) and (e=0)
      do begin
        inc(i);
        if (s[i]=' ') or (s[i]=',')
        then begin
          num:=copy(s,1,i-1);
          if num[1]='.' then num:='0'+num;
(*          if num[length(num)]='.' then num:=num+'0';               !*)
          val(num,coef[k],e); inc(k);
	  delete(s,1,i); enleve_espaces;
          i:=1;
	  if e<>0 then SignalerErreur(330,'');
        end;
      end;
      deg:=k-1;
      elimine(p)
    end
  end;
  FinModule
end;


{ effectue la saisie (simple) d'un polynôme (sans indéterminée) }
procedure Saisie(var p:polynome);
var
  s:string;
  Option:boolean;
begin
  Option:=OptionArretSiErreur;
  ArreterSiErreur(false);
  pn_Erreur:=0;
  repeat
    {$i-} readln(s); {$i+}
    chaine(s,p);
    if (pn_Erreur=330) or (ioresult<>0) then
      writeln(' ** Erreur. Recommencez ** ');
  until pn_Erreur<>330;
  ArreterSiErreur(Option);
end;


{ mode d'affiche des polynômes pour StrP }
procedure Mode_Affichage(cn,es,st:byte);
begin
  pn_coefsnuls := cn=1;  { affichage des coefficients nuls                  }
  pn_espace    := es=1;  { espace entre les différents monômes              }
  pn_star      := st=1;  { étoile entre le coefficient et la puissance de X }
end;


{ convertit en une chaîne un polynôme avec une indéterminée choisie }
function StrP(p:polynome;ind:string):string;
var
  i,j:integer;
  el,s:string;
begin
  elimine(p);
  with p do
    if deg=-1
    then el:=code_nul
    else begin
      el:='';
      if ind=''
      then for i:=0 to deg
        do begin
          el:=el+Mode.Form(coef[i])+' ';
          if i<>deg then el:=el+' ';
        end
      else for i:=0 to deg do
        if (abs(coef[i])>zero) or pn_coefsnuls
        then begin
          if pn_espace and (i<>0) and (i<>deg) then el:=el+' ';
          if coef[i] < 0
          then el:=el+'-'
          else if i<>0 then el:=el+'+';
          if pn_espace and (i<>0) then el:=el+' ';
          if (abs(coef[i])<>1) or (i=deg)
          then begin
            el:=el+Mode.Form(abs(coef[i]));
            if pn_star and (i<deg) then el:=el+'*';
          end;
          if i<>deg then el:=el+ind;
          if i<deg-1 then begin str(deg-i:0,s); el:=el+'^'+s; end;
        end;
    end;
  strp:=el
end;


{ affiche un polynôme avec une indéterminée choisie }
procedure Affiche(P:Polynome;Ind:string);
begin
  Write(StrP(P,Ind))
end;

{ affiche un polynôme avec une indéterminée choisie et insère un CR }
procedure AfficheLn(P:Polynome;Ind:string);
begin
  Writeln(StrP(P,Ind))
end;


{ calcul (x+a)^n avec les coefficients de Newton }
procedure Binome(var p:polynome;n:integer;a:real);
var
  i:word;
  b:real;
begin
  DebutModule(317,'Binôme');
  if n>MaxPoly then SignalerErreur(304,'');
  if n<0 then nul(p)
  else with p
    do begin
      b:=1.0;
      deg:=n;
      for i:=0 to n
      do begin
        coef[i]:=MultReal(Cnp(n,i),b);
        b:=MultReal(b,a)
      end
    end;
  FinModule
end;


{ multiplie deux polynômes selon le schéma suivant R=P.Q }
procedure Produit(p,q:polynome;var r:polynome);
var
  i,j:integer;
begin
  DebutModule(304,'Produit');
  elimine(p); elimine(q); nul(r);
  if p.deg+q.deg>maxpoly then SignalerErreur(304,'')
  else
    if (p.deg<>-1) and (q.deg<>-1) then
      with r do
      begin
        deg:=p.deg+q.deg;
        for i:=0 to deg do coef[i]:=0.0;
        for i:=0 to p.deg do
          for j:=0 to q.deg do
            coef[i+j]:=AddReal(MultReal(p.coef[i],q.coef[j]),coef[i+j]);
      end;
  FinModule
end;


{ division euclidienne de deux polynômes selon le schéma suivant :
  P=S.Q+R  et  0 ≤ deg R < deg Q                                   }
procedure Divise(p,q:polynome;var s,r:polynome);
var
  i,j,k:integer;
  c:real;
begin
  DebutModule(313,'Divise');
  nul(s); nul(r);
  elimine(p); elimine(q);
  if q.deg=-1 then SignalerErreur(313,'')
  else
    if p.deg<>-1  { si p est nul alors s=r=0 }
    then
      if q.deg=0 then
      begin
	s:=p;
	prodr(s,1/q.coef[0])   { rapport dans ce cas toujours défini }
      end
      else begin
        if p.deg >= q.deg then
        begin
          j:=0;
          repeat
            c:=p.coef[j]/q.coef[0];
            inc(s.deg); s.coef[s.deg]:=c;
            for i:=j to q.deg+j do
              p.coef[i]:=SubReal(p.coef[i],MultReal(c,q.coef[i-j]));
            inc(j)
          until j>p.deg-q.deg;
          elimine(p)
        end;
        r:=p;
      end;
  FinModule
end;


{ additionne deux polynômes selon le schéma suivant R=P+Q }
procedure Addition(p,q:polynome;var r:polynome);
var
  i:integer;
begin
  DebutModule(302,'Addition');
  if p.deg < q.deg        { si deg P < deg Q on inverse P et Q }
  then begin              { R contient P }
    r:=q; q:=p; p:=r
  end
  else r:=p;              { on charge R par P }
  for i:=p.deg-q.deg to p.deg do
    r.coef[i]:=AddReal(p.coef[i],q.coef[i-p.deg+q.deg]);
  elimine(r);
  FinModule
end;

{ soustraie de polynômes : R = P - Q }
procedure Soustraction(p,q:polynome;var r:polynome);
begin
  DebutModule(303,'Soustraction');
  Oppose(q);
  Addition(p,q,r);
  FinModule
end;


{ teste si deux polynômes sont identiques à "Zero" près }
function Egalite(p,q:polynome):boolean;
var
  i:integer;
begin
  elimine(p); elimine(q);
  if p.deg=q.deg
  then begin
    egalite:=true;
    for i:=0 to p.deg do
      if abs(p.coef[i]-q.coef[i])>zero
      then egalite:=false;
  end
  else egalite:=false
end;


{ transforme le polynôme P en -P }
procedure Oppose(var p:polynome);
var
  i:integer;
begin
  elimine(p);
  with p do for i:=0 to deg do coef[i]:=-coef[i]
end;


{ transforme le polynôme P en un polynôme associé unitaire }
procedure Unitaire(var p:polynome);
var
  i:integer;
begin
  elimine(p);
  with p do
    if deg<>-1 then
    begin
      for i:=1 to deg do coef[i]:=coef[i]/coef[0];
      coef[0]:=1.0;
    end;
end;


{ calcul le pgcd de deux polynomes : R=pgcd(P,Q) }
procedure PGCD(P,Q:Polynome;var R:Polynome);
var
  s:polynome;
begin
  DebutModule(315,'PGCD');
  while q.deg>=0
  do begin
    divise(p,q,s,r); p:=q; q:=r;
  end;
  r:=p;
  unitaire(r);
  FinModule
end;


{ calcul le ppcm de deux polynomes : R=pgcd(P,Q) }
procedure PPCM(p,q:polynome;var r:polynome);
var
  s:polynome;
begin
  DebutModule(316,'PPCM');
  produit(p,q,s);
  pgcd(p,q,r);
  divise(s,r,r,s);
  unitaire(r);
  FinModule
end;


{ affecte la valeur réelle X au polynome P }
procedure Constante(var P:Polynome;X:real);
begin
  if abs(X)<=zero then nul(P)
  else begin
    P.deg:=0;
    P.coef[0]:=X;
  end;
end;


{ dérive le polynôme P }
procedure Derive(var p:polynome);
var
  i:integer;
begin
  with p do begin
    if deg <= 0 then nul(p)
    else begin
      for i:=0 to deg do coef[i]:=coef[i]*(deg-i);
      dec(deg);
    end;
  end;
end;


{ intègre le polynôme P }
procedure Integre(var p:polynome);
var
  i:integer;
begin
  DebutModule(311,'Intègre');
  elimine(p);
  if p.deg>=maxpoly then SignalerErreur(304,'')
  else with p do begin
    inc(deg);
    for i:=0 to deg-1 do coef[i]:=coef[i]/(deg-i);
    coef[deg]:=0.0;
  end;
  FinModule
end;


{ calcul la valeur du polynôme P au point X par le schéma d'Hörner }
function Valeur(p:polynome;x:real):real;
var
  i:integer;
  r:real;
begin
  DebutModule(301,'Valeur');
  r:=0.0;
  with p do
    if deg<=0 then r:=coef[0]
    else for i:=0 to deg do r:=AddReal(MultReal(r,x),coef[i]);
  Valeur:=r;
  FinModule
end;


{ élève le polynôme P à la puissance b }
procedure Puissance(var p:polynome;n:integer);
var
  p1,p2,p3:polynome;
begin
  DebutModule(308,'Puissance');
  if p.deg*n>MaxPoly then SignalerErreur(304,'')
  else
    if n=0 then constante(p,1)
    else
      if p.deg=0
      then
        constante(p,PuissReal(p.coef[0],n))
      else begin
        if (p.deg=-1) or (n<0)
        then nul(p)
        else begin
          constante(p1,1);
          while n>0
          do begin
            if odd(n) then produit(p,p1,p1);
            n:=n div 2;
            if n>0 then produit(p,p,p);
          end;
          p:=p1;
        end;
      end;
  FinModule
end;


{ calcule l'intégrale du polynôme P sur le segment [A,B] }
function Integrale(p:polynome;a,b:real):real;
begin
  DebutModule(312,'Intégrale');
  integre(p);
  integrale:=valeur(p,b)-valeur(p,a);
  FinModule
end;


{ multiplie le polynôme P par le réel A }
procedure ProdR(var p:polynome;a:real);
var
  i:integer;
begin
  DebutModule(306,'ProdR');
  if abs(a)<=zero
  then nul(p)
  else with p do for i:=0 to deg do coef[i]:=MultReal(a,coef[i]);
  FinModule
end;


{ additionne le polynôme P et le réel A }
procedure AddR(var p:polynome;a:real);
begin
  DebutModule(307,'AddR');
  with p
  do if deg=-1
    then constante(p,a)
    else begin
      coef[deg]:=AddReal(a,coef[deg]);
      elimine(p);
    end;
  FinModule
end;


{ calcule le polynôme de Tchebichev d'espèce E (1 ou 2) et de rang N }
procedure Tcheb(var p:polynome;n,e:integer);
var
  p0,p1,p2x:polynome;
begin
  DebutModule(318,'Tcheb');
  if (e<>1) and (e<>2)
  then nul(p)
  else begin
     constante(p0,1);
     deg1(p1,e,0);
     chaine('2 0',p2x);   { p2x contient le polynôme P(X)=2X }
     if n<=0
     then p:=p0
     else
       if n=1
       then p:=p1
       else begin
         repeat
           produit(p2x,p1,p);
           oppose(p0);
           addition(p0,p,p);
           p0:=p1;
           p1:=p;
           dec(n);
         until n<2;
       end;
  end;
  FinModule
end;


{ division selon les puissances croissantes à l'ordre n }
procedure DivCrois(p,q:polynome;n:word;var s,r:polynome);
var
  piv:real;
  i,j:word;
begin
  DebutModule(314,'DivCrois');
  elimine(p); elimine(q);
  renverse(p); renverse(q); nul(s); nul(r);
  if (abs(q.coef[0])<zero) or (q.deg=-1)
  then SignalerErreur(314,'')
  else begin
    with p do for j:=deg+1 to MaxPoly do coef[j]:=0.0;
    for i:=0 to n
    do begin
      piv:=p.coef[i]/q.coef[0];
      with s do begin inc(deg); coef[deg]:=piv; end;
      for j:=1 to q.deg do p.coef[j+i]:=p.coef[j+i]-piv*q.coef[j];
      p.coef[i]:=0.0;
    end;
  end;
  r:=p;
  with r do for i:=0 to n do coef[i]:=coef[i+n+1]; r.deg:=n;
  renverse(s); elimine(s); renverse(r); elimine(r);
  FinModule
end;


{ multiplie P par X^n (n entier relatif) }
procedure ProdX(var p:polynome;n:integer);
var i:word;
begin
  DebutModule(310,'ProdX');
  elimine(p);
  if p.deg+n>maxpoly then SignalerErreur(304,'')
  else
    with p do
    begin
      if n>0 then for i:=deg+1 to deg+n do coef[i]:=0.0;
      inc(deg,n);
    end;
  FinModule
end;


{ calcul P(Q(x)) }
procedure Compose(p,q:polynome;var r:polynome);
var
  q1,q2:polynome;
  i:word;
begin
  DebutModule(305,'Compose');
  elimine(p); elimine(q);
  if p.deg*q.deg>maxpoly+1 then SignalerErreur(304,'')
  else begin
    constante(r,p.coef[p.deg]);
    q2:=q;
    for i:=p.deg-1 downto 0
    do begin
      q1:=q; prodr(q1,p.coef[i]);
      addition(r,q1,r);
      produit(q,q2,q);
    end;
  end;
  FinModule
end;


{ translate P au point a : calcul P(x+a) }
procedure Translate(var p:polynome;a:real);
var c:polynome;
begin
  DebutModule(309,'Translate');
  deg1(c,1,a);
  compose(p,c,p);
  FinModule
end;


{ assigne P = aX+b }
procedure Deg1(var p:polynome;a,b:real);
begin
  with p do begin
    deg:=1;
    coef[0]:=a;
    coef[1]:=b;
  end;
  elimine(p);
end;

{ assigne P=aX^2+bX+c }
procedure Deg2(var p:polynome;a,b,c:real);
begin
  with p do begin
    deg:=2;
    coef[0]:=a;
    coef[1]:=b;
    coef[2]:=c;
  end;
  elimine(p);
end;


{ génère un polynôme au hasard. Utiliser RANDOMIZE pour un peu de diversité }
procedure Hasard(var p:polynome;d:integer;min,max:real;entier:boolean);

  { génère un nombre pseudo-aléatoire selon les conditions imposées }
  function genere:real;
  begin
    if entier then genere:=random(round(max-min+1))+min
    else genere:=random*(max-min)+min;
  end;

var
  i:integer;

begin
  DebutModule(319,'Hasard');
  if d>maxpoly then SignalerErreur(304,'')
  else
    with p do begin
      i:=0;
      repeat
        coef[0]:=genere;
        inc(i);
      until (coef[0]<>0) or (i=10);
           { si au bout de 10 tirages on n'a pas trouvé de nombres non nuls, }
           { on abandonne et P ne sera pas de degré D, mais le polynôme nul  }
      if i=20 then nul(p)
      else begin
        deg:=d;
        for i:=1 to d do coef[i]:=genere
      end;
    end;
end;


{ recherche la valuation d'un polynôme }
function Valuation(p:polynome):integer;
var i:integer;
begin
  elimine(p);
  with p do
    if deg=-1 then i:=-1
    else begin
      i:=0;
      repeat
        if abs(coef[deg-i])<=zero then
        begin
          coef[deg-i]:=0.0;
          inc(i)
        end
      until (coef[deg-i]<>0) or (i=deg)
    end;
  valuation:=i
end;


          {*********************************************************}

{ sauve un polynôme dans le fichier T }
procedure Sauve(var t:text;p:polynome);
var s:string;
begin
  DebutModule(335,'Sauve');
  s:=strp(p,'');
  {$i-} writeln(t,s); {$i+}
  if ioresult<>0 then SignalerErreur(335,'');
  FinModule
end;

{ lit un polynôme à partir du le fichier T }
procedure Lit(var t:text;var p:polynome);
var
  s:string;
  result:boolean;
begin            { "saute" les lignes vides }
  DebutModule(336,'Lit');
  repeat
    {$i-} readln(t,s); {$i+}
    result:=ioresult=0;
  until (s<>'') or result;
  if result then chaine(s,p) else SignalerErreur(336,'');
  FinModule
end;


{ sauve 1 polynôme dans un fichier "nommé" }
procedure Sauve1(nom:string;p:polynome);
var
  fic:text;
  result:boolean;
begin
  DebutModule(337,'Sauve1');
  if pos('.',nom)=0 then nom:=nom+'.POL';
  assign(fic,nom);
  {$i-} rewrite(fic);
  result:=ioresult=0;
  writeln(fic,StrP(p,'')); {$i+}
  if (ioresult<>0) or not result then SignalerErreur(337,'');
  close(fic);
  FinModule
end;

{ lit 1 polynôme à partir d'un fichier "nommé" }
procedure Lit1(nom:string;var p:polynome);
var fic:text; s:string;
begin
  DebutModule(338,'Lit1');
  if pos('.',nom)=0 then nom:=nom+'.POL';
  assign(fic,nom);
  {$i-} reset(fic); {$i+}
  if ioresult<>0 then SignalerErreur(338,'')
  else begin
    {$i-} readln(fic,s); {$i+}
    if ioresult<>0 then SignalerErreur(336,'')
    else chaine(s,p);
  end;
  close(fic);
  FinModule
end;


          {*********************************************************}

{ schéma de Hörner pour une valeur complexe de l'indéterminée }
procedure ValeurC(p:polynome;rx,ix:real;var r,i:real);
var
  a:real;
  k:word;
begin
  DebutModule(320,'ValeurC');
  r:=0; i:=0;
  with p do
    if deg <> -1 then
      for k:=0 to deg do
      begin
        a:=r;
        r:=MultReal(r,rx)-MultReal(i,ix)+coef[k];
        i:=MultReal(a,ix)+MultReal(i,rx)
      end;
  FinModule
end;


          {*********************************************************}

{ retourne la puissance 1/2 d'un nombre complexe }
procedure SqrtC(var r,i:real);
begin
  DebutModule(321,'SqrtC');
  if (r<>0) or (i<>0) then
    if (r<0) and (i=0) then
    begin
      i:=sqrt(-r);
      r:=0
    end
    else begin
      r:=sqrt((sqrt(sqr(r)+sqr(i))+r)/2);
      i:=i/2/r
    end;
  FinModule
end;


{ Module COMB - version 1.0 - Samedi 10/03/90 }
{ calculs combinatoires                       }

{ Calcul du C(n,p) sans employer les factorielles   }
{ et en effectuant les divisions au fur et à mesure }
function Cnp(n,p:word):longint;
var
  c_prov,             { emploi d'une variable provisoire pour Cnp }
  indice,             { indice de la boucle générale              }
  diviseur:word;      { facteurs successifs de p!                 }
begin
  if p>n then Cnp:=0
  else
    if (p=0) or (p=n) then Cnp:=1
    else begin
      if p>n div 2 then p:=n-p;
      c_prov:=1;
      diviseur:=2;
      for indice:=n downto n-p+1 do
      begin
        c_prov:=c_prov*indice;
        while ((c_prov mod diviseur)=0) and (diviseur<=p) do
        begin
          c_prov:=c_prov div diviseur;
          inc(diviseur);
        end;
      end;
      Cnp:=c_prov;
    end;
end;

{ calcul d'une factorielle limitée au type LongInt (i.e 10! ou 11!) }
function Fact(n:word):longint;
var
  i:word;
  f:longint;
begin
  f:=1;
  for i:=2 to n do f:=f*i;
  Fact:=f;
end;


          {*********************************************************}

function MessErreur:string;
var
  S:string;
begin
  case pn_Erreur of
    304 : S:='degré trop élevé';
    313 : S:='division euclidienne par le polynôme nul';
    314 : S:='division puiss. croiss. par le polynôme nul';

    330 : S:='chaîne invalide pour un polynôme';

    335 : S:='erreur d''enregistrement sur disque';
    336 : S:='erreur de lecture sur disque';
    337 : S:='erreur de création de fichier';
    338 : S:='erreur d''accès au disque';
    else S:='ERREUR DANS L''UNITE POLYNM'
  end;
  MessErreur:=S
end;

          {*********************************************************}

{ initialisation de l'unité }
begin
  pn_Erreur:=0;
  Mode_Affichage(0,0,1)
end.

{ ***************************** FIN DU MODULE ******************************* }
