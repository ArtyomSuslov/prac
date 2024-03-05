#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

int
main(int argc, char **argv)
{
    // (p1 || p2) >> f && p3

    argc--;
    argv++;

    int status;
    char *p1 = argv[0];
    char *p2 = argv[1];
    char *f = argv[2];
    char *p3 = argv[3];
    pid_t pid;
    
    if ((pid = fork()) == 0) {
        // O_WRONLY | O_CREAT | O_TRUNC for (>)
        // O_WRONLY | O_CREAT | O_APPEND for (>>)

        int file = open(f, O_WRONLY | O_CREAT | O_APPEND, 0666);
        dup2(file, STDOUT_FILENO);
        close(file);
        
        if (fork() == 0) {
            execlp(p1, p1, (char *)0);
            exit(EXIT_FAILURE);
        }
        wait(&status);
        
        // checking for non-zero exit is not right
        // it is better to check for zero exit and then go to "else"

        if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
            // if first succeed
            exit(EXIT_SUCCESS);
        }
        
            // if first fails
        if (fork() == 0) {
            execlp(p2, p2, (char *)0);
            exit(EXIT_FAILURE);
        }
        wait(&status);

        if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
            // if second succeed
            exit(EXIT_SUCCESS);
        } else {
            // if second fails
            exit(EXIT_FAILURE);
        }
    }
    
    waitpid(pid, &status, 0);
    if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
        if (fork() == 0) {
            execlp(p3, p3, (char *)0);
            exit(EXIT_FAILURE);
        }
        wait(&status);
    }

    return 0;
}