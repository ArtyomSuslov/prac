#include <stdio.h>

int
main(void)
{
    char line[82];
    if (fgets(line, 82, stdin) == NULL) {
        printf("EMPTY INPUT\n");
    } else {
        printf("%s", line);
    }
}