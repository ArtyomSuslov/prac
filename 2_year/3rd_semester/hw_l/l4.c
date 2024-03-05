#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>

enum { BUF_SIZE = 1024 };

int
buffered_read(int fd, char *byte)
{
    static char buf[BUF_SIZE];
    static ssize_t number_of_read_bytes = 0;
    static int cur_pos = 0;

    if (cur_pos == number_of_read_bytes) {
        cur_pos = 0;
        number_of_read_bytes = read(fd, &buf[0], BUF_SIZE);
        if (number_of_read_bytes == 0) {
            return 0;
        }
    }
    *byte = buf[cur_pos++];
    return 1;
}

int
main(void)
{
    int fd[2];
    pipe(fd);

    if (fork() == 0) {
        close(fd[0]);
        int counter = 1;
        char byte;
        while (buffered_read(STDIN_FILENO, &byte) == 1) {
            if ((counter++) % 2 == 0) {
                write(fd[1], &byte, 1);
            }
        }
        close(fd[1]);
        exit(EXIT_SUCCESS);
    }

    if (fork() == 0) {
        if (fork() == 0) {
            close(fd[1]);
            int counter = 1;
            char byte;
            while (buffered_read(fd[0], &byte) == 1) {
                if ((counter++) % 2 == 0) {
                    write(STDOUT_FILENO, &byte, 1);
                }
            }
            close(fd[0]);
            exit(EXIT_SUCCESS);

        }
        close(fd[0]);
        close(fd[1]);
        wait(NULL);
        exit(EXIT_SUCCESS);
    }

    close(fd[0]);
    close(fd[1]);

    while (wait(NULL) != -1);

    return 0;
}