  {  Driver pour piloter la table tracante sous turbo pascal
                 By J.P. Lefebvre  Janvier 1988              }
UNIT DRIVER30 ;

INTERFACE

Const  terminateur = ';' ;
       separateur = ',';
       Nb_Chiffres = 4;
       L_Caractere = 0.190 ;
       H_Caractere = 0.270 ;
       nb_max_grad = 40 ;
       Taille_max_Car = 500;
       Taille_min_Car = 20;

VAR  Traceur : text ;
     Chaine  : string;

Procedure FORMAT_A3;
Procedure FORMAT_A4;
Procedure INIT_TRACEUR;
Procedure PLUME_HAUTE;
Procedure PLUME_BASSE;
Procedure CHOIX_PLUME(i:integer);
Procedure FENETRE_TRC(xmin,xmax,ymin,ymax:real);
Procedure DEPLACE_TRC(x,y:real);
Procedure TRACE_TRC(x,y:real);
Procedure TRACE_TRC_R(Dx,Dy:real);
Procedure POINT_TRC(x,y :real);
Procedure CROIX_TRC(x,y,h:real);
Procedure DROITE_GRADUEE_HORIZONTALE(Xorig,Yorig,xmin,xmax,gradX:real);
Procedure DROITE_GRADUEE_VERTICALE(Xorig,Yorig,ymin,ymax,gradY:real);
Procedure TAILLE_CARACTERE(PourCent : integer);
Procedure X_AXE_TRC(xmin,xmax,grad:real);
Procedure Y_AXE_TRC(ymin,ymax,grad:real);
Procedure CADRE_GRADUE_ET_AXES( Xmin,Xmax,Ymin,Ymax,GradX,GradY : real);
Procedure RECTANGLE(x1,y1, x2,y2:real);

IMPLEMENTATION

function ROND( x : real ; p : integer ) : string ;
         var   xcar : string ;
begin
     Str(x:0:p,xcar);
     ROND:=xcar;
end;
            {--------------------------------------------------------}

Function sup(x : real ): real;
Begin
     if x=int(x) then  sup:=x
                   Else
                      if x>=0 then  sup:= int(x)+1   Else  sup:=int(x) ;
End;

Function inf(x : real ): real;
Begin
     if x=int(x) then  inf:=x
                   Else
                      if x>=0 then  inf:= int(x)   Else  inf:=int(x)-1 ;
End;

Procedure FAIRE(ch : string);
Begin
     Write(Traceur,ch);
End;

Procedure FINIR;
Begin
     FAIRE(';');
End;

Procedure FORMAT_A3;
Begin
     FAIRE('PS3;');
End;

Procedure FORMAT_A4;
Begin
     FAIRE('PS4;');
End;

Procedure INIT_TRACEUR;
Begin
     Assign(Traceur,'COM1');
     ReWrite(Traceur);
     FAIRE('IN;');
     FAIRE('CS34;');   { Choix des caractäres Francais }
     FAIRE('SP;');
End;

Procedure PLUME_HAUTE;
Begin
     FAIRE('PU;');
End;

Procedure PLUME_BASSE;
Begin
     FAIRE('PD;');
End;

Procedure CHOIX_PLUME(i:integer);
Begin
     if i in [0..6] then   begin
                                Str(i,chaine);
                                chaine:='SP'+chaine
                            end
                      Else
                            chaine:='SP';
     FAIRE(chaine+terminateur);
End;

Procedure FENETRE_TRC(xmin,xmax,ymin,ymax:real);
Begin
     xmin:=inf(xmin) ; xmax:=sup(xmax) ;
     ymin:=inf(ymin) ; ymax:=sup(ymax) ;
     chaine:='SC';
     chaine:=chaine+ROND(xmin,Nb_Chiffres)+separateur;
     chaine:=chaine+ROND(xmax,Nb_Chiffres)+separateur;
     chaine:=chaine+ROND(ymin,Nb_Chiffres)+separateur;
     chaine:=chaine+ROND(ymax,Nb_Chiffres);
     FAIRE(chaine+terminateur);
End;

 Procedure DEPLACE_TRC(x,y:real);
 Begin
      PLUME_HAUTE;
      chaine:='PU';
      chaine:=chaine+ROND(x,Nb_Chiffres)+separateur;
      chaine:=chaine+ROND(y,Nb_Chiffres);
      FAIRE(chaine+terminateur);
End;


Procedure TRACE_TRC(x,y:real);
Begin
      PLUME_BASSE;
     chaine:='PA';
      chaine:=chaine+ROND(x,Nb_Chiffres)+separateur;
      chaine:=chaine+ROND(y,Nb_Chiffres)+';';
      FAIRE(chaine);
End;

Procedure TRACE_TRC_R(Dx,Dy:real);
Begin
      PLUME_BASSE;
     chaine:='PR';
      chaine:=chaine+ROND(Dx,Nb_Chiffres)+separateur;
      chaine:=chaine+ROND(Dy,Nb_Chiffres);
      FAIRE(chaine+terminateur);
      FAIRE('PA;');
End;

Procedure POINT_TRC(x,y :real);
Begin
     DEPLACE_TRC(x,y);
     PLUME_BASSE;
End;

Procedure CROIX_TRC(x,y,h:real);
Begin
     DEPLACE_TRC(x-h,y-h);
     TRACE_TRC_R(h+h,h+h);
     PLUME_HAUTE;
     DEPLACE_TRC(x-h,y+h);
     TRACE_TRC_R(h+h,-h-h);
     PLUME_HAUTE;
End;

Procedure DROITE_GRADUEE_HORIZONTALE(Xorig,Yorig,xmin,xmax,gradX:real);

     Var  x    : real;
          k    : integer;
Begin
     If abs(gradX)<Abs(Xmax-Xmin)/nb_max_grad then
        Begin
             DEPLACE_TRC(Xmin,Yorig);
             TRACE_TRC(Xmax,Yorig);
        End
              ELSE
        Begin
            For k:=1 to 2 do
                Begin
                      DEPLACE_TRC(Xorig,Yorig);
                      x:=Xorig;
                      While (x<=xmax) and (xmin<=x) do
                          Begin
                             x:=x+gradX;
                             TRACE_TRC(x,Yorig);
                             FAIRE('XT;');
                           End;
                    gradX:=-gradX;
               End;
        End;
       PLUME_HAUTE;
End;

Procedure DROITE_GRADUEE_VERTICALE(Xorig,Yorig,ymin,ymax,gradY:real);

     Var  y    : real;
          k    : integer;
Begin
     If abs(gradY)<Abs(Ymax-Ymin)/nb_max_grad then
        Begin
             DEPLACE_TRC(Xorig,ymin);
             TRACE_TRC(Xorig,ymax);
        End
              ELSE
        Begin
            For k:=1 to 2 do
                Begin
                      DEPLACE_TRC(Xorig,Yorig);
                      y:=Yorig;
                      While (y<=ymax) and (ymin<=y) do
                          Begin
                             y:=y+gradY;
                             TRACE_TRC(Xorig,y);
                             FAIRE('YT;');
                           End;
                    gradY:=-gradY;
               End;
        End;
        PLUME_HAUTE;
End;


Procedure TAILLE_CARACTERE(PourCent : integer);
          Var  Larg , Haut   : real;
Begin
     If pourCent>taille_max_car Then pourCent:=taille_max_car;
     If pourCent<taille_min_car Then pourCent:=taille_min_car;
     Larg:=L_Caractere*pourCent/100;
     Haut:=H_caractere*pourCent/100;
     FAIRE('SI'+ROND(Larg,nb_Chiffres)+separateur+ROND(Haut,nb_Chiffres)+terminateur);
End;

Procedure ECRIS_TRC( Texte : string ; xDebut,yDebut : real ; taille : integer);
Begin
     TAILLE_CARACTERE(taille);
     DEPLACE_TRC(xDebut,yDebut);
     FAIRE('LB'+Texte);
     FAIRE(chr(3));
End;

Procedure X_AXE_TRC(xmin,xmax,grad:real);
Var   dx , dy  :real;

begin
     DROITE_GRADUEE_HORIZONTALE(0,0,xmin,xmax,grad);
     dx:=(Xmax-Xmin)/nb_max_grad ;
     dy:=dx/2;
     ECRIS_TRC('X',Xmax-dx,dy,100);
end;


Procedure Y_AXE_TRC(ymin,ymax,grad:real);
Var   dy   :real;

begin
     DROITE_GRADUEE_VERTICALE(0,0,ymin,ymax,grad);
     dy:=(Ymax-ymin)/nb_max_grad;
     ECRIS_TRC(' Y',0,Ymax-dy,100);
end;

Procedure CADRE_GRADUE_ET_AXES( Xmin,Xmax,Ymin,Ymax,GradX,GradY : real);
Begin
     DROITE_GRADUEE_HORIZONTALE(0,Ymax,Xmin,Xmax,GradX);
     DROITE_GRADUEE_HORIZONTALE(0,Ymin,Xmin,Xmax,GradX);
     DROITE_GRADUEE_VERTICALE(Xmin,0,Ymin,Ymax,GradY);
     DROITE_GRADUEE_VERTICALE(Xmax,0,Ymin,Ymax,GradY);
     X_AXE_TRC(xmin,Xmax,GradX);
     Y_AXE_TRC(Ymin,Ymax,GradY);
End;

Procedure RECTANGLE(x1,y1, x2,y2:real);
Begin
     DEPLACE_TRC(x1,y1);
     TRACE_TRC(x1,y2);
     TRACE_TRC(x2,y2);
     TRACE_TRC(x2,y1);
     TRACE_TRC(x1,y1);
End;
  END.