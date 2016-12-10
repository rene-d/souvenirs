program rubik_test;

uses
  Graph, Dos, Crt,       { unités standard du Turbo Pascal   }
  RubikIni,              { déclarations générales            }
  RubikRot,              { mouvements de faces du cube       }
  Rubik3D,               { module d'affichage en 3D          }
  Rubik2D,               { module d'affichage en 2D          }
  BGIdriv,               { drivers graphiques de Borland     }
  BGIfont,               { fontes graphiques de Borland      }
  Souris,                { gestion (simplifiée de la souris) }
  RubikMvt,              { bibliothèque des générateurs      }
  Chrono,
  CopyRight;



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
  writeln('»ALT:');
  writeln('mvt indir.');
  writeln('[xyz]');
  writeln('rot. cube');
  writeln('»ALT:');
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
var
  c:char; tf:byte;
  b,x,y:word;
  regs:registers;
begin
  repeat
    visu;
    regs.ax:=0; intr($16,regs);                   { scrute le clavier }
    case regs.ax of

      $1041,$1061 : rotation(avant,false);             { A ou Shift A }
      $1950,$1970 : rotation(arriere,false);           { P ou Shift P }
      $2348,$2368 : rotation(dessus,false);            { H ou Shift H }
      $3042,$3062 : rotation(dessous,false);           { B ou SHift B }
      $2247,$2267 : rotation(gauche,false);            { G ou Shift G }
      $2044,$2064 : rotation(droite,false);            { D ou Shift D }

      $1E00 : rotation(avant,true);                    { Alt A        }
      $1900 : rotation(arriere,true);                  { Alt P        }
      $2300 : rotation(dessus,true);                   { Alt H        }
      $3000 : rotation(dessous,true);                  { Alt B        }
      $2200 : rotation(gauche,true);                   { Alt G        }
      $2000 : rotation(droite,true);                   { Alt D        }

      $2D58,$2D78 : rotation_cube(avant_arriere,true); { X ou Shift X }
      $1559,$1579 : rotation_cube(gauche_droite,true); { Y ou Shift Y }
      $115A,$117A : rotation_cube(haut_bas,true);      { Z ou Shift Z }

      $2D00 : rotation_cube(avant_arriere,false);      { Alt X        }
      $1500 : rotation_cube(gauche_droite,false);      { Alt Y        }
      $2C00 : rotation_cube(haut_bas,false);           { Alt Z        }

      $0F09 : inc(theta,30);                           { Tab          }
      $0F00 : dec(theta,30);                           { Shift Tab    }
      $29FD : inc(phi,30);                             { ²            }
      $29FC : dec(phi,30);                             { ⁿ            }

      $3B00 : dec(theta,incr);                         { F1           }
      $3C00 : inc(theta,incr);                         { F2           }
      $3D00 : dec(phi,incr);                           { F3           }
      $3E00 : inc(phi,incr);                           { F4           }
      $5E00 : theta:=180-theta;                        { Ctrl F1      }
      $6000 : phi:=-phi;                               { Ctrl F3      }

      $4300 : special;                                 { F9           }
      $4400 : menu;                                    { F10          }

    end;

    if (regs.al=$00) and (regs.ah>=$78) and (regs.ah<=$83) then
       execute(chr(regs.ah-$47),false);

    case regs.ah of
      $02..$0D : execute(chr($2F+regs.ah),true);
    end;

    theta:=theta mod 360;
    phi:=phi mod 360;

    if regs.ax=$011B then           { si on a appuyé sur Esc, alors on   }
    begin                           { attend un autre caractère pour     }
      regs.ax:=0;                   { confirmation de la sortie          }
      intr($16,regs);               { (2 fois Esc : quitte le programme) }
    end;

  until regs.ax=$011B;
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

  closegraph;
end.


