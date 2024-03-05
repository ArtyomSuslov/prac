#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int
exec_prog(char *path, char **arguments)
{
    int status;
    if (fork() == 0) {
        execvp(path, arguments);
        exit(EXIT_FAILURE);
    }
    wait(&status);
    if (WIFEXITED(status) != 0 && WEXITSTATUS(status) == 0) {
        return EXIT_SUCCESS;
    }
    return EXIT_FAILURE;
}

int
main(int argc, char **argv)
{
    argv++;
    argc--;

    char *path_2 = argv[argc - 1];
    char **args_2 = argv + argc - 1;
    argv[argc - 1] = NULL;
    
    // lazy C logic :)
    if (exec_prog(argv[0], argv) == EXIT_SUCCESS && exec_prog(path_2, args_2)) {
    }

    return 0;
}