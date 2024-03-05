#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>

enum
{
    MAX_COUNT = 5,
    WHEN_TO_STOP = '5' 
};

int number_of_sigints = 0;
char what_to_print[2] = {'0', '\n'};

void
exit_after_5_sigint(int s)
{
    number_of_sigints++;
}

int
main(void)
{
    pid_t pid;
    signal(SIGINT, exit_after_5_sigint);
    
    if ((pid = fork()) == 0) {
        for (;;) {
            pause();
            if (number_of_sigints--) {
                what_to_print[0]++;
                write(STDOUT_FILENO, &what_to_print[0], 2);
            }
            if (what_to_print[0] == WHEN_TO_STOP) {
                exit(EXIT_SUCCESS);
            }
        }
    }
    
    for (int i = 0; i < MAX_COUNT; ++i) {
        usleep(50);
        kill(pid, SIGINT);
    }
    
    wait(NULL);
    return 0;
}