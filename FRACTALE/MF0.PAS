uses Dos, Crt, Graph;

const
  GraphPath='';
  GraphCard: INTEGER= Detect;
  GraphMode: INTEGER= 0;

const
  deg_rad=3.1415926535/180;
  rap=2.06;

var
  noeud:array[1..129,1..129] of integer;

{*************************************************************}
var ChronoH, ChronoM, ChronoS, ChronoC: word;

procedure StartChrono;
begin
  GetTime(ChronoH,ChronoM,ChronoS,ChronoC)
end;

function StopChrono:longint;  { en centièmes de secondes }
var
  H,M,S,C:word;
  CH,CM,CS,CC:integer;
begin
  GetTime(H,M,S,C);
  CC:=INTEGER(C)-INTEGER(ChronoC);
  CS:=INTEGER(S)-INTEGER(ChronoS) + CC div 100;
  CM:=INTEGER(M)-INTEGER(ChronoM) + CS div 60;
  CH:=INTEGER(H)-INTEGER(ChronoH) + CM div 60;
  CC:=CC mod 100;
  CS:=CS mod 60;
  CM:=CM mod 60;
  StopChrono:=CC+100*(CS+60*(CM+60*CH));
end;
{*************************************************************}

function randon:longint;
begin
  randomize; randon:=random(32767);
end;


procedure MontsFractals(mail,prof,mer, theta,phi,ray,
               alpha,beta,r, typ:integer; alea:longint);

const
  premiere:boolean=false;
  alea_prec:longint=-1;
  dn_prec:integer=-1;
  prof_prec:integer=-1;
  theta_prec:integer=10000;
  phi_prec:integer=10000;
  ray_prec:integer=-1;

type
  vecteur=array[1..3] of real;

var
  generee:boolean;
  dn,i,ecrx,ecry:integer;
  ct,st,cp,sp,cp_st,sp_st,cp_ct,sp_ct,xobs,yobs,zobs,xecl,yecl,zecl,
  echx,echy,xcent,ycent:real;
  v1,v2,vn,vecl,vobs,bary,c:vecteur;
  pt:array[1..3] of vecteur;


procedure genere_matrice;
var
  i,j,a,b,c,d:integer;
  pas,ech:integer;

  function altitude:integer;
  begin
    if random>prof/100 then altitude:=-random(ech)
    else altitude:=random(ech);
  end;

begin
  writeln('Génération d''une matrice');
  fillchar(noeud,129*129*2,0);    { noeud[i,j]=0 pour tout (i,j) }
  RandSeed:=alea;                 { générateur aléatoire         }
  pas:=dn-1;
  ech:=8000;
  while pas>1 do
  begin
    i:=1;
    repeat
      j:=1;
      repeat
        a:=i+(pas div 2); b:=j+(pas div 2); c:=i+pas; d:=j+pas;
        noeud[i,b]:=(noeud[i,j]+noeud[i,d]+altitude) div 2;
        noeud[a,j]:=(noeud[i,j]+noeud[c,j]+altitude) div 2;
        noeud[a,b]:=(noeud[c,j]+noeud[i,d]+altitude) div 2;
        inc(j,pas);
      until j>=dn-i+1;
      inc(i,pas);
    until i>=dn;
    pas:=pas div 2;
    ech:=ech div 2;
  end;
end;


procedure coord_ecran(c:vecteur;var xe,ye:real);
var d:real;
begin
  d:=c[1]*cp_ct+c[2]*sp_ct+c[3]*st-ray;
  xe:= (c[1]*sp-c[2]*cp)/d;
  ye:=(c[1]*cp_st+c[2]*sp_st-c[3]*ct)/d;
end;

procedure coord_spaciales(ci,cj:integer;var c:vecteur);
begin
  c[1]:=((1-ci)/(dn-1)+1/3)*(4000.0*sqrt(3));
  c[2]:=((cj-1)+(ci-1)/2)*8000/(dn-1)-4000.0;
  c[3]:=noeud[ci,cj];
  if c[3]<mer then c[3]:=mer;
end;

procedure coord_ibm(ci,cj:integer;var x,y:integer);
var
  a,b,c,d:real;
begin
  a:=((1-ci)/(dn-1)+1/3)*(4000.0*sqrt(3));
  b:=((cj-1)+(ci-1)/2)*8000/(dn-1)-4000.0;
  c:=noeud[ci,cj]; if c<mer then c:=mer;
  d:=a*cp_ct+b*sp_ct+c*st-ray;
  x:=round(( (a*sp-b*cp)/d)           *echx+xcent);
  y:=round(( (a*cp_st+b*sp_st-c*ct)/d)*echy+ycent);
end;

procedure contour(x1,y1,x2,y2,x3,y3,c:integer);
begin
  setcolor(c);
  line(x1,y1,x2,y2);
  line(x2,y2,x3,y3);
  line(x3,y3,x1,y1);
end;


procedure centrage_ecran;
var
  xemin,yemin,xemax,yemax:real;
  stp:integer;
  v:vecteur;
  xe,ye:real;
  i,j:integer;

begin
  writeln('Calcul du centrage sur l''écran');
  xemin:=1000; yemin:=1000;
  xemax:=-1000; yemax:=-1000;
  stp:=1;
  if mail>5 then for i:=1 to mail-5 do stp:=stp*2;  { stp=2^(mail-5) }
  i:=1;
  repeat
    j:=1;
    repeat
      coord_spaciales(i,j,v); coord_ecran(v,xe,ye);
      if xe<xemin then xemin:=xe;
      if xe>xemax then xemax:=xe;
      if ye<yemin then yemin:=ye;
      if ye>yemax then yemax:=ye;
      inc(j,stp);
    until j>dn-i+1;
    inc(i,stp);
  until i>dn;
  echx:=ecrx/(xemax-xemin)/rap;
  echy:=ecry/(yemax-yemin);
  if echy<echx then echx:=echy;
  echy:=echx; echx:=echx*rap;
  xcent:=((ecrx+1-echx*(xemax+xemin))/2);
  ycent:=((ecry+1-echy*(yemax+yemin))/2);
end;


procedure trace;
var
  i,j:integer;
  x1,y1,x2,y2,x3,y3:integer;
begin
  for i:=2 to dn do
    for j:=1 to dn-i+1 do
    begin
      coord_ibm(  i,  j,x1,y1);
      coord_ibm(i-1,  j,x2,y2);
      coord_ibm(i-1,j+1,x3,y3);
      contour(x1,ecry-y1,x2,ecry-y2,x3,ecry-y3,1);
    end;
end;



begin  { MontsFractals }
  RestoreCRTMode;

  ecrx:=GetMaxX; ecry:=GetMaxY;

  writeln('Calcul des constantes');

  dn:=1; for i:=1 to mail do dn:=dn*2; inc(dn);  { dn=2^mail+1 }

  ct:=cos(theta*deg_rad); st:=sin(theta*deg_rad);
  cp:=cos(phi*deg_rad);   sp:=sin(phi*deg_rad);
  cp_st:=cp*st; sp_st:=sp*st;
  cp_ct:=cp*ct; sp_ct:=sp*ct;

  xobs:=ray*cp_ct;
  yobs:=ray*cp_st;
  zobs:=ray*st;

  if typ=3 then
  begin
    xecl:=r*cos(alpha*deg_rad)*cos(beta*deg_rad);
    yecl:=r*cos(alpha*deg_rad)*sin(beta*deg_rad);
    zecl:=r*sin(alpha*deg_rad);
  end;

{ si c'est la première fois ou si on a changé qqch à la définition de la
matrice, on la régénère }
  if premiere or (alea_prec<>alea) or (dn_prec<>dn) or (prof_prec<>prof) then
  begin
    genere_matrice;
    generee:=true;
  end
  else generee:=false;
  premiere:=false;  { ce n'est plus la première fois }
  alea_prec:=alea;
  dn_prec:=dn;
  prof_prec:=prof;

{ si on a calculée une nouvelle matrice (generee=TRUE) ou si on a changé
qqch à la position de l'observateur, on recalcule le centrage }
  if (ray_prec<>ray) or (theta_prec<>theta) or (phi_prec<>phi) or generee or true then
    centrage_ecran;
  ray_prec:=ray;
  theta_prec:=theta;
  phi_prec:=phi;

  SetGraphMode(GraphMode);   { positionne le mode graphique }
  ClearViewPort;

  if typ=1 then trace
  else begin
  end;
end;


procedure donnees;
begin
{  mail:=5; prof:=50; mer:=300; theta:=40; phi:=145; ray:=10000; typ:=1; alea:=5392;}
end;

PROCEDURE InitGraphique;
BEGIN
  InitGraph(GraphCard,GraphMode,GraphPath);
  IF GraphResult<0 THEN
  BEGIN
    WriteLn('Problème graphique insoluble.');
    Halt(1);
  END;
END;

                      var i:integer; f:file;
begin
  InitGraphique;

  for i:=650 to 1050 do
  begin
    startchrono;
    montsfractals(5,50,i,40,135,10000,0,0,0,1,32350);
    directvideo:=false;
    writeln('mont'+chr((i-250) div 100+48),'    mer ',i,'    temps ',stopchrono/100:0:2);
    assign(f,'a:mont'+chr((i-250) div 100+48));
    rewrite(f,1);
    blockwrite(f,mem[$b800:0],$4000);
    close(f);
    if readkey=#0 then;
    INC(i,199);
  end;
  closegraph;
end.


procedure L630;
begin
  if phi<180 then
    for i:=2 to dn do
    begin
      tst:=0;
      for j:=1 to dn-i+1 do
      begin
        L710; L870;
      end;
    end
  else
    for i:=2 to dn do
    begin
      tst:=0;
      for j:=dn-i+1 downto 1 do
      begin
        L870;
        L710;
      end;
    end;
end;

procedure L710;
begin
  coord_spaciales(i-1,j,c);
  for l:=1 to 3 do
  begin
    v1[l]:=c[l]; pt[1,l]:=c[l];
  end;
  coord_spaciales(i,j,c);
  for l:=1 to 3 do
  begin
    v1[l]:=v1[l]-c[l]; pt[2,l]:=c[l];
  end;
  if tst=0 then tst:=1
  else begin
    if phi<180 then coord_spaciales(i,j-1,c) coord_spaciales(i-1,j+1,c);
    for l:=1 to 3 do pt[3,l]:=c[l];
    L2020;
  end;
end;

870 ci=i-1 : cj=j+1 : gosub 3320
880 for l=1 to 3
890   v2(l)=c(l) : pt(1,l)=c(l)
900 next l
910 ci=i : cj=j : gosub 3320
920 for l=1 to 3
930   v2(l)=v2(l)-c(l) : pt(2,l)=c(l)
940 next l
950 if tst=0 then tst=1 : goto 1020
960 if phi<180 then ci=i-1 else cj=j+1
970 gosub 3320
980 for l=1 to 3
990   pt(3,l)=c(l)
1000 next l
1010 gosub 2020
1020 return






1030 if phi>60 then deb=1 : sens=1 : else fin=1 : sens=-1
1040 for i=2 to dn
1050   tst=0 : if phi>60 then fin=dn-i+1 : else deb=dn-i+1
1060   for j=deb to fin step sens
1070     if phi>60 then gosub 1110 : gosub 1270 else gosub 1270 : gosub 1110
1080   next j
1090 next i
1100 return

1110 ci=j : cj=i-1 : gosub 3320
1120 for l=1 to 3
1130   v2(l)=c(l) : pt(1,l)=c(l)
1140 next l
1150 cj=i : gosub 3320
1160 for l=1 to 3
1170   v2(l)=v2(l)-c(l) : pt(2,l)=c(l)
1180 next l
1190 if tst=0 then tst=1 : goto 1260
1200 if phi>60 then ci=j-1 else ci=j+1 : cj=i-1
1210 gosub 3320
1220 for l=1 to 3
1230   pt(3,l)=c(l)
1240 next l
1250 gosub 2020
1260 return

1270 ci=j+1 : cj=i-1 : gosub 3320
1280 for l=1 to 3
1290   v1(l)=c(l) : pt(1,l)=c(l)
1300 next l
1310 ci=j : cj=i : gosub 3320
1320 for l=1 to 3
1330   v1(l)=v1(l)-c(l) : pt(2,l)=c(l)
1340 next l
1350 if tst=0 then tst=1 : goto 1420
1360 if phi>60 then cj=i-1 else ci=j+1
1370 gosub 3320
1380 for l=1 to 3
1390   pt(3,l)=c(l)
1400 next l
1410 gosub 2020
1420 return

1430 if phi<300 then deb=1 : sens=1 : else fin=1 : sens=-1
1440 for i=dn-1 to 1 step -1
1450   tst=0 : if phi<300 then fin=i : else deb=i
1460   for j=deb to fin step sens
1470     k=i+1-j
1480     if phi<300 then gosub 1520 : gosub 1680 else gosub 1680 : gosub 1520
1490   next j
1500 next i
1510 return

1520 ci=j : cj=k+1 : gosub 3320
1530 for l=1 to 3
1540   v1(l)=c(l) : pt(1,l)=c(l)
1550 next l
1560 cj=k : gosub 3320
1570 for l=1 to 3
1580   v1(l)=v1(l)-c(l) : pt(2,l)=c(l)
1590 next l
1600 if tst=0 then tst=1 : goto 1670
1610 if phi<300 then ci=j-1 : cj=k+1 : else ci=j+1
1620 gosub 3320
1630 for l=1 to 3
1640   pt(3,l)=c(l)
1650 next l
1660 gosub 2020
1670 return

1680 ci=j+1 : cj=k : gosub 3320
1690 for l=1 to 3
1700   v2(l)=c(l) : pt(1,l)=c(l)
1710 next l
1720 ci=j : gosub 3320
1730 for l=1 to 3
1740   v2(l)=v2(l)-c(l) : pt(2,l)=c(l)
1750 next l
1760 if tst=0 then tst=1 : goto 1830
1770 if phi<300 then cj=k+1 else ci=j+1 : cj=k-1
1780 gosub 3320
1790 for l=1 to 3
1800   pt(3,l)=c(l)
1810 next l
1820 gosub 2020
1830 return

1840 c=1
1850 for i=2 to dn
1860   for j=1 to dn-i+1
1870     ci=i : cj=j : gosub 3220
1880     xe(1)=xe*echx+xcent : ye(1)=ye*echy+ycent
1890     ci=i-1 : gosub 3220
1900     xe(2)=xe*echx+xcent : ye(2)=ye*echy+ycent
1910     cj=j+1 : gosub 3220
1920     xe(3)=xe*echx+xcent : ye(3)=ye*echy+ycent
1930     gosub 3600
1940   next j
1950 next i
1960 return

1970 rem
1980 rem ************************************************
1990 rem  Calcul de couleurs et remplissage des facettes
2000 rem ************************************************
2010 rem
2020 indm=0 : ncoul=0
2030 if pt(1,3)=mer and pt(2,3)=mer and pt(3,3)=mer then indm=1 : goto 2300
2040 vn(1)=v1(2)*v2(3)-v1(3)*v2(2)
2050 vn(2)=v1(3)*v2(1)-v1(1)*v2(3)
2060 vn(3)=v1(1)*v2(2)-v1(2)*v2(1)
2070 vn=sqr(vn(1)^2+vn(2)^2+vn(3)^2)
2080 for n=1 to 3
2090   bary(n)=(pt(1,n)+pt(2,n)+pt(3,n))/3
2100 next n
2110 vobs(1)=bary(1)-xobs
2120 vobs(2)=bary(2)-yobs
2130 vobs(3)=bary(3)-zobs
2140 prosc=vn(1)*vobs(1)+vn(2)*vobs(2)+vn(3)*vobs(3)
2150 vobs=sqr(vobs(1)^2+vobs(2)^2+vobs(3)^2)
2160 cosang=prosc/(vn*vobs)
2170 ang=atn(sqr(1-cosang^2)/cosang)
2180 if ang>0 then ncoul=1
2190 if ncoul=1 or type=2 then 2300
2200 vecl(1)=bary(1)-xecl
2210 vecl(2)=bary(2)-yecl
2220 vecl(3)=bary(3)-zecl
2230 prosc=vn(1)*vecl(1)+vn(2)*vecl(2)+vn(3)*vecl(3)
2240 vecl=sqr(vecl(1)^2+vecl(2)^2+vecl(3)^2)
2250 cosang=prosc/(vn*vecl)
2260 ang=atn(sqr(1-cosang^2)/cosang)
2270 if ang<0 then ang=ang+3.1415926535
2280 coul=int(ang/fang+.5)
2290 if coul<>0 then freq=15/coul else freq=1e+30
2300 for n=1 to 3
2310   c(1)=pt(n,1) : c(2)=pt(n,2) : c(3)=pt(n,3)
2320   gosub 3230
2330   xe(n)=int(xe*echx+xcent+.5) : ye(n)=int(ye*echy+ycent+.5)
2340 next n
2350 if ye(2)>=ye(1) and ye(2)>=ye(3) then exx=xe(1) : exy=ye(1) : xe(1)=xe(2) : ye(1) = ye(2) : xe(2)=exx : ye(2)=exy : goto 2370
2360 if ye(3)>=ye(1) and ye(3)>=ye(2) then exx=xe(1) : exy=ye(1) : xe(1)=xe(3) : ye(1) = ye(3) : xe(3)=exx : ye(3)=exy
2370 if ye(3)>ye(2) then exx=xe(2) : exy=ye(2) : xe(2)=xe(3) : ye(2) = ye(3) : xe(3)=exx : ye(3)=exy
2380 ex1=xe(1)-xe(2) : ey1=ye(1)-ye(2)
2390 ex2=xe(1)-xe(3) : ey2=ye(1)-ye(3)
2400 ex3=xe(2)-xe(3) : ey3=ye(2)-ye(3)
2410 if ey1<>0 then stp1=ex1/ey1
2420 if ey2<>0 then stp2=ex2/ey2
2430 if ey3<>0 then stp3=ex3/ey3
2440 pch=int(rnd*freq+1.5) : comp=1
2450 cpt2=0
2460 for cpt1=0 to ey1
2470   x1=int(xe(1)-cpt1*stp1+.5) : x2=int(xe(1)-cpt2*stp2+.5) : y1=ye(1)-cpt1
2480   if ey1=0 then x1=xe(2)
2490   if ey2=0 then x2=xe(3)
2500   gosub 3420
2510 next cpt1
2520 for cpt1=1 to ey3
2530   x1=int(xe(2)-cpt1*stp3+.5) : x2=int(xe(1)-cpt2*stp2+.5) : y1=ye(1)-cpt2
2540   gosub 3420
2550 next cpt1
2560 if (type=2 and ncoul=0 and indm=0) or (type=3 and ncoul=1) or bord$="o" or bord$="O" then c=1 : gosub 3600
2570 return
2580 rem
2590 rem ****************************
2600 rem   Génération de la matrice
2610 rem ****************************
2620 rem



3370 rem
3380 rem *******************************
3390 rem   Sous-programme de coloriage
3400 rem *******************************
3410 rem
3420 if (ncoul=1 and type=2) or (y1 mod 2=0 and indm=1) then c=1 else c=0
3430 if type=2 or indm=1 or ncoul=1 then line(x1,y1)-(x2,y1),c : goto 3530
3440 if x1<>x2 then 3470
3450 if comp=int(pch+.5) then pset(x1,y1),1 else pset(x1,y1),0
3460 goto 3530
3470 for n=x1 to x2 step sgn(x2-x1)
3480   c=0
3490   if comp=int(pch+.5) then c=1 : pch=pch+freq
3500   pset(n,y1),c
3510   comp=comp+1
3520 next n
3530 cpt2=cpt2+1
3540 return
3550 rem
3560 rem **********************
3570 rem   Tracé des contours
3580 rem **********************
3590 rem
3600 line(xe(1),ye(1))-(xe(2),ye(2)),c
3610 line(xe(2),ye(2))-(xe(3),ye(3)),c
3620 line(xe(3),ye(3))-(xe(1),ye(1)),c
3630 return

