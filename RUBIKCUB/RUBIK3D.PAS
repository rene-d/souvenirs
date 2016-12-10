unit Rubik3D;       { code : 4800 ;  data : 426 }


interface


uses                      { inclut les unités nécessaires }
  Graph,                  { routines graphiques standard  }
  RubikIni;               { déclarations globales         }


type
  n3D = 1..2;             { numéro de la vue 3D }


procedure definit3D(n:n3D;_x0,_y0,_lx,_ly,_width,_cadre:integer);

procedure visu3D(n:n3D;theta,phi,distance:integer);



implementation


type
  { types utilisés pour la géométrie de l'espace }
  matrice3x3 = array[1..3,1..3] of real;    { matrice de rotation spatiale }
  point2Dr   = record x,y : real; end;
  point3D    = record x,y,z : shortint; end;
  point3Dr   = record x,y,z : real; end;
  point2D    = pointtype;

  pour_tri   = record                 { utilisé pour trier les faces selon }
                 f : faces;           { leur éloignement de l'observateur, }
                 d : real;            { seules les trois plus proches sont }
               end;                   { dessinées en général               }

  vue3D   = record                 { définit une vue 3D                    }
              x0,y0,lx,ly,         { rectangle de visualisation            }
              width,               { épaisseur du tracé des arêtes du cube }
              p_theta,p_phi,p_distance,             { valeurs de phi,theta }
                                          { et distance du tracé précedent }
              cadre : integer;        { couleur du cadre entourant le cube }

              a_tracer:boolean;    { indique la nécessité de tout retracer }
              xmin,xmax,ymin,ymax,xratio,yratio:real;
                  { paramètres de "l'homothétie" (c'est plutôt la composée }
                  { de deux affinités, l'une d'axe Ox et l'autre d'axe Oy) }
                  { pour ajuster le cube dans son cadre sur l'écran        }
              ordre:array[1..3] of faces;    { ordre dans lequel les faces }
                                    { doivent être tracées pour apparaître }
                                    { correctement sur l'écran             }
              nb : 1..3;       { nombre de faces visibles (au maximum : 3) }
            end;

const
  { coordonnées spatiales des sommets pour calculer les échelles }
  coord_sommets:array[1..8] of point3D=
    ((x:-3;y:-3;z: 3),(x:-3;y: 3;z: 3),(x: 3;y: 3;z: 3),(x: 3;y:-3;z: 3),
     (x:-3;y:-3;z:-3),(x:-3;y: 3;z:-3),(x: 3;y: 3;z:-3),(x: 3;y:-3;z:-3));

  { coordonnées spatiales des faces }
  coord_faces:array[faces] of array[1..4] of point3D=
    ( ((x:-3;y:-3;z:-3),(x: 3;y:-3;z:-3),(x: 3;y:-3;z: 3),(x:-3;y:-3;z: 3)),
      ((x: 3;y:-3;z:-3),(x: 3;y: 3;z:-3),(x: 3;y: 3;z: 3),(x: 3;y:-3;z: 3)),
      ((x: 3;y: 3;z:-3),(x:-3;y: 3;z:-3),(x:-3;y: 3;z: 3),(x: 3;y: 3;z: 3)),
      ((x:-3;y: 3;z:-3),(x:-3;y:-3;z:-3),(x:-3;y:-3;z: 3),(x:-3;y: 3;z: 3)),
      ((x: 3;y:-3;z: 3),(x: 3;y: 3;z: 3),(x:-3;y: 3;z: 3),(x:-3;y:-3;z: 3)),
      ((x:-3;y:-3;z:-3),(x:-3;y: 3;z:-3),(x: 3;y: 3;z:-3),(x: 3;y:-3;z:-3)) );

  { coordonnées des milieux de chaque face pour déterminer les faces visibles }
  milieux:array[faces] of point3D=
    ((x: 0;y:-3;z: 0),(x: 3;y: 0;z: 0),(x: 0;y: 3;z: 0),
     (x:-3;y: 0;z: 0),(x: 0;y: 0;z: 3),(x: 0;y: 0;z:-3));




var
  vues3D  : array[n3D] of vue3D;
  mrot    : array[n3D] of matrice3x3;



procedure visu3D(n:n3D;theta,phi,distance:integer);

var
  tri                  : array[faces] of pour_tri;
  interm               : pour_tri;
  cos_theta,sin_theta,
  cos_phi,sin_phi      : real;
  observateur          : point3Dr;


  { calcule différentes valeurs pour la représentation 3D }
  procedure ini_mrot(n:n3D);
  begin
    cos_theta:=cos(theta*pi/180); sin_theta:=sin(theta*pi/180);
    cos_phi:=cos(phi*pi/180);     sin_phi:=sin(phi*pi/180);
    mrot[n][1,1]:=-sin_theta;
    mrot[n][1,2]:=cos_theta;
  { mrot[n][1,3]:=0; }

    mrot[n][2,1]:=-cos_theta*cos_phi;
    mrot[n][2,2]:=-sin_theta*cos_phi;
    mrot[n][2,3]:=-sin_phi;

    mrot[n][3,1]:=-cos_theta*sin_phi;
    mrot[n][3,2]:=-sin_theta*sin_phi;
    mrot[n][3,3]:=cos_phi;

    observateur.x:=10*cos_theta*cos_phi; { 15 est la distance de l'obser-  }
    observateur.y:=10*sin_theta*cos_phi; { vateur avec le centre du cube : }
    observateur.z:=10*sin_phi;           { aléatoire pourvu que ce soit en }
                                                     { dehors du cube                  }
  end;


  procedure projette(p3D:point3D;var p2D:point2Dr);
  var x,y,z:real;
  begin
    x:=mrot[n][1,1]*p3D.x+mrot[n][1,2]*p3D.y{+mrot[n][1,3]*p3D.z}; {mrot[n][1,3] est nul}
    y:=mrot[n][2,1]*p3D.x+mrot[n][2,2]*p3D.y+mrot[n][2,3]*p3D.z+distance;
    z:=mrot[n][3,1]*p3D.x+mrot[n][3,2]*p3D.y+mrot[n][3,3]*p3D.z;
    p2D.x:=x/y;
    p2D.y:=z/y;
  end;


  procedure ecran(p:point2Dr;var pe:point2D);
  begin
    with vues3D[n] do
    begin
      pe.x:=round((p.x-xmin)*xratio)+x0;
      pe.y:=round((ymax-p.y)*yratio)+y0;
    end;
  end;


  procedure projette_ecran(p3D:point3D;var p2De:point2D);
  var
    p2D:point2Dr;
  begin
    projette(p3D,p2D);
    ecran(p2D,p2De);
  end;


  procedure trace_face3D(face:faces);
  var
    p1,p2,p3,p4:point2D;
    x1,y1,x2,y2:integer;
    milieu_x,milieu_y:real;
    i,j:integer;
    une_face:array[0..3,0..3] of pointtype;
  begin
    projette_ecran(coord_faces[face,1],p1);
    projette_ecran(coord_faces[face,2],p2);
    projette_ecran(coord_faces[face,3],p3);
    projette_ecran(coord_faces[face,4],p4);


    if (abs(p1.x-p3.x)+abs(p1.y-p3.y)>3) or
      (abs(p2.x-p4.x)+abs(p2.y-p4.y)>3) then
    begin

      { calcule les coordonnées des 16 points du quadrillage d'une face }
      for i:=0 to 3 do
      begin
        x1:=p1.x+(i*(p4.x-p1.x)) div 3;
        y1:=p1.y+(i*(p4.y-p1.y)) div 3;
        x2:=p2.x+(i*(p3.x-p2.x)) div 3;
        y2:=p2.y+(i*(p3.y-p2.y)) div 3;
        for j:=0 to 3 do
          with une_face[j,i] do
          begin
           { x:=round(p1.x+i/3*(p2.x-p1.x)+j/3*(p4.x-p1.x));
             y:=round(p1.y+j/3*(p4.y-p1.y)+i/3*(p2.y-p1.y)); }
            x:=x1+(j*(x2-x1)) div 3;
            y:=y1+(j*(y2-y1)) div 3;
          end;
      end;

      { trace chaque facette }
      setcolor(noir); setlinestyle(solidln,0,normwidth);
      for i:=0 to 2 do
        for j:=0 to 2 do
        begin
          facette[1]:=une_face[i,j];
          facette[2]:=une_face[i+1,j];
          facette[3]:=une_face[i+1,j+1];
          facette[4]:=une_face[i,j+1];
          facette[5]:=facette[1];       { referme le quadrilatère (facette) }
          if monochrome     { si écran monochrome, représente les faces par }
                            { des motifs différents pour les distinguer     }
          then setfillstyle(table_motifs[rubik[face,i+1,j+1]],couleur_mono)
          else setfillstyle(solidfill,table_couleurs[rubik[face,i+1,j+1]]);
          fillpoly(5,facette);
        end;

      { trace le contour de la face en trait défini dans vues3D[n].width }
      setlinestyle(solidln,0,vues3D[n].width);
      facette[1]:={une_face[0,0]} p1;
      facette[2]:={une_face[0,3]} p2;
      facette[3]:={une_face[3,3]} p3;
      facette[4]:={une_face[3,0]} p4;
      facette[5]:=facette[1];   { referme le quadrilatère (face) }
      drawpoly(5,facette);

    end;
  end;


var                      { variables propres à la partie principale de visu3D }
  i      : integer;
  p1,p2  : point2D;
  p2D    : point2Dr;
  face   : faces;

begin { partie principale de visu3D }

  with vues3d[n] do
  begin

    { si a_tracer est vrai ou si les angles de vision ont changé,         }
    { alors on recalcule les valeurs nécessaires à la projection 2D       }
    { sinon, on évite tous ces calculs longs et déjà faits antérieurement }
    if a_tracer or (theta<>p_theta)
      or (phi<>p_phi) or (distance<>p_distance) then
    begin
      a_tracer:=false;
      p_theta:=theta;   { mémorise ancienne valeur pour évaluer la nécessité }
      p_phi:=phi;       { du recalcul de la projection                       }
      p_distance:=distance;

      ini_mrot(n);      { initialise les valeurs pour la projection }

      { cherche les valeurs minimales et maximales obtenues lors de la }
      { projection 2D pour ajuster au mieux le cube dans le cadre      }
      xmin:=1000; ymin:=1000; xmax:=-1000; ymax:=-1000;
      for i:=1 to 4 do
      begin
        projette(coord_faces[avant,i],p2D);    { utilise les coordonnées    }
        if xmin>p2D.x then xmin:=p2D.x;      { des faces avant et arriere }
        if xmax<p2D.x then xmax:=p2D.x;      {(on aurait pu choisir aussi }
        if ymax<p2D.y then ymax:=p2D.y;      { gauche et droite, ou bien  }
        if ymin>p2D.y then ymin:=p2D.y;      { dessus et dessous          }

        projette(coord_faces[arriere,i],p2D);
        if xmin>p2D.x then xmin:=p2D.x;
        if xmax<p2D.x then xmax:=p2D.x;
        if ymax<p2D.y then ymax:=p2D.y;
        if ymin>p2D.y then ymin:=p2D.y;
      end;

      { calcule l'homothétie qui permettra d'ajuster le cube dans son cadre }
      xratio:=(xmax+xmin)/2;
      xmax:=(xmax-xratio)*1.15+xratio;
      xmin:=(xmin-xratio)*1.15+xratio;
      yratio:=(ymax+ymin)/2;
      ymax:=(ymax-yratio)*1.15+yratio;
      ymin:=(ymin-yratio)*1.15+yratio;
      xratio:=lx/(xmax-xmin);
      yratio:=ly/(ymax-ymin);


      { calcul des distances milieux des faces - observateur }
      for face:=gauche to dessous do
      begin
        tri[face].d:=sqr(observateur.x-milieux[face].x)+
          sqr(observateur.y-milieux[face].y)+
          sqr(observateur.z-milieux[face].z);
        tri[face].f:=face;
      end;

      { tri à bulles : tri les faces par distances décroissantes }
      face:=gauche;
      while face<dessous do
      begin
        if tri[face].d>tri[succ(face)].d then  { échange deux faces }
        begin
          interm:=tri[succ(face)];
          tri[succ(face)]:=tri[face];
          tri[face]:=interm;
          face:=gauche;
        end
        else inc(face);
      end;


      nb:=3;        { nombre de faces à tracer: 3 par défaut, peut tomber à 1 }
      if (tri[faces(3)].d-tri[faces(2)].d)>0.1 then ordre[1]:=tri[faces(2)].f
      else nb:=2;
      if (tri[faces(2)].d-tri[faces(1)].d)>0.1 then ordre[2]:=tri[faces(1)].f
      else nb:=1;
      ordre[3]:=tri[faces(0)].f;        { la face la plus proche est toujours }
                                        { visible : on la trace en dernier    }


      { efface le rectangle (ou carré !) où va être affiché le cube }
      { et trace le cadre qui l'entoure                             }
      with vues3D[n] do
      begin
        facette[1].x:=x0;    facette[1].y:=y0;
        facette[2].x:=x0+lx; facette[2].y:=y0;
        facette[3].x:=x0+ly; facette[3].y:=y0+lx;
        facette[4].x:=x0;    facette[4].y:=y0+ly;
        facette[5].x:=x0;    facette[5].y:=y0;
        setfillstyle(solidfill,black);
        setlinestyle(solidln,0,thickwidth);
        setcolor(cadre);
      end;
      fillpoly(5,facette);

    end { fin de if a_tracer .... }
    else
      if cube_inchange then exit;   { les paramètres de visualisation sont }
                       { inchangés et le cube est inchangé : il n'y pas de }
                       { raison de le tracer une nouvelle fois !           }

    { trace les faces visibles }
    for i:=(3-nb)+1 to 3 do trace_face3D(ordre[i]);

  end;


end; { fin de visu3D }


procedure definit3D(n:n3D;_x0,_y0,_lx,_ly,_width,_cadre:integer);
begin
  with vues3D[n] do
  begin
    x0:=_x0; y0:=_y0; lx:=_lx; ly:=_ly; width:=_width; cadre:=_cadre;
    a_tracer:=true;  { si a_tracer est vrai, alors les valeurs p_...       }
  end;               { ne jouent aucun rôle : elles ne sont qu'actualisées }

end;


end.