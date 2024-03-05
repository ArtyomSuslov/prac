#include <stdio.h>
#include <unistd.h>

int
main(void)
{
    // first program
    int variant;
    scanf("%i", &variant);

    switch (variant) {
    case 0:
        printf("A\nB\nB\nC\nC\n");
        break;
    case 1:
        printf("A\nB\nC\nB\nC\n");
        break;
    default:
        printf("UNKNOWN\n");
    }

    // second program
    scanf("%i", &variant);
    
    switch (variant) {
    case 0:
        printf("1\n2\n2\n");
        break;
    case 1:
        printf("2\n1\n2\n");
        break;
    case 2:
        printf("2\n2\n1\n");
        break;
    default:
        printf("UNKNOWN\n");
    }

    return 0;
}