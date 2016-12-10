program FRACTALES;

{ dessin de fractales, leur graine étant un trait brisé continu }
{ RENE DEVICHI - 2 juin 1990 - Le Luc                           }
{ Turbo Pascal 4.0                                              }
{ le 7 juin                                                     }

uses Crt,Graph,grecr; { remplacer par GrTrc pour l'imprimante }

type
  point2D=record
                x,y:real;
          end;
const
  nFract:integer=1;

var
  gen:array[0..15] of point2D;  { points de la fractale }
  longGen:integer;
  seg1,seg2:point2D;            { segment de la graine  }
  sens:array[0..14] of boolean;
  premier,              { pour Deplace au lieu de Trace             }
  stoppe:boolean;       { indique si on arrête le programme par ESC }

function randomboolean:boolean; { générartion aléatoire de booléens }
begin                           { éventuellement pour le "sens"     }
  randomboolean:=random>=0.5
end;


procedure initFract;
begin
    case nFract of

      1 : begin
        (* «courbe de Mandelbrot» : courbe qui remplit l'«île de Vonkoch» *)
        longgen:=13;
        gen[ 0].x:=   -1;   gen[ 0].y:= 0;            sens[ 0]:=false;
        gen[ 1].x:= -2/3;   gen[ 1].y:= sqrt(3)/3;    sens[ 1]:=true;
        gen[ 2].x:= -1/3;   gen[ 2].y:= 2*sqrt(3)/3;  sens[ 2]:=true;
        gen[ 3].x:=  1/3;   gen[ 3].y:= 2*sqrt(3)/3;  sens[ 3]:=true;
        gen[ 4].x:=  2/3;   gen[ 4].y:= sqrt(3)/3;    sens[ 4]:=true;
        gen[ 5].x:=  1/3;   gen[ 5].y:= 4*sqrt(3)/9;  sens[ 5]:=false;
        gen[ 6].x:=    0;   gen[ 6].y:= 5*sqrt(3)/9;  sens[ 6]:=false;
        gen[ 7].x:= -1/3;   gen[ 7].y:= 4*sqrt(3)/9;  sens[ 7]:=false;
        gen[ 8].x:= -1/3;   gen[ 8].y:= 2*sqrt(3)/9;  sens[ 8]:=true;
        gen[ 9].x:=  1/3;   gen[ 9].y:= 2*sqrt(3)/9;  sens[ 9]:=true;
        gen[10].x:=    0;   gen[10].y:= sqrt(3)/9;    sens[10]:=false;
        gen[11].x:= -1/3;   gen[11].y:= 0;            sens[11]:=false;
        gen[12].x:=  1/3;   gen[12].y:= 0;            sens[12]:=true;
        gen[13].x:=    1;   gen[13].y:= 0;
        seg1:=gen[0];
        seg2:=gen[longgen];
      end;

      2 : begin
        (* courbe de Von Koch *)
        longgen:=4;
        gen[ 0].x:=   -1;   gen[ 0].y:= 0;            sens[ 0]:=true;
        gen[ 1].x:= -1/3;   gen[ 1].y:= 0;            sens[ 1]:=true;
        gen[ 2].x:=    0;   gen[ 2].y:= sqrt(3)/3;    sens[ 2]:=true;
        gen[ 3].x:=  1/3;   gen[ 3].y:= 0;            sens[ 3]:=true;
        gen[ 4].x:=    1;   gen[ 4].y:= 0;
        seg1:=gen[0];
        seg2:=gen[longgen];  { if faut que seg2.y=seg1.y }
      end;

    3 : begin
        (* courbe de Peano *)
        longgen:=9;
        gen[ 0].x:=   -3;   gen[ 0].y:= 0;            sens[ 0]:=true;
        gen[ 1].x:=   -1;   gen[ 1].y:= 0;            sens[ 1]:=true;
        gen[ 2].x:=   -1;   gen[ 2].y:= 2;            sens[ 2]:=true;
        gen[ 3].x:=    1;   gen[ 3].y:= 2;            sens[ 3]:=true;
        gen[ 4].x:=    1;   gen[ 4].y:= 0;            sens[ 4]:=true;
        gen[ 5].x:=    1;   gen[ 5].y:=-2;            sens[ 5]:=true;
        gen[ 6].x:=   -1;   gen[ 6].y:=-2;            sens[ 6]:=true;
        gen[ 7].x:=   -1;   gen[ 7].y:= 0;            sens[ 7]:=true;
        gen[ 8].x:=    1;   gen[ 8].y:= 0;            sens[ 8]:=true;
        gen[ 9].x:=    3;   gen[ 9].y:= 0;
        seg1:=gen[0];
        seg2:=gen[longgen];         { if faut que seg2.y=seg1.y }
      end;

    end;
end;

procedure pause;
begin
  if readkey=#0 then;
end;


procedure dessine(ori,ext:point2D;sensf:boolean;ordre:integer);
var
  C,S,A,B,m,dsx,dsy,dx,dy:real;
  i:integer;
  anti:shortint;
begin
  if not stoppe then
  begin
{ calcul coefficients de la transformation :
  [seg1,seg2] --> [ori,ext] }
      if sensf then anti:=1 else anti:=-1;
{ sensf=true  => similitude directe;
  sensf=false => similitude indirecte }
      dsx:=seg1.x-seg2.x;
      dsy:=seg1.y-seg2.y;
      m:=sqr(dsx)+sqr(dsy);
      dx:=ori.x-ext.x;
      dy:=ori.y-ext.y;
      C:=(dsx*dx+dsy*dy*anti)/m;
      S:=(dsx*dy-dsy*dx*anti)/m;
      A:=ori.x-(C*seg1.x-S*seg1.y*anti);
      B:=ori.y-(S*seg1.x+C*seg1.y*anti);
     { on a : x' = C*x-S*y*anti+A  et  y' = S*x+C*y*anti+B }

      if ordre<=0 then  { ordre=0 => fractale = sa graine }
      begin
        if premier then
        begin
          with gen[0] do deplace(C*x-S*y*anti+A,S*x+C*y*anti+B);
          premier:=false;
        end;
        for i:=1 to longGen do
          with gen[i] do
          begin
            { setcolor(i+1); }
            trace(C*x-S*y*anti+A,S*x+C*y*anti+B);
          end;
      end

      else begin
        for i:=1 to longGen do
        begin
          if keypressed then if readkey=#27 then
          begin
            stoppe:=true;
            EXIT;
          end;
          with gen[i-1] do  { calcul nouvelles origine et extrêmité }
          begin
            ori.x:= C*x-S*y*anti+A;
            ori.y:= S*x+C*y*anti+B;
          end;
          with gen[i] do
          begin
            ext.x:= C*x-S*y*anti+A;
            ext.y:= S*x+C*y*anti+B;
          end;
          dessine(ori,ext,not(sens[i-1] xor sensf),pred(ordre));
{ dessine la fractale à l'ordre précédent dans le bon sens }
        end;
      end;
  end;
end;

procedure dessineFractale(ori,ext:point2D;ordre:integer);
begin
  stoppe:=false;
  premier:=true;
  dessine(ori,ext,true,ordre);
end;

{ dessine la courbe fractale dans le repère de la graine }
procedure ordre(n:integer);
begin
  dessineFractale(seg1,seg2,n);
end;

procedure VONKOCH(n:integer);
var
  s1,s2,s3:point2D;
begin
  nFract:=2;
  initFract;
  fenetre(-1,1,-1,1);
  s1.x:=0;            s1.y:=-1;
  s2.x:=cos(5*pi/6);  s2.y:=sin(5*pi/6);
  s3.x:=cos(pi/6);    s3.y:=sin(pi/6);
  dessineFractale(s1,s2,n);
  dessine(s2,s3,true,n);
  dessine(s3,s1,true,n);
end;

procedure PEANO(n:integer);
begin
  nFract:=3;
  initFract;
  fenetre(-3,3,-3,3);
  ordre(n);
end;

procedure MANDELBROT(n:integer);
var
  s1,s2:point2D;
begin
  nFract:=1;
  initFract;
  fenetre(-1.155,1.15500,-0.5775,1.7325);
  s1.x:=-1; s1.y:=0;
  s2.x:= 1; s2.y:=0;
  dessinefractale(s1,s2,n);
{  deplace(-1,0); trace(-1,-0.577); trace(1,-0.5775); trace(1,0);}
end;

  var i:word;
begin
  initgraphique(0);
  mandelbrot(2);
  pause;
  closegraph;
end.

