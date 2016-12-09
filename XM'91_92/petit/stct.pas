program reponse_a_un_echelon ;

{$i g640c350.ega }
{$i graphe.lib }
{$i d:imprime.pas }

type tableau=array[1..2] of real ;

const dt=1e-5 ;
      ve=1.0  ;
       k=1.0  ;
      Rp=40000.0 ;
       R=20000.0 ;
      R1=10000.0 ;
      C2=1e-9 ;
      w1=2127.659574 ;
      w2=10000.0 ;
      vd=1.0 ;

var h,eps,tmax,t : real ;
    n : integer ;
    v : tableau ;

function vep(t:real):real ;
var z:real;
begin
  z:=-t/dt;
  if (z>40) then begin
    vep:=0;
  end
  else if (z<-40) then begin
    vep:=0;
  end
  else begin
    z:=exp(z);
    vep:=ve*z/(dt*sqr(1+z)) ;
  end;
end ;

procedure f(var n:integer ; var t:real ; var x,dx:tableau ) ;
begin
  dx[1]:=x[2] ;
  dx[2]:=k*rp/(r*r1*c2)*vep(t)+w1*w2*k*vd-(w1+w2)*x[2]-w1*w2*x[1] ;
end ;

{$i runge.pas }

begin
  write('tmax : ') ; readln(tmax) ;
  write('h : ') ; readln(h) ;
  t:=-1e-3 ;
  v[1]:=0 ;
  v[2]:=0 ;
  n:=2 ;
  eps:=1e-8 ;
  initgraphique ;
  couleur(15) ;
  fenetre(-0.001,tmax,-1,15) ;
  x_axe(0,0,0.01) ;
  y_axe(0,0,5) ;
  deplace(-0.001,0) ;
  repeat
      runge(n,eps,h,t,v) ;
      trace(t,v[1]) ;
  until t>tmax ;
end.
