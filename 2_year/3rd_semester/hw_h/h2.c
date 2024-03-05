#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { STR_LEN = 257 };

int
lexicographic_order(const void *arg1, const void *arg2)
{
    return strcmp(*(char **)arg1, *(char **)arg2);
}

void 
*my_bsearch(
        void *key,
        void *base,
        size_t num_of_elem,
        size_t width,
        int (*compare) (const void *key, const void *datum))
{
    size_t left = 0;
    size_t right = num_of_elem;
    size_t middle;

    while (left < right) {
        middle = (right + left) / 2;

        // ejudge is not happy with (void *) arithmetics
        void *cur_str = (void *)((char *)base + width * middle);
        int cmp = compare(cur_str, key);
        
        // we will shrink borders from the left
        if (cmp == 0) {
            return cur_str;
        } else if (cmp > 0) {
            right = middle;
        } else {
            left = middle + 1;
        }
    }
    
    return NULL;
}

int
main(int argc, char **argv)
{
    argc--;
    argv++;
    
    char str[STR_LEN];
    fgets(&str[0], STR_LEN, stdin);
    if (strstr(&str[0], "\n") != NULL) {
        *strstr(&str[0], "\n") = 0;
    }

    if (argc == 0) {
        printf("0\n");
        return 0;
    }

    qsort((void *)argv, (size_t)argc, sizeof(char *), lexicographic_order);

    // without this variable I was given a Segmentation fault
    // my firt idea was to put &str, but it was not working
    char *pointer_to_str_start = &str[0];
    char *str_in_arr = (char *)my_bsearch(&pointer_to_str_start, argv, argc, sizeof(char *), lexicographic_order);

    if (str_in_arr != NULL) {
        printf("%li\n", (str_in_arr - (char *)argv) / sizeof(char *) + 1); 
    } else {
        printf("0\n");
    }

    return 0;
}