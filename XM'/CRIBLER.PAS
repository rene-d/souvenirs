unit cribler;

interface

uses crt;

const
  n= 700;    (* d‚termine le nombre de nb premiers … calculer *)

function premier(e:longint):boolean;

implementation

const
  masque: array[0..7] of byte= (1,2,4,8,16,32,64,128);


type
  partie= (haut,bas);
  entier= array[partie] of word;

var
  nn: word;
  i: entier;
  crible: array[0..n] of byte;

procedure page_suivante;
begin
  readln;
  clrscr;
  gotoxy(1,1);
end;

procedure tabulation;
begin
 if wherey= 24 then
  if wherex< 70 then gotoxy(wherex+1,1)
  else page_suivante
 else gotoxy(wherex-7,wherey+1);
end;

procedure success(var p: entier);
begin
 p[bas]:= succ(p[bas]) and 7;
 if p[bas]= 0 then p[haut]:= succ(p[haut]);
end;

procedure add(var a: entier; b: entier);
var k:word;
begin
  k:= a[bas]+b[bas];
  a[haut]:= a[haut]+b[haut]+k shr 3;
  a[bas]:= k and 7;
end;

procedure doublinc(var i: entier);
var k:word;
begin
  k:= ((i[bas] shl 1) and 6) or 1;
  i[haut]:= (i[haut] shl 1)+(i[bas] shr 2);
  i[bas]:= k;
end;

procedure ecrire(p: entier);
var x: longint;
begin
  x:=16*p[haut]+2*p[bas]+1;
  write(x:7);
end;

procedure ent(e:longint;var p:entier);
begin
  p[bas]:=(e div 2) and 7;
  p[haut]:=e shr 4;
end;


function premier(e:longint):boolean;
begin
  if e and 1=0 then premier:=(e=2)
  else
    premier:=(crible[e shr 4] and masque[(e div 2) and 7]<>0);
end;


function crib(p: entier): boolean;
begin
  crib:= (crible[p[haut]] and masque[p[bas]] <> 0);
end;




procedure crib2(p: entier);
begin
 if crib(p) then
  crible[p[haut]]:= crible[p[haut]] xor (masque[p[bas]] xor 0);
end;

procedure _cribler(i: entier);
var lim: word;
    j: entier;
begin
  j:= i;
  doublinc(i);
  lim:= n-i[haut]+1;
  while j[haut]< lim do
  begin
    add(j,i);
    crib2(j);
  end;
end;


begin
  nn := succ(trunc(sqrt(n)/4));
  fillchar(crible,sizeof(crible),$FF);
  i[bas] := 1;
  i[haut] := 0;
  while (i[haut]< n) do
  begin
    tabulation;
    if i[haut]< nn then _cribler(i);
    repeat success(i);
    until crib(i);
  end;
end.

