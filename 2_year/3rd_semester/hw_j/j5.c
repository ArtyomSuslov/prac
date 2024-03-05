#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/types.h>

int
main(void)
{
    setbuf(stdin, 0);
    int symb, first_symb = getchar(), status;
    pid_t pid;
    while ((symb = getchar()) != EOF) {
        if ((pid = fork()) == 0) {
            if (symb == first_symb) {
                printf("%c%c", symb, symb);
            }
            exit(EXIT_SUCCESS);
        } else if (pid < 0) {
            // we have hit the limit of running processes
            // we need to finish one of them to make one more
            wait(&status);
            if (fork() == 0) {
                if (symb == first_symb) {
                    printf("%c%c", symb, symb);
                }
                exit(EXIT_SUCCESS);
            }
        }
    }

    while (wait(&status) != (-1));
    printf("\n");

    return 0;
}