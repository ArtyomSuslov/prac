#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <fcntl.h>
#include <string.h>

// forgot about "\n\0" in the end, tried 81 last time :)
enum { MAX_STRLEN = 82 }; 

// I tried to do this not using FILE
// But I guess it is more sutable in this kind of exercises

int
main(int argc, char **argv)
{
    FILE *fp = fopen(argv[1], "r");
    FILE *fp_temp = tmpfile();
    
    char needle[MAX_STRLEN];
    fgets(needle, MAX_STRLEN, stdin);
    
    // I'm deleting '\n' because otherwise strstr will look
    // for its occurances in the end of needle
    char *new_line_p = strchr(needle, '\n');
    if (new_line_p != NULL) {
        *new_line_p = '\0';
    }

    char haystack[MAX_STRLEN];
    while (fgets(haystack, MAX_STRLEN, fp) != NULL) {
        // I guess we don't need to delete '\n' in haystack
        // because strstr won't search farther then '\n'
        if (strstr(haystack, needle) != NULL) {
            fwrite(haystack, sizeof *haystack, strlen(haystack), fp_temp);
        }
    }
    
    fclose(fp);
    fp = fopen(argv[1], "w+");

    fseek(fp_temp, 0L, SEEK_SET);

    while (fgets(haystack, MAX_STRLEN, fp_temp) != NULL) {
        fwrite(haystack, sizeof *haystack, strlen(haystack), fp);
    }

    fclose(fp);
    fclose(fp_temp);

    return 0;
}