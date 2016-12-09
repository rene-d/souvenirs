#include <std.h>
#include <sys/stat.h>

unsigned long *pihex;
unsigned long *pidec;
unsigned long nbdec;
unsigned long cpt;
unsigned long mult=1000000000L;

main()
{
    charge();
    conv();
    sauve();
}

charge()
{
    FILE *stream;
    struct stat statbuf;

    stream=fopen("pihex","rb");
    if (stream == NULL) {
        fprintf(stderr, "conv: fichier pihex introuvable\n");
        exit(1);
    }

    if (fstat(fileno(stream),&statbuf)) {
        perror("conv");
        exit(1);
    }

    nbdec = (statbuf.st_size)/4-1;
    printf("nombre de tranches de 8 chiffres: %d\n", nbdec);

    pihex = malloc(statbuf.st_size);
    fread(pihex, sizeof(unsigned long), nbdec+1, stream);

    fclose(stream);
}



sauve()
{
    FILE *stream;
    register int i;

    stream=fopen("pidec","wb");
    fwrite(pidec, sizeof(unsigned long), nbdec+1, stream);
    fclose(stream);

    stream=fopen("pi.dec","wt");
    for (i=1; i<=nbdec; i++)
        fprintf(stream, "%09lu", pidec[i]);
    fclose(stream);

}



conv()
{
    pidec = malloc(sizeof(unsigned long)*(nbdec+1));
    if (!pidec) {
        perror("conv");
        exit(1);
    }

    *pidec = *pihex;    /* transfert partie d‚cimale qui est la mˆme */


asm("       /* assembly begins here */

    movl _pidec,%edi        /* edi pointe sur pidec */
    movl _nbdec,%eax
    movl %eax,_cpt          /* cpt = nbdec */

LR21:
    addl $4,%edi            /* on saute pidec[0] */
    movl _pihex,%esi        /* esi pointe sur pihex */
    movl _nbdec,%ecx        /* ecx variable de boucle */

    xorl %edx,%edx          /* retenue nulle au d‚part */
LR20:
    mov %edx,%ebx           /* ebx = retenue pr‚c‚dente */
    movl (%esi,%ecx,4),%eax     /* eax = pihex[i] */
    mull _mult
    addl %ebx,%eax          /* edx:eax += retenue pr‚c‚dente */
    adcl $0,%edx            /* edx:eax = r+pihex[i]*1E9 */
    movl %eax,(%esi,%ecx,4)     /* pihex[i] = eax */
    loop LR20

    movl %edx,(%edi)        /* pidec[j] = r */
    decl _cpt
    jnz LR21

"); /* assembly ends here, back to C ! */
}
