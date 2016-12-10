program edite;

var
  ok:boolean;

procedure execute(m:char);
begin
  ok:=true;
  case upcase(m) of
    'A' : rotation(avant,
    program rubik_test;

uses
  Graph,Dos,Crt,
  RubikIni,
  RubikRot,
  Rubik3D,
  Rubik2D,
  BGIdriv,
  BGIfont,
  Souris;



var
  theta,phi,distance   : integer;



type
  fen=record x1,y1,x2,y2:integer; end;

  procedure tf(f:fen);
  begin
    setcolor(noir);
    setlinestyle(0,0,1);
    setfillstyle(1,6);
    with f do bar(x1+texte_x div 3,y1+texte_y div 3,x2-texte_x div 3,y2-texte_y div 3);
    setfillstyle(1,0);
    with f do bar(x1+2*texte_x div 3,y1+2*texte_y div 3,x2-2*texte_x div 3,y2-2*texte_y div 3);
    setcolor(8);
    with f do rectangle(x1+texte_x div 3,y1+texte_y div 3,x2-texte_x div 3,y2-texte_y div 3);
    setcolor(noir);
    with f do rectangle(x1+2*texte_x div 3,y1+2*texte_y div 3,x2-2*texte_x div 3,y2-2*texte_y div 3);
  end;


var
  f1,f2,f3:fen;i:integer;



procedure parametres;  { affiche les paramètres de visualisation dans f3 }
var
  ligne:string[65];
  s:string;
  x,y:integer;
begin
  setfillstyle(0,0);
  with f3 do bar(x1+texte_x,y1+texte_y,x2-texte_x,y2-texte_y);
  settextstyle(sansseriffont,horizdir,1);
  settextjustify(lefttext,toptext);
  setcolor(noir);
  moveto(f3.x1+4*texte_x div 3,f3.y1+texte_y div 2);
  outtext('vue 3D : theta:'+stri(theta));
  moveto(f3.x1+4*texte_x div 3+textwidth('vue 3D : theta:+000  '),gety);
  outtext('phi:'+stri(phi));
  moveto(f3.x1+4*texte_x div 3+textwidth('vue 3D : theta:+000  phi:+000  '),gety);
  outtext('distance:'+stri(distance));
  moveto(f3.x1+4*texte_x div 3,f3.y1+texte_y div 2+textheight(#219));
{ ligne:='vue 2D : '; outtext(ligne); }
  if cube_fait(rubik) then
  begin
    setcolor(red);
    outtext('Le cube est fait.');
  end;
end;




procedure visu;
begin
  cacher_souris;
  parametres;
  if cube_inchange and not meme(rubik,ancien_rubik,sizeof(rubiks_cube)) then
  begin                            { teste une modification sur le cube    }
    cube_inchange:=false;          { pour ne pas le réafficher inutilement }
    ancien_rubik:=rubik;
  end;
  visu3d(1,theta,phi,distance);
  visu3d(2,theta+180,-phi,distance);                 { vue du point opposé }
  visu2d;
  cube_inchange:=true;
  montrer_souris;
end;


procedure aide;
begin
  directvideo:=false;
  textcolor(red);
  window(69,2,78,25);
  writeln(' A I D E ');
  writeln;
  textcolor(blue);
  writeln('F1: Θ-');
  writeln('F2: Θ+');
  writeln('F3: Φ-');
  writeln('F4: Φ+');
  writeln('TAB: Θ++');
  writeln('²: Φ++');
  writeln;
  writeln('[gadphb]');
  write('mvt direct');
  writeln('»CTRL:');
  writeln('mvt indir.');
  writeln('F5,F6,F7');
  writeln('rot. cube');
  writeln('»CTRL:');
  writeln('rot. inv.');
  writeln;
  writeln;
  textcolor(yellow);
  writeln('F9:spécial');
  write('F10: MENU');
end;



procedure special;
var
  i:integer;
begin
  randomize;
  for i:=1 to 52 do rotation(faces(random(6)),boolean(random(2)));
end;


procedure menu;
begin
end;




var incr:integer;

procedure editeur;
var c:char;tf:byte;
  b,x,y:word;
begin
  repeat
    visu;
    c:=upcase(readkey);
    if c=#0 then begin tf:=ord(readkey); end;
    case c of
      '+' : inc(incr);
      '-' : dec(incr);
      #9 : inc(theta,30);                               { Tab        }
      '²' : inc(phi,30);
      'ⁿ' : dec(phi,30);
      #0 : case tf of
              59 : dec(theta,incr);                     { F1         }
              60 : inc(theta,incr);                     { F2         }
              61 : dec(phi,incr);                       { F3         }
              62 : inc(phi,incr);                       { F4         }
              94 : theta:=180-theta;                    { Ctrl F1    }
              96 : phi:=-phi;                           { Ctrl F3    }
              15 : dec(theta,45);                       { Shift Tab  }

              63 : rotation_cube(avant_arriere,true);   { F5         }
              98 : rotation_cube(avant_arriere,false);  { Ctrl F5    }
              64 : rotation_cube(gauche_droite,true);   { F6         }
              99 : rotation_cube(gauche_droite,false);  { Ctrl F6    }
              65 : rotation_cube(haut_bas,true);        { F7         }
             100 : rotation_cube(haut_bas,false);       { Ctrl F7    }
              67 : special;                             { touche F9  }
              68 : menu;                                { touche F10 }
           end;


      'A': rotation(avant,false);
      'D': rotation(droite,false);
      'P': rotation(arriere,false);
      'G': rotation(gauche,false);
      'H': rotation(dessus,false);
      'B': rotation(dessous,false);
      ^A: rotation(avant,true);
      ^D: rotation(droite,true);
      ^P: rotation(arriere,true);
      ^G: rotation(gauche,true);
      ^H: rotation(dessus,true);
      ^B: rotation(dessous,true);
    end;
    theta:=theta mod 360;
    phi:=phi mod 360;
  until c=#27;
end;




begin
  noir:=white;
  ini_ecran;
  ini_rubik;
  definit3d(1,40,40,180,180,thickwidth,0);
  definit3d(2,280,60,100,100,normwidth,0);
  definit2d(240,200,60,60,thickwidth);
  theta:=25; phi:=30; distance:=35; incr:=5;
  f1.x1:=texte_x div 2; f1.x2:=(5*max_x) div 6-texte_x div 2;
  f1.y1:=texte_y div 2; f1.y2:=(7*max_y) div 8-texte_y div 2;
  f2.x1:=(5*max_x) div 6+texte_x div 2; f2.x2:=max_x-texte_x div 2;
  f2.y1:=texte_y div 2; f2.y2:=(7*max_y) div 8-texte_y div 2;
  f3.x1:=texte_x div 2; f3.x2:=(5*max_x) div 6-texte_x div 2;
  f3.y1:=(7*max_y) div 8+texte_y div 2; f3.y2:=max_y-texte_y div 2;
  tf(f1); tf(f2); tf(f3);

  aide;
  editeur;

  readln;
  closegraph;
end.





