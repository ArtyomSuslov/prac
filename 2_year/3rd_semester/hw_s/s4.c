#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <fcntl.h>

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
run_command(Command *);

int
cmd_simple(Command *cmd)
{
    int status, return_value = 0;
    if (fork() == 0) {
        execvp(cmd->argv[0], cmd->argv);
        exit(EXIT_FAILURE);
    }
    wait(&status);
    if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
        return_value = 1;
    }
    return return_value;
}

int
cmd_redirect(Command *cmd)
{
    int status, return_value = 0;
    
    if (fork() == 0) {
        int fd;
        switch (cmd->rd_mode) {
        case RD_INPUT: {
            fd = open(cmd->rd_path, O_RDONLY);
            dup2(fd, STDIN_FILENO);
            close(fd);
            int exit_value = run_command(cmd->rd_command);
            exit(exit_value);
        }
        case RD_OUTPUT: {
            fd = open(cmd->rd_path, O_WRONLY | O_CREAT | O_TRUNC, 0666);
            dup2(fd, STDOUT_FILENO);
            close(fd);
            int exit_value = run_command(cmd->rd_command);
            exit(exit_value);
        }
        case RD_APPEND: {
            fd = open(cmd->rd_path, O_WRONLY | O_CREAT | O_APPEND, 0666);
            dup2(fd, STDOUT_FILENO);
            close(fd);
            int exit_value = run_command(cmd->rd_command);
            exit(exit_value);
        }
        default:
            break;
        }
    }
    wait(&status);
    if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
        return_value = 1;
    }
    return return_value; 
}

int
cmd_pipeline(Command *cmd)
{
    return 0;
}

int
cmd_seq1(Command *cmd)
{
    if (fork() == 0) {
        int exit_value = run_command(&cmd->seq_commands[0]);
        exit(exit_value);
    }

    for (int i = 1; i < cmd->seq_size; ++i) {
        if (cmd->seq_operations[i - 1] == OP_SEQ) {
            while (wait(NULL) != -1);
        }
        if (fork() == 0) {
            int exit_value = run_command(&cmd->seq_commands[i]);
            exit(exit_value);
        }
    }

    while (wait(NULL) != -1);
    return 0;
}

int
cmd_seq2(Command *cmd)
{
    int skip_until_next_disj = 0;
    int skip_until_next_conj = 0;

    int status, return_value = 0;
    if (fork() == 0) {
        int exit_value = run_command(&cmd->seq_commands[0]);
        exit(exit_value);
    }
    wait(&status);
    
    for (int i = 1; i < cmd->seq_size; ++i) {
        switch (cmd->seq_operations[i - 1]) {
        case OP_CONJUNCT: {
            if (!skip_until_next_disj) {
                if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
                    if (fork() == 0) {
                        int exit_value = run_command(&cmd->seq_commands[i]);
                        exit(exit_value);
                    }
                    wait(&status);
                } else {
                    skip_until_next_disj = 1;
                }
            }
            if (skip_until_next_conj) {
                skip_until_next_conj = 0;
            }
            break;
        }
        case OP_DISJUNCT: {
            if (!skip_until_next_conj) {
                if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
                    if (fork() == 0) {
                        int exit_value = run_command(&cmd->seq_commands[i]);
                        exit(exit_value);
                    }
                    wait(&status);
                } else {
                    skip_until_next_conj = 1;
                }
            }
            if (skip_until_next_disj) {
                skip_until_next_disj = 0;
            }
            break;
        }
        default:
            break;
        }
    }
    if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
        return_value = 1;
    }
    return return_value;
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