#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *
read_long_string(long *str_len)
{
    long str_size = 2;
    char *str = calloc(sizeof(*str), str_size + 1);
    if (fgets(str, str_size + 1, stdin) == NULL) {
        free(str);
        return NULL;
    }
    while (strstr(str, "\n") == NULL) {
        str_size *= 2;
        str = realloc(str, sizeof(*str) * str_size + 1);
        fgets(str + str_size / 2, str_size / 2 + 1, stdin);
    }
    *str_len = strlen(str);
    return str;
}

void
print_long_string(char *str)
{
    if (str != NULL) {
        printf("%s", str);
    }
}

void
free_string(char *str)
{
    if (str != NULL) {
        free(str);
    }
}

int
main(void)
{
    char *str, *maxlen_str = NULL;
    long cur_len, max_len = -1;
    
    str = read_long_string(&cur_len);
    while (str != NULL) {
        if (cur_len >= max_len) {
            free_string(maxlen_str);
            maxlen_str = str;
            max_len = cur_len;
        } else {
            free_string(str);
        }
        str = read_long_string(&cur_len);
    }
    
    if (maxlen_str == NULL) {
        maxlen_str = str;
        max_len = cur_len;
    }
    
    print_long_string(maxlen_str);
    
    free_string(maxlen_str);

    return 0;
}