unit rubikmvt;

interface

uses
  rubikini,
  rubikrot;


const
  gen1='hdHD.HAha';
  gen2='HGhg.haHA';
  gen3='a.hdHD.A';
  gen4='P.DHdh.p';
  gen5='dPDp.hhphhP';
  gen6='hhDhhd.hDhd';
  gen7='hAHGhga';
  gen8='G.hdH.g.hDH';
  gen9='a.dhDH.dhDH.dhDH.A';
  gen10='hPHGPg.A.GpghpH.a';
  gen11='hPHGPg.aa.GpghpH.aa';
  gen12='aDAd.dHDh.hAHa.aDAd.dHDh.hAHa';

var
  ok:boolean;


procedure execute(m:string;sens:boolean);


implementation


procedure generateur(c:char;sens:boolean); forward;

procedure exe(c:char;sens:boolean);
begin
  ok:=true;
  case c of
    '.',' ' : ;
    'a' : rotation(avant,not sens);
    'p' : rotation(arriere,not sens);
    'g' : rotation(gauche,not sens);
    'd' : rotation(droite,not sens);
    'b' : rotation(dessous,not sens);
    'h' : rotation(dessus,not sens);
    'A',chr(65 or 128) : rotation(avant,sens);
    'P',chr(80 or 128) : rotation(arriere,sens);
    'G',chr(71 or 128) : rotation(gauche,sens);
    'D',chr(68 or 128) : rotation(droite,sens);
    'B',chr(66 or 128) : rotation(dessous,sens);
    'H',chr(72 or 128) : rotation(dessus,sens);
    '1'..#60 : generateur(c,sens);
    chr(49 or 128)..chr(60 or 128) : generateur(chr(ord(c)-128),not sens);
    'x' : rotation_cube(avant_arriere,sens);
    'y' : rotation_cube(gauche_droite,sens);
    'y' : rotation_cube(haut_bas,sens);
    'X',chr(88 or 128) : rotation_cube(avant_arriere,not sens);
    'Y',chr(89 or 128) : rotation_cube(gauche_droite,not sens);
    'Z',chr(90 or 128) : rotation_cube(haut_bas,not sens);
    else ok:=false;
  end;
end;


procedure execute(m:string;sens:boolean);
{ sens=true si on lit m de gauche à droite, false dans le cas contraire }
var i:integer;
begin
  if sens then
    for i:=1 to length(m) do exe(m[i],true)
  else
    for i:=length(m) downto 1 do exe(m[i],false);
end;


procedure generateur(c:char;sens:boolean);
begin
  case c of
    '1' : execute(gen1,sens);
    '2' : execute(gen2,sens);
    '3' : execute(gen3,sens);
    '4' : execute(gen4,sens);
    '5' : execute(gen5,sens);
    '6' : execute(gen6,sens);
    '7' : execute(gen7,sens);
    '8' : execute(gen8,sens);
    '9' : execute(gen9,sens);
    #58 : execute(gen10,sens);
    #59 : execute(gen11,sens);
    #60 : execute(gen12,sens);
  end;
end;

end.