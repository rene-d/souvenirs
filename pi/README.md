# PI

Ce programme a calculé en 1991 lorsque j'étais en Math Spé environ 1 million de décimales, en 70 heures sur un 486DX/50 muni de 4 Mo de RAM. Ce n'est pas un record, et loin de là, mais j'étais quand même assez fier... Il faut se replacer dans le contexte de l'époque ! Maintenant, d'autres méthodes de calcul au temps d'exécution non proportionnel à n² (comme c'est la cas ici) mais à n•log n et l'augmentation spectaculaire de la puissance des machines rendent quelque peu obsolètes ces programmes.

Voici néanmoins les sources des programmes que j'avais écrits :

* [million.c](asm/million.c) : programme avec un peu de C, beaucoup d'assembleur x86. Crée un fichier pihex qui contient les «hexadécimales» de pi nécessaire pour conv.c. Se compile avec djgpp ou éventuellement gcc.
* [conv.c](asm/conv.c) : convertit pi d' « hexadécimales » en décimales. Crée un fichier pi.dec.
* [prt.c](asm/prt.c) : petit programme en C pour visualiser le fichier million.dec (i.e. pi.dec).
* [gausshex.c](c/gausshex.c) : La même chose, entièrement en C et probablement pas très optimisée, mais plus facile à comprendre. C'est le code source d'__origine__ (j'ai juste changé 2 #include).

Et des liens plus actuels:

* [Chronology of computation of π](https://en.wikipedia.org/wiki/Chronology_of_computation_of_π)
* Les [formules de Machin](https://en.wikipedia.org/wiki/Machin-like_formula) : la méthode de calcul de π utilisée ici
* [y-cruncher](http://www.numberworld.org/y-cruncher/) : le programme des records, utilise la formule de [Chudnowsky](https://en.wikipedia.org/wiki/Chudnovsky_algorithm)
* [Mini-Pi](https://github.com/Mysticial/Mini-Pi) : la version «opensource» non-optimisée de y-cruncher