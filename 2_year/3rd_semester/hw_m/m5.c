#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/wait.h>
#include <sys/types.h>

enum { QUEUE_MAXLENGTH = 1000 };

int fd;
pid_t pid_queue[QUEUE_MAXLENGTH];
int number_of_sons = 0;
int queue_pointer = 0;

void
add_one_to_number(int sig)
{
    int number;
    read(fd, &number, sizeof number);
    lseek(fd, 0L, SEEK_SET);
    number++;
    write(fd, &number, sizeof number);
    lseek(fd, 0L, SEEK_SET);
    close(fd);

    exit(EXIT_SUCCESS);
}

void
continue_son_from_queue(int sig)
{
    if (queue_pointer < number_of_sons) {
        kill(pid_queue[queue_pointer++], SIGUSR2);
    }
}

int
main(void)
{
    int num;
    scanf("%i", &num);
    
    char filename[] = "./tempXXXXXX";
    fd = mkstemp(filename);
    unlink(filename);
    
    int zero = 0;
    write(fd, &zero, sizeof zero);
    lseek(fd, 0L, SEEK_SET);

    signal(SIGUSR1, continue_son_from_queue);
    signal(SIGUSR2, add_one_to_number);

    pid_t pid;
    for (int i = 0; i < num; ++i) {
        while ((pid = fork()) == -1) {
            if (waitpid(-1, 0, WNOHANG) == 0) {
                raise(SIGUSR1);
            }
            usleep(1000);
        }
        if (pid == 0) {
            for (;;) {
                usleep(1000);
            }
        }
        pid_queue[number_of_sons++] = pid;
    }
    printf("%i\n", number_of_sons);

    while (queue_pointer != number_of_sons) {
        if (waitpid(-1, 0, WNOHANG) == 0) {
            raise(SIGUSR1);
        }
    }

    while (wait(NULL) != -1);

    read(fd, &num, sizeof num);
    printf("%i\n", num);

    close(fd);
    return 0;
}