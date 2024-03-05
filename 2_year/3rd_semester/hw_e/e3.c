#include <stdio.h>
#include <string.h>
#include <ctype.h>

void
print_first_three_symbols(char **array)
{
    while (*array != NULL) {
        if (strlen(*array) >= 3) printf("%.3s\n", *array);
        ++array;
    }
}

void
divide_string_into_words(char *string, char **array_of_words) {
    int already_in_words_array = 0;
    while (*string) {
        if (isalpha(*string)) {
            if (!already_in_words_array) {
                already_in_words_array = 1;
                *array_of_words++ = string;
            }
        } else {
            already_in_words_array = 0;
            *string = 0;
        }
        ++string;
    }
    *array_of_words = NULL;
}

int
main(void)
{
    static char string[82];
    static char *array_of_words[41];

    fgets(string, 82, stdin);
    *strchr(string, '\n') = 0;

    divide_string_into_words(string, array_of_words);
    print_first_three_symbols(array_of_words);

    return 0;
}