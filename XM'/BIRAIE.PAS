{$I g640c350.ega}
{$I graphe.lib}
{$I imprime.pas}
{$R+}

var sig1,sig2,sig01,sig02,L01,L02,c1,c2,dsig,L0,c,sig0,deltasig,z:real;
    m,l :integer;
    sig,Lu:array[0..200]of real;

Function Lum (var z :real):real;

    begin

     Lum:=L01*exp(-sqr((z-sig01)/c1))+L02*exp(-sqr((z-sig02)/c2));

    end;
Begin
   write('valeur centrale de la bande spectrale:');
   readln(sig0);
   write('largeur de la bande spectrale:');
   readln(deltasig);
   sig1:=sig0-deltasig*0.5;
   writeln('sig1=',sig1:8:6);
   sig2:=sig0+deltasig*0.5;
   writeln('sig2=',sig2:8:6);
   writeln('centre de la premiäre raie:');
   readln(sig01);
   writeln('centre de la deuxiäme raie:');
   readln(sig02);
   write('luminance maximale premiäre raie:');
   readln(L01);
   write('luminance maximale deuxiäme raie:');
   readln(L02);
   write('coefficient d''etendue premiäre raie:');
   readln(c1);
   write('coefficient d''ätendue deuxiäme raie:');
   readln(c2);

     initgraphique;
     couleur (15);
     fenetre(sig1,sig2,0.0,1.20);
     x_axe(0.0,0.0,1E+3);
     y_axe(sig0,0.0,0.1);
     deplace(sig1,0.0);
     dsig:=(sig2-sig1)/200.0;
     for m:=0 to 200 do begin
        sig[m]:=sig1+dsig*m;
        z:=sig[m];
        Lu[m]:=Lum(z);
        trace (sig[m],Lu[m]);
        end;
     pausegraphique;
     writeln('sig1=',sig1:8:6);
     writeln('sig2=',sig2:8:6);
     writeln('sig01=',sig01:8:6);
     writeln('sig02=',sig02:8:6);
     writeln('L01=',L01:8:6);
     writeln('L02=',L02:8:6);
     writeln('c1=',c1:8:6);
     writeln('c2=',c2:8:6);
     write('voulez_vous une hardcopy(1):');
     readln(l);
     if(l =1)then begin
        hardcopy(false);
     end;
  end.
