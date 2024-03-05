#include "print.h"
#include <stdio.h>
#include <stdarg.h>

static char buf[BUF_SIZE];
static int counter = 0;

static void output(const char buffer[])
{
    printf("%s", buffer);
    fflush(stdout);
}

void flush(void)
{
    buf[BUF_SIZE - 1] = 0;
    output(buf);
    counter = 0;
}

void 
print(const char format[], ...)
{
    va_list arguments;
    va_start(arguments, format);
    int string_pointer = 0;
    char symbol;
    while (1) {
        symbol = format[string_pointer++];
        switch (symbol) {
            case 0: {
                break;
            }
            case '%': {
                if (counter == (BUF_SIZE - 1)) flush();
                buf[counter++] = va_arg(arguments, int);
                break;
            }
            case '\n': {
                if (counter == (BUF_SIZE - 1)) flush();
                buf[counter++] = '\n';
                buf[counter] = 0;
                output(buf);
                counter = 0;
                break;
            }
            default: {
                if (counter == (BUF_SIZE - 1)) flush();
                buf[counter++] = symbol;
            }
        }
        if (!symbol) break;
    }
    va_end(arguments);
}