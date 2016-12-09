#include <std.h>

main()
{
    FILE *stream;
    int c;
    unsigned long i=0;

    stream=fopen("million.dec","rb");
    while ( (c=fgetc(stream)) != EOF) {
        if (i % 50 == 0) printf("\n%-5lu   ", i/50+1);
        else if (i % 5 == 0) {
            putchar(' ');
            if (i%2==0) putchar(' ');
        }
        putchar(c);
        i++;
    }
    fclose(stream);
}
