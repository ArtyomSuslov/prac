#include <stdio.h>

enum
{
    DATA_ARRAY_SIZE = 10000,
    COMMAND_OK = 0x0,
    NO_ID = 0x1,
    WRONG_CMD = 0x2,
    GETVAL = 0x3,
    SETVAL = 0x4
};

typedef struct DataType {
    int id;
    int value;
} DataType;

typedef union Argument {
    int int_value;
    int *int_pointer_value;
} Argument;

DataType data[DATA_ARRAY_SIZE];

int
command(int id, int cmd, Argument arg)
{
    if (cmd != GETVAL && cmd != SETVAL) {
        return WRONG_CMD;
    }
    for (int i = 0; i < DATA_ARRAY_SIZE; ++i) {
        if (data[i].id == id) {
            if (cmd == GETVAL) {
                *arg.int_pointer_value = data[i].value;
                return COMMAND_OK;
            } else if (cmd == SETVAL) {
                data[i].value = arg.int_value;
                return COMMAND_OK;
            }
        }
    }
    return NO_ID;
}

int
main(void)
{
    for (int j = 0; j < 2; ++j) {
        int i, id, value;
        scanf("%i %i %i", &i, &id, &value);
        data[i - 1].id = id;
        data[i - 1].value = value;
    }

    int a;
    Argument arg;
    arg.int_pointer_value = &a;

    int d;
    scanf("%i", &d);
    if (command(d, GETVAL, arg) == COMMAND_OK) {
        arg.int_value = *arg.int_pointer_value;
        arg.int_value += 1;
        command(d, SETVAL, arg);
        printf("%i\n", arg.int_value);
    } else {
        printf("NONE\n");
    }

    return 0;
}