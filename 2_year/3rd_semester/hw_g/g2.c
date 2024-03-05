#include <stdio.h>

int
main(int argc, char **argv)
{
    FILE *g2_file  = fopen(argv[1], "r+");
    char first_two_bytes[2];

    if (fread(first_two_bytes, sizeof *first_two_bytes, 2, g2_file) == 2) {
        fseek(g2_file, sizeof *first_two_bytes, SEEK_SET);
        fwrite(&first_two_bytes[0], sizeof *first_two_bytes, 1, g2_file);
    }

    fclose(g2_file);
    return 0;
}