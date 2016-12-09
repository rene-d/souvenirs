program euler;

uses modubase,crt;

var x,y,yp,x1,y1,yp1:real;
    i:integer;

begin
 initgraphique;
 fenetre(0,2,0,50);
 x_axe(0,0,0.1);
 y_axe(0,0,1);
 x:=0;
 y:=1;
 croix(x,y);
 repeat
  begin
    yp:=2*y+x*x;
    x:=x+0.01;
    y:=y+0.01*yp;
    trace(x,y);
  end;
 until (x>2);
 pausegraphique;

 x:=0;
 y:=1;
 croix(x,y);
 repeat
   begin
     x1:=x+0.005;
     yp1:=2*y+x*x;
     y1:=y+0.005*yp1;
     yp:=2*y1+x1*x1;
     y:=y+0.01*yp;
     x:=x+0.01;
     trace(x,y);
   end;
 until(x>2);
pausegraphique;
end.