unit RubikIni;       { diverses déclarations et initialisations }
                     { contient aussi diverses petites routines }
                     { utiles au programme                      }


interface


uses
  Crt,Dos,           { les unités de gestion de l'écran et du DOS }
  Graph,             { l'unité graphique standard                 }
  BGIdriv,           { inclut également tous les drivers BGI      }
  BGIfont;           { et les fontes vectorielles utilisés        }


const
  bgipath_defaut = 'C:\TP\BGI';
  monochrome     : boolean = false;          { type d'écran utilisé }
  couleur_mono   : integer = lightgray;



type
  couleurs    = (rouge ,vert ,orange,bleu   ,blanc ,jaune  );
  faces       = (gauche,avant,droite,arriere,dessus,dessous);
  aretes      = 1..3;
  col_cube    = array[aretes] of couleurs;
  faces_cube  = array[aretes] of col_cube;
  rubiks_cube = array[faces] of faces_cube;

  directions  = (haut_bas,gauche_droite,avant_arriere);


  str10       = string[10];            { pour les noms de couleurs et de face }


const
  { table de correspondance entre les couleurs "théoriques" (celles qui sont }
  { gardées en mémoire pour gérer les déplacements) et celles qui seront     }
  { affichées à l'écran. Cet ordre correspond en fait à mon cube personnel   }
  table_couleurs : array[couleurs] of integer =
    (red,green,lightred,blue,white,yellow);


  { même chose mais pour les motifs en cas d'écran monochrome }
  table_motifs   : array[couleurs] of integer =
     (solidfill,ltslashfill,xhatchfill,
     closedotfill,bkslashfill,interleavefill);


  pc_bord = 115/100;  { distance en % du cube au cadre dans la vue 3D }




var
  noir  : word;                               { couleur de fond          }
  texte_x, texte_y, max_x, max_y : word;      { valeurs liées à la carte }
  facette : array[1..5] of pointtype;         { pour tracer les facettes }

  rubik, ancien_rubik, rubik_fait : rubiks_cube;  { mémorisation du cube }
  cube_inchange : boolean;





procedure ini_rubik;

function nom_face(face : faces) : str10;

procedure ini_ecran;



function stri(i:integer):string;

function strr(r:real):string;

function meme(var a,b;n:word):boolean;

function cube_fait(var cube:rubiks_cube):boolean;


procedure debug(s:string);



implementation


procedure ini_rubik;
var
  c,l  : aretes;
  face : faces;
begin
  for face:=gauche to dessous do
    for c:=1 to 3 do
      for l:=1 to 3 do
        rubik[face,c,l]:=couleurs(face);
end;


function nom_face(face : faces) : str10;
begin
  case face of
    gauche : nom_face:='Gauche ';
    avant  : nom_face:='Avant  ';
    droite : nom_face:='Droite ';
    arriere: nom_face:='Arrière';
    dessus : nom_face:='Dessus ';
    dessous: nom_face:='Dessous';
  end;
end;


var
  carte,mode:integer;

procedure ini_ecran;
var
  erreur  : integer;
  bgipath : string[79];

  procedure abort(msg:string);
  begin
    writeln(msg,': ',grapherrormsg(erreur));
    halt(1);
  end;
begin
  { enregistrement des  }
{  if registerbgidriver(@CGADriverProc)   <0 THEN abort('CGA');     }
  if registerbgidriver(@EGAVGADriverProc)<0 THEN abort('EGA/VGA');
{  if registerbgidriver(@HercDriverProc)  <0 THEN abort('Herc');    }
{  if registerbgidriver(@ATTDriverProc)   <0 THEN abort('AT&T');    }
{  if registerbgidriver(@PC3270DriverProc)<0 THEN abort('PC 3270'); }

  { Enregistrement des polices de caractères graphiques. }
{  if registerBGIfont(@GothicFontProc)   <0 then abort('Gothic');   }
  if RegisterBGIfont(@SansSerifFontProc)<0 then abort('SansSerif');
{  if RegisterBGIfont(@SmallFontProc)    <0 then abort('Small');    }
{  if RegisterBGIfont(@TriplexFontProc)  <0 then abort('Triplex');  }

  carte:=VGA; mode:=VGAHi;
  bgipath:=getenv('BGIPATH');
  if bgipath='' then bgipath:=bgipath_defaut;
  initgraph(carte,mode,bgipath);
  erreur:=graphresult;
  if (erreur<>grOk) or (carte<0) then
  begin
    writeln('Problème graphique.');
    writeln('(',grapherrormsg(erreur),')');
    halt(1);
  end;

  texte_y:=textheight(#219);
  texte_x:=textwidth(#219);

  max_x:=getmaxx;
  max_y:=getmaxy;


  { si on a défini la variable BGIMONO, force monochrome à true, }
  { sinon on laisse à monochrome sa valeur d'initialisation      }
  if length(getenv('BGIMONO'))<>0 then monochrome:=true;

  if not monochrome then
  begin
    noir:=lightgray;
    setbkcolor(noir);
    setpalette(noir,black);
  end;

end;




function stri(i:integer):string;
var s:string;
begin
  str(i,s);
  stri:=s;
end;


function strr(r:real):string;
var s:string;
begin
  str(r:0:2,s);
  strr:=s;
end;


{ permet de comparer des types de données habituellement incomparables }
{ a et b sont des données de type quelconque de longueur n             }
function meme(var a,b;n:word):boolean;
type
  bytearray=array[1..60000] of byte;  { pour le 'type cast' }
begin
  while (n>0) and (bytearray(a)[n]=bytearray(b)[n]) do dec(n);
  meme:=(n=0);
end;



function cube_fait(var cube:rubiks_cube):boolean;
var
  face:faces;
  i:integer;
begin
  cube_fait:=true;
  for face:=gauche to dessous do
    for i:=1 to 8 do
      if cube[face,i mod 3+1,i div 3+1]<>cube[face,1,1] then
        cube_fait:=false;
end;


procedure debug(s:string);
begin
  directvideo:=false;
  gotoxy(1,1);
  writeln(s+'       ');
end;


begin    { initialise les variables globales }
  cube_inchange:=false;     { force un premier affichage (surtout en 2D) }
  ini_rubik;
  rubik_fait:=rubik; { rubik_fait servira à tester si le cube est "fait" }
end.
