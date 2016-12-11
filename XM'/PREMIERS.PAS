unit premiers;

interface
      uses crt;
function premier(e:longint):boolean;

implementation

const
  masque: array[0..7] of byte= (1,2,4,8,16,32,64,128);

type
  tab=array[0..32700] of byte;

var
  crible:tab;
  fic:file of tab;

function premier(e:longint):boolean;
begin
  if e and 1=0 then premier:=(e=2)
  else
    premier:=(crible[e shr 4] and masque[(e div 2) and 7]<>0);
end;

begin
  assign(fic,'ERATOSTH');
  reset(fic);
  read(fic,crible);
  close(fic);
end.