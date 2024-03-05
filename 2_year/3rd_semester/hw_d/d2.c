#include <stdio.h>
#include <string.h>

char * 
my_strcat(char *first_str, const char *second_str)
{
    char *pointer = first_str;
    while (*pointer != 0) pointer++;
    while (*second_str != 0) *pointer++ = *second_str++;
    *pointer = 0;
    return first_str;
}

int 
main(void) 
{
    static char first_str[161], second_str[82];
    fgets(first_str, 82, stdin);
    *strchr(first_str, '\n') = 0;
    fgets(second_str, 82, stdin);
    *strchr(second_str, '\n') = 0;
    printf("%s", my_strcat(first_str, second_str));
    
    return 0;
}