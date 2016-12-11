{***************************************************************************
*  TSR : une unité pour réaliser des programmes résidents en Turbo-Pascal. *
**------------------------------------------------------------------------**
*  Auteur            : MICHAEL TISCHER                                     *
*  Développé le      :  1.09.1989                                          *
*  Dernière MAJ      :  4.09.1989                                          *
***************************************************************************}

unit TSR;

{$S-R-}  { Ni pile ni contrôle des domaines de validité }

interface

uses DOS, CRT;  { Inclut les unités DOS et CRT }

{-- Déclarations des types pour appeler les procédures/fonctions publiques -}

type TsrIdStr     = string[20]; { Chaîne d'identification }
     TsrProcedure = procedure;  { Procédure TSR du programme principal }

{-- Procédures et fonctions publiques ---------------------------------}

function  TsrYetInstalled( var IDStr     : TsrIdStr ) : boolean;
function  TsrGetPtr      (     Adresse   : pointer )  : pointer;
function  TsrRemove                                   : boolean;
function  TsrShowScreen                               : boolean;
procedure TsrInstall     (     KeyState  : word;
                               ActKey    : byte;
                               Call      : TsrProcedure );
procedure TsrNewKey      (     NewStatus : word;
                               NewScan   : byte );

{-- Variables globales et constantes typées publiques --------------------}

const TsrHercPage : integer = 0;  { Page Hercules en le mode graphique (0/1) }

{-- Constantes publiques -------------------------------------------------}

      {-- Scan codes des différentes touches -----------------------------}

const SC_ESC             = $01;      SC_W               = $2C;
      SC_1               = $02;      SC_X               = $2D;
      SC_2               = $03;      SC_C               = $2E;
      SC_3               = $04;      SC_V               = $2F;
      SC_4               = $05;      SC_B               = $30;
      SC_5               = $06;      SC_N               = $31;
      SC_6               = $07;      SC_VIRGULE         = $32;
      SC_7               = $08;      SC_POINTVIRGULE    = $33;
      SC_8               = $09;      SC_2POINTS         = $34;
      SC_9               = $0A;      SC_POINDEX         = $35;
      SC_0               = $0B;      SC_SHIFT_DROIT     = $36;
      SC_PARENDROITE     = $0C;      SC_PRINT_SCREEN    = $37;
      SC_EGAL            = $0D;      SC_ALT             = $38;
      SC_BACKSPACE       = $0E;      SC_ESPACE          = $39;
      SC_TAB             = $0F;      SC_CAPS            = $3A;
      SC_A               = $10;      SC_F1              = $3B;
      SC_Z               = $11;      SC_F2              = $3C;
      SC_E               = $12;      SC_F3              = $3D;
      SC_R               = $13;      SC_F4              = $3E;
      SC_T               = $14;      SC_F5              = $3F;
      SC_Y               = $15;      SC_F6              = $40;
      SC_U               = $16;      SC_F7              = $41;
      SC_I               = $17;      SC_F8              = $42;
      SC_O               = $18;      SC_F9              = $43;
      SC_P               = $19;      SC_F10             = $44;
      SC_CIRCONFLEX      = $1A;      SC_NUM_LOCK        = $45;
      SC_DOLLAR          = $1B;      SC_SCROLL_LOCK     = $46;
      SC_RETURN          = $1C;      SC_CURSOR_HOME     = $47;
      SC_CONTROL         = $1D;      SC_CURSOR_UP       = $48;
      SC_Q               = $1E;      SC_CURSOR_PG_UP    = $49;
      SC_S               = $1F;      SC_NUM_MINUS       = $4A;
      SC_D               = $20;      SC_CURSOR_LEFT     = $4B;
      SC_F               = $21;      SC_NUM_5           = $4C;
      SC_G               = $22;      SC_CURSOR_RIGHT    = $4D;
      SC_H               = $23;      SC_NUM_PLUS        = $4E;
      SC_J               = $24;      SC_CURSOR_END      = $4F;
      SC_K               = $25;      SC_CURSOR_DOWN     = $50;
      SC_L               = $26;      SC_CURSOR_PG_DOWN  = $51;
      SC_M               = $27;      SC_INSERT          = $52;
      SC_UACCENT         = $28;      SC_DELETE          = $53;
      SC_PLUSGRAND       = $29;      SC_SYS_REQUEST     = $54;
      SC_SHIFT_GAUCHE    = $2A;      SC_F11             = $57;
      SC_ETOILE          = $2B;      SC_F12             = $58;

      {-- Représentation binaire des touches de contrôle ------------------}

const LSHIFT =     1;    { Touche SHIFT gauche }
      RSHIFT =     2;    { Touche SHIFT droite }
      CTRL   =     4;    { Touche CTRL }
      ALT    =     8;    { Touche ALT }
      SYSREQ =  1024;    { Touche SYS-REQ sur les AT }
      BREAK  =  4096;    { Touche BREAK }
      NUM    =  8192;    { Touche NUM }
      CAPS   = 16384;    { Touche CAPS }

      NOKEY  = 128;      { Absence de touche à scan code }

implementation

{$L tsra}    { Incorpore le module en assembleur }

{-- Constantes internes au module ----------------------------------------}

const MONO_ADR_REG   = $3b4;   { Adresses des différents ports permettant }
      MONO_DATA_REG  = $3b5;   { d'accéder directement aux cartes vidéo }
      LP_RESET_LATCH = $3bb;
      LP_TRIGGER     = $3ba;
      LP_SET_LATCH   = $3b9;
      MONO_STATUS    = $3ba;
      MONO_COMD      = $3b8;
      VGA_GC_ADR     = $3ce;
      VGA_GC_DATA    = $3cf;
      VGA_SQ_ADR     = $3c4;
      VGA_SQ_DATA    = $3c5;
      HERC_CONF      = $3bf;

{-- Déclarations de types internes au module -----------------------------}

type VioSaveBuf  = array [$0000..$3fff] of byte;{16 Ko de la mémoire vidéo}
     VSPtr       = ^VioSaveBuf;  { Pointe sur la mémoire vidéo physique }
     VideoCartes = ( MDA, CGA, HERC, EGA, VGA, UNKNOWN );
     PSP         = record  { Emule le PSP }
                     dummy  : array [0..$2b] of byte;{champs sans importance}
                     EnvSeg : word;      { Segment de l'environnement }
                   end;
     PSPPTR      = ^PSP;  { Pointe sur le PSP }
     HiLo        = record {Décompose un mot en octets de poids faible et fort}
                     LoByte,
                     HiByte : byte;
                   end;


{-- Variables globales internes au module ---------------------------------}

var {-- Variables pour sauvegarder et restaurer l'écran et son contexte ---}

    VideoCarte  : VideoCartes;    { Carte vidéo actuelle }
    VideoMode,   { N° du mode vidéo initial }
    LignesEcran,   { Nombre de lignes d'écran (<>0 : EGA, VGA) }
    VideoPage   : byte;  { N° de la page d'écran initiale }
    InGrafic    : boolean;  { Mode graphique actif ? }
    CurStartEnd,   { Lignes de balayage de début et de fin du curseur }
    CurPos      : word;    { Position du curseur }
    PalRegs     : array [1..17] of byte;   { Palette VGA }
    DACRegs     : array [1..768] of byte;   { Couleurs VGA-DAC }
    SaveBuf     : VioSaveBuf;  { Buffer pour sauver la mémoire vidéo }
    VioPtr      : VSPtr;    { Pointe sur la mémoire vidéo }

    {-- Variables servant à gérant le changement de contexte DOS --------}

    TsrStackSeg,  { Segement de pile du présent programme }
    TsrStackOFs,  { Pointeur de pile du présent programme }
    TsrDTAOfs,    { Adresse du DTA du présent programme }
    TsrDTASeg,
    TsrPSP,       { Segment du PSP du programme courant }
    OldTsrPSP   : word;  { Segment d'une version déjà installée }
    TsrProc     : TsrProcedure;   { Procédure TSR du programme principal }

{-- Déclarations des routines externes du module en assembleur -----------}

procedure key_mask                             ; external;
procedure scan_code                            ; external;
procedure TsrAInit( KeyState : word;
                    ActKey   : byte )          ; external;
function  TsrRestoreVec               : boolean; external;

{***************************************************************************
*  IsHercInGraph : Indique si la carte Hercules installée fonctionne en    *
*                  mode graphique ou en mode texte                         *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Sortie : TRUE = mode graphique actif , FALSE = mode texte               *
*  Info    : Le numéro de la page active ne peut pas être renseigné        *
***************************************************************************}

function IsHercInGraph : boolean;

var LpPos : record  { Offset du crayon optique en mémoire vidéo  }
              case boolean of
                TRUE  : ( LoB, HiB : byte );  { Position sous forme de deux octets }
                FALSE : ( LpWord : integer ); { Position sous forme de mot unique }
              end;

begin
  port[ LP_RESET_LATCH ] := 0;   { Initialise le registre du crayon optique }

  {-- Attend le début, puis la fin du retour de balayage vertical du faisceau d'électrons }
  
  while ( port[ LP_TRIGGER ] and $80 <> 0 ) do ;  { Début }
  while ( port[ LP_TRIGGER ] and $80 = 0 ) do ;   { Fin }

  {-- Attend le début du prochain retour de balayage vertical et simule  --}
  {-- le déclenchement du crayon lumineux pour obtenir sa position       --}
  {-- et en déduire la taille de la mémoire vidéo et par conséquent      --}
  { -- le mode vidéo de la carte }
  inline ($fa); { cli, interdit les interruptions }

  while ( port[ LP_TRIGGER ] and $80 <> 0 ) do ;  { Attend le début }
  port[ LP_SET_LATCH ]:=0;  { Fixe la position du crayon }

  inline ($fb);  { sti, autorise à nouveau les interruptions }

  {-- Lit la position du crayon dans les registres $10 et $11  -----}
  {-- du contrôleur vidéo -----}

  port[ MONO_ADR_REG ] := $10;   { Position, octet de poids fort }
  LpPos.HiB := port[ MONO_DATA_REG ];
  port[ MONO_ADR_REG ]:=$11;  { Position, octet de poids faible  }
  LpPos.LoB := port[ MONO_DATA_REG ];

  IsHercInGraph := ( LpPos.LpWord ) > ( 45 * 87 );
end;

{***************************************************************************
*  GetVideoData : indique le type et le mode de la carte vidéo installée   *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Variables globales : VideoCarte/W, VideoMode/W, VideoPage/W,            *
*                       LignesEcran/W, VioPtr/W, InGrafic/W,               *
***************************************************************************}

procedure GetVideoData;

const VGAVioTab : array [0..12] of VideoCartes =
                   ( UNKNOWN, MDA    , CGA    , UNKNOWN, EGA    ,
                     EGA,     UNKNOWN, VGA    , VGA    , UNKNOWN,
                     CGA,     CGA,     CGA                      );

var Regs   : Registers;  { Registres pour gérer les interruptions }
    i      : integer;  { Compteur }
    Status : byte;   { Port d'état MDA-/Hercules }

begin
  VideoCarte := UNKNOWN;  { Carte inconuue pour le moment }

  Regs.AH := $0f;  { N° de la fonction "Lire le mode vidéo " }
  Intr( $10, Regs ); { Interruption vidéo du BIOS }
  VideoMode := Regs.AL and $7f;  { Mémorise le mode, supprime le bit 7 }
  VideoPage := Regs.BH;  { Stocke la page d'écran }

  Regs.AH := $03;  { N° de la fonction "Lire la position du curseur " }
  Intr( $10, Regs );  { Déclenche l'interruption }
  CurStartEnd := Regs.CX;  { Mémorise les lignes de balayage de début et de fin du curseur }
  CurPos      := Regs.DX;   { Stocke la position du curseur }

  Regs.AX := $1a00;  { La fonction 1A n'existe que pour les cartes VGA }
  Intr( $10, Regs );
  if ( Regs.AL = $1a ) then  { La fonction est-elle disponible ? }
    begin  { Oui, VGA, le code de la carte active est en BL }
      if ( Regs.BL <> $ff ) then   { Carte connue ? }
        VideoCarte := VGAVioTab[ Regs.BL ] { Oui, l'identifie dans le tableau }
    end
  else  { Pas de VGA, est-ce une EGA? }
    begin
      Regs.ah := $12;  { Fonction 12h Option 10 h }
      Regs.bl := $10;   
      intr($10, Regs);  { Déclenche l'interruption vidéo du BIOS }
      if Regs.bl <> $10 then { Y-a-t il une carte EGA ? }
        VideoCarte := EGA; { Oui }
    end;

  {-- Vérifie si la carte EGA ou VGA ne se trouve pas en mode graphique }
  if ( VideoCarte = EGA ) or ( VideoCarte = VGA ) then
    begin
      LignesEcran := Mem[ $40 : $84 ]; { Nombre de lignes d'écran }
      if ( VideoMode > 7 ) then  { En mode graphique ? }
        begin  { Oui }
          InGrafic := TRUE;
          VioPtr   := Ptr( $a000, $0000 );
        end
      else   { Non, en mode texte }
        begin
          InGrafic := FALSE;
          VioPtr   := Ptr( $b800, $0000 );
        end;
    end;

  if ( VideoCarte = UNKNOWN ) then  { Carte vidéo inconnue ? }
   if ( MemW[ $0040:$0063 ] = MONO_ADR_REG ) then  { Est-elle monochrome ? }
     begin { Oui, il doit s'agir d'une carte MDA ou Hercules }
       VioPtr := Ptr( $b000, $0000 );

       {-- Pour distinguer une carte MDA d'une carte Hercules, il faut examiner -}
       {-- le bit 7 du registre d'état du contrôleur vidéo -}
       {-- Le contenu de ce bit varie si la carte est Hercules -}

       Status := port [ MONO_STATUS ] and $80;  { Lit le port d'état du contrôleur vidéo }
       i := 0;
       while ( port[ MONO_STATUS ] and $80 = Status ) and ( i < 32767 )
         do inc( i );

       if ( i = 32767 ) then { Le bit a-t-il varié ? }
         VideoCarte := MDA  { Non -> MDA }
       else  { Oui, il doit s'agir d'une carte Hercules }
         begin
           VideoCarte := HERC;
           InGrafic := IsHercInGraph; { Détermine le mode graphique éventuel }
           if InGrafic then  { Si carte Hercules en mode graphique  }
             VioPtr := Ptr( $b000 + $800 * TsrHercPage, 0 ); {Tient compte de la page }
         end;
     end
   else   { Il s'agit d'une carte CGA }
     begin
       VideoCarte := CGA;
       InGrafic   := ( VideoMode >= 4 ) and ( VideoMode <= 6 );
       VioPtr     := Ptr( $b800, $0000 );
     end
end;

{***************************************************************************
*  PutHerc2Graph : Remet la carte Hercules en mode graphique               *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Info    : - Pour rétablir le mode texte d'une carte Hercules, il suffit *
*              d'appeler la fonction 00H du BIOS vidéo                     *
*            - La page graphique activée est celle qui correspond au       *
*              numéro indiqué par la variable TsrHercPage .                *
***************************************************************************}

procedure PutHerc2Graph;

const CrtRegs : array[0..11] of byte = { Valeurs pour le registre du contrôleur vidéo }
              ( 53,  45,  46,   7,  91,   2,  87,  87,   2,   3,   0,   0 );

var i : integer;  { Compteur d'itérations }

begin
  port[ HERC_CONF ] := 1 + ( TsrHercPage * 2 );  { Active la page }

  port[ MONO_COMD ] := $02; { Interrompt le rafraîchissement de l'écran }

  for i:= 0 to 11 do   { Parcourt les différents registres du contrôleur }
    begin
      port[ MONO_ADR_REG ]  := i;  { Numéro du registre }
      port[ MONO_DATA_REG ] := CrtRegs[ i ];   { Valeur envoyée au port de données }
    end;

  port[ MONO_COMD ] := $0A + (TsrHercPage * $80);  { Rétablit le rafraîchissement de l'écran }
end;

{***************************************************************************
*  SetVioMode : Fixe un nouveau mode vidéo                                 *
**------------------------------------------------------------------------**
*  Entrée : MODENUM  = Numéro du mode vidéo                                *
***************************************************************************}

procedure SetVioMode( ModeNum : byte );

var Regs : Registers;  { Registres pour gérer les interruptions  }

begin
  Regs.AX := ModeNum;   { AH = 0, AL = numéro du mode }
  Intr( $10, Regs );
end;

{***************************************************************************
*  SaveVideoContext : Sauvegarde le contexte de l'écran actuel             *
*                     et déclenche le mode vidéo 80*25 caractères .        *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Info    : Le contexte vidéo peut être restauré par ResetVideoContext    *
*  Variables globales : PalRegs/W, DACRegs/W                               *
***************************************************************************}

procedure SaveVideoContext;

var Regs : Registers;  { Registres pour gérer les interruptions }

begin
  GetVideoData;  { Détermine le type de carte vidéo et d'autres informations }
  if ( VideoCarte = VGA ) then  { A-t-on une carte VGA ? }
    begin { Oui, sauvegarde registres palette et DAC }
      Regs.AX := $1009;  { Sauve 16 registres de palette et le registre de la couleur de bordure }
      Regs.DX := Ofs( PalRegs ); { Charge l'adresse du buffer en ES:DX }
      Regs.ES := Seg( PalRegs );
      intr( $10, Regs );

      Regs.AX := $1017; { Sauve les registres DAC }
      Regs.BX := 0;     { à partir du premier }
      Regs.CX := 256;   { et jusqu'au 256e }
      Regs.DX := Ofs( DACRegs ); { Charge l'adresse du buffer en ES:DX }
      Regs.ES := Seg( DACRegs );
      intr( $10, Regs );
    end;

  if (( VideoCarte = EGA ) or ( VideoCarte = VGA )) and InGrafic then
    begin   { Sauvegarde des parties de plans de bits }

      {-- En mode texte, les caractères situés dans la mémoire vidéo }
{ à partir du segment $B800 sont reproduits dans le premier plan de bits  }
      {-- Les 4 premiers Ko de ce plan sont sauvegardés .   }

      portw[ VGA_GC_ADR  ] := $0005;  { Mode de lecture 0 }
      portw[ VGA_GC_ADR  ] := $0004;  { du plan de bits n°0 }
      move( VioPtr^, SaveBuf[0], $1000 );

      {-- Les attributs des caractères sont reproduits dans le plan }
{ de bits n°1  }
      {-- Les 4 premiers Ko de ce plan sont copiés dans le buffer SaveBuf }


      portw[ VGA_GC_ADR  ] := $0104;  { Active le plan de bits n°1 }
      move( VioPtr^, SaveBuf[$1000], $1000 );

      {-- Les caractères définis par l'utilisateur sont reproduits }
      { dans le plan de bits n°2 . Comme ils occupent jusqu'à 8 Ko  } 
      {-- on copie dans le buffer les 8 premiers Ko du plan n° 2 }
      portw[ VGA_GC_ADR  ] := $0204; { Active le plan de bits n°2 }
      move( VioPtr^, SaveBuf[$2000], $2000 );

      SetVioMode( $83 );   { Active le mode texte 80x25 caractères }
                           { sans effacer la mémoire vidéo (plans de bits)}
      ClrScr;  { Efface l'écran }
    end
  else   { L'écran doit être sauvegardé }
    begin
      SaveBuf := VioPtr^;  { Copie 16 Ko de mémoire vidéo dans le buffer }
      if ( VideoCarte = MDA ) or ( VideoCarte = HERC ) then
        SetVioMode( 7 )  { Active le mode monochrome }
      else
        SetVioMode( 3 );
    end;

  Regs.AX := $0500;  { Recherche la page 0 }
  Intr( $10, Regs );
end;


{***************************************************************************
*  RestoreVideoContext : Restaure le mode vidéo initial ainsi que tous     *
*                        les paramètres sauvegardés par                    *
*                        SaveVideoKontext                                  *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Variables globales : VideoCarte/R, VideoPage/R, CurStartEnd/R, CurPos/R,*
*                       VioPtr/R, SaveBuf/R, PalRegs/R, DACRegs/R          *
***************************************************************************}

procedure RestoreVideoContext;

var Regs : Registers; { Registres pour gérer les interruptions }

begin
  if (( VideoCarte = EGA ) or ( VideoCarte = VGA )) and InGrafic then
    begin  { EGA et VGA en mode graphique }
      SetVioMode( $80 or VideoMode ); { Rétablit le mode vidéo d'origine }

      portw[ VGA_GC_ADR  ] := $0005;  { Mode écriture 0 }
      portw[ VGA_GC_ADR  ] := $ff08;  { Met $ff dans le registre de masquage }

      {-- Recopie les 4 premiers Ko de SaveBuff  ----}
      {-- dans le plan de bit n°0 } 

      port[ VGA_SQ_ADR  ] := $02;   { Désactive les plans de bits n° 1 à 3 }
      port[ VGA_SQ_DATA ] := $01;   { en appliquant le masque $01  }
      move( SaveBuf[0], VioPtr^, $1000);

      {-- Recopie la deuxième tranche de 4 Ko de SaveBuf dans ---}
      {-- le plan de bit n° 1 }

      port[ VGA_SQ_ADR  ] := $02;   { Désactive les plans de bits n° 0,2,3 }
      port[ VGA_SQ_DATA ] := $02;   { en appliquant le masque $02 }
      move( SaveBuf[$1000], VioPtr^, $1000 );

      {-- Recopie à leur emplacement d'origine les 8 Ko    }
      {-- sauvegardés du plan de bits n° 2 }                       

      port[ VGA_SQ_ADR  ] := $02;  { Désactive les plans de bits n°0,1,3 }
      port[ VGA_SQ_DATA ] := $04;  { en appliquant le masque $04 }
      move( SaveBuf[$2000], VioPtr^, $2000 );

      port[ VGA_SQ_ADR  ] := $02; { Réactive tous les plans de bits }
      port[ VGA_SQ_DATA ] := $0f; { en remettant les valeurs par défaut }
    end
  else  { Autres cartes ou EGA/VGA en mode texte }
    begin
      if ( VideoCarte = HERC ) and InGrafic then  { Graphique Hercules ? }
        PutHerc2Graph { Oui, rétablit le mode graphique }
      else  { Autres cartes en mode texte ou graphique }
        SetVioMode( VideoMode ); { Restaure l'ancien mode vidéo }
      VioPtr^ := SaveBuf;  { Recopie 16 Ko du buffer dans la mémoire vidéo }
    end;

  {-- Rend leurs valeurs initiales aux registres de palettes et aux registres DAC des cartes VGA ----------}

  if ( VideoCarte = VGA ) then { A-t-on une carte VGA ? }
    begin   { Oui, restaure les registres }
      Regs.AX := $1002; { Charge les 16 registres de palette et le registre de la couleur de bordure }
      Regs.DX := Ofs( PalRegs );  { Met l'adresse du buffer en ES:DX }
      Regs.ES := Seg( PalRegs );
      intr( $10, Regs );

      Regs.AX := $1012;  { Charge les registres DAC }
      Regs.BX := 0;      { en commençant par le premier }
      Regs.CX := 256;    { et en allant jusqu'au dernier }
      Regs.DX := Ofs( DACRegs ); { Met l'adresse du buffer en ES:DX }
      Regs.ES := Seg( DACRegs );
      intr( $10, Regs );
    end;

  {-- Reprend la page d'écran initiale, repositionne le curseur ---}
  {-- en lui rendant son aspect d'origine ---}

  if ( ( VideoCarte = EGA ) or ( VideoCarte = VGA ) ) and
       ( LignesEcran > 25 ) and ( InGrafic = FALSE ) then
    begin  { Rétablit le mode 43/50 lignes }
      Regs.AX := $1112;  { N° de la fonction "Activer le jeu de caractères 8x8" }
      Regs.BL := 0;  { Première table de caractères }
      intr( $10, Regs );
    end;

  Regs.AH := 5;  { N° de la fonction "Fixer la page d'écran" }
  Regs.AL := VideoPage;
  Intr( $10, Regs );

  Regs.AH := 1;  { N° de la fonction "Définir l'aspect de l'écran " }
  Regs.CX := CurStartEnd;  { Ligne de début et de fin de balayage }
  Intr( $10, Regs );

  Regs.AH := 2;  { N° de la fonction "Positionner le curseur " }
  Regs.BH := VideoPage;   { Page d'écran concernée }
  Regs.DX := CurPos;    { Position à établir }
  Intr( $10, Regs );
end;

{***************************************************************************
*  TsrGetPtr : fournit un pointeur sur une variable du programme résident  *
*              installé en mémoire centrale                                *
**------------------------------------------------------------------------**
*  Entrée : ADRESSE = Adresse de la variable à l'intérieur de la version   *
*                     du programme en cours d'exécution                    *
*  Sortie : Pointeur sur la variable à l'intérieur du programme installé   *
*  Info   : Avant d'appeler cette fonction, il faut s'assurer par          *
*           TsrYetInstalled qu'il existe bien une copie du programme       *
*           résident en mémoire centrale                                   *
*  Variables globales : OldTsrPSP/R                                        *
***************************************************************************}

function TsrGetPtr( Adresse : pointer ) : pointer;

begin
  TsrGetPtr := ptr(OldTsrPSP + ( Seg(Adresse^)-PrefixSeg ), Ofs(Adresse^));
end;

{***************************************************************************
*  TsrYetInstalled : Détecte la présence du programme résident installé    *
**------------------------------------------------------------------------**
*  Entrée : IDStr = Chaîne d'identification                                *
*  Sortie : TRUE, si le programme a été trouvé, sinon FALSE                *
*  Variable globale : OldTsrPSP/W                                          *
***************************************************************************}

function TsrYetInstalled( var IDStr : TsrIdStr ) : boolean;

type MCB       = record  { Reproduit un MCB }
                   IdCode : char;  {"M" = existe successeur, "Z" = Dernier MCB }
                   PSP : word;{ Segment du PSPassocié  }
                   Paras : word;   { Nombre de paragraphes du bloc contrôlé }
                 end;
     MCBPTR    = ^MCB; { Pointe sur un MCB }
     MCBPTRPTR = ^MCBPTR; { Pointe sur un pointeur de MCB }
     STRPTR    = ^TsrIdStr; { Pointe sur une chaîne d'identification }

var Regs     : Registers;  { Registres pour gérer les interruptions }
    ActMCB   : MCBPTR;   { Pointe sur le MCB courant }
    PSPFound : word;     { Segment du PSP du programme trouvé }
    Fin     : boolean;   { Dernier MCB atteint }

begin
  {-- Détermine un pointeur sur le premier MCB -------------------------}

  Regs.AH := $52;  { La fonction $52 renvoie l'adresse du DIB }
  MsDos( Regs );
  ActMCB := MCBPTRPTR( ptr( Regs.ES, Regs.BX-4 ) )^;

  {-- Passe en revue les différents MCB --------------------------}

  Fin     := FALSE;
  PSPFound := 0; { Le programme n'a pas encore été trouvé }

  repeat
    {-- Vérifie si la chaîne d'identification se trouve } 
    {-- dans le bloc géré par le MCB et si le cas échéant il ne }
    {-- s'agit pas du programme en cours d'exécution  }

    if (STRPTR( Ptr(Seg(IDStr)-PrefixSeg+ActMCB^.PSP, Ofs(IDstr)))^ = IDStr)
       and ( ActMCB^.PSP <> PRefixSeg ) then
      PSPFound := ActMCB^.PSP; { On a trouvé une copie du programme  }

    if ( ActMCB^.IDCode = 'Z' ) then  { Dernier MCB ? }
      Fin := TRUE  { Oui, la recherche est terminée }
    else  { Non, fait pointer ACtMCB sur le MCB suivant }
      ActMCB := ptr( Seg(ActMCB^) + ActMCB^.Paras + 1, 0 );
  until ( PSPFound <> 0 ) or Fin;

  OldTsrPSP := PSPFound;  { Mémorise le segement du programme }
  TsrYetInstalled := ( PSPFound <> 0 );  { PSPFound <> 0 --> Programme trouvé }
end;

{***************************************************************************
*  DummyHandler : nouveau gestionnaire des interrruptions $1b et $23.      *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Info    : N'est actif que pendant l'exécution du programme résident !   *
***************************************************************************}

procedure DummyHandler; interrupt;

begin
end;

{***************************************************************************
*  CritErrHandler : Nouveau gestionnaire de l'interruption $24 déclenchée  *
*                   par les erreurs critiques                              *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Info    : N'est actif que pendant l'exécution du programme résident !   *
***************************************************************************}

procedure CritErrHandler( Flags, CS, IP, AX, BX, CX ,
                          DX, SI, DI, DS, ES, BP : HiLo ); interrupt;

begin
  AX.LoByte := 3;  { Arrête la fonction DOS où est survenue l'erreur  }
end;               { avec un code erreur }

{***************************************************************************
*  TsrStart : Appelé par le module en assembleur lorsque l'utilisateur     *
*             actionne la touche d'activation                              *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Variables globales : TsrPSP/R, TsrDTAOfs/R, TsrDTASeg/R, TsrProc/R      *
***************************************************************************}

procedure TsrStart;

var Regs       : Registers;  { Registres pour gérer les interruptions }
    DTASeg,  { Adresse du DTA de l'application interrompue }
    DTAOfs,
    PSP        : word; { Segment du PSP de l'application interrompue }
    OldCritErr,  { Pointe sur l'ancien gestionnaire des erreurs critiques }
    OldBreak,    { Pointe sur l'ancien gestionnaire de Break }
    OldCBreak  : pointer;  { Pointe sur l'ancien gestionnaire de Ctrl Break }

begin
  {-- Remplace le gestionnaire de Ctrl-Break et le gestionnaire des erreurs critiques ---------------------}
  GetIntVec( $23, OldCBreak );
  SetIntVec( $23, @DummyHandler );
  GetIntVec( $1b, OldBreak );
  SetIntVec( $1b, @DummyHandler );
  GetIntVec( $24, OldCritErr );
  SetIntVec( $24, @CritErrHandler );

  {-- Lit l'adresse du segment du PSP de l'application interrompue --------}
  Regs.AH := $51; { N° de la fonction "Get PSP" }
  MsDos( Regs );
  PSP := Regs.BX; { Segment du PSP }

  {-- Recherche l'adresse du DTA de l'application interrompue -------------}
  Regs.AH := $2f;  { N° de la fonction "Rechercher l'adresse du DTA " }
  MsDos( Regs );
  DTASeg := Regs.ES; { Segment du DTA }
  DTAOfs := Regs.BX; { Offset du DTA }

  {-- Fixe le PSP du programme --------------------------------------------}
  Regs.AH := $50; { N° de la fonction "Fixer le PSP " }
  Regs.BX := TsrPSP;  { Segment du PSP de Turbo Pascal }
  MsDos( Regs );

  {-- Fixe le DTA du programme --------------------------------------------}
  Regs.AH := $1a;  { N° de la fonction "Fixer le DTA " }
  Regs.DX := TsrDTAOfs;  { Charge en DS:DX un pointeur sur le DTA }
  Regs.DS := TsrDTASeg;
  MsDos( Regs );

  {-- Prépare l'appel de la procédure résidente ---------------------------}
  SaveVideoContext;  { Sauvegarde l'écran et son contexte }
  TsrProc;  { Déclenche la procédure résidente }
  RestoreVideoContext;  { Restaure l'écran et son contexte }

  {-- Réactive le DTA de l'application interrompue ------------------------}
  Regs.AH := $1a; { N° de la fonction "Fixe le DTA " }
  Regs.DX := DTAOfs;  { Charge en DS:DX un pointeur sur le DTA }
  Regs.DS := DTASeg;
  MsDos( Regs );

  {-- Rétablit le PSP de l'application interrompue -----------------------}
  Regs.AH := $50;  { N° de la fonction "Fixer le PSP" }
  Regs.BX := PSP;  { Segment du PSP initial }
  MsDos( Regs );

  {-- Restaure le gestionnaire d'interruption de Ctrl-Break et celui des erreurs critiques -------}
  SetIntVec( $23, OldCBreak );
  SetIntVec( $1b, OldBreak );
  SetIntVec( $24, OldCritErr );
end;

{***************************************************************************
*  TsrShowScreen : Ramène sur l'écran le contenu sauvegardé par            *
*                  SaveVideoContext lorsque c'est possible                 *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Sortie : TRUE, si la carte vidéo se trouvait en mode texte au moment de *
*           l'activation du programme résident, sinon  FALSE               *
*  Variables globales : VideoCarte/R, VioPtr/R, SaveBuf/R                  *
***************************************************************************}

function TsrShowScreen : boolean;

var Result : boolean;

begin
  if ( VideoCarte = MDA ) or ( VideoCarte = CGA ) then
   Result := TRUE  { Pas de problème avec les cartes MDA et CGA }
  else   { Avec les cartes HERC, EGA et VGA il faut que le mode texte ait été actif }
   Result := ( InGrafic = FALSE );
  if Result then   { Affichage possible ? }
    VioPtr^ := SaveBuf; { Oui, recopie le buffer en mémoire vidéo }
  TsrShowScreen := Result;
end;

{***************************************************************************
*  TsrInstall : Installe le programme à titre résident                     *
**------------------------------------------------------------------------**
*  Entrée : KEYSTATE = Etat de la touche de contrôle qui doit activer le   *
*                      programme résident                                  *
*            ACTKEY  = Scan code de la touche à combiner avec la touche    *
*                      de contrôle pour activer le programme               *
*            CALL    = Procédure TSR à activer                             *
*  Info   : - La procédure ne rend pas la main au programme appelant mais  *
*             met fin à l'exécution du programme                           *
*           - La constante NOKEY peut être transmise comme paramètre       *
*             ACTKEY si aucune touche n'est à associer aux touches de      *
*             commande                                                     *
*  Variables globales : TsrProc/W                                          *
***************************************************************************}

procedure TsrInstall( KeyState : word; ActKey : byte; Call : TsrProcedure );

begin
  TsrProc := Call; { Mémorise la procédure à appeler }
  TsrAInit( KeyState, ActKey );  { Initialise le module en assembleur }
  Keep(0);   { Rend le programme résident }
end;





{***************************************************************************
*  TsrNewKey : Change la touche d'activation d'un programme résident       *
*              déjà installé                                               *
**------------------------------------------------------------------------**
*  Entrée : NEWSTATUS = nouveau masque définissant les touches de contrôle *
*            NEWSCAN   = nouveau scan code de la touche associée           *
*  Info    : Avant d'appeler cette procédure il faut s'assurer par         *
*            TsrYetInstalled qu'il existe bien une copie du programme      *
*            résident en mémoire                                           *
*  Variables globales : OldTsrPSP/R                                        *
***************************************************************************}

procedure TsrNewKey( NewStatus : word; NewScan : byte );

type WORDP = ^word;
     BYTEP = ^byte;

begin
  {-- Les deux arguments sont reportés dans les variables key_mask et --}
  {-- scan_code qui se trouvent dans le module en assembleur -}

  WORDP(TsrGetPtr( @key_mask ))^  := NewStatus;
  BYTEP(TsrGetPtr( @scan_code ))^ := NewScan;
end;

{***************************************************************************
*  TsrRemove : Retire de la mémoire une version installée du programme     *
*              résident                                                    *
**------------------------------------------------------------------------**
*  Entrée : néant                                                          *
*  Sortie : TRUE en cas de succès, FALSE si le programme n'a pas pu être   *
*            désinstallé en raison du recouvrement par un autre programme  *
*            résident.                                                     *
*  Info    : Avant d'appeler cette procédure il faut s'assurer par         *
*            TsrYetInstalled qu'il existe bien une copie du programme      *
*            résident en mémoire                                           *
*  Variables globales : OldTsrPSP/R                                        *           *
***************************************************************************}

function TsrRemove : boolean;

var Regs : Registers;  { Registres pour gérer les interruptions }

begin
  if TsrRestoreVec then { Rétablit les anciens gestionnaires d'interruption }
    begin  { Tout est o.k. }
      {-- Libère le bloc d'environnement du programme par l'intermédiaire de }
      {-- la fonction $49 de DOS }

      Regs.AH := $49; { N° de fonction DOS }
      Regs.ES := PSPPTR(ptr(OldTsrPSP, 0))^.EnvSeg; { Segment du PSP }
      MsDos( Regs );

      {-- Libère la mémoire occupée par l'ancien programme -----------------}

      Regs.AH := $49; { N° de fonction DOS }
      Regs.ES := OldTsrPSP;  { Segment de la mémoire allouée }
      MsDos( Regs );
      TsrREmove := TRUE; { Programme retiré avec succès }
    end
  else   { Le programme a été court-circuité par un autre programme résident  }
    TsrRemove := FALSE;
end;

{***************************************************************************
*  TsrInit : Procédure d'initialisation interne destinée à mémoriser       *
*            diverses informations indispensables au programme résident    *
**------------------------------------------------------------------------**
*  Entrée             : néant                                              *
*  Variables globales : TsrPSP/W, TsrDTAOfs/W, TsrDTASeg/W, TsrStackSeg/W, *
*                       TsrStackOfs/W                                      *
***************************************************************************}

procedure TsrInit;

var Regs : Registers;   { Registres pour gérer les interruptions }

begin
  TsrStackSeg := SSeg;  { Pile de Turbo Pascal }
  TsrStackOfs := SPtr;

  TsrPSP := PrefixSeg;   { Segment du PSP }

  {-- Recherche l'adresse du DTA avant de la stocker }
  Regs.AH := $2f;  { N° de la fonction "Chercher l'adresse du DTA " }
  MsDos( Regs );
  TsrDTASeg := Regs.ES;  { Segment du DTA }
  TsrDTAOfs := Regs.BX;  { Offset du DTA }
end;

{**----------------------------------------------------------------------**}
{** Code de démarrage de l'unité                                         **}
{**----------------------------------------------------------------------**}

begin
  TsrInit;
end.


