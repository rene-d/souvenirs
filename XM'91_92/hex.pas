{$D-,S-,V-} {no debug information, no stack-checking, no var-string checking}
unit HEX;
interface

  type str8=string[8];

  function hexa(long:byte;nbr:longint):str8;

implementation

  function hexa(long:byte;nbr:longint):str8;
  var
    i:byte;
    resul:str8;
  begin
    resul:='';
    for i:=0 to long-1 do
      resul:=copy('0123456789ABCDEF',1+(nbr shr (4*i)) and $F,1)+resul;
    hexa:=resul;
  end;

end.