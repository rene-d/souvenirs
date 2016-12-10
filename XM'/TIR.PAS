program runge_kutta;

type
  p2d=array[1..2] of real;

const
  a=0.0;
  b=1.0;

function f(x,y,yp:real):real;
begin
{  f:=exp(y); }
f:=2*y*y*y;
end;



procedure ff(t:real;X:p2d;var Y:p2d);
begin
  y[1]:=x[2];
  y[2]:=f(t,x[1],x[2]);
end;

procedure runge(var y:p2d;a,b:real;n:integer);
var
  t,h:real;
  arg,k1,k2,k3,k4:p2d;
  j:integer;
begin
  h:=(b-a)/n;
  t:=a;
  for j:=1 to n do
  begin
    ff(t,y,k1);

    arg[1]:=y[1]+h*k1[1]/2;
    arg[2]:=y[2]+h*k1[2]/2;
    ff(t+h/2,arg,k2);

    arg[1]:=h*y[1]+k2[1]/2;
    arg[2]:=h*y[2]+k2[2]/2;
    ff(t+h/2,arg,k3);

    arg[1]:=y[1]+h*k3[1];
    arg[2]:=y[2]+h*k3[2];
    ff(t+h,arg,k4);

    y[1]:=y[1]+h/6*(k1[1]+2*k2[1]+2*k3[1]+k4[1]);
    y[2]:=y[2]+h/6*(k1[2]+2*k2[2]+2*k3[2]+k4[2]);

    t:=t+h;
  end;
end;

function runge2(a,b,y0,alpha:real):real;
var
  y:p2d;
begin
  y[1]:=y0;
  y[2]:=alpha;
  runge(y,a,b,26);
  runge2:=y[2];     { renvoie la valeur y'(b) }
end;




procedure tir(AA,BB:real);
var
  a0,a1,a2:real;
  b0,b1:real;
begin
  a0:=0; a1:=1;

  repeat
    b0:=runge2(a,b,a,a0);
    b1:=runge2(a,b,a,a1);
    a2:=a0+(a1-a0)*(bb-b0)/(b1-b0);
    a0:=a1;
    a1:=a2;
  until  abs(bb-b1)<=0.000001;

  writeln(a1);
end;

begin
writeln(runge2(1,2,1,-1));
end.