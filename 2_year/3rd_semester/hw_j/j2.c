#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int
main(int argc, char **argv)
{
    argv++;
    argc--;

    int status;

    if (fork() == 0) {
        execvp(argv[0], argv);
        exit(0);
    } else {
        wait(&status);
        if (WIFEXITED(status) != 0) {
            printf("%i\n", WEXITSTATUS(status));
        } else if (WIFSIGNALED(status) != 0) {
            printf("%i\n", WTERMSIG(status));
        }
    }

    return 0;
}