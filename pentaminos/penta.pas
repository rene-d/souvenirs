program pentaminos;
{$M 65000,0,0,r-,s-}
uses crt,dos;

const
  maxx=10;
  maxy=6;
  limite=12;
  path='c:\$pentas';
  version='0.32p 22/08/92';


{ PENTAMINOS - (c) René DEVICHI 1992 - août 1992
Problème :
On peut former 12 pièces différentes avec 5 petits carrés qui gardent au
moins un côté en commun (voir la définition des pièces un peu plus bas).
Ces 12 pièces ont une superficie totale de 60 petits carrés ou 60 unités.
Le problème de pentaminos est donc de faire tenir ces 12 pièces dans un
rectangle de 6 sur 10 (ou 5 sur 12, ou 4 sur 15, ou 3 sur 20) étant
entendu que l'on peut orienter la pièce dans n'importe quelle direction
et qu'on peut aussi la retourner (cela correspond en fait à une symétrie).
Il y a 2339 solutions différentes pour le rectangle de 6 sur 12,
2 solutions (bien que le programme en donne 4) pour le rectangle de 3 sur 20.

Idée du programme :
On appelle une première fois la procédure pentamino avec un tableau vide
et la pièce 1 en paramètres. Cette procédure cherche la première
position valable pour la pièce, la place dans le tableau, puis appelle
elle-même avec en paramètres le nouveau tableau et la pièce suivante.
La récursion s'arrête dès lors qu'on ne peut plus placer une pièce
ou si le tableau est rempli.

Format du fichier de sortie :
Le fichier de sortie s'apparente à un fichier "historique" : les informations
sont ajoutées les unes aux autres à la suite.
Mot-clé de début de section : [DIMENSIONS]
Mot-clé de fin de section : [FIN]
Syntaxe :
[DIMENSIONS] - sur la ligne suivante, deux entiers (dimensions du rectangle)
[TEMPS DEBUT] - sur la ligne suivante, la date (date heure) du début de la recherche
[TEMPS FIN] - sur la ligne suivante, la date (date heure) de la fin d'exécution
[ECOULE] - sur la ligne suivante, le temps écoulé entre [TEMPS DEBUT] et [TEMPS FIN]
[PENTAMINO.xxxx] xxxx est un numéro - sur les lignes suivantes, le rectangle correspondant à un pentamino

}

type
  piece=array[1..5,1..5] of byte;
  rectangle=array[1..maxx,1..maxy] of byte;

const
  pieces:array[1..12] of piece=
    (((0,1,0,0,0),                      {      ██       } { 1 }
      (1,1,1,0,0),                      {    ██████     }
      (0,1,0,0,0),                      {      ██       }
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,1,1,1,1),                      {  ██████████   } {  2 }
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0)),


     ((1,0,1,0,0),                      {   ██  ██      } {  3 }
      (1,1,1,0,0),                      {   ██████      }
      (0,0,0,0,0),                      {               }
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,0,0,0,0),                      {   ██          } {  4 }
      (1,1,0,0,0),                      {   ████        }
      (0,1,1,0,0),                      {     ████      }
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((0,1,0,0,0),                      {    ██         } {  5 }
      (0,1,0,0,0),                      {    ██         }
      (1,1,1,0,0),                      {  ██████       }
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,0,0,0,0),                      {   ██          } {  6 }
      (1,0,0,0,0),                      {   ██          }
      (1,1,1,0,0),                      {   ██████      }
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((0,0,1,0,0),                      {   ██          } {  7 }
      (1,1,1,0,0),                      {   ██████      }
      (1,0,0,0,0),                      {       ██      }
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,1,1,1,0),                      {  ████████     } {  8 }
      (1,0,0,0,0),                      {  ██           }
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,1,1,1,0),                      {  ████████     } {  9 }
      (0,1,0,0,0),                      {    ██         }
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,1,1,0,0),                      {  ██████       } { 10 }
      (1,1,0,0,0),                      {  ████         }
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((1,1,1,0,0),                      {  ██████       } { 11 }
      (0,0,1,1,0),                      {      ████     }
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0)),

     ((0,0,1,0,0),                      {      ██       } { 12 }
      (1,1,1,0,0),                      {  ██████       }
      (0,1,0,0,0),                      {    ██         }
      (0,0,0,0,0),
      (0,0,0,0,0))

    );

  cols:array[1..13] of byte=
    (red,green,cyan,magenta,blue,yellow,
     brown,lightblue,lightgreen,
     lightred,lightmagenta,lightgray,blink+darkgray);

const
  recursions:longint=0;

var
  npentaminos:integer;
  jeu:array[1..12] of array[1..8] of piece;
  dim:array[1..12] of array[1..8] of record x,y:integer; end;
  maxdir:array[1..12] of integer;
  tableau:rectangle;
  initplaces:array[1..12] of record dir,pos,x,y:integer; end;
  stop,affiche:boolean;
  codestop:integer;
  fic:text;

  timer:longint absolute $40:$6C;
  t0,t1:longint;
  debut,fin:DateTime;



procedure norm(p:piece;var q:piece);
var
  i,j,k:integer;
  zero:boolean;
begin
  zero:=true;
  i:=0;
  repeat
    inc(i);
    for j:=1 to 5 do
      zero:=zero and (p[i,j]=0);
  until (zero=false) or (i>=6);   { i est le numéro de ligne (ou colonne) contenant un élément non nul }
  if (i>1) and (i<=5) then
  begin
    for k:=i to 5 do
      for j:=1 to 5 do p[k-i+1,j]:=p[k,j];
    for k:=7-i to 5 do
      for j:=1 to 5 do p[k,j]:=0;
  end;

  zero:=true;
  i:=0;
  repeat
    inc(i);
    for j:=1 to 5 do
      zero:=zero and (p[j,i]=0);
  until (zero=false) or (i>=6);
  if (i>1) and (i<=5) then
  begin
    for k:=i to 5 do
      for j:=1 to 5 do p[j,k-i+1]:=p[j,k];
    for k:=7-i to 5 do
      for j:=1 to 5 do p[j,k]:=0;
  end;
  q:=p;
end;


procedure tourneG(p:piece;var q:piece);
var
  i,j:integer;
begin
  for i:=1 to 5 do
    for j:=1 to 5 do
      q[6-i,j]:=p[j,i];
  norm(q,q);
end;


procedure tourneD(p:piece;var q:piece);
var
  i,j:integer;
begin
  for i:=1 to 5 do
    for j:=1 to 5 do
      q[i,6-j]:=p[j,i];
  norm(q,q);
end;


procedure retourne(p:piece;var q:piece);
var
  i,j:integer;
begin
  for i:=1 to 5 do
    for j:=1 to 5 do
      q[i,6-j]:=p[i,j];
  norm(q,q);
end;


procedure dimension(var p:piece;var l,c:integer);
var
  i,j:integer;
  zero:boolean;
begin
  l:=5;
  zero:=true;
  repeat
    for j:=1 to 5 do
      zero:=zero and (p[l,j]=0);
    dec(l);
  until (l=0) or (zero=false);
  inc(l);

  c:=5;
  zero:=true;
  repeat
    for i:=1 to 5 do
      zero:=zero and (p[i,c]=0);
    dec(c);
  until (c=0) or (zero=false);
  inc(c);
end;


procedure aff(p:piece);
var
  i,j:integer;
  x,y:integer;
begin        
  x:=wherex;
  y:=wherey;
  for j:=1 to 5 do
  begin
    gotoxy(x,wherey);
    for i:=1 to 5 do
      if p[i,j]=1 then write(#219#219) else write(#249#249);
    writeln;
  end;
  writeln;
  gotoxy(x,y);
end;


{ initialisation des tableaux de définition des pièces }
procedure initjeu;
var
  i,j,k,x,y:integer;
  p:piece;
begin
  x:=0;                 { petite vérification... }
  for k:=1 to 12 do
    for i:=1 to 5 do
      for j:=1 to 5 do
        inc(x,pieces[k][i,j]);
  if (x<>60) or (maxx*maxy<>60) or (maxx<maxy) then
  begin
    writeln('Erreur de définition des pièces.');
    halt(5);
  end;

  { jeu[np,dir] contient la définition de la pièce np dans la direction dir }
  { dim[np,dir] contient ses dimensions }

  jeu[1,1]:=pieces[1];          { pièce à une seule position }
  maxdir[1]:=1;

  jeu[2,1]:=pieces[2];          { pièce à deux positions }
  tourneD(pieces[2],jeu[2,2]);
  maxdir[2]:=2;

  for i:=3 to 6 do              { pièces symétriques à quatre positions }
  begin
    p:=pieces[i];
    for k:=1 to 4 do
    begin
      jeu[i,k]:=p;
      tourneD(p,p);
    end;
    maxdir[i]:=4;
  end;

  jeu[7,1]:=pieces[7];          { pièce non symétrique quatre positions }
  tourneD(pieces[7],jeu[7,2]);
  retourne(pieces[7],jeu[7,3]);
  tourneD(jeu[7,3],jeu[7,4]);
  maxdir[7]:=4;

  for i:=8 to 12 do             { pièces à huit positions }
  begin
    p:=pieces[i];
    for k:=1 to 4 do
    begin
      jeu[i,k]:=p;
      tourneD(p,p);
    end;
    retourne(pieces[i],p);
    for k:=5 to 8 do
    begin
      jeu[i,k]:=p;
      tourneD(p,p);
    end;
    maxdir[i]:=8;
  end;

  for i:=1 to 12 do                     { on calcule les dimensions des 12 pièces }
    for k:=1 to maxdir[i] do            { dans toutes les directions possibles }
    begin
      dimension(jeu[i,k],x,y);
      dim[i,k].x:=x;
      dim[i,k].y:=y;
    end;

end;


procedure zerotab;
var i,j:integer;
begin
  npentaminos:=0;
  for i:=1 to maxx do
    for j:=1 to maxy do
      tableau[i,j]:=0;
end;


procedure afftab(t:rectangle);
var
  i,j:integer;
  w:word;
begin
  for j:=1 to maxy do
  begin
    for i:=1 to maxx do
    begin
      w:=j*160+i*4-164+162;
      if t[i,j]=0 then
      begin
        memw[$B800:w]:=(white shl 8)+249;
        memw[$B800:w+2]:=(white shl 8)+249;
      end
      else begin
        memw[$B800:w]:=(cols[t[i,j]] shl 8)+219;
        memw[$B800:w+2]:=memw[$B800:w];
      end;
    end;
  end;
end;


{ même chose que afftab mais à un autre endroit de l'écran }
procedure affpent(t:rectangle);
var
  i,j:integer;
  w:word;
begin
  for j:=1 to maxy do
  begin
    for i:=1 to maxx do
    begin
      w:=j*160+i*4-164+162+160*11;
      if t[i,j]=0 then
      begin
        memw[$B800:w]:=(white shl 8)+249;
        memw[$B800:w+2]:=(white shl 8)+249;
      end
      else begin
        memw[$B800:w]:=(cols[t[i,j]] shl 8)+219;
        memw[$B800:w+2]:=memw[$B800:w];
      end;
    end;
  end;
end;


{ sauve un pentamino dans le fichier fic }
procedure sauvepent(t:rectangle);
var
  i,j:integer;
begin
{  if limite<>12 then exit; }
  writeln(fic); 
  writeln(fic,'[PENTAMINO.',npentaminos,']'#9#9';',timer-t0);
  for j:=1 to maxy do
  begin
    for i:=1 to maxx do write(fic,t[i,j]:4);
    writeln(fic);
  end;
  flush(fic);
end;



procedure statusline(etat:word);
var x,y:integer;
begin
  x:=wherex;
  y:=wherey;
  gotoxy(1,25);
{  textbackground(lightgray); clreol; }
  if (etat and 1)=1 then textcolor(green) else textcolor(red);
  write('Space');
  textcolor(white); write(':Affichage o/n║');
  if (etat and 2)=2 then textcolor(green) else textcolor(red);
  write('ESC');
  textcolor(white); write(':Menu│');
  if (etat and 4)=4 then textcolor(green) else textcolor(red);
  write('Alt X');
  textcolor(white); write(':Quitter│');
  if (etat and 8)=8 then textcolor(green) else textcolor(red);
  write('Alt S');
  textcolor(white); write(':Sauver│');
  if (etat and 16)=16 then textcolor(green) else textcolor(red);
  write('Alt R');
  textcolor(white); write(':Restaurer');
  gotoxy(x,y);
end;




type
  tok=record x,y:integer; end;

var
  pile:array[1..100] of tok;
  ntok:integer;

procedure empile(x,y:integer);
begin
  if ntok>=100 then                     { impossible !! }
  begin
    writeln('Débordement de la pile !');
    halt(6);
  end;
  pile[ntok].x:=x; pile[ntok].y:=y;
  inc(ntok);
end;

function depile(var x,y:integer):boolean;
begin
  if (ntok<=1) then depile:=false
  else begin
    dec(ntok);
    x:=pile[ntok].x; y:=pile[ntok].y;
    depile:=true;
  end;
end;

function fill(var t:rectangle;x,y:integer):integer;
var
  i,x1,x2,nn:integer;
  fl:boolean;
begin
  if (y<1) or (y>maxy) or (x<1) or (x>maxx) then exit;
  ntok:=1;
  nn:=0;
  empile(x,y); 	
  while(depile(x,y)=true) do
  begin
    if t[x,y]=0 then
    begin
      x1:=x; x2:=x;
      while (x1>1) and (t[x1-1,y]=0) do dec(x1);
      while (x2<maxx) and (t[x2+1,y]=0) do inc(x2);
      for i:=x1 to x2 do t[i,y]:=13;
      inc(nn,x2-x1+1);

      if (y>1) then
      begin
        fl:=(t[x1,y-1]=0);
        if (fl) then empile(x1,y-1);
        for i:=x1+1 to x2 do
        begin
          if (fl=true) and (t[i,y-1]<>0) then fl:=false
          else if (fl=false) and (t[i,y-1]=0) then
            begin
              fl:=true;
              empile(i,y-1);
            end;
        end;
      end;

      if (y<maxy) then
      begin
        fl:=(t[x1,y+1]=0);
	if(fl) then empile(x1,y+1);
	for i:=x1+1 to x2 do
        begin
	  if (i=x2+1) then halt(4);             { ?????? }
	  if (fl=TRUE) and (t[i,y+1]<>0) then fl:=false
          else if (fl=false) and (t[i,y+1]=0) then
          begin
            fl:=TRUE;
	    empile(i,y+1);
          end
        end;
      end;
    end;
  end;
  fill:=nn;
end;


{ recherche l'espace libre minimum dans le tableau }
{ le prédicat renvoyé est vrai si l'espace libre est compatible, faux dans le cas contraire }
function espaceslibres(t:rectangle):boolean;
var
  i,j,k:integer;
begin
  for i:=1 to maxx do
    for j:=1 to maxy do
    begin
      if t[i,j]=0 then
      begin
        k:=fill(t,i,j);
        if ((k mod 5)<>0) or (k<5) then
        begin
          espaceslibres:=false;
          exit;
        end;
      end;
    end;
  espaceslibres:=true;
end;


{ cherche la première position valable à partir de (x,y) }
{ retourne false si pas de position trouvée dans le tableau }
function position(num,dir:integer;var t:rectangle;var x,y:integer):boolean;
var
  i,j,k,l,c:integer;
  test:boolean;
  p:piece;
label testfalse;
begin
  if num=1 then  { spécial pour la pièce n°1 }
  begin          {if x=0 then begin x:=1; y:=2; position:=true; exit; end;}
    inc(x);
    if x>(maxx div 2)-1+(maxx mod 2) then
    begin
      x:=1;
      inc(y);
      if y>(maxy div 2)-1+(maxy mod 2) then
      begin
        position:=false;
        x:=maxx+1; y:=maxy+1;
        exit;
      end;
    end;
    position:=true;
    exit;
  end;

  p:=jeu[num,dir];
  l:=dim[num,dir].x;
  c:=dim[num,dir].y;
  if (x>maxx) or (y>maxy) then
  begin
    position:=false;
    exit;
  end;

  { donne la position suivante }
  inc(x);
  if x+l>maxx+1 then
  begin
    x:=1;
    inc(y);
    if y+c>maxy+1 then
    begin
      position:=false;
      x:=maxx+1; y:=maxy+1;
      exit;
    end;
  end;
  if (x+l-2>=maxx) or (y+c-2>=maxy) then
  begin
    position:=false;
    exit;
  end;

  repeat
    test:=true;
    for i:=1 to l do
      for j:=1 to c do
        if (p[i,j]<>0) and (t[x+i-1,y+j-1]<>0) then
          {test:=false;}
          goto testfalse;         { on gagne peut-être 0.5% au maximum en vitesse }
    if (test=false) then
    begin
testfalse:
      test:=false;
      inc(x);
      if x+l>maxx+1 then
      begin
        x:=1;
        inc(y);
        if y+c>maxy+1 then
        begin
          position:=false;
          x:=maxx+1; y:=maxy+1;
          exit;
        end;
      end;
    end;
  until (test=true);
  position:=true;
end;



procedure testkey;
var
  scancode:word;
label nocar;
begin
  asm
    mov  ah,11h
    int  16h
    jz   nocar                          { pas de touche frappée }
    mov  [scancode],ax
    xor  ax,ax                          { enlève le caractère du buffer }
    int  16h
  end;
  if scancode=$11B then                 { touche ESC }
  begin
    statusline(4+8);
    asm
      xor   ax,ax
      int   16h
      mov   [scancode],ax
    end;
    if scancode=$2D00 then                      { Alt X }
    begin
      stop:=true;
      codestop:=1;
    end
    else if scancode=$3B00 then                 { F1 }
    begin
      stop:=true;
      codestop:=0;
    end
    else if scancode=$1F00 then                 { Alt S }
    begin
      stop:=true;
      codestop:=2;
    end
    else if scancode=$1300 then                 { Alt R }
    begin
      stop:=true;
      codestop:=3;
    end;
    statusline(3);
  end
  else
    if scancode=$3920 then                      { Space }
       affiche:=not affiche;
nocar:
end;


{var x0,y0:integer; test,test2:boolean;}

{ procédure principale: c'est elle qui effectue récursivement la recherche }
procedure pentamino(var t:rectangle;np:integer);
var
  p:piece;
  u:rectangle;
  i,j,dir,x,y,pos:integer;
  w:word;
begin
  testkey;                      { teste les touches pressées }
                                { fin=true signifie que l'on doit sortir de la récursion }
                                { la position des pièces est alors sauvegardée           }
  if stop then exit;
  inc(recursions);
  if np>=limite+1 then
  begin
    affpent(t);
    inc(npentaminos);
    gotoxy(1,22);
    if npentaminos=1 then
    begin
      write('Pentamino trouvé : 1');
      clreol;
    end
    else begin
      write('Pentaminos trouvés : ',npentaminos);
      clreol;
    end;
    sauvepent(t);
    exit;
  end;
  w:=np*160-160+116+18;
  for dir:=1 to maxdir[np] do
  begin
    p:=jeu[np,dir];
    pos:=0;
    x:=0; y:=1;
    while position(np,dir,t,x,y)=true do                { tant qu'une position a été trouvée }
    begin

      inc(pos);
      mem[$b800:w]:=48+dir;                             { affichage de l'état de la recherche }
      mem[$b800:w+16]:=48+((pos div 10) mod 10);        { ce n'est utile que pour passer le temps }
      mem[$b800:w+18]:=48+(pos mod 10);

      u:=t;
      for i:=1 to 5 do                                  { on ajoute à la copie de t la pièce p }
        for j:=1 to 5 do                                { dans la position (x,y)               }
           if p[i,j]<>0 then u[x+i-1,y+j-1]:=np;

      if espaceslibres(u) then                          { vérification des espaces libres pour u (le nouveau tableau) }
      begin
{       test2:=true;
        for i:=np+1 to 12 do
        begin
          test:=false;
          for j:=1 to maxdir[i] do
          begin
            x0:=0; y0:=1;
            test:=position(i,j,u,x0,y0) or test;
          end;
          if test=false then test2:=false;
        end;
        if test2 then

      begin
 }       if affiche then afftab(u);
        pentamino(u,np+1);
        if stop then
        begin
          initplaces[np].pos:=pos;
          initplaces[np].dir:=dir;
          initplaces[np].x:=x;
          initplaces[np].y:=y;
          exit;
        end;
      end;
    end;
  end;

  mem[$b800:w]:=32;
  mem[$b800:w+16]:=32;
  mem[$b800:w+18]:=32;
end;



procedure inittab;
var
  p:piece;
  i,j,k,x,y:integer;
begin
  for i:=1 to maxx do           { met le tableau à zéro }
    for j:=1 to maxy do
      tableau[i,j]:=0;
{  k:=1;
  while (k<=12) and (initplaces[k].pos<>0) do
  begin
    p:=jeu[k,initplaces[k].dir];
    x:=0; y:=1;
    for i:=1 to initplaces[k].pos do
      if position(k,initplaces[k].dir,tableau,x,y)=false then
      begin
        writeln('Mauvaise initialisation');
        halt(4);
      end;
    for i:=1 to 5 do
      for j:=1 to 5 do
        if p[i,j]<>0 then tableau[x+i-1,y+j-1]:=k;
    inc(k);
  end;
}
end;



procedure sauvetab;
var
  i:integer;
  c:char;
  ficsav:text;
begin
  gotoxy(1,22); clreol;
  write('Numéro de sauvegarde : ');
  repeat
    asm
      xor   ax,ax
      int   16h
      mov   byte ptr [c],al
    end;
  until ((c>='1') and (c<='9')) or (c=#27);
  if c=#27 then exit;
  write(c);
  assign(ficsav,'penta'+c+'.sav');
  rewrite(ficsav);
  for i:=1 to 12 do
    writeln(ficsav,initplaces[i].dir:1,'  ',initplaces[i].pos:2);
  close(ficsav);
end;

procedure chargetab;
var
  i:integer;
  c:char;
  ficsav:text;
begin
  gotoxy(1,22); clreol;
  write('Numéro de sauvegarde : ');
  repeat
    asm
      xor   ax,ax
      int   16h
      mov   byte ptr [c],al
    end;
  until (c>='1') or (c<='9');
  write(c);
  assign(ficsav,'penta'+c+'.sav');
  {$i-} reset(ficsav); {$i+}
  if ioresult<>0 then
  begin
    for i:=1 to 12 do
    begin
      initplaces[i].dir:=1;
      initplaces[i].pos:=0;
    end;
  end
  else begin
    for i:=1 to 12 do
      readln(ficsav,initplaces[i].dir,initplaces[i].pos);
    close(ficsav);
  end;
end;


function formdate(dt:datetime):string;
var
  s:string;
begin
  if (dt.hour div 10)=0 then s[1]:=' '
  else s[1]:=char(48+(dt.hour div 10));
  s[2]:=char(48+(dt.hour mod 10));
  s[3]:=':';
  s[4]:=char(48+(dt.min div 10));
  s[5]:=char(48+(dt.min mod 10));
  s[6]:=':';
  s[7]:=char(48+(dt.sec div 10));
  s[8]:=char(48+(dt.sec mod 10));
  s[9]:=' ';
  s[10]:=char(48+(dt.day div 10));
  s[11]:=char(48+(dt.day mod 10));
  s[12]:='/';
  s[13]:=char(48+(dt.month div 10));
  s[14]:=char(48+(dt.month mod 10));
  s[15]:='/';
  s[16]:=char(48+((dt.year div 10) mod 10));
  s[17]:=char(48+(dt.year mod 10));
  s[0]:=#17;
  formdate:=s;
end;


procedure swapdt(var t0,t1:datetime);
var
  dt:datetime;
begin
  dt:=t0;
  t0:=t1;
  t1:=dt;
end;

function formdiff(t0,t1:datetime):string;  { suppose que les années et les mois soient identiques }
var
  s:string;
begin
{  if (t0.month<>t1.month) or (t0.year<>t1.year) then exit;
  if (t0.day>t1.day) then swapdt(t0,t1)
  else if (t0.hour>t1.hour) then swapdt(t0,t1)
  else if (t0.min>t1.min) then swapdt(t0,t1)
  else if (t0.sec>t1.sec) then swapdt(t0,t1); }
  if t1.day-t0.day<=1 then s:='.. jour  ..:..:..' else s:='.. jours ..:..:..';

  if t1.sec<t0.sec then
  begin
    inc(t1.sec,60);
    inc(t0.min,1);
  end;
  if t1.min<t0.min then
  begin
    inc(t1.min,60);
    inc(t0.hour,1);
  end;
  if t1.hour<t0.hour then
  begin
    inc(t1.hour,24);
    inc(t0.day,1);
  end;
  s[1]:=chr(48+((t1.day-t0.day) div 10) mod 10);
  s[2]:=chr(48+(t1.day-t0.day) mod 10);
  s[10]:=chr(48+((t1.hour-t0.hour) div 10) mod 10);
  s[11]:=chr(48+(t1.hour-t0.hour) mod 10);
  s[13]:=chr(48+((t1.min-t0.min) div 10) mod 10);
  s[14]:=chr(48+(t1.min-t0.min) mod 10);
  s[16]:=chr(48+((t1.sec-t0.sec) div 10) mod 10);
  s[17]:=chr(48+(t1.sec-t0.sec) mod 10);
  formdiff:=s;
end;

var
  i,j:integer;
  log:text;
  c:char;
  DayOfWeek, Sec100:word;
begin
  { prépare l'écran d'affichage }
  textcolor(white); textbackground(black);
  clrscr;

  { cadre pour les tableaux lors de la cherche }
  gotoxy(1,1); write(#201);
  for i:=1 to maxx*2 do write(#205); write(#187);
  for j:=1 to maxy do
  begin
   gotoxy(1,j+1); write(#186);
   gotoxy(maxx*2+2,j+1); write(#186);
  end;
  gotoxy(1,maxy+2); write(#200);
  for i:=1 to maxx*2 do write(#205); write(#188);

  { cadre pour les pentaminos }
  gotoxy(1,12); write(#201);
  for i:=1 to maxx*2 do write(#205); write(#187);
  for j:=1 to maxy do
  begin
   gotoxy(1,j+12); write(#186);
   gotoxy(maxx*2+2,j+12); write(#186);
  end;
  gotoxy(1,maxy+13); write(#200);
  for i:=1 to maxx*2 do write(#205); write(#188);

  for i:=1 to 12 do
  begin
     gotoxy(50,i);
     textcolor(cols[i]); write(#219#219);
     textcolor(white); write(' pièce ',i:2,' : dir . - pos .. ');
  end;
  gotoxy(1,24); write('PENTAMINOS - version '+version+' - (c) René Devichi 1992');
  statusline(3);

  initjeu;

  { ouvre le fichier de sortie }
  assign(fic,path);
  {$i-} append(fic); {$i+}
  if ioresult<>0 then rewrite(fic) else append(fic);
  writeln(fic);

  writeln(fic,'[DIMENSIONS]'); { écrit l'identification }
  writeln(fic,maxx:3,maxy:5);
  writeln(fic);

  writeln(fic,'[DATE DEBUT]');
  getdate(debut.Year, debut.Month, debut.Day, DayOfWeek);
  gettime(debut.Hour, debut.Min, debut.Sec, Sec100);
  writeln(fic,formdate(debut));
{  writeln(fic);}

  for i:=1 to 12 do          { on commence par un tableau vide au lancement du programme }
  begin
    initplaces[i].dir:=0;
    initplaces[i].pos:=0;
  end;
  npentaminos:=0;

  affiche:=false;

    gotoxy(1,22); write('Recherche de pentaminos...'); clreol;
    inittab;
    stop:=false; codestop:=0;
    t0:=timer;                            { début de la recherche }
    pentamino(tableau,1);
{    writeln;writeln(timer-t0);writeln(recursions); }
    if stop and (codestop=2) then sauvetab;

  writeln(fic);
  writeln(fic,'[DATE FIN]');
  getdate(fin.Year, fin.Month, fin.Day, DayOfWeek);
  gettime(fin.Hour, fin.Min, fin.Sec, Sec100);
  writeln(fic,formdate(fin));
  writeln(fic);

  writeln(fic,'[ECOULE]');
  writeln(fic,formdiff(debut,fin));

                              { ferme le fichier de pentaminos }
  writeln(fic,'[FIN]'#9#9';',recursions);
  close(fic);
end.
