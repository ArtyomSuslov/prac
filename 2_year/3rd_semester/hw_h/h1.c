#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
lexicographic_order(const void *arg1, const void *arg2)
{
    return strcmp(*(char **)arg2, *(char **)arg1);
}

int
new_order(const void *arg1, const void *arg2)
{
    const char *str1 = *(char **)arg1;
    const char *str2 = *(char **)arg2;

    int odd_len1 = strlen(str1) % 2, odd_len2 = strlen(str2) % 2;
    
    if (!odd_len1 && !odd_len2) {
        return strcmp(str1, str2);
    } else if (odd_len1 && !odd_len2) {
        return 1;
    } else if (!odd_len1 && odd_len2 ) {
        return (-1);
    } else {
        return strcmp(str2, str1);
    }
}

int
main(int argc, char **argv)
{
    argc--;
    argv++;

    qsort(argv, argc, sizeof(char *), lexicographic_order);

    for (int i = 0; i < argc; ++i) {
        printf("%s\n", argv[i]);
    }
    
    qsort(argv, argc, sizeof(char *), new_order);
    
    for (int i = 0; i < argc; ++i) {
        printf("%s\n", argv[i]);
    }

    return 0;
}