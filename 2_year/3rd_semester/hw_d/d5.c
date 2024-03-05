#include <stdio.h>

int
equal_no_spaces(const char *str_1, const char *str_2)
{
    const char *pointer_1, *pointer_2;
    pointer_1 = str_1;
    pointer_2 = str_2;
    while ((*pointer_1 == *pointer_2 || *pointer_1 == ' ' || *pointer_2 == ' ') && (*pointer_1 && *pointer_2)) {
        if (*pointer_1 == ' ') {
            pointer_1++;
            continue;
        }
        if (*pointer_2 == ' ') {
            pointer_2++;
            continue;
        }
        pointer_1++, pointer_2++;
    }
    if (*pointer_1 == *pointer_2) return 1;
    else return 0;
}

int
main(void)
{
    char str_1[82], str_2[82];
    fgets(str_1, 82, stdin);
    fgets(str_2, 82, stdin);
    if (equal_no_spaces(str_1, str_2)) printf("YES\n");
    else printf("NO\n");

    return 0;
}