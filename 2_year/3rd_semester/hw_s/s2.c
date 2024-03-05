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
cmd_simple(Command *cmd)
{
    return 0;
}

int
cmd_redirect(Command *cmd)
{
    return 0;
}

int
cmd_pipeline(Command *cmd)
{
    return 0;
}

int
cmd_seq1(Command *cmd)
{
    return 0;
}

int
cmd_seq2(Command *cmd)
{
    return 0;
}

int
run_command(Command *cmd)
{
    int return_value = 0;
    
    switch (cmd->kind) {
    case KIND_SIMPLE: {
        return_value = cmd_simple(cmd);
        break;
    }
    case KIND_REDIRECT: {
        return_value = cmd_redirect(cmd);
        break;
    }
    case KIND_PIPELINE: {
        return_value = cmd_pipeline(cmd);
        break;
    }
    case KIND_SEQ1: {
        return_value = cmd_seq1(cmd);
        break;
    }
    case KIND_SEQ2: {
        return_value = cmd_seq2(cmd);
        break;
    }
    default: {
        return_value = 1;
        break;
    }
    }

    return return_value;
}

int
main(void)
{
    return 0;
}