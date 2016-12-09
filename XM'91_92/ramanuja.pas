program ramanujan;

 uses crt;

  const siz=200;

  type nb=array[0..siz] of byte;


  var a,b,c:nb;
      i,j,k:integer;

  procedure zero(var a:nb);
    var i:integer;
      begin
        for i:=0 to siz do a[i]:=0
      end;

  procedure show(a:nb);
    var i:integer;
      begin
        write(a[0],',');
        for i:=1 to siz do write(a[i]);
        writeln
      end;

  procedure add(var a:nb;b,c:nb);      {* a=b+c *}
    var i:integer;
        x:byte;
      begin
        x:=0;
        for i:=siz downto 1 do begin
                                 x:=b[i]+c[i]+x;
                                 a[i]:=x mod 10;
                                 x:=x div 10;
                               end;
        a[0]:=b[0]+c[0]+x
      end;

  procedure addecal(var a:nb;b,c:nb;k:integer); {* a=b+c.10^-k *}
    var i:integer;
        x:byte;
      begin
        if k=0 then add(a,b,c)
               else begin
                      x:=0;
                      for i:=siz downto k do begin
                                               x:=b[i]+c[i-k]+x;
                                               a[i]:=x mod 10;
                                               x:=x div 10;
                                             end;
                      for i:= k-1 downto 1 do begin
                                                x:=b[i]+x;
                                                a[i]:=x mod 10;
                                                x:=x div 10;
                                              end;
                      a[0]:=b[0]+x;
               end
      end;

  procedure mul(var a:nb;b,c:nb);     {* a=b*c  b<1 *}
    var d:nb;
        i:integer;
        x:byte;
      begin
        d:=b;
        zero(a);
        for x:=1 to 9 do begin
                           for j:=0 to siz do if c[j]=x then addecal(a,a,d,j);
                           add(d,d,b);
                         end
      end;

  procedure mulsc(var a:nb;b:nb;k,n:integer);  {* a=b*k.10^-n *}
    var i,j:integer;
      begin
        zero(a);
        j:=0;
        for i:=siz downto n do begin
                                 j:=b[i-n]*k+j;
                                 a[i]:=j mod 10;
                                 j:=j div 10;
                               end;
        if n=0 then a[0]:=a[0]+j*10
               else begin
                      i:=n-1;
                      while ((j<>0) and (i>-1)) do begin
                                                     a[i]:=j mod 10;
                                                     j:=j div 10;
                                                     i:=i-1;
                                                   end;
                    end
      end;

  procedure sub(var a:nb;b,c:nb);  {* a=b-c *}
    var x,i,y:integer;
      begin
        x:=0;
        for i:=siz downto 0 do begin
                                 y:=b[i]-c[i]-x;
                                 x:=0;
                                 while y<0 do begin
                                                x:=x+1;
                                                y:=y+10;
                                              end;
                                 a[i]:=y;
                               end
      end;

  procedure subsc(var a:nb;x:integer;c:nb); {* a=x-c *}
    var b:nb;
      begin
        zero(b);
        b[0]:=x;
        sub(a,b,c)
      end;

  procedure inv(var a:nb;b:nb);   {* a=1/b *}
    var x:nb;
        i:integer;
        t:real;
      begin
        zero(a);
        t:=b[0]+0.1*b[1]+0.01*b[2];
        t:=1/t;
        a[0]:=trunc(t);
        a[1]:=trunc((t-a[0])*10);
        a[2]:=trunc((t-a[0])*100-a[1]*10);
        for i:= 1 to 10 do begin
                             mul(x,b,a);
                             subsc(x,2,x);
                             mul(a,x,a);
                           end
      end;

  procedure sqrtn(var a:nb;b:nb);     {* a=sqrt(b) *}
    var x:nb;
        i:integer;
        t:real;
      begin
        zero(a);
        t:=b[0]+0.1*b[1]+0.01*b[2];
        t:=sqrt(t);
        a[0]:=trunc(t);
        a[1]:=trunc((t-a[0])*10);
        a[2]:=trunc((t-a[0])*100-a[1]*10);
        for i:= 1 to 10 do begin
                             inv(x,a);
                             mul(x,x,b);
                             add(x,x,a);
                             mulsc(a,x,5,1);
                           end
      end;


begin
 clrscr;
 a[0]:=0;
 for i:=1 to siz do a[i]:=trunc(5*cos(i)+5);
 for i:=0 to siz do b[i]:=trunc(5*sin(i)+5);
 show(a);
 show(b);
 add(c,a,b);
 show(c);
 addecal(c,a,b,1);
 show(c);
 mul(c,a,b);
 show(c);
 mulsc(c,b,25,2);
 show(c);
{ inv(c,a);
 show(c);
 inv(c,b);
 show(c);
 inv(c,c);
 show(c); }
 sqrtn(c,b);
 show(c);
 repeat until keypressed;
 end.