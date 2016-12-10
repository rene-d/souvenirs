uses crt,polynm;

type
  dcp=record
    nb:word;
    zero:array[1..MaxPoly] of record
      re,im:real;
    end;
    ordre:array[1..MaxPoly] of word;
  end;

const
  epsilon:real=1E-10;


procedure BAIRSTOW(po:polynome;var zeros:dcp);

var
  nb_deci:word;

procedure reglage(var r:real);
var
  e:integer;
  y:byte;
  r1:real;
  s:string;
  c:char;
begin
  y:=wherey;
  repeat
    val(mant(r),r1,e); str(r1:1:nb_deci,s); s:=s+'E'+xpon(r);
    gotoxy(1,y);
    write('[',r,'] RND ',nb_deci:2,' (+,-) : ',s); clreol;
    repeat
      c:=readkey;
    until (c='-') or (c='+') or (c=^C) or (c=^M) or (c=^J);
    if c=^C then begin writeln('  Avorté'); exit; end;
    if (c='-') and (nb_deci>0) then dec(nb_deci);
    if c='+' then inc(nb_deci);
  until (c=^M) or (c=^J);
  val(s,r1,e);
  if e<>0
  then writeln('  Erreur')
  else begin
    gotoxy(1,y); clreol;
    r:=r1;
  end;
end;


procedure undeplus(a:byte;var p,q:real);
var
  d:real;
  z:polynome;
begin
  with zeros do begin
    inc(nb);
    with zeros.zero[nb]
    do if a=0
      then begin
        r:=-q/p; i:=0;
        reglage(r);
      end
      else begin
        write('L''algorithme a trouvé le polynôme ');
        deg2(z,1,p,q);afficheln(z,'X');
        reglage(p); reglage(q);
        d:=sqr(p)-4*q;
        if d>=0 then begin
          d:=sqrt(d); r:=(-p-d)/2; i:=0;
          inc(nb); zero[nb].r:=(-p+d)/2; zero[nb].i:=0;
        end else
        begin
          r:=p;
          i:=q;
        end;
      end;
  end;
end;

procedure trouve(p,q,e:real);
var
    a,b,c:coefficients;
    t,y,z,v,d,u:real;
    s,n,i,j,k:word;

begin
  unitaire(po);
  a:=po.coef; n:=po.deg;
  zeros.nb:=0;
  if (n=2) or (n=1) then begin undeplus(n-1,a[n-1],a[n]); exit; end;
  repeat
    j:=0;

    repeat
      b[0]:=a[0]; b[1]:=a[1]-p*b[0];
      for k:=2 to n do b[k]:=a[k]-p*b[k-1]-q*b[k-2];

      c[0]:=b[0]; c[1]:=b[1]-p*c[0];
      for k:=2 to n-2 do c[k]:=b[k]-p*c[k-1]-q*c[k-2];
      c[n-1]:=-p*c[n-2]-q*c[n-3];

      d:=sqr(c[n-2])-c[n-1]*c[n-3];
      u:=b[n-1]*c[n-2]-b[n]*c[n-3];
      v:=b[n]*c[n-2]-b[n-1]*c[n-1];

      if d=0 then begin write('La méthode est inadaptée'); halt; end;

      y:=u/d; z:=v/d; p:=p+y; q:=q+z;
      inc(j);
    until (j>=200) or ((abs(y)+abs(z))<E);

    if j>=200
    then begin write('Le calcul demande trop d''itérations...'); halt; end;

    undeplus(1,p,q);
    dec(n,2);
    a:=b;
  until n<=2;

  if n=2 then undeplus(1,p,q);
  if n=1 then undeplus(0,b[0],b[1]);

end;


begin
  nb_deci:=10;
  trouve(0,0,1E-10);
end;


var j:word;po,p:polynome;zeros:dcpr;
begin
  chaine('1 -4 -8 4 4 -1',po); affiche(po,'X');
  bairstow(po,zeros);
  with zeros do for j:=1 to nb do with zero[j] do
    if i=0 then writeln(r) else begin writeln('1 ' ,r,'  ',i); end;
end.
