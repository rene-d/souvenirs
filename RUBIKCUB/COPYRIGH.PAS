unit copyright;

interface
implementation

uses
  crt,dos,graph;

const
  c0='(c) 1991, René D';

var
  exitold:pointer;

{$f+} procedure myexitproc; {$f-}
var
  regs:registers;
begin
  restorecrtmode;
  directvideo:=false;
  window(1,1,80,25);

  writeln('Le Rubik''s Cube (tm) a été inventé en 1973 par M. Ernö Rubik, professeur ');
  writeln('à l''université de Prague en Tchécoslovaquie. L''intérêt qu''il a suscité à ');
  writeln('travers le monde est énorme.');
  writeln('Bien d''autres programmeurs ont élaboré des programmes de Rubik''s Cube');
  writeln('sur ordinateurs. Certains (M. Thistlethwaite) s''en sont servis pour');
  writeln('démontrer différents résultats.');
  writeln('Etudier certaines combinaisons de mouvements du cube est très pénible');
  writeln('avec un vrai cube : on a vite assez de le remonter après une fausse');
  writeln('manoeuvre. J''ai donc écrit ce programme qui était, à l''origine du moins,');
  writeln('un simple défi de programmation.');
  writeln;
  exitproc:=exitold;
end;

begin
  exitold:=exitproc;
  exitproc:=@myexitproc;
end.