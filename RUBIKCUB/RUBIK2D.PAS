unit Rubik2D;         { code : 688 ;  data : 14 }

interface

uses
  Graph,              { routines graphiques standard                }
  RubikIni;           { déclarations pour le programme Rubik's cube }


procedure definit2D(_x0,_y0,_lx,_ly,_width:integer);

procedure visu2D;


implementation


var
  x0,y0,xface,yface,width : integer;
  xfacette,yfacette : integer;


procedure visu2D;

  procedure trace_face2D(x,y:integer;face:faces);
  var i,j:integer;
  begin
    setcolor(noir);
    setlinestyle(solidln,0,normwidth);
    for i:=0 to 2 do
      for j:=0 to 2 do
      begin
        facette[1].x:=x+i*xfacette;     facette[1].y:=y+(2-j)*yfacette;
        facette[2].x:=x+i*xfacette;     facette[2].y:=y+(3-j)*yfacette;
        facette[3].x:=x+(i+1)*xfacette; facette[3].y:=y+(3-j)*yfacette;
        facette[4].x:=x+(i+1)*xfacette; facette[4].y:=y+(2-j)*yfacette;
        facette[5].x:=x+i*xfacette;     facette[5].y:=y+(2-j)*yfacette;

        if monochrome     { si écran monochrome, représente les faces par }
                          { des motifs différents pour les distinguer     }
        then setfillstyle(table_motifs[rubik[face,i+1,j+1]],couleur_mono)
        else setfillstyle(solidfill,table_couleurs[rubik[face,i+1,j+1]]);

        fillpoly(5,facette);
      end;
    setlinestyle(solidln,0,width);
    moveto(x,y); lineto(x+xface,y);
    lineto(x+xface,y+yface);
    lineto(x,y+yface);
    lineto(x,y);
  end;


begin
  if cube_inchange then exit;
  trace_face2D(x0,          y0+yface-1,  gauche);
  trace_face2D(x0+xface-1,  y0+yface-1,  avant);
  trace_face2D(x0+2*xface-1,y0+yface-1,  droite);
  trace_face2D(x0+3*xface-1,y0+yface-1,  arriere);
  trace_face2D(x0+xface-1,  y0,          dessus);
  trace_face2D(x0+xface-1,  y0+2*yface-1,dessous);
end;


procedure definit2D(_x0,_y0,_lx,_ly,_width:integer);
begin
  x0:=_x0; y0:=_y0; xface:=_lx; yface:=_ly;
  xfacette:=xface div 3;
  yfacette:=yface div 3;
end;


end.