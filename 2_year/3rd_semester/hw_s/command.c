#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <fcntl.h>
#include "command.h"

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
    int status, return_value = 0;
    int fd[2];
    pipe(fd);

    for (int command_counter = 0; command_counter < cmd->pipeline_size; ++command_counter) {
        if (fork() == 0) {
            if (cmd->pipeline_size > 1) {
                if (command_counter == 0) {
                    dup2(fd[1], STDOUT_FILENO);
                } else if (command_counter == cmd->pipeline_size - 1) {
                    dup2(fd[0], STDIN_FILENO);
                } else {
                    dup2(fd[0], STDIN_FILENO);
                    dup2(fd[1], STDOUT_FILENO);
                }
            }
            close(fd[0]);
            close(fd[1]);
            int exit_status = run_command(&cmd->pipeline_commands[command_counter]);
            exit(exit_status);
        }
    }

    close(fd[0]);
    close(fd[1]);

    while (wait(&status) != -1);
    if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
        return_value = 1;
    }
    return return_value;
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