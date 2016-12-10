{$R-,S+,I+,D+,F-,V+,B-,N-,L+ }
{$M 16384,0,30000 }
uses dos,polynm,modes;

var p:polynome;fichier:text;i,j:integer;

procedure zdeg1(a:real);
var s:string;
begin
  if abs(a)<polynm.zero then a:=0;
  s:='zéro réel : '+form(a);
  writeln(s,'   différence',valeur(p,a));
  if valeur(p,a)>sqrt(polynm.zero) then writeln(fichier,strp(p,'x '));
end;

procedure zdeg2(a,b:real);
var s:string;       p2,q:polynome;
begin
  if abs(a)<=polynm.zero then a:=0;
  if abs(b)<=polynm.zero then b:=0;
  if sqr(a)-4*b >=- polynm.zero then begin writeln('Erreur dans ZDEG2'); halt; end;
  s:='p de degré 2 : 1 '+form(a)+' '+form(b);
  write(s);
  deg2(p2,1,a,b);divise(p,p2,p2,q);
  if abs(q.coef[0])<=sqrt(polynm.zero) then begin q.coef[0]:=0;elimine(q); end;
  writeln('    '+strp(q,''));
  if q.deg<>-1 then writeln(fichier,strp(p,'x '));
end;


function sqrcub(x:real):real; { retourne la racine cubique d'un réel }
var y:real;
begin
  y:=exp(ln(abs(x))/3); if x<0 then y:=-y;
  sqrcub:=y;
end;

function ASIN(x:real):real; forward;

FUNCTION ACOS(X:REAL):REAL;
BEGIN
  IF ABS(X)<0.7 THEN ACOS:=pi/2-ASIN(X)
  ELSE
    IF X>0 THEN IF X<=1 THEN ACOS:=ARCTAN((sqrt(1/sqr(x)-1))) ELSE halt
    ELSE ACOS:=pi-ACOS(-X);
END;

FUNCTION ASIN;
BEGIN
  IF ABS(X)>0.7
    THEN ASIN:=pi/2-ACOS(X)
    ELSE ASIN:=ARCTAN(x/sqrt(1-sqr(x)));
END;


{ trouve les zéros d'un polynôme de degré 2, 3 ou 4
  sort les résultats avec la procédure ZDEG1 ou ZDEG2 }

procedure zeros(px:polynome);
  function discriminant(b,c:real):real; begin end;
const pi2s3=2.09439510239;   { 2*pi/3 }
var
  delta,b:real;
  d,e,p,q,r,f,g,s,m,l,t,z:real;
  qx1,qx2:polynome;
begin
  unitaire(px);  { px.coef[0]=1 }
  afficheln(px,'x');
  with px do
  begin
    b:=-coef[1]/deg;  { "changement" d'indéterminée commun }
    case deg of
      -1,0: begin writeln('Erreur dans la procédure Zéros'); HALT; end;
      1 : zdeg1(b);
      2 : begin
            delta:=sqr(b)-coef[2]; if abs(delta)<=polynm.zero then delta:=0;
            d:=sqrt(abs(delta));
            if delta<0 then zdeg2(coef[1],coef[2])
            else {if delta=0 then zdeg1(b)
              else} begin
                zdeg1(b-d);
                zdeg1(b+d);
              end;
          end;

      3 : begin
            p:=-3*sqr(b)+coef[2];
            q:=-2*b*sqr(b)+b*coef[2]+coef[3];   { X^3+pX+q=P(X+b) }

            d:=p*sqr(p)/27+sqr(q)/4;   { discriminant de X^3+pX+q }
            if abs(d)<zero then d:=0;
            if d<0 then
            begin
              m:=2*sqrt(-p/3);
              t:=ACOS(- 4*q/ (m*m*m) )/3;
              zdeg1(m*cos(t+pi2s3)+b);
              zdeg1(m*cos(t-pi2s3)+b);
              zdeg1(m*cos(t)+b);
            end
            else begin
              r:=sqrcub(-q/2+sqrt(d))+sqrcub(-q/2-sqrt(d))+b;
              zdeg1(r);
              deg1(qx1,1,-r); divise(px,qx1,px,qx2);
              zeros(px);             { px est alors de degré 2 }
            end;
          end;

      4 : begin
            e:=-coef[1]/4;   { changement d'indéterminée Y:=X+e }
            b:=-e;
            p:=coef[2]-6*sqr(b);
            q:=coef[3]+2*b*(4*sqr(b)-coef[2]);
            r:=coef[4]-coef[3]*b+coef[2]*sqr(b)-3*sqr(sqr(b));
{ P(X)  =  X^4 + pX^2 + qX + r }
           if abs(q)<=polynm.zero then q:=0;
           if q=0 then { si polynôme bicarré }
            begin
              delta:=discriminant(p,r);
              if delta<0 then
              begin
                r:=system.sqrt(r);
                if p-2*r<-polynm.zero then
                begin                                                                                         writeln('xx');
                  deg2(qx1,1,(2*r-p),b); zeros(qx1);
                  deg2(qx1,1,(p-2*r),b); zeros(qx1);
                end else
                if p+2*r<-polynm.zero then
                begin                                      writeln('xx');
                  deg2(qx1,1,(2*r+p),-b); translate(qx1,-0); zeros(qx1);
                  deg2(qx1,1,-(2*r+p),-b); translate(qx1,-0); zeros(qx1);
                end else write('2',#7);
              end
              else begin
                delta:=sqrt(delta);
                deg2(qx1,1,0,(p-delta)/2); translate(qx1,-e); zeros(qx1);
                deg2(qx1,1,0,(p+delta)/2); translate(qx1,-e); zeros(qx1);
              end
            end
            else begin   write('1',#7);
              f:=-4*r-sqr(p)/3;
              g:=8*r*p/3-sqr(q)-2*p*sqr(p)/27;
              s:=0;
              if g<>0 then
              begin
                l:=4*f*f*f/27+g*g;
                if l<0 then s:=2*sqrt(-f/3)*cos((pi/2+arctan(g/sqrt(-l))/3))
                else begin l:=sqrt(l); s:=sqrcub((l-g)/2)-sqrcub((l+g)/2); end;
                s:=s+p/3;
                m:=sqr(s)-4*r;
              end;
            end;
          end;
    end; { case deg of }
  end; { with px do }
end; { procedure zeros }


procedure ran(var p:polynome;d:integer);
 var i:integer;
begin
  with  p do begin
    deg:=d;
    repeat coef[0]:=random*1000-500; until coef[0]<>0;
    for i:=1 to d do coef[i]:=random*1000-500;
  end;
end;

begin
  assign(fichier,'erreur.pas');
  rewrite(fichier);              sci(3);
  chaine('1  1 0 1',p);
  for j:=3 to 3 do for i:=1 to 1 do begin ran(p,j); zeros(p); writeln;end;
  close(fichier);
{  exec('a:command.com','/Ctype b:erreur.pas');}
end.
