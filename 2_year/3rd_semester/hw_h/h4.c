#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>

enum { SWITCH_DICT_SIZE = 10 };

typedef void (*SwitchFunc)(char *);

typedef struct SwitchType
{
    char *string;
    SwitchFunc func;
} SwitchType;

void
add_func(char *str)
{
    static int add_counter = 0;
    add_counter++;
    if (add_counter % 2 == 1) {
        printf("%i\n", add_counter);
    }
}

void
sub_func(char *str)
{
    static int sub_counter = 0;
    sub_counter++;
    if (sub_counter == 2) {
        exit(0);
    }
}

void
default_func(char *str)
{
    // default is doing nothing
}

void
string_switch(SwitchType switch_dict[], char *str)
{
    // cases
    for (int i = 0; i < SWITCH_DICT_SIZE; ++i) {
        if (switch_dict[i].string == NULL) {
            break;
        }
        if (strcmp(str, switch_dict[i].string) == 0) {
            // if switch_dict[i].func == NULL than this function is an empty code
            if (switch_dict[i].func != NULL) {
                switch_dict[i].func(str);
            }
            return;
        }
    }

    // default
    switch_dict[0].func(str);
}

int
main(int argc, char **argv)
{
    //           !agreement!
    // we put default at switch_dict[0]
    // every other functions will go futher

    SwitchType switch_dict[SWITCH_DICT_SIZE] = 
    {
        {"default", default_func}, 
        {"add", add_func}, 
        {"sub", sub_func}
    };

    argc--;
    argv++;

    for (int i = 0; i < argc; ++i) {
        string_switch(switch_dict, argv[i]);
    }

    return 0;
}