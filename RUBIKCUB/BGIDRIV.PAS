{**************************************************************}
{********** B G I D R I V                          *** (TP) ***}
{**************************************************************}
{    Copyright (c) 1985, 89 Borland International, Inc.      OE}

UNIT Bgidriv;  { (Appelée Drivers dans version US) }
{ Unité de démonstration pour BGILINK.PAS. Elle rassemble en un seul fichier
  TPU tous les pilotes graphiques BGI disponibles. Vous pouvez ensuite
  aisément intégrer ceux-ci à votre code exécutable lors de l'édition de
  liens. Reportez-vous à BGILINK.PAS pour plus de détails.
}

INTERFACE
{PROCEDURE ATTDriverProc;}
{PROCEDURE CgaDriverProc;}
PROCEDURE EgaVgaDriverProc;
{PROCEDURE HercDriverProc;}
{PROCEDURE PC3270DriverProc;}

IMPLEMENTATION
{PROCEDURE ATTDriverProc; EXTERNAL;
{$L C:\TP\BGI\ATT.OBJ }

{PROCEDURE CgaDriverProc; EXTERNAL;
{$L C:\TP\BGI\CGA.OBJ }

PROCEDURE EgaVgaDriverProc; EXTERNAL;
{$L C:\TP\BGI\EGAVGA.OBJ }

{PROCEDURE HercDriverProc; EXTERNAL;
{$L C:\TP\BGI\HERC.OBJ }

{PROCEDURE PC3270DriverProc; EXTERNAL;
{$L C:\TP\BGI\PC3270.OBJ }

END.

{********** FIN DE BGIDRIV.PAS                        *** (TP) ***}