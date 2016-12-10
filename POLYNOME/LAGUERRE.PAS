program ZEROS_DE_LAGUERRE;

{ version 1.0 - René DEVICHI (c) 1990                       }
{ --------------------------------------------------------- }
{ Méthode de Laguerre pour calculer avec une suite complexe }
{ les zéros d'un polynôme quelconque de R[X].               }

uses CRT, Modes, Polynm, PolyC;

var
  epsilon:real;


procedure tab;
var x,y:integer;
begin
  x:=wherex;
  y:=wherey;
  x:=(x div 8)*8+8;
  if x>80 then
  begin
    x:=1;
    inc(y);
    if y=26 then
    begin                 halt;
      gotoxy(1,25);writeln;
      y:=25;
    end;
  end;
  gotoxy(x,y);
end;

{$i b:\zeros234}

procedure laguerre(p:polynome);
var
  rzk,izk,rsk,isk:real;
  pp,ps,q,q0:polynome;
  ok:boolean;    { indique si on a trouvé un zéro }

  procedure initialise;
  begin
(*    unitaire(p); *)
    pp:=p; derive(pp);           { pp : dérivée de P         }
    ps:=pp; derive(ps);          { ps : dérivée seconde de P }
    produit(pp,pp,q);
    prodr(q,sqr(p.deg-1));
    produit(p,ps,q0);
    prodr(q0,-p.deg*(p.deg-1));
    addition(q,q0,q);            { Q=(n-1)²P'²-n(n-1)P.P"    }
    prodr(p,-p.deg);             { P <- n.P                  }
  end;  { initialise }


  function etape_laguerre:boolean;   { calcule Sk, étape de Laguerre }
  var
    rp,ip,rpp,ipp,rq,iq,r1,i1,r2,i2:real;
    d1,d2:boolean;

    function diviseC(a,b,c,d:real;var r,i:real):boolean;
    var den:real;        { calcule r+I*i=(a+i*b)/(c+i*d) }
    begin
      den:=sqr(c)+sqr(d);
      if den=0 then diviseC:=false
      else begin
        diviseC:=true;
        r:=(a*c+b*d)/den;
        i:=(-a*d+b*c)/den;
      end;
    end;

    procedure retour1;
    begin
      rsk:=r1; isk:=i1;
    end;

    procedure retour2;
    begin
      rsk:=r2; isk:=i2;
    end;

  begin  { etape_laguerre }
    valeurC(p,rzk,izk,rp,ip);
    valeurC(pp,rzk,izk,rpp,ipp);
    valeurC(q,rzk,izk,rq,iq);
    sqrtc(rq,iq);
    d1:=diviseC(rp,ip,rpp+rq,ipp+iq,r1,i1);
    d2:=diviseC(rp,ip,rpp-rq,ipp-iq,r2,i2);
    etape_laguerre:=true;           { a priori l'étape est calculable }
    if (d1 and d2) then
      if sqr(r1)+sqr(i1)<sqr(r2)+sqr(i2) then retour1 else retour2
    else
      if d1 then retour1
      else
        if d2 then retour2
        else
          etape_laguerre:=false;   { on n'a pas pu la calculer }
  end;  { etape_laguerre }


  procedure trouve_un_zero;
  var
    k,essai:word;
    erreurcalcul:boolean;
  begin
    essai:=0;
    repeat
      rzk:=2*random-1; izk:=2*random-1;        { Z0 est tiré au hasard }
      k:=0;
      repeat
        erreurcalcul:=not etape_laguerre;
        rzk:=rzk+rsk; izk:=izk+isk;       { Zk+1=Zk+Sk }
        inc(k);
      until (sqr(rsk)+sqr(isk)<=epsilon) or (k>=100) or erreurcalcul;
      inc(essai);
    until (not erreurcalcul) or (essai>6);
    if erreurcalcul or (essai>6) then ok:=false else ok:=true;
  end;

  procedure multiplicite;
  var
    q,a,b,c,z:polynome;
    o:integer;
  begin
{ crée un polynôme dont la racine est Zk }
    if abs(izk)<=epsilon
    then deg1(q,1,-rzk)
    else deg2(q,1,-2*rzk,sqr(rzk)+sqr(izk));
{ Q poly dont les racines sont Zk et son conjugué si Zk est complexe, Zk uniquement si il est réel }
    o:=-1;   { ordre de multiplicité de la racine ou du polynôme de degré 2 à descriminant négatif }

    repeat
      a:=p;
      divise(p,q,p,b);
      inc(o);          if o>100 then begin writeln('Aïe !!!'); HALT; end;
    until (b.deg<>-1) or (p.deg=-1);
    p:=a;
    affiche(q,''); tab; tab; writeln('ordre de multiplicité : ',o);
    write('polynôme restant= '); { polynôme restant par divisions successives de P par ses diviseurs }
    tab;afficheln(p,'');
  end;


begin { corps de la procédure Laguerre }
  epsilon:=polynm.zero; { valeur de la précision souhaitée }

repeat
  if p.deg>2 then
  begin
    initialise;
    trouve_un_zero;
    if not ok then begin writeln('Méthode de Laguerre divergente.'); EXIT; end;
  end
  else zeros(p,rzk,izk);

  writeln;  write('Zéro (complexe) trouvé : '); ecritcln(rzk,izk);
  multiplicite;
until p.deg<=0;
          writeln;
end;


var p:polynome;
begin
  chaine('1  5 2 3 -4',p);
  afficheln(p,'x');
  laguerre(p);
end.

