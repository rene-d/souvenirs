#! /bin/bash
# convertit les fichiers MSDOS (CP437, CRLF et ^Z) en fichiers UTF-8 Unix

for i in $*; do
	[ -f ${i}.old ] && continue
	mv $i ${i}.old
	cat ${i}.old | iconv -f cp437 -t utf-8 | tr -d '\032\r' > $i
	touch -r $i.old $i
done