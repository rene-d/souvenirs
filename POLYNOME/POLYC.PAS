unit polyc;

interface

uses polynm;

  procedure valeurC(p:polynome;rx,ix:real;var r,i:real);
  procedure sqrtc(var r,i:real);

implementation

procedure valeurC;
var
  a:real;
  k:word;
begin
  r:=0; i:=0;
  if p.deg=-1 then EXIT;
  with p do
    for k:=0 to deg do
    begin
      a:=r;
      r:=r*rx-i*ix+coef[k];
      i:=a*ix+i*rx
    end
  end;

procedure sqrtC;
begin
  if not( (r=0) and (i=0) ) then
    if (r<0) and (i=0) then
    begin
      i:=sqrt(-r);
      r:=0;
    end
    else begin
      r:=sqrt((sqrt(sqr(r)+sqr(i))+r)/2);
      i:=i/2/r;
    end;
  end;

end.
