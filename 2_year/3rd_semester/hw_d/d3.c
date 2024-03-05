#include <stdio.h>
#include <string.h>

int 
ends_with(const char *str_1, const char *str_2)
{
    int len_1 = strlen(str_1);
    int len_2 = strlen(str_2);
    
    if (len_1 > len_2) return 0;
    
    const char *pointer_1 = str_1;
    const char *pointer_2 = str_2 + (len_2 - len_1);
    
    while ((*pointer_1 == *pointer_2) && (*pointer_1 && *pointer_2)) {
        pointer_1++;
        pointer_2++;
    }
    
    return *pointer_1 == 0;
}

int
main(void)
{
    static char first_str[82], second_str[82];
    
    fgets(first_str, 82, stdin);
    fgets(second_str, 82, stdin);
    *strchr(first_str, '\n') = 0;
    *strchr(second_str, '\n') = 0;

    if (ends_with(first_str, second_str)) printf("YES\n");
    else printf("NO\n");
    
    return 0;
}