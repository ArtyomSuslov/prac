#include <stdlib.h>
#include <string.h>

#include "command.h"

int
init_empty_command(Command *c)
{
    c->kind = KIND_EMPTY;
    return 0;
}

int
init_sequence_command(Command *c, int kind)
{
    switch (kind) {
    case KIND_SEQ1:
        c->kind = KIND_SEQ1;
        break;
    case KIND_SEQ2:
        c->kind = KIND_SEQ2;
        break;
    default:
    }
    c->seq_size = 0;
    return 0;
}

int
append_command_to_sequence(Command *c, Command *cmd)
{
    c->seq_size++;
    c->seq_commands = realloc(c->seq_commands, sizeof c->seq_commands * c->seq_size);
    c->seq_commands[c->seq_size - 1] = *cmd;
    return 0;
}

int
append_operation_to_sequence(Command *c, int op)
{
    c->seq_operations = realloc(c->seq_operations, sizeof c->seq_operations * c->seq_size);
    c->seq_operations[c->seq_size - 1] = op; 
    return 0;
}

int
init_pipeline_command(Command *c)
{
    c->kind = KIND_PIPELINE;
    c->pipeline_size = 0;
    return 0;
}

int
append_to_pipeline(Command *c, Command *cmd)
{
    c->pipeline_size++;
    c->pipeline_commands = realloc(c->pipeline_commands, sizeof c->pipeline_commands * c->pipeline_size);
    c->pipeline_commands[c->pipeline_size - 1] = *cmd;
    return 0;
}

int
init_redirect_command(Command *c)
{
    c->kind = KIND_REDIRECT;
    return 0;
}

int
set_rd_command(Command *c, Command *cmd)
{
    c->rd_command = malloc(sizeof c->rd_command);
    c->rd_command[0] = *cmd;
    return 0;
}

int
init_simple_command(Command *c)
{
    c->kind = KIND_SIMPLE;
    c->argc = 0;
    c->argv = NULL;
    return 0;
}

int
append_word_simple_command(Command *c, char *arg)
{
    c->argc++;
    c->argv = realloc(c->argv, c->argc * sizeof c->argv);
    strcpy(c->argv[c->argc - 1], arg);
    return 0;
}

void 
free_command(Command *c)
{
    switch (c->kind) {
    case KIND_SIMPLE:
        free(c->argv);
        break;
    case KIND_REDIRECT:
        free(c->rd_command);
        break;
    case KIND_PIPELINE:
        free(c->pipeline_commands);
        break;
    case KIND_SEQ1:
    case KIND_SEQ2:
        free(c->seq_commands);
        free(c->seq_operations);
        break;
    default:
        break;
    }
}