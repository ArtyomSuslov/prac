#include <stdio.h>
#include <stdarg.h>
#include <limits.h>

enum Type{INT, DOUBLE};

void
vmax(enum Type arg_type, size_t num_of_arg,...) {
    va_list args;
    va_start(args, num_of_arg);
    if (arg_type == INT) {
        int max = 0, cur;
        char flag = 0;
        for (int i = 1; i <= num_of_arg; ++i) {
            if (!flag) {
                max = va_arg(args, int);
                flag = 1;
            }
            else {
                max = ((cur = va_arg(args, int)) > max)?cur:max; 
            }
        }
        printf("%i\n", max);
    }
    else {
        double max = 0.0, cur;
        char flag = 0;
        for (int i = 1; i <= num_of_arg; ++i) {
            if (!flag) {
                max = va_arg(args, double);
                flag = 1;
            }
            else {
                max = ((cur = va_arg(args, double)) > max)?cur:max; 
            }
        }
        printf("%g\n", max);
    }
    va_end(args);
}

int
main(void) {

    vmax(INT, 6, 1, 2, 3, 10, 5, 4);
    vmax(INT, 5, INT_MIN, 10, -1, 0, 1);
    vmax(INT, 4, 10, -100, -1, -2);
    vmax(INT, 6, 10, 10, 10, 10, 10, 10);

    vmax(DOUBLE, 6, 0.1, 0.2, 100.0, 0.4, 0.5, 0.3);
    vmax(DOUBLE, 5, -123123.0, 0.0, 0.1, 0.2, 100.0);
    vmax(DOUBLE, 1, 100.0);
    vmax(DOUBLE, 2, 100.0, 99.9999);

    return 0;
}