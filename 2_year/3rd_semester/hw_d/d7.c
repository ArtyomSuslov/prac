#include <stdio.h>
#include <string.h>
#include <ctype.h>

void
number_first_else_last(char *str)
{
    char buf[82];
    char *from_start, *from_finish, *pointer = str;
    from_start = buf;
    from_finish = buf + (strlen(str) - 2);
    while (*pointer && (*pointer != '\n')) {
        if (isdigit(*pointer)) *from_start++ = *pointer++;
        else *from_finish-- = *pointer++;
    }
    *(buf + strlen(str) - 1) = '\n';
    *(buf + strlen(str)) = 0;
    pointer = buf;
    while (*pointer) *str++ = *pointer++;
    *str = 0;
    return;
}

int
main(void)
{
    char string[82];
    fgets(string, 82, stdin);
    number_first_else_last(string);
    printf("%s", string);
}