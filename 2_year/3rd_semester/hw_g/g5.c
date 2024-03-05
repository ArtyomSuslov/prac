#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
    char *substring = argv[2];
    int substr_len = strlen(substring);

    if (*substring == 0) {
        return 0;
    }

    FILE *g5_file  = fopen(argv[1], "r");
    FILE *temp_file = tmpfile();
    
    int symb;
    char *temp_str = calloc(substr_len + 1, sizeof *temp_str);
    long str_start_pos = 0, where_to_return;
    
    while ((symb = fgetc(g5_file)) != EOF) {
        if (symb == substring[0]) {
            // saving the position where we need to return to if temp_str is not right
            where_to_return = ftell(g5_file);

            // reading temp_str to compare it with substring
            fseek(g5_file, (-1) * sizeof(char), SEEK_CUR);
            fgets(temp_str, substr_len + 1, g5_file);
            
            if (strcmp(temp_str, substring) == 0) {
                // if they are equal we go to the start of line and copy it to temp_file
                fseek(g5_file, str_start_pos, SEEK_SET);
                while ((symb = fgetc(g5_file)) != EOF) {
                    if (symb == '\n') {
                        break;
                    }
                    fwrite(&symb, sizeof(char), 1, temp_file);
                }
                // writing \n to temp_file if line isn't last
                if (symb == '\n') {
                    fwrite(&symb, sizeof(char), 1, temp_file);
                    str_start_pos = ftell(g5_file);
                }
            } else {
                // if (temp_str != substring) we return to "where_to_return" point
                fseek(g5_file, where_to_return, SEEK_SET);
            }
        }
        // each line we need to know where it starts
        if (symb == '\n') {
            str_start_pos = ftell(g5_file);
        }
    }

    fclose(g5_file);
    g5_file  = fopen(argv[1], "w");
    fseek(temp_file, 0L, SEEK_SET);

    // copy temp_file to g5_file
    while (fread(&symb, sizeof(char), 1, temp_file) == 1) {
        fputc(symb, g5_file);
    }
    
    free(temp_str);
    fclose(temp_file);
    fclose(g5_file);

    return 0;
}