/* version un peu modernisée de prt.c */

#include <stdio.h>

int main()
{
    FILE *stream;
    int c;
    unsigned long i = 0;

    stream = fopen("million.dec", "rb");
    while ((c = fgetc(stream)) != EOF) {
	if (i == 0) printf("   PI = 3.");
	else if (i % 100 == 0) printf("\n%7lu   ", i);
        else if (i % 10 == 0) putchar(' ');
        putchar(c);
        i++;
    }
    printf("\n");
    fclose(stream);
    return 0;
}
