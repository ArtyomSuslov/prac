#include <stdio.h>
#include <stdlib.h>

int
main(void)
{
    int n;
    scanf("%i", &n);
    int *pointer = (int *)calloc(n, sizeof(int)), *temp = pointer;
    for (int i = 0; i < n; ++i) {
        scanf("%i", temp++);
    }
    temp = pointer + n - 1;
    for (int i = 0; i < n; ++i) {
        printf("%i ", *temp--);
    }
    free(pointer);

    return 0;
}