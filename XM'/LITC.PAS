program LitC;

uses crt,dos;

const
  sec_by_cyl:word=17;
  sec_by_clu:word=4;
  sides:byte=5;
  cyl_by_side:word=976;
  bytes_by_sec:word=512;
  sectors:longint=82960;
  n_reserv:word=1;
  n_fat:byte=2;
  sec_by_fat:word=81;
  first_sec:word=17;
  files_in_root:word=512;
  clusters:word=20688;
  bytes_by_cluster:word=2048;
  signature_boot=$aa55;


type
  style=(idem,ascii0,ascii,hexadecimal,decimal,ascii2);
  sector=record side:byte;cyl,sec:word; end;
  string3=string[3];
  string8=string[8];
  ttime=record hour,min,sec:word; end;
  tdate=record year,month,day:word; end;
  tentry=array[0..31] of byte;


  zaza=array[0..511] of byte;
var
  bboot,buf:zaza;
  clu:array[0..2047] of byte;
  regs:registers;

  boot:sector;


procedure int_13;
var
  regs2:registers;
begin
  with regs do
  begin
    regs2:=regs;
    intr($13,regs);
    if flags and 1=1 then { si une erreur on essaie encore une fois }
    begin
      regs:=regs2;
      intr($13,regs);
      if flags and 1=1 then
      begin
        write('erreur d''accŠs nø',ah,'  : ');
        case ah of
          $80 : writeln('Time-out');
        else writeln('???');
        end;
        halt;
      end;
    end;
  end;
end;


function hexa(long:byte;nbr:longint):string;
var
  i:byte;
  resul:string;
begin
  resul:='';
  for i:=0 to long-1 do
    resul:=copy('0123456789ABCDEF',1+(nbr shr (4*i)) and $F,1)+resul;
  hexa:=resul;
end;

function deci(long:integer;nbr:longint):string;
var
  s:string;
begin
  str(nbr,s);
  while copy(s,1,1)=' ' do delete(s,1,1);
  if long<0 then while length(s)<-long do insert(' ',s,1)
  else  while length(s)<long do insert('0',s,1);
  deci:=s;
end;

procedure writetst(s:string);
var
  i:integer;
begin
  for i:=1 to length(s) do
    if byte(s[i]) in [0,7,9,10,13] then write(' ')
    else write(s[i]);
end;

procedure pause;
var regs:registers;
begin
  regs.ah:=$00;
  intr($16,regs);
end;

function to_word(n:word):word;
begin
  to_word:=256*word(bboot[n+1])+word(bboot[n]);
end;


procedure display_sector(s:style);
var i,j:integer;
begin
  case s of
    idem : begin for i:=0 to 511 do write(chr(buf[i])); end;
    ascii : begin
      for i:=0 to 511 do
        if not (buf[i] in [0,7,9,10,13]) then
          write(char(buf[i]))
        else
          write('.');
        writeln;
    end;
    ascii2 : begin
      for i:=0 to 511 do
        if not (buf[i] in [0,7,9,10,13]) then write(char(buf[i]));
        writeln;
      end;
    hexadecimal : begin
      for i:=0 to 31 do
      begin
        write(hexa(4,i*16),'  ');
        for j:=0 to 15 do
        begin
          write(hexa(2,buf[i*16+j]));
          if j=7 then write('-') else write(' ');
        end;
        write('  ');
        for j:=0 to 15 do
          if not (buf[i*16+j] in [0,7,9,10,13]) then
            write(char(buf[i*16+j]))
          else write('.');
        writeln;
        if i=15 then readln;
      end;
    end;
  end;
end;


procedure display_cluster(s:style);
var
  n,i,j:word;
begin
  n:=bytes_by_sec*sec_by_clu;
  case s of
    idem : begin for i:=0 to n-1 do write(chr(clu[i])); end;
    ascii : begin
      for i:=0 to n-1 do
        if not (clu[i] in [0,7,9,10,13]) then
          write(char(clu[i]))
        else
          write('.');
        writeln;
    end;
    ascii0 : begin
      for i:=0 to 2047 do
      begin
        if not (clu[i] in [7]) then write(char(clu[i]))
        else write('.'); if i mod 250=0 then pause; end;
        writeln;
    end;
    ascii2 : begin
      for i:=0 to 2047 do
        if not (clu[i] in [0,7,9,10,13]) then write(char(clu[i]));
        writeln;
      end;
    hexadecimal : begin
      for i:=0 to 2048 div 16-1 do
      begin
        write(hexa(4,i*16),'  ');
        for j:=0 to 15 do
        begin
          write(hexa(2,clu[i*16+j]));
          if j=7 then write('-') else write(' ');
        end;
        write('  ');
        for j:=0 to 15 do
          if not (clu[i*16+j] in [0,7,9,10,13]) then
            write(char(clu[i*16+j]))
          else write('.');
        writeln;
        if (i+1) mod 16=0 then readln;
      end;
    end;
  end;
end;


procedure read_sec(f,p,s:word);
var
  regs2:Registers;
begin
  with regs do
  begin
    ah:=$02;
    al:=$01;
    cl:=s;     { secteur }
    ch:=lo(p); { piste   }
    if p>255 then  cl:=cl or ((hi(p) and $03) shl 6);
    dh:=f;     { face    }
    dl:=$80;   { lecteur }
    es:=seg(buf);
    bx:=ofs(buf);
    regs2:=regs;
    int_13;
  end;
end;

function cherche(s:string):boolean;   { cherche une chaŒne dans un secteur }
var i,p:word;
begin
  for p:=0 to 511-length(s) do
  begin
    i:=1;
    while buf[p+i-1]=byte(s[i]) do inc(i);
    if i>=length(s) then
    begin
      cherche:=true;
      exit;
    end;
  end;
  cherche:=false;
end;


procedure read_partition(display_partition:boolean); { sector (0,0,1) }
var
  i,o,w,sec,cyl:word;
begin
  read_sec(0,0,1);
  if buf[$1fe]+256*buf[$1ff]<>signature_boot then
    writeln('Attention : le secteur (0,0,1) n''est pas un secteur "boot".');

  sectors:=0;
  for i:=0 to 3 do
  begin
    o:=i*16+$1be;
    if buf[o]=$80 then
    begin
      sec:=buf[o+2] and $3f;
      cyl:=buf[o+3]+((buf[o+2] and $c0) shl 2);
      boot.side:=buf[o+1];
      boot.cyl:=cyl;
      boot.sec:=sec;
    end;
    inc(sectors,buf[o+$0c]+buf[o+$0d]*256+(buf[o+$0e]+buf[o+$0f]*256)*$10000);
  end;

  if display_partition then
  begin
    writeln('------------------------------------------------------------------');
    writeln('|                       TABLE DE PARTITION                       |');
    writeln('------------------------------------------------------------------');
    writeln('|No|type      |status    |d‚but     |fin       |premier |nombres |');
    writeln('------------------------------------------------------------------');
    for i:=0 to 3 do
    begin
      o:=$1be+i*16;
      write('|',1+i:2,'|');
      case buf[o+4] of
        $00:write('libre     |');
        $01:write('dos+fat12 |');
        $02:write('xenix     |');
        $03:write('xenix     |');
        $04:write('dos+fat16 |');
        $05:write('dos ext   |');
        $06:write('big dos   |');
        $db:write('concurrent|');
        else write('???       |');
      end;
      if buf[o]=$80 then write('boot      |') else write('non active|');
      w:=buf[o+2]+buf[o+3]*256;
      sec:=w and $3f;
      cyl:=hi(w)+((w and $c0) shl 2);
      write('(',buf[o+1],',',cyl:3,',',sec:2,')|');

      w:=buf[o+6]+buf[o+7]*256;
      sec:=w and $3f;
      cyl:=hi(w)+((w and $c0) shl 2);
      write('(',buf[o+5],',',cyl:3,',',sec:2,')|');

      write(buf[o+$08]+buf[o+$09]*256+(buf[o+$0a]+buf[o+$0b]*256)*$10000:8,'|');
      writeln(buf[o+$0c]+buf[o+$0d]*256+(buf[o+$0e]+buf[o+$0f]*256)*$10000:8,'|');
    end;
    writeln('------------------------------------------------------------------');
    writeln;
  end;
end;


procedure read_boot(affichage_boot:boolean);
var
  i:integer;
begin
  with boot do read_sec(side,cyl,sec);
  bboot:=buf;

  sec_by_clu:=bboot[$0d];
  sec_by_cyl:=to_word($18);
  sides:=to_word($1a);
  inc(sectors,to_word(28));
  cyl_by_side:=sectors div (sides*sec_by_cyl);
  bytes_by_sec:=to_word($0b);
  bytes_by_cluster:=bytes_by_sec*sec_by_clu;
  sec_by_fat:=to_word($16);
  n_fat:=bboot[$10];
  n_reserv:=to_word($0e);
  first_sec:=to_word($1c);
  files_in_root:=to_word($11);
  clusters:=(sectors-first_sec-n_reserv-sec_by_fat*n_fat
       -(files_in_root*32) div bytes_by_sec) div sec_by_clu+1;



  { writeln(to_word($20)+to_word($22)*$10000);  { dos 4.0 : nb total de secteurs }
  { writeln(to_word($1c)+to_word($1e)*$10000);  { dos 4.0 : nb de secteurs sp‚ciaux }

  if affichage_boot then
  begin
    if bboot[0]=$E9 then
writeln('adresse de la routine boot                 : $',hexa(4,to_word(1)+3))
    else
      if bboot[0]=$eb then
writeln('adresse de la routine boot                 : $',hexa(4,bboot[1]+2))
      else
        writeln('instruction de saut pour la routine boot   : ',
          hexa(2,bboot[0]),' ',hexa(2,bboot[1]),' ',hexa(2,bboot[2]));
    write  ('message de copyright                       : ');
    for i:=0 to 7 do write(char(bboot[i+3])); writeln;
    writeln('octets par secteur                         : ',to_word(11));
    writeln('secteurs par cluster                       : ',bboot[13]);
    writeln('nombre de secteurs r‚serv‚s                : ',to_word(14));
    writeln('nombre de copies de la FAT                 : ',bboot[16]);
    writeln('nombre d''entr‚es dans le r‚pertoire racine : ',to_word(17));
    writeln('nombre total de secteurs                   : ',to_word(19));
    write('descripteur de support (ID)                : $',hexa(2,bboot[21]));
    if bboot[21]=$f8 then writeln(' (disque dur)') else writeln;
    writeln('nombre de secteurs par FAT                 : ',to_word(22));
    writeln('nombre de secteurs par piste               : ',to_word(24));
    writeln('nombre de tˆtes de lecture/‚criture        : ',to_word(26));
    writeln('premier secteur                            : ',to_word(28));
    writeln;
  end;
end;


procedure read_abs(n:longint);
var
  sec:sector;
begin
  with sec do
  begin
    side:=(n div sec_by_cyl) mod sides;
    cyl:=(n div sec_by_cyl) div sides;
    sec:=(n mod sec_by_cyl)+1;
  end;
  with sec do read_sec(side,cyl,sec);
end;


procedure read_sec_fat(n:word); { n between 0 and sec_by_fat-1 }
begin
  read_abs(first_sec+n_reserv+n);
end;

function read_fat(n:word):word; { n=num‚ro de cluster entre 2 et ??? }
begin
  read_sec_fat(n*2 div bytes_by_sec);
  read_fat:=buf[n*2 mod bytes_by_sec]+256*buf[n*2 mod bytes_by_sec+1];
end;


procedure initialization;
begin
  read_partition(false);
  read_boot(false);
  read_sec_fat(0);
  if (buf[0]<>$f8) or (buf[1]<>$ff) or (buf[2]<>$ff) or (buf[3]<>$ff) then
    writeln('ATTENTION : la FAT ne contient pas les codes F8 FF FF FF.');
end;


procedure characteristics;
begin
  writeln('Disque dur :');
  writeln('nombre de faces                 : ',sides);
  writeln('nombre de cylindres par face    : ',cyl_by_side);
  writeln('nombre de secteurs par cylindre : ',sec_by_cyl);
  writeln('nombre total de secteurs        : ',sectors);
  writeln('capacit‚ totale en octets       : ',sectors*bytes_by_sec,' (',
     (sectors*bytes_by_sec div 1024)/1024:0:2,' Mo)');
  writeln;
  writeln('secteurs par cluster            : ',sec_by_clu);
  writeln('nombre de clusters              : ',clusters);
end;





function cluster(n:word):longint;
begin
  cluster:=first_sec+n_reserv+n_fat*sec_by_fat
     +(files_in_root*32) div bytes_by_sec+(n-2)*sec_by_clu;
end;

procedure read_clu(n:word);
var
  s:longint;
  sec,cyl,side:word;
  regs2:registers;         i:word;
begin
  s:=cluster(n);
 side:=(s div sec_by_cyl) mod sides;
  cyl:=(s div sec_by_cyl) div sides;
  sec:=(s mod sec_by_cyl)+1;
  with regs do
  begin
    ah:=$02;
    al:=sec_by_clu;
    cl:=sec;     { secteur }
    ch:=lo(cyl); { piste   }
    if cyl>255 then  cl:=cl or ((hi(cyl) and $03) shl 6);
    dh:=side;     { face    }
    dl:=$80;   { lecteur }
    es:=seg(clu);
    bx:=ofs(clu);
    int_13;
  end;
  (*read_abs(s);  for i:=0 to 511 do clu[i]:=buf[i];
  read_abs(s+1);for i:=512 to 1023 do clu[i]:=buf[i-512];
  read_abs(s+2);for i:=1024 to 1535 do clu[i]:=buf[i-1024];
  read_abs(s+3);for i:=1536 to 2047 do clu[i]:=buf[i-1536];*)
end;


var
  line:string;

procedure set_line(n:integer;s:string);
var
  i:integer;
begin
  if n=0 then begin line[0]:=#75; for i:=1 to 75 do line[i]:=#32; end
  else for i:=n to n+length(s)-1 do line[i]:=s[i-n+1];
end;


procedure dir_entry(n:word;mask:byte;var buffer);
var
  entry:tentry absolute buffer;
  typ:byte;
  name:string8; ext:string3;
  attr:byte;
  date:tdate; time:ttime;
  clu:word;
  taille:longint;
  y,i:word;
begin
  typ:=entry[0];
  name[0]:=#8; for i:=0 to 7 do name[i+1]:=chr(entry[i]);
  ext[0]:=#3; for i:=0 to 2 do ext[i+1]:=chr(entry[i+8]);
  attr:=entry[$0b];
  clu:=entry[$1a]+256*entry[$1b];
  taille:=entry[$1c]+word(entry[$1d])*256+(entry[$1e]+entry[$1f]*256)*$10000;
  with time do
  begin
    hour:=entry[$17] shr 3;
    min:=entry[$16] shr 5+(entry[$17] and 7) shl 3;
    sec:=(entry[$16] and $1f)*2;
  end;
  with date do
  begin
    year:=entry[$19] shr 1+1980;
    month:=entry[$18] shr 5+(entry[$19] and 1) shl 4;
    day:=entry[$18] and $1f;
  end;

  if (typ<>0) and ((mask and attr)<>0) then
  begin
    set_line(0,'');
    set_line(1,deci(-4,n));
    if typ=$05 then name[1]:=chr($e5);
    set_line(6,name);
    set_line(14,' '+ext);
    if (attr and $10)=$10 then set_line(21,'<REP>');
    if (attr and $08)=$08 then set_line(26,'<VOL>');
    set_line(33,'....');
    if (attr and $01)=$01 then set_line(33,'R');
    if (attr and $02)=$02 then set_line(34,'H');
    if (attr and $04)=$04 then set_line(35,'S');
    if (attr and $20)=$20 then set_line(36,'A');
    set_line(38,deci(-7,taille));
    set_line(47,'['+deci(-5,clu)+']');
    set_line(56,deci(2,date.day)+'/'+deci(2,date.month)+'/'+deci(4,date.year));
    set_line(69,deci(-2,time.hour)+':'+deci(2,time.min)+':'+deci(2,time.sec));
  end;
end;

procedure read_sec_root(n:word);
begin
  read_abs(first_sec+n_fat*sec_by_fat+n_reserv+n);
end;


procedure dir_root;
var
  s,i,nf:word;
begin
  nf:=0;
  writeln('R‚pertoire ROOT (i.e.: C:\) :');
  writeln;
  for s:=0 to ((files_in_root*32) div bytes_by_sec)-1 do
  begin
    read_sec_root(s);
    for i:=0 to (bytes_by_sec div 32)-1 do
    begin
      inc(nf);
      if buf[i*32]=0 then exit;
      if (buf[i*32]<>$e5) then begin dir_entry(nf,$3f,buf[i*32]); writeln(line); end;
        if nf mod 22=0 then
        begin
          write('<strike any key to continue>');
          pause; write(#13);
        end;
    end;
  end;
end;


procedure dir_sub(n:word);  { beginning cluster }
var
  s,i,nf:word;
begin
  if n<2 then dir_root
  else begin
    nf:=0;
    writeln('Sous-r‚pertoire :');
    writeln;
    while n<$fff0 do
    begin
      read_clu(n);
      for i:=0 to ((bytes_by_sec*sec_by_clu) div 32)-1 do
      begin
        inc(nf);
        if clu[i*32]=0 then exit;
        if (clu[i*32]<>$e5) then begin dir_entry(nf,$3f,clu[i*32]); writeln(line); end;
        if nf mod 22=0 then
        begin
          write('<strike any key to continue>');
          pause; write(#13);
        end;
      end;
    end;
  end;
end;


procedure read_file(n:word;size:longint);
begin
  if size=-1 then size:=4000000; { about maximun size }
  while (n<$fff0) and (size>0) do
  begin
    read_clu(n); n:=read_fat(n);
    if size>bytes_by_cluster then display_cluster(hexadecimal)
    else display_cluster(hexadecimal);
    dec(size,bytes_by_cluster);
  end;
end;


procedure transfer_file(n:word;size:longint;name:string);
var
  fil:file;
begin
  assign(fil,name);
  rewrite(fil,1);
  while (n<$fff0) and (size>0) do
  begin
    read_clu(n); n:=read_fat(n);
    if size>bytes_by_cluster then blockwrite(fil,clu,bytes_by_cluster)
    else blockwrite(fil,clu,size);
    dec(size,bytes_by_cluster);
  end;
  close(fil);
end;



{-------------------------------------------------------------}

procedure ligne(y:integer);
var
  i:integer;
begin
  gotoxy(1,y);
  for i:=1 to 80 do write(#196);
end;


procedure menu;
var s:string;
begin
  ligne(23);
  window(1,24,80,25);
  gotoxy(1,24);  clrscr;
  repeat
    textcolor(red); write('Commande >> ');
    textcolor(blue); readln(s)
  until s='FIN';
end;

var i,j:integer;    f:file of zaza;
begin
  initialization;
read_sec(0,0,1);
assign(f,'a:s-0-0-1');
rewrite(f); write(f,buf);
close(f);
display_sector(hexadecimal);
with boot do read_sec(side,cyl,sec);
assign(f,'a:s-boot-1');
rewrite(f); write(f,buf);
close(f);
end.
