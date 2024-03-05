#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>

void
close_pipe(int fd[])
{
    close(fd[0]);
    close(fd[1]);
}

void
process_a(void)
{
    int input_bytes[2], output_bytes[2];
    ssize_t read_bytes;
    while ((read_bytes = read(STDIN_FILENO, &input_bytes[0], 2 * sizeof *input_bytes)) 
            == 2 * sizeof *input_bytes) {
        output_bytes[0] = input_bytes[0] + input_bytes[1];
        output_bytes[1] = input_bytes[0] - input_bytes[1];
        write(STDOUT_FILENO, &output_bytes[0], 2 * sizeof *output_bytes);
    }
}

void
process_son(int numbers[], int fd_for_a[], int sync_fd[])
{
    int result[2];
    char sync_byte;
    
    // we will wait untill there is a byte in synchronizing pipe
    // if there is one we are reading the byte and by doing so we are 
    // stopping other children from entering this critical section
    
    read(sync_fd[0], &sync_byte, sizeof sync_byte);
    
    write(fd_for_a[1], &numbers[0], 2 * sizeof *numbers);
    close_pipe(fd_for_a);
    read(STDIN_FILENO, &result[0], 2 * sizeof *result);
    
    // giving other children permission to use process A's pipe
    write(sync_fd[1], &sync_byte, sizeof sync_byte);
    
    close_pipe(sync_fd);
    fprintf(stdout, "%i %i %i %i\n", numbers[0], numbers[1], result[0], result[1]);
}

int
main(void)
{
    setbuf(stdin, 0);
    int fd_for_a[2], fd_for_son[2];
    pipe(fd_for_a);
    pipe(fd_for_son);

    // starting process A
    if (fork() == 0) {
        dup2(fd_for_a[0], STDIN_FILENO);
        dup2(fd_for_son[1], STDOUT_FILENO);
        close_pipe(fd_for_a);
        close_pipe(fd_for_son);
        process_a();
        exit(EXIT_SUCCESS);
    }

    int input_bytes[2];
    pid_t pid;

    // we need to synchronize child processes while they are working with
    // critical resource - process A's pipe
    // we can't use signals and semaphores yet so I am using
    // extra pipe to show process whether they can work with CR or no

    int sync_fd[2];
    pipe(sync_fd);
    char sync_byte = 1;
    write(sync_fd[1], &sync_byte, sizeof sync_byte);

    while (fscanf(stdin, "%i%i", &input_bytes[0], &input_bytes[1]) == 2) {
        while ((pid = fork()) == -1) {
            wait(NULL);
        }
        if (pid == 0) {
            dup2(fd_for_son[0], STDIN_FILENO);
            close_pipe(fd_for_son);
            process_son(input_bytes, fd_for_a, sync_fd);
            exit(EXIT_SUCCESS);
        }
    }

    close_pipe(sync_fd);
    close_pipe(fd_for_a);
    close_pipe(fd_for_son);

    while (wait(NULL) != -1);
    
    return 0;
}