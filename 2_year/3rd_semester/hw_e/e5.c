#include <stdio.h>
#include <string.h>

void
print_words_with_begin(char **array_of_words)
{
    while (*array_of_words != NULL) {
        if (strstr(*array_of_words, "begin")) {
            printf("%s\n", *array_of_words);
        }
        ++array_of_words;
    }
}

void
divide_string_into_words(char *string, char **array_of_words) {
    int already_in_words_array = 0;
    while (*string) {
        if ((*string >= 'a' && *string <= 'z') 
                || (*string >= 'A' && *string <= 'Z')) {
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
    
    print_words_with_begin(array_of_words);
}