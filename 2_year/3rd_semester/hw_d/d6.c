#include <stdio.h>
#include <string.h>

const char *
my_strstr(const char *, const char *);

int
main(void)
{
    char str_1[82], str_2[4] = "end";
    fgets(str_1, 82, stdin);
    const char *temp, *prev = NULL;
    temp = my_strstr(str_1, str_2);
    if (temp == NULL) {
        printf("%s", str_1);
    } else {
        while (temp != NULL) {
            prev = temp;
            temp = my_strstr(temp + strlen(str_2), str_2);
        }
        printf("%s", prev + strlen(str_2));
    }
    return 0;
}

int
str_compare(const char *str_1, const char *str_2)
{
    while (*str_1 && *str_2) {
        if (*str_1 != *str_2) {
            return 0;
        }
        str_1++, str_2++;
    }
    return (*str_2 == 0);
}

const char *
my_strstr(const char *str_1, const char *str_2)
{
    while (*str_1 != 0) {
        if (*str_1 == *str_2) {
            if (str_compare(str_1, str_2)) return str_1;
        }
        str_1++;
    }
    return NULL;
}