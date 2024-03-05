#ifndef COMMAND
#define COMMAND

enum CommandKind
{
    // command kind
    KIND_SIMPLE,
    KIND_REDIRECT,
    KIND_PIPELINE,
    KIND_SEQ1,
    KIND_SEQ2,
    KIND_EMPTY,

    // redirect operations
    RD_INPUT,
    RD_OUTPUT,
    RD_APPEND,

    // sequence onerations
    OP_CONJUNCT,
    OP_DISJUNCT,
    OP_SEQ,
    OP_BACKGROUND
};

typedef struct Command 
{
    // command kind
    enum CommandKind kind;
    
    // for simple
    union {
        struct {
            int argc;
            char **argv;
        };
        
        // for redirect
        struct {
            int rd_mode;
            char *rd_path;
            struct Command *rd_command;
        };

        // for pipeline
        struct {
            int pipeline_size;
            struct Command *pipeline_commands;
        };

        // for sequence
        struct {
            int seq_size;
            int *seq_operations;
            struct Command *seq_commands;
        };
    };
} Command;

int
init_empty_command(Command *);

int
init_sequence_command(Command *, int);

int
append_command_to_sequence(Command *, Command *);

int
append_operation_to_sequence(Command *, int);

int
init_pipeline_command(Command *);

int
append_to_pipeline(Command *, Command *);

int
init_redirect_command(Command *);

int
set_rd_command(Command *, Command *);

int
init_simple_command(Command *);

int
append_word_simple_command(Command *, char *);

void 
free_command(Command *);

#endif