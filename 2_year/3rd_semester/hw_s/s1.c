enum
{
    // command kind
    KIND_SIMPLE,
    KIND_REDIRECT,
    KIND_PIPELINE,
    KIND_SEQ1,
    KIND_SEQ2,

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
    int kind;
    
    // for simple
    int argc;
    char **argv;
    
    // for redirect
    int rd_mode;
    char *rd_path;
    struct Command *rd_command;

    // for pipeline
    int pipeline_size;
    struct Command *pipeline_commands;

    // for sequence
    int seq_size;
    int *seq_operations;
    struct Command *seq_commands;

} Command;

int
main(void)
{
    return 0;
}