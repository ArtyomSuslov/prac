#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/types.h>

int
main(int argc, char **argv)
{
    int fd[2];
    pipe(fd);
    char **p1 = argv + 1, **p2 = NULL;

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--") == 0) {
            argv[i] = NULL;
            p2 = &argv[i + 1];
            break;
        }
    }

    if (fork() == 0) {
        dup2(fd[1], STDOUT_FILENO);
        close(fd[0]);
        close(fd[1]);
        execvp(*p1, p1);
        exit(EXIT_FAILURE);
    }

    if (fork() == 0) {
        dup2(fd[0], STDIN_FILENO);
        close(fd[0]);
        close(fd[1]);
        execvp(*p2, p2);
        exit(EXIT_FAILURE);
    }

    // we are closing pipe before waiting to close children's stdin and stdout
    // otherwise they will wait for changes in stdin forever
    close(fd[0]);
    close(fd[1]);

    while (wait(NULL) != -1);

    return 0;
}