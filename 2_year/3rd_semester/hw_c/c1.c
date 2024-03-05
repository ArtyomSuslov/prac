#include <stdio.h>

/// WRITE HERE
int
gcd(int x, int y){
    while (x && y) {
        if (x >= y) {
            x -= y;
        }
        else {
            y -= x;
        }
    }
    return (x | y);
}
///

int
main(void)
{
    typedef struct {
        int a, b, ans;
    } Test;

    static Test tests[] = {
        { .a = 6, .b = 8, .ans = 2, },
        { .a = 8, .b = 6, .ans = 2, },
        { .a = 6, .b = 7, .ans = 1, },
        { .a = 7, .b = 6, .ans = 1, },
        { .a = 6, .b = 3, .ans = 3, },
        { .a = 3, .b = 6, .ans = 3, },
        { .a = 16, .b = 6, .ans = 2, },
        { .a = 6, .b = 16, .ans = 2, },
    };

    for (size_t i = 0; i < sizeof tests / sizeof *tests; ++i) {
        int r = gcd(tests[i].a, tests[i].b);
        if (r != tests[i].ans) {
            printf("TEST %lu FAILED: a = %d, b = %d, expected %d, "
                    "gotten %d\n", i, tests[i].a, tests[i].b, tests[i].ans, r);
            return 0;
        }
    }

    printf("OK\n");
}
