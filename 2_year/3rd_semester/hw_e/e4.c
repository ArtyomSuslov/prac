#include <stdio.h>
#include <string.h>

void
print_the_longest_words(char **array_of_words)
{
    int max_length = 0, counter = 0;
    char *pointers_to_maxlength[41];
    
    while (*array_of_words != NULL) {
        int current_length = strlen(*array_of_words);
        
        if (current_length == max_length) {
            pointers_to_maxlength[counter++] = *array_of_words;
        
        } else if (current_length > max_length) {
            counter = 0;
            pointers_to_maxlength[counter++] = *array_of_words;
            max_length = current_length;
        }
        ++array_of_words;
    }
    pointers_to_maxlength[counter] = NULL;
    
    for (counter = 0; pointers_to_maxlength[counter] != NULL; ++counter) {
        printf("%s\n", pointers_to_maxlength[counter]);
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
    
    print_the_longest_words(array_of_words);
}