10 '
20 '
30 '
40 '
50 '
60 '
70 '
80 '
85 input "nom du fichier image : ",nomf$
90 key off
100 screen 2
110 window(0,0)-(639,199)
120 coef=3.1415926535/180
130 fang=3.1415926535/15
140 defint n
150 dim v1(3),v2(3),vecl(3),vobs(3),pt(3,3),xe(3),ye(3),bary(3),c(3)
160 cls
170 input "Degré de maillage (0 à 7)     : ",mail
180 input "Indice de profil (1 à 100)    : ",prof
190 input "Type aléatoire (0 à 32000)    : ",alea
200 input "Elévation du niveau de la mer : ",mer
210 print
220 input "Angle de vision vertical Theta (-90<Theta<90)  : ",theta
230 input "Angle de vision horizontal Phi (0<Phi<360)     : ",phi
240 input "Distance de l'observateur à l'origine ( >5000) : ",ray
250 ct=cos(theta*coef) : st=sin(theta*coef)
260 cp=cos(phi*coef) : sp=sin(phi*coef)
270 xobs=ray*ct*cp
280 yobs=ray*ct*sp
290 zobs=ray*st
300 print : print "Sélectionnez un type de tracé"
310 print"  1. Rapide"
320 print"  2. parties cachées"
330 print"  3. Surface éclairée"
340 input" > ",type
350 if type<>3 then 450
360 print
370 input"Angle vertical d'éclairage Alpha (-90<Alpha<90)      : ",alpha
380 input"Angle horizontal d'éclairage Bêta (0<Bêta<360)       : ",beta
390 input"Distance de la source lumineuse à l'origine ( >5000) : ",r
400 alpha=alpha*coef : beta=beta*coef
410 xecl=r*cos(alpha)*cos(beta)
420 yecl=r*cos(alpha)*sin(beta)
430 zecl=r*sin(alpha)
440 input"Désirez-vous les contours des facettes ? (O/N) : ",bord$
450 locate 23,17 : print "Les calculs sont en cours : veuillez patienter"
460 tpav=timer
465 temps1$=time$
470 gosub 2630 : gosub 2950
480 rem
490 rem ********************************
500 rem   Sous-programmes d'affichage
510 rem ********************************
520 cls
530 if type=1 then gosub 1840 : goto 570
540 if phi>=120 and phi<240 then gosub 630 : goto 570
550 if phi<120 then gosub 1030 : goto 570
560 gosub 1430
570 beep
573 temps2$=time$
574 lprint "temps écoulé"
575 lprint "départ  : ",temps1$
576 lprint "fin	    : ",temps2$
577 lprint "sauvegarde sous le nom : ",nomf$
578 def seg=&hb800 : bsave nomf$,0,&h3FFF
580 temps=int(timer-tpav+.5)
585 heu=int(temps/3600) : minu=int(temps/60) mod 60 : sec=temps mod 60
590 a$=inkey$
600 if a$=chr$(13) then locate 1,1 : input "",nom$ : beep : def seg=&hb800 : bsave nom$,0,&h3FFF
610 if a$="t" or a$="T" then locate 2,6 : print minu;"min ";sec;"s" : if heu<>0 then locate 2,1 : print heu;"h"
615 if a$="s" or a$="S" then screen 0 : end
620 goto 590
630 if phi<180 then deb=1 : sens=1 : else fin=1 : sens=-1
640 for i=2 to dn
650   tst=0 : if phi<180 then fin=dn-i+1 : else deb=dn-i+1
660   for j=deb to fin step sens
670     if phi<180 then gosub 710 : gosub 870 else gosub 870 : gosub 710
680   next j
690 next i
700 return
710 ci=i-1 : cj=j : gosub 3320
720 for l=1 to 3
730   v1(l)=c(l) : pt(1,l)=c(l)
740 next l
750 ci=i : gosub 3320
760 for l=1 to 3
770   v1(l)=v1(l)-c(l) : pt(2,l)=c(l)
780 next l
790 if tst=0 then tst=1 : goto 860
800 if phi<180 then cj=j-1 else cj=j+1 : ci=i-1
810 gosub 3320
820 for l=1 to 3
830   pt(3,l)=c(l)
840 next l
850 gosub 2020
860 return
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
2630 randomize alea
2640 dn=2^mail+1 : pas=dn-1 : ech=4000
2650 dim noeud(dn,dn)
2660 while pas>1
2670   for i=1 to dn-pas step pas
2680     for j=1 to dn-i-pas+1 step pas
2690       a=i+pas/2 : b=j+pas/2 : c=i+pas : d=j+pas
2700       gosub 2870
2710       noeud(i,b)=(noeud(i,j)+noeud(i,d))/2+alt
2720       gosub 2870
2730       noeud(a,j)=(noeud(i,j)+noeud(c,j))/2+alt
2740       gosub 2870
2750       noeud(a,b)=(noeud(c,j)+noeud(i,d))/2+alt
2760     next j
2770   next i
2780   pas=pas/2
2790   ech=ech/2
2800 wend
2810 return
2820 rem
2830 rem ********************************
2840 rem   Calcul aléatoire d'altitudes
2850 rem ********************************
2860 rem
2870 alt=rnd*ech
2880 if rnd>prof/100 then alt=-alt
2890 return
2900 rem
2910 rem ****************************************
2920 rem   Sous-programme de calcul du centrage
2930 rem ****************************************
2940 rem
2950 xemin=1000 : yemin=1000
2960 xemax=-1000 : yemax=-1000
2970 if mail>5 then stp=2^(mail-5) else stp=1
2980 for i=1 to dn step stp
2990   for j=1 to dn-i+1 step stp
3000     ci=i : cj=j
3010     gosub 3220
3020     if xe<xemin then xemin=xe
3030     if xe>xemax then xemax=xe
3040     if ye<yemin then yemin=ye
3050     if ye>yemax then yemax=ye
3060   next j
3070 next i
3080 ecrx=600 : ecry=190
3090 rap=2.62
3100 echx=ecrx/(xemax-xemin)/rap
3110 echy=ecry/(yemax-yemin)
3120 if echy<echx then echx=echy
3130 echy=echx : echx=echx*rap
3140 xcent=(640-echx*(xemax+xemin))/2
3150 ycent=(200-echy*(yemax+yemin))/2
3160 return
3170 rem
3180 rem ************************************
3190 rem   Calcul de coordonnées de l'écran
3200 rem ************************************
3210 rem
3220 gosub 3320
3230 d=c(1)*cp*ct+c(2)*sp*ct+c(3)*st-ray
3240 xe=(c(1)*sp-c(2)*cp)/d
3250 ye=(c(1)*cp*st+c(2)*sp*st-c(3)*ct)/d
3260 return
3270 rem
3280 rem ************************************
3290 rem   Calcul des coordonnées spatiales
3300 rem ************************************
3310 rem
3320 c(1)=((1-ci)/(dn-1)+1/3)*4000*sqr(3)
3330 c(2)=((cj-1)+(ci-1)/2)*8000/(dn-1)-4000
3340 c(3)=noeud(ci,cj)
3350 if c(3)<mer then c(3)=mer
3360 return
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
