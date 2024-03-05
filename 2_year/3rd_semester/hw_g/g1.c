#include <stdio.h>

int
main(int argc, char **argv)
{
    FILE *g1_file  = fopen(argv[1], "r");
    long str_counter = 1;
    int symb;
    while ((symb = fgetc(g1_file)) != EOF) {
        if (str_counter % 2 == 0) {
            printf("%c", symb);
        }
        if (symb == '\n') {
            str_counter++;
        }
    }
    fclose(g1_file);
    return 0;
}