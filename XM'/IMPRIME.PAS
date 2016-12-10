

const
  XMaxGlb       = 79;    { Number of bytes -1 in one screen line }
  XScreenMaxGlb = 639;   { Number of pixels -1 in one screen line }
  YMaxGlb       = 349;   { Number of lines -1 on the screen }
  ScreenSizeGlb = 16383; { Total size in integers of the screen }
  GrafBase      = $A000;  { Segment location of the hardware screen }



procedure hardcopy(inverse:boolean); { EPSON }
  var i,j,top:integer;
      ColorLoc,PrintByte:byte;

function PD(X, Y : integer) : boolean;
{ Return true if the color of the pixel at (X, Y) matches ColorGlb }
begin
  PD := (ColorLoc = 0) xor (Mem[GrafBase:Y*80 + X shr 3]
                       and (128 shr (X and 7)) <> 0);
end; { PD }


  procedure doline(top:integer);
  var j:integer;
    function ConstructByte(j,i:integer):byte;
      const Bits:array [0..7] of byte=(128,64,32,16,8,4,2,1);
      var CByte,k:byte;
      begin
        i:=i shl 3;
        CByte:=0;
        for k:=0 to top do
          if PD(j,i+k) then CByte:=CByte or Bits[k];
        ConstructByte:=CByte;
      end;
    begin
      write(lst,^['L');
      write(lst,chr(lo(XScreenMaxGlb+1)),chr(Hi(XScreenMaxGlb+1)));
      for j:=0 to XScreenMaxGlb do
       begin
        PrintByte:=ConstructByte(j,i);
        if inverse then PrintByte:=not PrintByte;
        write(lst,chr(PrintByte));
       end;
      writeln(lst);
    end;

  begin
    top:=7;
    ColorLoc:=255;
    write(lst,^['3'#24);
    for i:=0 to ((YMaxGlb+1) shr 3)-1 do doline(7);
    i:=((YMaxGlb+1) shr 3);
    if (YMaxGlb+1) and 7<>0 then
      doline((YMaxGlb+1) and 7);
    writeln(lst,^['2');
  end;
