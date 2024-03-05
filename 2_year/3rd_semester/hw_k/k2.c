#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int
main(int argc, char **argv)
{
    argc--;
    argv++;

    if (fork() == 0) {
        char *prog = argv[0];
        int file = open(argv[1], O_RDONLY);

        dup2(file, STDIN_FILENO);
        close(file);
        execlp(prog, prog, (char *)0);
        exit(EXIT_FAILURE);
    }

    wait(NULL);

    return 0;
}