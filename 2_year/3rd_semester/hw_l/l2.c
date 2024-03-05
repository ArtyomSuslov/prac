#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

int
main(int argc, char **argv)
{
    // (p1 || p2) | p3 args...

    int status;
    char **p1 = &argv[1];
    char **p2 = &argv[2];
    char **p3 = &argv[3];
    int fd[2];
    pipe(fd);
    
    if (fork() == 0) {

        dup2(fd[1], STDOUT_FILENO);
        close(fd[0]);
        close(fd[1]);
        
        if (fork() == 0) {
            execlp(*p1, *p1, (char *)0);
            exit(EXIT_FAILURE);
        }
        wait(&status);

        if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
            if (fork() == 0) {
                execlp(*p2, *p2, (char *)0);
                exit(EXIT_FAILURE);
            }
            wait(NULL);
        }
        exit(EXIT_SUCCESS);
    }
    
    if (fork() == 0) {
        dup2(fd[0], STDIN_FILENO);
        close(fd[0]);
        close(fd[1]);
        execvp(*p3, p3);
        exit(EXIT_FAILURE);
    }

    close(fd[0]);
    close(fd[1]);

    while(wait(NULL) != -1);

    return 0;
}