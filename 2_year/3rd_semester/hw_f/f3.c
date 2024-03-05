#include <stdio.h>
#include <stdlib.h>

int
main(void)
{
    unsigned length_of_array = 2, current_length = 1;
    int *pointer = malloc(length_of_array * sizeof *pointer), *temp = pointer;
    int number;

    while (scanf("%i", &number) == 1) {
        if ((current_length - 1) == length_of_array) {
            length_of_array *= 2;
            pointer = realloc(pointer, length_of_array * sizeof *pointer);
            temp = pointer + current_length - 1;
        }
        *temp++ = number;
        current_length++;
    }

    current_length--; // we did one extra current_length++
    
    if (current_length != 0) {
        temp = pointer + current_length - 1;
    }
    
    for (int i = 0; i < current_length; ++i) {
        printf("%i ", *temp--);
    }
    printf("\n");

    free(pointer);

    return 0;
}