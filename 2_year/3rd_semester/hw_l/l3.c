#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

void
close_pipe(int fd[])
{
    close(fd[0]);
    close(fd[1]);
}

int
main(int argc, char **argv)
{
    // grep -E "^[a-z0-9_]+\(" | cut -d '(' -f 1 | sort -u

    int fd_1[2], fd_2[2];
    pipe(fd_1);
    pipe(fd_2);
    
    if (fork() == 0) {
        dup2(fd_1[1], STDOUT_FILENO);
        close_pipe(fd_1);
        close_pipe(fd_2);
        execlp("grep", "grep", "-E", "^[a-z0-9_]+\\(", (char *)0);
        exit(EXIT_FAILURE);
    }

    if (fork() == 0) {
        dup2(fd_1[0], STDIN_FILENO);
        dup2(fd_2[1], STDOUT_FILENO);
        close_pipe(fd_1);
        close_pipe(fd_2);
        execlp("cut", "cut", "-d", "(", "-f", "1", (char *)0);
        exit(EXIT_FAILURE);
    }

    // we don't need first pipe anymore
    close_pipe(fd_1);

    if (fork() == 0) {
        dup2(fd_2[0], STDIN_FILENO);
        close_pipe(fd_2);
        execlp("sort", "sort", "-u", (char *)0);
        exit(EXIT_FAILURE);
    }

    close_pipe(fd_2);

    while (wait(NULL) != -1);

    return 0;
}