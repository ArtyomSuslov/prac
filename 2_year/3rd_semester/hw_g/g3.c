#include <stdio.h>
#include <ctype.h>

int
main(int argc, char **argv)
{
    FILE *g3_file  = fopen(argv[1], "r");
    FILE *temp_num_file = tmpfile();
    int number = 0;

    while (fscanf(g3_file, "%i", &number) == 1) {
        fwrite(&number, sizeof number, 1, temp_num_file);
    }

    fclose(g3_file);
    g3_file  = fopen(argv[1], "w");

    // checking whether there are any numbers written
    if (ftell(temp_num_file) != 0) {
        fread(&number, sizeof number, 1, temp_num_file);
        fprintf(g3_file, "%i ", number);

        // while we are in temp_num_file do
        while (fseek(temp_num_file, sizeof number * (-2), SEEK_CUR) != -1) {
            fread(&number, sizeof number, 1, temp_num_file);
            fprintf(g3_file, "%i ", number);
        }
    }
    
    fclose(temp_num_file);
    fclose(g3_file);
    return 0;
}