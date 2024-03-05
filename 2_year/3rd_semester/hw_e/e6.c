#include <stdio.h>
#include <string.h>

int
main(int argc, char *argv[])
{
    for (int i = 1; i < argc; ++i) {
        printf("%s\n", argv[i]);
    }

    for (int i = 1; i < argc; ++i) {
        char *pointer = strstr(argv[i], "end");
        if (pointer) {
            pointer = strstr(pointer + 3, "end");
            if (pointer) {
                pointer += 3;
                if (*pointer) printf("%s\n", pointer);
            }
        }
    }

    return 0;
}