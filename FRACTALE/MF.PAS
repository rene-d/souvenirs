PROGRAM  Monts_Fractals ;

USES Dos, Crt, Graph, Chrono;

CONST
  GraphPath= 'c:\tp\bgi';
  GraphCard: INTEGER= Detect;
  GraphMode: INTEGER= 0;


CONST
  deg_rad   = 0.017453292;  { = 3.1415926535/180; }
  fang      = 0.20943951;   { = 3.1415926535/15;  }
  pitch     = 2.06;
  max_noeud = 65;           { = 2^6+1;            }

  Premiere: BOOLEAN= TRUE;


VAR
  noeud: ARRAY[1..max_noeud,1..max_noeud] OF INTEGER;
  _alea: LONGINT;
  _dn,_prof,_theta,_phi,_ray: INTEGER;
  echx,echy,xcent,ycent: REAL;


FUNCTION StrI(i: INTEGER): STRING;
VAR s:STRING;
BEGIN
  Str(i,s);
  IF Copy(s,1,1)=' ' THEN Delete(s,1,1);
  IF Length(s)=1 THEN StrI:='0'+s ELSE StrI:=s;
END;


PROCEDURE Pause;
VAR c:CHAR;
BEGIN
  REPEAT
    c:=ReadKey;
  UNTIL (c=' ') OR (c=#27) OR (c=#13);
END;

FUNCTION Randon: LONGINT;  { fournit un nombre ALEATOIRE }
BEGIN
  Randomize; Randon:=Random(32767);
END;


PROCEDURE Echange(VAR a,b: INTEGER);
VAR c:INTEGER;
BEGIN
  c:=a; a:=b; b:=c;
END;


PROCEDURE InitGraphique;
BEGIN
  InitGraph(GraphCard,GraphMode,GraphPath);
  IF GraphResult<0 THEN
  BEGIN
    WriteLn('Problème graphique insoluble.');
    Halt(1);
  END;
END;



PROCEDURE MontsFractals(mail,prof,mer, theta,phi,ray,
                         alpha,beta,r: INTEGER; bord: BOOLEAN;
                         typ: INTEGER; alea: LONGINT);

TYPE
  vecteur= ARRAY[1..3] OF REAL;

VAR
  tst: BOOLEAN;
  i,j,k,dn,ecrx,ecry: INTEGER;
  ct,st,cp,sp,cp_st,sp_st,cp_ct,sp_ct,
  xobs,yobs,zobs,xecl,yecl,zecl: REAL;
  x1,y1,x2,y2,x3,y3: INTEGER;
  v1,v2: vecteur;
  pt: ARRAY[1..3] OF vecteur;


PROCEDURE Genere_Matrice;
VAR
  i,j,a,b,c,d: INTEGER;
  pas,ech: INTEGER;

  FUNCTION Altitude: INTEGER;
  BEGIN
    IF Random>prof/100 THEN Altitude:=-Random(ech)
    ELSE Altitude:=Random(ech);
  END;

BEGIN
  WriteLn('Génération d''une matrice');
  WriteLn(' degré de maillage : ',mail);
  WriteLn(' indice de profil  : ',prof,'%');
  WriteLn(' niveau de la mer  : ',mer);
  WriteLn(' random seed       : ',alea);

  FillChar(noeud,Sqr(max_noeud)*2,0);  { noeud[i,j]=0 pour tout (i,j) }
  RandSeed:=alea;                      { générateur aléatoire         }
  pas:=dn-1;  { 2^mail }
  ech:=4000*2;
  WHILE pas>1 DO
  BEGIN
    i:=1;
    REPEAT
      j:=1;
      REPEAT
        a:=i+(pas DIV 2); b:=j+(pas DIV 2); c:=i+pas; d:=j+pas;
        noeud[i,b]:=(noeud[i,j]+noeud[i,d]+altitude) DIV 2;
        noeud[a,j]:=(noeud[i,j]+noeud[c,j]+altitude) DIV 2;
        noeud[a,b]:=(noeud[c,j]+noeud[i,d]+altitude) DIV 2;
        Inc(j,pas);
      UNTIL j>dn-i;
      Inc(i,pas);
    UNTIL i>=dn;
    pas:=pas DIV 2;
    ech:=ech DIV 2;
  END;
END;


PROCEDURE Coord_Spatiales(ci,cj: INTEGER; VAR c: vecteur);
BEGIN
  c[1]:=((1-ci)/(dn-1)+1/3)*(4000.0*Sqrt(3));
  c[2]:=((cj-1)+(ci-1)/2)*8000/(dn-1)-4000.0;
  c[3]:=noeud[ci,cj];
  IF c[3]<mer THEN c[3]:=mer;
END;


PROCEDURE Centrage_Ecran;
VAR
  xemin,yemin,xemax,yemax: REAL;
  stp: INTEGER;
  v: vecteur;
  d,xe,ye: REAL;
  i,j: INTEGER;
BEGIN
  WriteLn('Recherche du centrage sur l''écran');
  WriteLn('  position de l''observateur : Θ=',theta,
     '°, Φ=',phi,'°, r=',ray);
  WriteLn('    i.e. : (',xobs:0:1,',',yobs:0:1,',',zobs:0:1,')');

  xemin:=1000; yemin:=1000;
  xemax:=-1000; yemax:=-1000;
  stp:=1;
  IF mail>5 THEN FOR i:=1 TO mail-5 DO stp:=stp*2;  { stp=2^(mail-5) }
  i:=1;
  REPEAT
    j:=1;
    REPEAT
      Coord_Spatiales(i,j,v);
      { calcul des coordonnées d'écran }
      d:=v[1]*cp_ct+v[2]*sp_ct+v[3]*st-ray;
      xe:=(v[1]*sp-v[2]*cp)/d;
      ye:=(v[1]*cp_st+v[2]*sp_st-v[3]*ct)/d;
      IF xe<xemin THEN xemin:=xe;
      IF xe>xemax THEN xemax:=xe;
      IF ye<yemin THEN yemin:=ye;
      IF ye>yemax THEN yemax:=ye;
      Inc(j,stp);
    UNTIL j>dn-i+1;
    Inc(i,stp);
  UNTIL i>dn;
  echx:=(ecrx*0.95)/(xemax-xemin)/pitch;
  echy:=(ecry*0.95)/(yemax-yemin);
  IF echy<echx THEN echx:=echy;
  echy:=-echx; echx:=echx*pitch;
  xcent:=(ecrx+1-echx*(xemax+xemin))/2;
  ycent:=(ecry+1-echy*(yemax+yemin))/2;
END;


PROCEDURE Coord_Ecran(c: vecteur; VAR xe,ye: INTEGER);
VAR d: REAL;
BEGIN
  d:=c[1]*cp_ct+c[2]*sp_ct+c[3]*st-ray;
  xe:=Round(echx*(c[1]*sp-c[2]*cp)/d+xcent);
  ye:=Round(echy*(c[1]*cp_st+c[2]*sp_st-c[3]*ct)/d+ycent);
END;


PROCEDURE Contour;
BEGIN
  SetColor(Brown);
  Line(x1,y1,x2,y2);
  Line(x2,y2,x3,y3);
  Line(x3,y3,x1,y1);
END;


{ trace une facette en typ=2 ou 3 }
PROCEDURE Facette2;
CONST
  freq: REAL= 0;
VAR
  pch,vn1,vn2,vn3,bary1,bary2,bary3,xr,yr,zr,stp1,stp2,stp3: REAL;
  ey1,ey2,ey3,COMP,cpt1,cpt2,xA,xB,yA: INTEGER;
  ncoul,indm: BOOLEAN;


  PROCEDURE Coloriage;
  VAR n: INTEGER;
  BEGIN
    IF (typ=2) OR indm OR ncoul THEN
    BEGIN
      IF (ncoul AND (typ=2)) OR (Odd(yA) AND indm) THEN SetColor(Blue)
      ELSE SetColor(0);
      Line(xA,yA,xB,yA)
    END
    ELSE BEGIN
      IF xA=xB THEN
      BEGIN
        IF COMP=Round(pch) THEN PutPixel(xA,yA,Brown)
        ELSE PutPixel(xA,yA,0);
      END
      ELSE BEGIN
        IF xB<xA THEN Echange(xA,xB);
        FOR n:=xA TO xB DO
        BEGIN
          IF COMP=Round(pch) THEN
          BEGIN
            pch:=pch+freq;
            PutPixel(n,yA,Brown);
          END
          ELSE PutPixel(n,yA,0);
          Inc(COMP);
        END;
      END;
    END;
    Inc(cpt2);
  END;


BEGIN
  indm:=FALSE; ncoul:=FALSE;
  IF (pt[1,3]=mer) AND (pt[2,3]=mer) AND (pt[3,3]=mer) THEN indm:=TRUE
  ELSE BEGIN
    vn1:=v1[2]*v2[3]-v1[3]*v2[2];
    vn2:=v1[3]*v2[1]-v1[1]*v2[3];
    vn3:=v1[1]*v2[2]-v1[2]*v2[1];
    bary1:=(pt[1,1]+pt[2,1]+pt[3,1])/3;
    bary2:=(pt[1,2]+pt[2,2]+pt[3,2])/3;
    bary3:=(pt[1,3]+pt[2,3]+pt[3,3])/3;

    ncoul:= vn1*(bary1-xobs)+vn2*(bary2-yobs)+vn3*(bary3-zobs) >0;

    IF (NOT ncoul) AND (typ=3) THEN
    BEGIN
     xr:=bary1-xecl;
     yr:=bary2-yecl;
     zr:=bary3-zecl;
{ bary1 et bary2 servent ici de variables intérmédiaires }
     bary1:=vn1*xr+vn2*yr+vn3*zr;
     bary2:=ArcTan(Sqrt(
(Sqr(vn1)+Sqr(vn2)+Sqr(vn3))*(Sqr(xr)+Sqr(yr)+Sqr(zr))/Sqr(bary1)-1));
     IF bary1<0 THEN COMP:=Round((Pi-bary2)/fang)
     ELSE COMP:=Round(bary2/fang);
     IF COMP<>0 THEN freq:=15/COMP ELSE freq:=1e30;
    END
    ELSE freq:=0;
  END;

  Coord_Ecran(pt[1],x1,y1);
  Coord_Ecran(pt[2],x2,y2);
  Coord_Ecran(pt[3],x3,y3);

  IF (y2>=y1) AND (y2>=y3) THEN
  BEGIN
    Echange(x1,x2);
    Echange(y1,y2);
  END
  ELSE
    IF (y3>=y1) AND (y3>=y2) THEN
    BEGIN
      Echange(x1,x3);
      Echange(y1,y3);
    END;
  IF (y3>y2) THEN
  BEGIN
    Echange(x2,x3);
    Echange(y2,y3);
  END;

  ey1:=y1-y2; ey2:=y1-y3; ey3:=y2-y3;
  IF ey1<>0 THEN stp1:=(x1-x2)/ey1;
  IF ey2<>0 THEN stp2:=(x1-x3)/ey2;
  IF ey3<>0 THEN stp3:=(x2-x3)/ey3;
  IF freq=0 THEN pch:=1 ELSE pch:=Int(Random*freq+1.5);
  COMP:=1;
  cpt2:=0;
  FOR cpt1:=0 TO ey1 DO
  BEGIN
    yA:=y1-cpt1;
    IF ey1=0 THEN xA:=x2 ELSE xA:=Round(x1-cpt1*stp1);
    IF ey2=0 THEN xB:=x3 ELSE xB:=Round(x1-cpt2*stp2);
    Coloriage;
  END;
  FOR cpt1:=1 TO ey3 DO
  BEGIN
    xA:=Round(x2-cpt1*stp3);
    xB:=Round(x1-cpt2*stp2);
    yA:=y1-cpt2;
    Coloriage;
  END;
  IF ((typ=2) AND NOT(ncoul OR indm)) OR ((typ=3) AND ncoul) OR bord
  THEN BEGIN
    SetColor(1);
    Contour;
  END;
END;


{ calcule une facette pour typ=2 ou 3 }
PROCEDURE Facette(i1,j1,i2,j2,i3,j3: INTEGER; VAR v: vecteur);
VAR l: BYTE;
BEGIN
  Coord_Spatiales(i1,j1,pt[1]); v:=pt[1];
  Coord_Spatiales(i2,j2,pt[2]);
  FOR l:=1 TO 3 DO v[l]:=v[l]-pt[2,l];
  IF tst THEN tst:=FALSE
  ELSE BEGIN
    Coord_Spatiales(i3,j3,pt[3]);
    Facette2;
  END
END;


BEGIN  { MontsFractals }
  RestoreCRTMode;
  ecrx:=GetMaxX; ecry:=GetMaxY;
  IF typ=2 THEN bord:=FALSE;

  phi:=phi MOD 360; IF phi<0 THEN Inc(phi,360);
  ct:=Cos(theta*deg_rad); st:=Sin(theta*deg_rad);
  cp:=Cos(phi*deg_rad);   sp:=Sin(phi*deg_rad);
  cp_st:=cp*st; sp_st:=sp*st;
  cp_ct:=cp*ct; sp_ct:=sp*ct;
  xobs:=ray*cp_ct;
  yobs:=ray*sp_ct;
  zobs:=ray*st;

  IF typ=3 THEN
  BEGIN
    xecl:=r*Cos(alpha*deg_rad)*Cos(beta*deg_rad);
    yecl:=r*Cos(alpha*deg_rad)*Sin(beta*deg_rad);
    zecl:=r*Sin(alpha*deg_rad);
  END;

{* si c'est la première fois ou si on a changé qqch à la définition
de la matrice, on la régénère }
  dn:=1; FOR i:=1 TO mail DO dn:=dn*2; Inc(dn);  { dn=2^mail+1 }
  tst:=Premiere OR (_alea<>alea) OR (_dn<>dn) OR (_prof<>prof);
  IF tst THEN Genere_Matrice;
{* ce n'est plus la première fois: les valeurs _???? sont valides }
  Premiere:=FALSE;
  _alea:=alea;  { on actualise les valeurs }
  _dn:=dn;
  _prof:=prof;

{* si on a calculée une nouvelle matrice (generee=TRUE) ou si on a
changé qqch à la position de l'observateur, on recalcule le centrage }
  IF (_ray<>ray) OR (_theta<>theta) OR (_phi<>phi) OR tst
  THEN Centrage_Ecran;
  _ray:=ray;
  _theta:=theta;
  _phi:=phi;

  SetGraphMode(GraphMode);   { positionne le mode graphique }
  ClearViewPort;

  IF (typ<>2) AND (typ<>3) THEN  { i.e.:  typ=1 }
  BEGIN
    SetColor(7);
    FOR i:=1 TO dn-1 DO
      FOR j:=1 TO dn-i DO
      BEGIN
        Coord_Spatiales(i+1,  j,v1); Coord_Ecran(v1,x1,y1);
        Coord_Spatiales(  i,  j,v1); Coord_Ecran(v1,x2,y2);
        Coord_Spatiales(  i,j+1,v1); Coord_Ecran(v1,x3,y3);
        Contour;
      END
  END
  ELSE BEGIN
    IF phi<60 THEN
      FOR i:=2 TO dn DO
      BEGIN
        tst:=TRUE;
        FOR j:=dn-i+1 DOWNTO 1 DO
        BEGIN
          Facette(j+1,i-1,  j,  i,j+1,  i,v1);
          Facette(  j,i-1,  j,  i,j+1,i-1,v2);
        END
      END
    ELSE
      IF phi<120 THEN
        FOR i:=2 TO dn DO
        BEGIN
          tst:=TRUE;
          FOR j:=1 TO dn-i+1 DO
          BEGIN
            Facette(  j,i-1,  j,  i,j-1,  i,v2);
            Facette(j+1,i-1,  j,  i,  j,i-1,v1);
          END
        END
      ELSE
        IF phi<180 THEN
          FOR i:=2 TO dn DO
          BEGIN
            tst:=TRUE;
            FOR j:=1 TO dn-i+1 DO
            BEGIN
              Facette(i-1,  j,  i,  j,  i,j-1,v1);
              Facette(i-1,j+1,  i,  j,i-1,  j,v2);
            END
          END
      ELSE
        IF phi<240 THEN
          FOR i:=2 TO dn DO
          BEGIN
            tst:=TRUE;
            FOR j:=dn-i+1 DOWNTO 1 DO
            BEGIN
              Facette(i-1,j+1,  i,  j,  i,j+1,v2);
              Facette(i-1,  j,  i,  j,i-1,j+1,v1);
            END
          END
        ELSE
          IF phi<300 THEN
            FOR i:=dn-1 DOWNTO 1 DO
            BEGIN
              tst:=TRUE;
              FOR j:=1 TO i DO
              BEGIN
                k:=i+1-j;
                Facette(  j,k+1,  j,  k,j-1,k+1,v1);
                Facette(j+1,  k,  j,  k,  j,k+1,v2);
              END
            END
          ELSE
            IF phi<360 THEN
              FOR i:=dn-1 DOWNTO 1 DO
              BEGIN
                tst:=TRUE;
                FOR j:=i DOWNTO 1 DO
                BEGIN
                  k:=i+1-j;
                  Facette(j+1,  k,  j,  k,j+1,k-1,v2);
                  Facette(  j,k+1,  j,  k,j+1,  k,v1);
                END
              END
  END;

  SetColor(1);
END;  { MontsFractals }


procedure ModifiePalette;
begin
   setpalette(brown,123);
end;


VAR
  temps: LONGINT; c:char; theta,phi,incr:integer; s,t:string[50];

BEGIN
  InitGraphique;                     theta:=1; phi:=38; incr:=3;
  repeat
    MontsFractals(5,60,-1200, 38, 1,9000, 40,270,12000,FALSE, 2,5505);
    str(phi:5,s); str(theta:5,t); s:=s+'  '+t; str(incr:5,t); s:=s+'  '+t;
    outtextxy(0,471,s);
    c:=upcase(readkey);
    case c of
      'W':dec(phi,incr);
      'X':inc(phi,incr);
      'N':inc(theta,incr);
      'B':inc(theta,incr);
      '+':inc(incr);
      '-':dec(incr);
    end;
  until c=#27;

  CloseGraph;
END.
