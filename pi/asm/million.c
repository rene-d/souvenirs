#include <std.h>
#include <pc.h>

unsigned long   *p239;
unsigned long   i239;

unsigned long   *p57;
unsigned long   i57;

unsigned long   *p18;
unsigned long   i18;

unsigned long   *temp;
unsigned long   *pihex;
unsigned long   indice = 1;
signed char     signe = 1;
unsigned long   nbdec;
unsigned long   t0, t1;

int             resume;


main(int argc, char *argv[])
{
    register int i;


    printf("Calcul des d‚cimales de ã par la formule de Gauss\n"
      "ã = 48ùArctan 1/18 + 32ùArctan 1/57 - 20ùArctan 1/239\n"
      "(c) Ren‚ DEVICHI 1991-93 GCC\n\n");


    nbdec = 0;
    if (argc > 1) {
        if (strcmp(argv[1], "continue")==0) resume=1; else resume=0;
        sscanf(argv[1], "%d", &nbdec);
    }
    if (nbdec < 5) nbdec = 100;

    if (resume) charge_etat();
    else {

        printf("\nCalcul de ã h‚xad‚cimal avec %d tranches de 8 chiffres\n", nbdec);


        /*
         * allocation de la m‚moire et initialisation des r‚els
         * (initialiastion normale)
         */

        p239 = malloc(sizeof(unsigned long)*(nbdec+1));
        for (i=1; i<=nbdec; p239[i++]=0L);
        *p239 = 20*239;
        i239=0;

        p57 = malloc(sizeof(unsigned long)*(nbdec+1));
        for (i=1; i<=nbdec; p57[i++]=0L);
        *p57 = 32*57;
        i57=0;

        p18 = malloc(sizeof(unsigned long)*(nbdec+1));
        for (i=1; i<=nbdec; p18[i++]=0L);
        *p18 = 48*18;
        i18=0;

        temp = malloc(sizeof(unsigned long)*(nbdec+1));
        for (i=0; i<=nbdec; temp[i++]=0L);

        pihex = malloc(sizeof(unsigned long)*(nbdec+1));
        for (i=0; i<=nbdec; pihex[i++]=0L);

        if (!p239 || !p57 || !p18 || !temp || !pihex) {
            printf("out of memory\n");
            exit(3);
        }

        t0 = time(NULL);
    }




    /*
     * boucle principal du calcul de pi
     */

    do {

        /*
         * teste si on a appuy‚ sur une touche
         * ESC sauvegarde l'‚tat du calcul et arrˆte le programme
         */

        if (kbhit()) {
            int c=getkey();
            switch (c) {
                case 0x1b :
                    sauve_etat();
                    exit(2);
                    break;
                case 0x0d :
                    putchar('\n');
                    break;
                case 0x09 : {
                    int x, y;
                    ScreenGetCursor(&y,&x);
                    printf(" i18=%6d indice=%6d\n", i18, indice);
                    ScreenSetCursor(y,0);
                    break;
                }
            }
        }



asm("

        /*
         * test de l'utilit‚ de chaque calcul de puissance
         * (r‚sultat dans bx)
         */

        xorw    %bx,%bx     /* bx = 0 */
        movl    _nbdec,%eax
        cmpl    _i57, %eax
        jb      LR10
        orw     $1,%bx      /* si i57<nbdec alors bx=.1 */
    LR10:
        cmpl    _i239,%eax
        jb      LR11
        orw     $2,%bx      /* si i239<nb4ec alors bx=1. */
    LR11:

        cld                 /* stosl va incr‚menter edi */


        /* on teste s'il est n‚cessaire de calculer p239 */

        cmpw    $3,%bx      /* si bx!=11b on ne calcule plus p239 */
        jne     LR2


        /*
         * calcul de p239
         */

        movl $57121,%ebx    /* diviseur */

        movl _nbdec,%ecx
        subl _i239,%ecx
        incl %ecx           /* ecx=(nbdec-i239+1) */

        movl _p239,%edi
        movl _i239,%eax
        leal (%edi,%eax,4),%edi    /* edi=p239+i239*4 */
        xorl %edx,%edx      /* premiŠre retenue nulle */
                            /* nota: la retenue est sur 64 bits avec les */
                            /* 32 bits de poids faible nuls */
                            /* d'o— l'astuce fantastique qui suit!!!!! */

    LR1:
        movl (%edi),%eax    /* %eax=p239[i] */
        divl %ebx           /* edx:eax/57151, reste dans edx, quotient dans eax */
                            /* le quotient on le stocke dans p239[i] */
                            /* le (reste << 32) est la retenue */
        stosl
        loop LR1

        movl _i239,%eax
        movl _p239,%edx
        cmpl $0,(%edx,%eax,4)
        jne LR2
        incl _i239
    LR2:


        /*
         * on teste si le calcul de p57 est n‚cessaire
         */

        cmpw $0,%bx         /* si bx=0 on ne calcule plus p57 */
        je LR4


        /*
         * calcul de p57
         */

        movl $3249,%ebx     /* diviseur */

        movl _nbdec,%ecx
        subl _i57,%ecx
        incl %ecx           /* ecx=(nbdec-i57+1) */

        movl _p57,%edi
        movl _i57,%eax
        leal (%edi,%eax,4),%edi      /* edi=p57+i57*4 */
        xorl %edx,%edx      /* retenue nulle */

    LR3:
        movl (%edi),%eax    /* %eax=p57[i] */
        divl %ebx           /* edx:eax/3249 */
        stosl
        loop LR3

        movl _i57,%eax
        movl _p57,%edx
        cmpl $0,(%edx,%eax,4)
        jne LR4
        incl _i57
    LR4:


        /*
         * calcul de p18
         */

        movl $324,%ebx      /* diviseur */

        movl _nbdec,%ecx
        subl _i18,%ecx
        incl %ecx           /* ecx=(nbdec-i18+1) */

        movl _p18,%edi
        movl _i18,%eax
        shll $2,%eax
        addl %eax,%edi      /* edi=p18+i18*4 */
        xorl %edx,%edx      /* retenue nulle */

    LR5:
        movl (%edi),%eax    /* %eax=p18[i] */
        divl %ebx           /* edx:eax/324 */
        stosl
        loop LR5



        /*
         * somme p18+p57-p239     c'est le plus embˆtant !!
         * ***********************************************************
         */

        movl _nbdec,%ecx    /* ecx:compteur */
        subl _i18,%ecx
        incl %ecx           /* ecx=(nbdec-i18+1) */

        mov _nbdec,%ebx     /* ebx:variable d'index */
        mov _temp,%edi

        xorb %dl,%dl         /* pas de retenue au d‚part */

    LR7:
        movb %dl,%dh            /* dh=retenue pr‚c‚dente */
        movl _p18,%esi
        movl (%esi,%ebx,4),%eax
        movl _p57,%esi
        addl (%esi,%ebx,4),%eax     /* eax=p18[i]+pp57[i] */
        setb    %dl                 /* dl=retenue(CF) */

        movl _p239,%esi
        subl (%esi,%ebx,4),%eax
        sbbb $0,%dl             /* dl=dl-retenue(CF) */

        andb %dh,%dh            /* si la retenue pr‚c‚dente est 0 */
        jz LR9                  /* on n'a pas de problŠme ! */
        jns LR8                 /* si elle est 1, on va … LR8 */ /* si SF=0 alors d‚pl */
        subl $1,%eax            /* elle vaut -1 */
        sbbb $0,%dl
                                /* on a trait‚ la retenue */
        jmp LR9
    LR8:
        addl $1,%eax            /* retenue=1 */
        adcb $0,%dl
    LR9:
        movl %eax,(%edi,%ebx,4)
        decl %ebx
        loop LR7



        /*
         * calcul de temp/indice
         */

        movl _indice,%ebx           /* diviseur */

        movl _nbdec,%ecx
        subl _i18,%ecx
        incl %ecx                   /* ecx=(nbdec-i18+1) */

        movl _temp,%edi
        movl _i18,%eax
        leal (%edi,%eax,4),%edi     /* edi=temp+i18*4 */
        xorl %edx,%edx              /* retenue nulle au d‚part */

    LR12:
        movl (%edi),%eax    /* eax=temp[i] */
        divl %ebx           /* edx:eax/indice */
        stosl
        loop LR12




        /*
         * calcul de pihex += signe*temp
         */

        movl _nbdec,%ecx    /* ecx:compteur */
        subl _i18,%ecx
        incl %ecx           /* ecx=(nbdec-i18+1) */

        movl _nbdec,%ebx     /* indexe les r‚els */
        movl _temp,%esi      /* esi pointe sur temp (la source) */
        movl _pihex,%edi     /* edi pointe sur pihex (la destination) */


        cmpb $1,_signe
        je LR13
                                /* signe moins: on soustrait */
        xorb %dl,%dl                /* retenue nulle au d‚part */
LR15:
        movsbl %dl,%edx
        movl (%edi,%ebx,4),%eax
        subl %edx,%eax
        setb %dl
        subl (%esi,%ebx,4),%eax     /* eax=pihex[i]-temp[i] */
        movl %eax,(%edi,%ebx,4)     /* pihex[4]=eax */
        adcb $0,%dl
        decl %ebx
        loop LR15

        movb $1,_signe          /* on change le signe */
        jmp LR14

LR13:                           /* signe plus: on additionne */

        xorb %dl,%dl                /* r=0 */
LR16:
        movsbl %dl,%eax            /* eax=r */
        addl (%edi,%ebx,4),%eax     /* eax=r+pihex[i] */
        setb %dl                    /* dl=nouvelle retenue */
        addl (%esi,%ebx,4),%eax     /* eax=r+pihex[i]+temp[i] */
        adcb $0,%dl                 /* dl=nouvelle retenue */
                                    /* toujours 0 ou 1 !!!!! */
/* cela signifie que si <setb %dl> a donn‚ dl=1, alors <adcb $0,%dl> est inutile */

        movl %eax,(%edi,%ebx,4)     /* pihex[i]=r+pihex[i]+temp[i] */
        decl %ebx
        loop LR16

        movb $-1,_signe         /* on change le signe */
LR14:


        /*
         * incr‚mente indice et ‚ventuellement i18
         */

        addl $2,_indice

        movl _i18,%eax
        movl _p18,%edx
        cmpl $0,(%edx,%eax,4)
        jne LR6
        incl _i18
    LR6:

");

    } while (i18 <= nbdec);

    t1=time(NULL);

    printf("\r%lu secondes\n", t1-t0);


    /*
     * lib‚ration de la m‚moire
     */

    free(p239);
    free(p57);
    free(p18);
    free(temp);

    sauve();        /* sauve pi hex */

    printf("ã is done.\n");
}


aff(n)
unsigned long *n;
{
    register int i;
    unsigned long *a;

    for (i=0; i<=nbdec; i++)
        printf("%08X%c", n[i], i%8==7 ? '\n' : ' ');
    if ((i-1)%8 != 7) putchar('\n');
}


conv(a,b)
unsigned long *a, *b;
{
    register unsigned i, j;
    register signed long r, tmp;
    unsigned long *c;

    c = malloc(sizeof(unsigned long)*(nbdec+1));
    for (i=0; i<=nbdec; i++) c[i]=a[i];

    b[0] = c[0];
    for(j=1; j<=nbdec; j++) {
        r = 0;
        for (i=nbdec; i>=1; i--) {
            tmp = r+(signed long)c[i]*10000;
            c[i] = tmp & 0xFFFF;
            r = tmp >> 16;
        }
        b[j] = r;
    }
    free(c);
}


sauve()
{
    FILE *stream;
    register int i;

    /* sauvegarde binaire */
    if ((stream = fopen("pihex","wb")) == NULL) {
        printf("Impossible d'ouvrir le fichier.");
        exit(3);
    }
    fwrite(pihex,sizeof(unsigned long),nbdec+1,stream);
    fclose(stream);

    /* sauvegarde en texte */
    if ((stream = fopen("pi.hex","wt")) == NULL) {
        printf("Impossible d'ouvrir le fichier.");
        exit(3);
    }
    for (i=1; i<=nbdec; i++) {
        fprintf(stream, "%08lX ", pihex[i]);
        if (i%8 == 0) fputc('\n', stream);
    }
    fclose(stream);
}

sauve_etat()
{
    FILE *stream;
    t1=time(NULL);
    printf("\rcalcul interrompu … %lu s.\n", t1-t0);
    printf("i18=%d\n", i18);

    stream=fopen("sauve/etat","wt");
    fprintf(stream,"%d %d %d %d %d %d\n", nbdec, i239, i57, i18, indice, (int)signe);
    fprintf(stream,"%d", t1-t0);
    fclose(stream);

    stream=fopen("sauve/reels","wb");
    fwrite(p239,sizeof(unsigned long),nbdec+1,stream);
    fwrite(p57,sizeof(unsigned long),nbdec+1,stream);
    fwrite(p18,sizeof(unsigned long),nbdec+1,stream);
    fwrite(temp,sizeof(unsigned long),nbdec+1,stream);
    fwrite(pihex,sizeof(unsigned long),nbdec+1,stream);
    fclose(stream);

    printf("sauvegarde effectu‚e, tapez <go32 pi continue> pour continuer\n");
}

charge_etat()
{
    FILE *stream;
    int i;
    printf("\rreprise calcul interrompu\n");

    stream=fopen("sauve/etat","rt");
    fscanf(stream,"%d %d %d %d %d %d\n", &nbdec, &i239, &i57, &i18, &indice, &i);
    signe=(signed char)i;
    fscanf(stream,"%d", &i);
    fclose(stream);

    p239 = malloc(sizeof(unsigned long)*(nbdec+1));
    p57 = malloc(sizeof(unsigned long)*(nbdec+1));
    p18 = malloc(sizeof(unsigned long)*(nbdec+1));
    temp = malloc(sizeof(unsigned long)*(nbdec+1));
    pihex = malloc(sizeof(unsigned long)*(nbdec+1));
    if (!p239 || !p57 || !p18 || !temp || !pihex) {
        printf("out of memory\n");
        exit(3);
    }

    stream=fopen("sauve/reels","rb");
    fread(p239,sizeof(unsigned long),nbdec+1,stream);
    fread(p57,sizeof(unsigned long),nbdec+1,stream);
    fread(p18,sizeof(unsigned long),nbdec+1,stream);
    fread(temp,sizeof(unsigned long),nbdec+1,stream);
    fread(pihex,sizeof(unsigned long),nbdec+1,stream);
    fclose(stream);

    t0=time(NULL)-i;
}
