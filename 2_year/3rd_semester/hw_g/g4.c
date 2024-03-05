#include <stdio.h>
#include <string.h>

enum { STR_LEN = 257 };

int
main(int argc, char **argv)
{
    if (argc == 2) {
        return 0;
    }

    FILE *g4_file  = fopen(argv[1], "r");
    FILE *temp_file = tmpfile();
    char *substring = argv[2], current_string[STR_LEN];
    
    while (fgets(current_string, STR_LEN, g4_file) != NULL) {
        if (strstr(current_string, substring) != NULL) {
            fprintf(temp_file, "%s", current_string);
        }
    }

    fclose(g4_file);
    g4_file = fopen(argv[1], "w");
    fseek(temp_file, 0L, SEEK_SET);

    while (fgets(current_string, STR_LEN, temp_file) != NULL) {
        fputs(current_string, g4_file);
    }
    
    fclose(temp_file);
    fclose(g4_file);

    return 0;
}