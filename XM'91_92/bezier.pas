program BezierRationnelle;

uses ModuBase;


const
  max_n=20;


type
  p2D=record x,y:real; end;
  __p=array[0..max_n] of p2D;
  __w=array[0..max_n] of real;


var
  n:integer;
  P:__p;
  w:__w;
  eps:real;



procedure Bezier(t:real;var Bp:p2D);
var
  Prj:array[0..max_n] of __p;
  wrj:array[0..max_n] of __w;
  r,j:integer;
begin
  for r:=1 to n do
    for j:=0 to n do
    begin
      Prj[r,j].x:=0;
      Prj[r,j].y:=0;
      wrj[r,j]:=0;
    end;
  Prj[0]:=P;
  wrj[0]:=w;
  for r:=1 to n do
    for j:=0 to n-r do
    begin
      wrj[r,j]:=(1-t)*wrj[r-1,j]+t*wrj[r-1,j+1];
      Prj[r,j].x:=(1-t)*wrj[r-1,j]/wrj[r,j]*Prj[r-1,j].x
        +t*wrj[r-1,j+1]/wrj[r,j]*Prj[r-1,j+1].x;
      Prj[r,j].y:=(1-t)*wrj[r-1,j]/wrj[r,j]*Prj[r-1,j].y
        +t*wrj[r-1,j+1]/wrj[r,j]*Prj[r-1,j+1].y;
    end;
  Bp:=Prj[n,0];
end;



procedure TraceBezier(Init:boolean);
var
  t:real;
  Bp:p2D;
  i:integer;
begin
  if Init then InitGraphique;
  if Init then Fenetre(-2,3,-2.5,1);
  if Init then x_Axe(0,0,1);
  if Init then y_Axe(0,0,1);
  for i:=0 to n do with P[i] do Cercle(x,y,0.01);
  with P[0] do Deplace(x,y);
  t:=0;
  repeat
    t:=t+eps;
    Bezier(t,Bp);
    with Bp do Trace(x,y);
  until (t+eps)>=1;
  with P[n] do Trace(x,y);
  if Init then PauseGraphique;
end;



procedure Init1(poids:real);
begin
  n:=2;                               { nombre-1 de points de la B-spline }
  eps:=1/100;                               { cent points sur la B-spline }
  P[0].x:=0; P[0].y:=0; w[0]:=1;             { coordonnées des n+1 points }
  P[1].x:=1; P[1].y:=1; w[1]:=poids;
  P[2].x:=2; P[2].y:=0; w[2]:=1;
end;



procedure Test_a_;
begin
  Init1(sqrt(2)/2);
  TraceBezier(true);
  Cercle(1,-1,sqrt(2));
  PauseGraphique;
  ModeTexte;
end;



procedure Test_b_;
var
  x:real;

  function y:real;
  begin
    y:=sqrt(3/4*(1-2/3*sqr(x-1)))-0.5;
  end;

begin
  Init1(sqrt(3)/3);
  TraceBezier(true);
  x:=P[0].x-0.1;
  Deplace(x,y);
  repeat
    x:=x+eps;
    Trace(x,y);
  until (x+eps)>=P[n].x+0.1;
  x:=P[n].x+0.1;
  Trace(x,y);
  PauseGraphique;
  ModeTexte;
end;



procedure Test_c_;
var
  x:real;

  function y:real;
  begin
    y:=-x*x/2+x;
  end;

begin
  Init1(1);
  TraceBezier(true);
  x:=P[0].x-1;
  Deplace(x,y);
  repeat
    x:=x+eps;
    Trace(x,y);
  until (x+eps)>=P[n].x+1;
  x:=P[n].x+1;
  Trace(x,y);
  PauseGraphique;
  ModeTexte;
end;



procedure Test_d_;
var
  C:real;
  co:integer;
begin
  Init1(1);     { init les coordonnées des points (peu importe les poids) }
  writeln('Le programme va choisir les poids en fonction de C.');
  writeln('Donnez la valeur de la constante C=w0·w2/w1² : ');
  readln(C); C:=abs(C);               { on se limite à des poids positifs }
  w[1]:=sqrt(w[0]*w[2]/C);    { on trace une première courbe avec w0=w2=1 }
  TraceBezier(true);
  w[0]:=0.5;
  co:=1;
  repeat
    w[1]:=sqrt(w[0]*w[2]/C);
    Couleur(co); co:=co+1;
    TraceBezier(false);
    writeln(w[0],' ',w[1],' ',w[2]);
    w[0]:=w[0]+1;
    PauseGraphique;
  until w[0]>5;
  PauseGraphique;
  ModeTexte;
end;



procedure Menu;
var
  choix:integer;
begin
  writeln;
  writeln;
  writeln('Programme Courbe Bézier rationnelle - Menu');
  repeat
    writeln;
    writeln('0 : Stoppe le programme');
    writeln('1 : Question 3° a)');
    writeln('2 : Question 3° b)');
    writeln('3 : Question 3° c)');
    writeln('4 : Question 3° d)');
    writeln('5 : Question 2°');
    writeln('6 : Saisie manuelle des points');
    readln(choix);
    case choix of
      1 : Test_a_;
      2 : Test_b_;
      3 : Test_c_;
      4 : Test_d_;
    end;
  until choix=0;
end;



begin
  eps:=1/100;                        { 100 points }
  Menu;
end.