/*

    GAUSSHEX.C
    version 1.0 du 19 octobre 1991
    Turbo C++ sous MSDOS 5.00
    (c) René DEVICHI 1990, 1991

    Formule de Gauss:
        π=48*Arctan(1/18)+32*Arctan(1/57)-20*Arctan(1/239)

    Méthode de calcul:

    ■ Le développement en série entière d'Arctan donne:
        Arctan(1/t)=t∙Σ (-1)ⁿ∙(1/t²)^(n+1)/(2n+1)

    ■ D'où:
        π=Σ (-1)ⁿ/(2n+1)∙
           [(48∙18∙(1/18²)^(n+1)+32∙57∙(1/57²)^(n+1)-20∙239∙(1/239²)^(n+1)]

    ■ Le reste de la série est majoré par (1/18²)ⁿ, ce qui fournit
    un test d'arrêt pour la précision voulue.

*/

#include <stdio.h>
#include <string.h>
#include <alloc.h>
#include <process.h>
#include <time.h>
#include <math.h>


#define word        unsigned int
#define dword       long int
#define udword      unsigned dword
#define reelsize    (nbdec+1)*sizeof(word)

int		nbdec;				/* nombre de tranches à calculer */

void	affiche(word *reel);
void	temps(double diff);


void main(void)
{
	/* variables */
	/*-----------*/

    word    *p239;          /* tableau des puissances de (1/239²) */
    word    *p57;           /* puissances de (1/57²) */
    word    *p18;           /* puissances de (1/18²) */
    word    *temp;          /* somme intermédiaire */
    word    *pihex;         /* pi en "hexadécimales" */
    word    *pidec;         /* pi en "décimales" */
    /* NB: seulement au plus cinq tableaux sont utilisés en même temps */

    int     i239=0;         /* position du 1er chiffre non nul dans p239 */
    int     i57=0;          /* position du 1er chiffre non nul dans p57 */
    int     i18=0;          /* position du 1er chiffre non nul dans p18 */
    int     indice=1;       /* indice de la somme (2n+1) */
	int     signe=1;        /* signe de la suite ((-1)^n) */

	int     i,j;            /* variables de calcul */
	dword   r,tmp;  		
    udword  ur,utmp;
    int     test1,test2;
	time_t  t1;				/* temps de chronométrage */
	char	ouinon;

    FILE    *stream;


	/* affiche premier message */
	/*-------------------------*/

	printf("Calcul de pi par la formule de Gauss\n");
	printf("pi/4 = 12 Arctan 1/18 + 8 Arctan 1/57 - 5 Arctan 1/239\n");
	printf("(c) René DEVICHI octobre 1991 - v1.0 Turbo C++\n\n");

	do{
		printf("Nombre de tranches de 4 décimales à calculer : ");
		scanf("%d",&nbdec);
	} while ((nbdec<10)||(nbdec>30000));


	/* réserve de la mémoire pour les variables */
    /*------------------------------------------*/

	if( ((pihex = malloc(reelsize)) == NULL) ||
		((p57   = malloc(reelsize)) == NULL) ||
		((p18   = malloc(reelsize)) == NULL) ||
		((temp  = malloc(reelsize)) == NULL) ||
		((p239  = malloc(reelsize)) == NULL)){
			printf("Pas assez de mémoire pour mener le calcul.\n");
			abort();
    }


    /* initialise les variables */
    /*--------------------------*/

    p239[0]=20*239;                     /* initialise le réel p239 */
    for(i=1;i<=nbdec;p239[i++]=0);

    p57[0]=32*57;                       /* idem pour p57 */
    for(i=1;i<=nbdec;p57[i++]=0);

    p18[0]=48*18;                       /* idem pour p18 */
    for(i=1;i<=nbdec;p18[i++]=0);

    for(i=0;i<=nbdec;pihex[i++]=0);     /* idem pour pihex */


    /* calcule pi */
    /*------------*/

	printf("Calcul ...     ");
	time(&t1);							/* marque le début du calcul */

    do{
        test2=(i239<=nbdec);
        test1=(i57<=nbdec);

        if(test1 && test2){
            ur=0;
            for(i=i239;i<=nbdec;i++){
                utmp=ur+(udword)p239[i];
                p239[i]=utmp/57121;
                ur=(utmp-(udword)(p239[i])*57121) << 16;
            }
            if(p239[i239]==0) i239++;
        }

        if(test1 || test2){
            ur=0;
            for(i=i57;i<=nbdec;i++){
                utmp=ur+(udword)p57[i];
                p57[i]=utmp/3249;
                ur=(utmp-(udword)(p57[i])*3249) << 16;
            }
            if(p57[i57]==0) i57++;
        }

        ur=0;
        for(i=i18;i<=nbdec;i++){
            utmp=ur+(udword)p18[i];
            p18[i]=utmp/324;
            ur=(utmp-(udword)(p18[i])*324) << 16;
        }

        r=0;
        for(i=nbdec;i>=i18;i--){
            tmp=r+(dword)p18[i]+(dword)p57[i]-(dword)p239[i];
            temp[i]=tmp & 0xFFFF;
            r=tmp >> 16;
        }

        ur=0;
        for(i=i18;i<=nbdec;i++){
            utmp=ur+(udword)temp[i];
            temp[i]=utmp/indice;
            ur=(utmp-(udword)(temp[i])*indice) << 16;
        }

        r=0;
        if(signe==-1)
            for(i=nbdec;i>=i18;i--){
                tmp=r-(dword)temp[i]+(dword)pihex[i];
                pihex[i]=tmp & 0xFFFF;
                r=tmp >> 16;
            }
        else
            for(i=nbdec;i>=i18;i--){
                tmp=r+(dword)temp[i]+(dword)pihex[i];
                pihex[i]=tmp & 0xFFFF;
                r=tmp >> 16;
            };

        signe*=-1;
        indice+=2;

        if(p18[i18]==0) i18++;

    } while(i18<=nbdec);

	temps(difftime(time(NULL),t1));

    /* libère la mémoire inutilisée */
    /*------------------------------*/

    free(p239);
    free(p57);
    free(p18);
    free(temp);


    /* conversion en décimal */
    /*-----------------------*/

	printf("Conversion ... ");
	time(&t1);

    if((pidec = malloc(reelsize)) == NULL){
        printf("Perte de mémoire ????\n");
        abort();
    }

    pidec[0]=pihex[0];
    for(j=1;j<=nbdec;j++){
        r=0;
        for(i=nbdec;i>=1;i--){
            tmp=r+(dword)pihex[i]*10000;
            pihex[i]=tmp & 0xFFFF;
            r=tmp >> 16;
        }
        pidec[j]=r;
    }

	temps(difftime(time(NULL),t1));

	free(pihex);					/* libère la mémoire */



    /* sauve le résultat dans un fichier */
    /*-----------------------------------*/

    if((stream=fopen("pidec","w"))==NULL){
        printf("Impossible d'ouvrir le fichier.");
        abort();
    }
    fwrite(&pidec[1],sizeof(word),nbdec,stream);
    fclose(stream);


	printf("\nAffichage de pi (O/N) ? ");
	fflush(stdin);				/* vide d'eventuelles frappes parasites */
	if(((ouinon=getc(stdin))=='O')||(ouinon=='o'))
		affiche(pidec);			/* affiche le résultat si demandé */
								
	printf("\n");
}


/* affiche le résultat en décimal par ligne de 50 décimales */
/*----------------------------------------------------------*/

void affiche(word *reel)
{
    int     i,count=0,tranches=0;
    char    str[6];                     /* 5 caractères au maximum */

    printf("pi = 3,\n");
    for(i=1;i<=nbdec;i++){
        sprintf(str,"%04d",reel[i]);
        if((count%=5)!=0){
            int j;
            for(j=5;j>=count+1;j--) str[j]=str[j-1];
            if(!(++tranches%10)) str[count]='\n';
            else str[count]=' ';
        }
        count+=1;
        printf("%s",str);
    }
    printf("\n");
}


void	temps(double diff)
{
	double	heu,min,sec;
	printf("fini en ");
	heu=floor(diff/3600.0);
	min=fmod(floor(diff/60.0),60.0);
	sec=fmod(diff,60.0);
	if(heu==0){
		if(min==0){
			if(sec==0) printf("moins d'une seconde");
			else printf("%02.0f s",sec);
		}
		else printf("%02.0f min %02.0f s",min,sec);
	}
	else printf("%.0f h %02.0f min %02.0f s",heu,min,sec);
	printf("\n");
}