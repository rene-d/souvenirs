UNIT BAIRSTOW;

{ unité BAIRSTOW - version 2.0 }
{ René DEVICHI - 1990          }

{ permet de trouver les zéros réels d'un polynôme:
on place le polynôme en mémoire par InitialisePolynome()
et on obtient la racine par la function ZeroP(trouve)
trouve est un booléen qui est vrai si la valeur renvoyée est une racine,
faux s'il n'y a plus de racine ou une erreur (récupérable dans bs_erreur)
EncoreZero renvoie l'état de la pile des racines du polynôme

remarque : bs_ se rapporte aux variables de l'unité  Bairstow

PRINCIPE
il y a deux façons d'utiliser cette unité :
- en utilisant la fonction ZeroP qui renvoie, tant qu'elle le peut
les zéros du polynôme.
- en appelant SolveReel qui place dans la pile toutes les racines
du polynôme ordonnées dans le sens croissant

}



INTERFACE

uses Crt, Polynm;

const
  bs_epsilon:real=1E-5;


type
  decomposition=record
                  nb:integer;
                  z:array[1..MaxPoly] of real;
                  coef_dom:real;
                end;
  decomp=^decomposition;


var
  bs_poly:polynome;
  bs_coef_dominant:real;
  bs_erreur:integer;


procedure InitialisePile;
procedure InitialisePolynome(p:polynome);
function  EncoreZero:boolean;
function  ZeroP(var trouve:boolean):real;

procedure Ordonne(var D:decomp);
procedure SolveReel(P:polynome;var D:decomp);


IMPLEMENTATION

const
  maxpile_zeros=5;
  max_iterations=75;

var
  pile_zeros:array[1..maxpile_zeros] of real;
  pointeur_pile_zeros:integer;


{ méthode d'itérations de Bairstow pour trouver         }
{ UN polynôme X^2+pX+q qui divise le polynôme de départ }
procedure ItereBairstow(var p,q:real);
var
     a,b,c:coefficients;
     t,y,z,v,d,u:real;
     s,n,i,j,k:word;
begin
     bs_erreur:=0;
     a:=bs_poly.coef; n:=bs_poly.deg;
     if (n=1) or (n=2) then begin writeln('????'); HALT; end;
     { en principe ne se produit jamais }
     j:=0;
     repeat
          b[0]:=a[0]; b[1]:=a[1]-p*b[0];
          for k:=2 to n do b[k]:=a[k]-p*b[k-1]-q*b[k-2];
          c[0]:=b[0]; c[1]:=b[1]-p*c[0];
          for k:=2 to n-2 do c[k]:=b[k]-p*c[k-1]-q*c[k-2];
          c[n-1]:=-p*c[n-2]-q*c[n-3];
          d:=sqr(c[n-2])-c[n-1]*c[n-3];
          u:=b[n-1]*c[n-2]-b[n]*c[n-3];
          v:=b[n]*c[n-2]-b[n-1]*c[n-1];
          if d=0 then
          begin
            bs_erreur:=1;
            writeln('La méthode est inadaptée');
            exit;
          end;
          y:=u/d; z:=v/d; p:=p+y; q:=q+z;
          inc(j);
     until (j>=max_iterations) or ((abs(y)+abs(z))<bs_epsilon);
     if j>=max_iterations then
     begin
       bs_erreur:=2;
       writeln('Trop d''itérations...');
     end;
end;


procedure InitialisePile;
begin
  pointeur_pile_zeros:=0;
end;

procedure InitialisePolynome(p:polynome);
begin
  InitialisePile;
  elimine(p);
  bs_coef_dominant:=p.coef[0];
  bs_poly:=p;
end;

function EncoreZero:boolean;
begin
   encoreZero:=(bs_poly.deg>0)
end;

function ZeroP(var trouve:boolean):real;
var
  x,y:real;
  delta,x1,x2:real;
  essai:byte;
  poly_aux:polynome;
begin
    trouve:=true;
    if pointeur_pile_zeros<>0 then
    begin
      zeroP:=pile_zeros[pointeur_pile_zeros];
      dec(pointeur_pile_zeros)
    end
    else begin
      unitaire(bs_poly);
      if bs_poly.deg<=0 then
        trouve:=false
      else
        if bs_poly.deg=1 then
        begin
          zeroP:=-bs_poly.coef[1];
          constante(bs_poly,1)
        end
        else begin
          if bs_poly.deg=2 then
          begin
            x:=bs_poly.coef[1];
            y:=bs_poly.coef[2];
          end
          else begin
            essai:=0;
            repeat
              x:=2*random-1; y:=2*random-1;
              ItereBairstow(x,y);
              inc(essai);
            until (bs_erreur=0) or (essai=10);
            if (essai=10) and (bs_erreur<>0) then
            begin
              writeln('solutions introuvables');
              trouve:=false;
              exit
            end
          end;
          deg2(poly_aux,1,x,y);
          divise(bs_poly,poly_aux,bs_poly,poly_aux);
          if abs(poly_aux.coef[0])>bs_epsilon then
          begin
            writeln('aïe !');
            writeln('algorithme ou programme défectueux.');
            HALT;
          end;
          delta:=sqr(x)-4*y;
          if abs(delta)<=zero then delta:=zero;
          if delta<0 then
          begin
            zeroP:=zeroP(trouve);
            exit;
          end;
          x1:=(-x-sqrt(delta))/2; x2:=(-x+sqrt(delta))/2;
          zeroP:=x1;
          inc(pointeur_pile_zeros);
          pile_zeros[pointeur_pile_zeros]:=x2;
        end;
    end;
end; { fin de ZeroP }


procedure Ordonne(var d:Decomp);

procedure Sort(l,r: integer);
var
  i,j: integer;
  x,y: real;
begin
  with d^ do
  begin
    i := l; j := r; x := z[(l+r) div 2];
    repeat
      while z[i]<x DO i:=i+1;
      while x<z[j] DO j:=j-1;
      if i<=j then
      begin
        y:=z[i]; z[i]:=z[j]; z[j]:=y;
        i:=i+1; j:=j-1;
      end;
    until i>j;
    if l<j then sort(l,j);
    if i<r then sort(i,r);
  end;
end;

begin
  Sort(1,d^.nb);
end;



{ trouve TOUS les zéros réels de P(X) et les place, classés par ordre
  croissant dans D                                                    }
procedure SolveReel(P:polynome;var D:decomp);
var
  trouve:boolean;
  index:integer;
  r:real;
begin
  new(D);
  InitialisePolynome(P);
  with D^ do
  begin
    coef_dom:=bs_coef_dominant;
    nb:=1;
    repeat
      z[D^.nb]:=zerop(trouve);
      inc(D^.nb);
    until not trouve;
    dec(nb,2);
  end;
  ordonne(d);
end;


begin
  InitialisePile;
end.

(***************************** FIN DU MODULE ********************************)

