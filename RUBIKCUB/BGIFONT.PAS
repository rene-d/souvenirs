{**************************************************************}
{********** B G I F O N T                          *** (TP) ***}
{**************************************************************}
{    Copyright (c) 1985, 89 Borland International, Inc.      OE}

UNIT Bgifont;   { (Appelée Fonts dans version US) }
{ Unité de démonstration pour BGILINK.PAS. Elle rassemble en un seul fichier
  TPU toutes les polices graphiques BGI disponibles. Vous pouvez ensuite
  aisément intégrer celles-ci à votre code exécutable lors de l'édition de
  liens. Reportez-vous à BGILINK.PAS pour plus de détails.
}

INTERFACE

{PROCEDURE GothicFontProc;}
PROCEDURE SansSerifFontProc;
{PROCEDURE SmallFontProc;}
{PROCEDURE TriplexFontProc;}

IMPLEMENTATION

{PROCEDURE GothicFontProc; EXTERNAL;
{$L c:\tp\bgi\GOTH.OBJ }

PROCEDURE SansSerifFontProc; EXTERNAL;
{$L c:\tp\bgi\SANS.OBJ }

{PROCEDURE SmallFontProc; EXTERNAL;
{$L c:\tp\bgi\LITT.OBJ }

{PROCEDURE TriplexFontProc; EXTERNAL;
{$L c:\tp\bgi\TRIP.OBJ }

END.

{********** FIN DE BGIFONT.PAS                         *** (TP) ***}