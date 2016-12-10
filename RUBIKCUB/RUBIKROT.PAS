unit RubikRot;        { effectue les mouvements des faces du cube    }
                      { d'apparence longue, ces routines fournissent }
interface             { en fait un code réduit et très rapide;       }
                      { l'utilisation de formules mathématiques de   }
uses                  { rotation était impensable !                  }
  RubikIni;


procedure tourne_face(face:faces;sens:boolean);

procedure rotation_cube(axe:directions;sens:boolean);

procedure rotation(face:faces;sens:boolean);



implementation


var
  tmp:col_cube;



procedure tourne_face(face:faces;sens:boolean);
var
  coul:couleurs;
begin
  if sens then
  begin
    { tourne une face dans le sens trigonométrique direct }
    coul:=rubik[face,2,1];
    rubik[face,2,1]:=rubik[face,1,2];
    rubik[face,1,2]:=rubik[face,2,3];
    rubik[face,2,3]:=rubik[face,3,2];
    rubik[face,3,2]:=coul;
    coul:=rubik[face,1,1];
    rubik[face,1,1]:=rubik[face,1,3];
    rubik[face,1,3]:=rubik[face,3,3];
    rubik[face,3,3]:=rubik[face,3,1];
    rubik[face,3,1]:=coul;
  end
  else begin
    { tourne dans le sens des aiguilles d'une montre }
    coul:=rubik[face,2,1];
    rubik[face,2,1]:=rubik[face,3,2];
    rubik[face,3,2]:=rubik[face,2,3];
    rubik[face,2,3]:=rubik[face,1,2];
    rubik[face,1,2]:=coul;
    coul:=rubik[face,1,1];
    rubik[face,1,1]:=rubik[face,3,1];
    rubik[face,3,1]:=rubik[face,3,3];
    rubik[face,3,3]:=rubik[face,1,3];
    rubik[face,1,3]:=coul;
  end;
end;




procedure prend_ligne(f:faces;n:aretes);
begin
  tmp[1]:=rubik[f,1,n];
  tmp[2]:=rubik[f,2,n];
  tmp[3]:=rubik[f,3,n];
end;

procedure prend_colonne(f:faces;n:aretes);
begin
  tmp[1]:=rubik[f,n,1];
  tmp[2]:=rubik[f,n,2];
  tmp[3]:=rubik[f,n,3];
end;

procedure met_colonne(f:faces;n:aretes;sens:boolean);
begin
  rubik[f,n,2]:=tmp[2];
  if sens then begin
    rubik[f,n,1]:=tmp[1];
    rubik[f,n,3]:=tmp[3];
  end
  else begin
    rubik[f,n,1]:=tmp[3];
    rubik[f,n,3]:=tmp[1];
  end;
end;

procedure met_ligne(f:faces;n:aretes;sens:boolean);
begin
  rubik[f,2,n]:=tmp[2];
  if sens then begin
    rubik[f,1,n]:=tmp[1];
    rubik[f,3,n]:=tmp[3];
  end
  else begin
    rubik[f,1,n]:=tmp[3];
    rubik[f,3,n]:=tmp[1];
  end;
end;

procedure ligne_colonne(f1:faces;n1:aretes;f2:faces;n2:aretes;sens:boolean);
begin
  rubik[f2,n2,2]:=rubik[f1,2,n1];
  if sens then begin
    rubik[f2,n2,1]:=rubik[f1,1,n1];
    rubik[f2,n2,3]:=rubik[f1,3,n1];
  end
  else begin
    rubik[f2,n2,1]:=rubik[f1,3,n1];
    rubik[f2,n2,3]:=rubik[f1,1,n1];
  end;
end;

procedure colonne_ligne(f1:faces;n1:aretes;f2:faces;n2:aretes;sens:boolean);
begin
  rubik[f2,2,n2]:=rubik[f1,n1,2];
  if sens then begin
    rubik[f2,1,n2]:=rubik[f1,n1,1];
    rubik[f2,3,n2]:=rubik[f1,n1,3];
  end
  else begin
    rubik[f2,1,n2]:=rubik[f1,n1,3];
    rubik[f2,3,n2]:=rubik[f1,n1,1];
  end;
end;

procedure colonne_colonne(f1:faces;n1:aretes;f2:faces;n2:aretes;sens:boolean);
begin
  rubik[f2,n2,2]:=rubik[f1,n1,2];
  if sens then begin
    rubik[f2,n2,1]:=rubik[f1,n1,1];
    rubik[f2,n2,3]:=rubik[f1,n1,3];
  end
  else begin
    rubik[f2,n2,1]:=rubik[f1,n1,3];
    rubik[f2,n2,3]:=rubik[f1,n1,1];
  end;
end;

procedure ligne_ligne(f1:faces;n1:aretes;f2:faces;n2:aretes;sens:boolean);
begin
  rubik[f2,2,n2]:=rubik[f1,2,n1];
  if sens then begin
    rubik[f2,1,n2]:=rubik[f1,1,n1];
    rubik[f2,3,n2]:=rubik[f1,3,n1];
  end
  else begin
    rubik[f2,1,n2]:=rubik[f1,3,n1];
    rubik[f2,3,n2]:=rubik[f1,1,n1];
  end;
end;

procedure inverse_lignes(face:faces);
begin
end;



procedure rotation_cube(axe:directions;sens:boolean);
var
  tmpf:faces_cube;
begin
  if sens then
    case axe of
      haut_bas : begin
          tourne_face(dessous,false);
          tourne_face(dessus,true);
          tmpf:=rubik[gauche];
          rubik[gauche]:=rubik[arriere];
          rubik[arriere]:=rubik[droite];
          rubik[droite]:=rubik[avant];
          rubik[avant]:=tmpf;
        end;
      gauche_droite : begin
          tourne_face(gauche,false);
          tourne_face(droite,true);
          tmpf:=rubik[dessus];
          rubik[dessus]:=rubik[arriere];
                                           tourne_face(dessus,true);
                                           tourne_face(dessus,true);
          rubik[arriere]:=rubik[dessous];
                                           tourne_face(arriere,true);
                                           tourne_face(arriere,true);
          rubik[dessous]:=rubik[avant];
          rubik[avant]:=tmpf;
        end;
      avant_arriere : begin
          tourne_face(avant,false);
          tourne_face(arriere,true);
          tmpf:=rubik[dessus];
          rubik[dessus]:=rubik[gauche];  tourne_face(dessus,not true);
          rubik[gauche]:=rubik[dessous]; tourne_face(gauche,not true);
          rubik[dessous]:=rubik[droite]; tourne_face(dessous,not true);
          rubik[droite]:=tmpf;           tourne_face(droite,not true);
        end;
    end
  else begin        { si rotation dans l'autre sens, on tourne 3 fois dans }
    rotation_cube(axe,true);    { le sens positif, ce qui revient au même, }
    rotation_cube(axe,true);    { est presque aussi rapide, réduit le code }
    rotation_cube(axe,true);    { et est moins long à écrire....           }
  end;
end;



procedure rotation(face:faces;sens:boolean);
begin
  if sens then  { sens direct }
  begin
    tourne_face(face,true);
    case face of
      avant:begin
        prend_ligne(dessous,3);
        colonne_ligne(gauche,3,dessous,3,false);
        ligne_colonne(dessus,1,gauche,3,true);
        colonne_ligne(droite,1,dessus,1,false);
        met_colonne(droite,1,true);
      end;
      droite:begin
        prend_colonne(dessous,3);
        colonne_colonne(avant,3,dessous,3,true);
        colonne_colonne(dessus,3,avant,3,true);
        colonne_colonne(arriere,1,dessus,3,false);
        met_colonne(arriere,1,false);
      end;
      arriere:begin
        prend_ligne(dessus,3);
        colonne_ligne(gauche,1,dessus,3,true);
        ligne_colonne(dessous,1,gauche,1,false);
        colonne_ligne(droite,3,dessous,1,true);
        met_colonne(droite,3,false);
      end;
      gauche:begin
        prend_colonne(dessus,1);
        colonne_colonne(avant,1,dessus,1,true);
        colonne_colonne(dessous,1,avant,1,true);
        colonne_colonne(arriere,3,dessous,1,false);
        met_colonne(arriere,3,not true);
      end;
      dessus:begin
        prend_ligne(arriere,3);
        ligne_ligne(droite,3,arriere,3,true);
        ligne_ligne(avant,3,droite,3,true);
        ligne_ligne(gauche,3,avant,3,true);
        met_ligne(gauche,3,true);
      end;
      dessous:begin
        prend_ligne(arriere,1);
        ligne_ligne(gauche,1,arriere,1,true);
        ligne_ligne(avant,1,gauche,1,true);
        ligne_ligne(droite,1,avant,1,true);
        met_ligne(droite,1,true);
      end;
    end;
  end
  else begin                      { même remarque que précédemment... }
    rotation(face,true);
    rotation(face,true);
    rotation(face,true);
  end;
end;


end.