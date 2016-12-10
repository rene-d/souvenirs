UNIT FRACRAT;

{ unité  FracRat                      version 1.2 M }
{ René DEVICHI -avril 1990                          }
{ ------------------------------------------------- }
{ opérations sur les fractions rationnelles de R(X) }

INTERFACE

{ Note: description du type Fraction
c'est un enregistrement de deux polynômes (NUM et DEN) et d'un
entier (DegF). DegF est le degré de la fraction, défini par la
procédure Simplifie comme NUM.Deg-DEN.Deg.                     }


uses
  CRT, Modub1, Polynm;

type
  fraction=record
                 num,den:polynome;
                 degf:integer;
           end;


procedure SimplifieF(var f:fraction);
procedure ChaineF(sn,sd:string;var f:fraction);
procedure AdditionF(f1,f2:fraction;var f:fraction);
procedure ProduitF(f1,f2:fraction;var f:fraction);
procedure AfficheF(f:fraction;ind:string);
procedure InverseF(var f:fraction);
procedure DeriveF(var f:fraction);


IMPLEMENTATION

{ simplifie la fraction rationnelle en divisant par le pgcd du num et dén  }
{ actualise aussi le degré de la fraction                                  }
PROCEDURE SimplifieF(var f:fraction);
var
  p,r:polynome;
begin
  DebutModule(351,'SimplifieF');
  with f
  do begin
    pgcd(num,den,p);
    divise(num,p,num,r);
    divise(den,p,den,r);
    degf:=num.deg-den.deg;
  end;
  FinModule
end;


{ même fonction que polynm.chaine pour les fractions }
PROCEDURE ChaineF(sn,sd:string;var f:fraction);
begin
  DebutModule(352,'ChaineF');
  with f
  do begin
    polynm.chaine(sn,num);
    polynm.chaine(sd,den);
    degf:=num.deg-den.deg;
  end;
  FinModule
end;


{ additionne deux fractions en simplifiant le résultat }
PROCEDURE AdditionF(f1,f2:fraction;var f:fraction);
var
  p:polynome;
begin
  DebutModule(353,'AdditionF');
  produit(f1.num,f2.den,f.num);
  produit(f1.den,f2.num,p);
  addition(f.num,p,f.num);
  produit(f1.den,f2.den,f.den);
  simplifief(f);
  FinModule
end;


{ multiplie deux fractions et simplifie le résultat }
PROCEDURE ProduitF(f1,f2:fraction;var f:fraction);
begin
  DebutModule(354,'ProduitF');
  produit(f1.num,f1.num,f.num);
  produit(f1.den,f2.den,f.den);
  simplifief(f);
  FinModule
end;


{ génère une chaîne de n espaces - pour afficheF }
function espace(n:word):string;
var i:word; s:string;
begin
  s:='';
  for i:=1 to n do s:=concat(s,' ');
  espace:=s;
end;


{ affiche la fraction F }
PROCEDURE AfficheF(f:fraction;ind:string);
var
  sn,sd:string;
  x,y,ln,ld,lmax,i:integer;
begin
  x:=wherex; y:=wherey;
  if y>22 then y:=22;
  sn:=strp(f.num,ind); ln:=length(sn);
  sd:=strp(f.den,ind); ld:=length(sd);
  if ln<ld then lmax:=ld else lmax:=ln;
  sd:=espace((lmax-ld) div 2)+sd;
  sn:=espace((lmax-ln) div 2)+sn;
  write(sn);
  gotoxy(x,y+1);
  for i:=1 to lmax do write(#196); { chr(196) = trait complet horizontal }
  gotoxy(x,y+2); write(sd);
end;


{ inverse la fraction : échange numérateur et dénominateur }
PROCEDURE InverseF(var f:fraction);
var p:polynome;
begin
  with f do begin
    p:=num;
    num:=den;
    den:=p;
  end;
end;


{ dérive la fraction F avec simplification }
PROCEDURE DeriveF(var f:fraction);
var a,b:polynome;
begin
  DebutModule(355,'DeriveF');
  a:=f.num; derive(a); produit(a,f.den,a);
  b:=f.den; derive(b); produit(b,f.num,b); oppose(b);
  addition(a,b,f.num);
  produit(f.den,f.den,f.den);
  simplifief(f);
  FinModule
end;


END.