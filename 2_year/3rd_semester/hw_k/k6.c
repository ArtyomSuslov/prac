#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/types.h>

void
put_byte_to_file(int fd, char *byte)
{
    write(fd, byte, 1);
    if (lseek(fd, 0L, SEEK_CUR) == 32) {
        lseek(fd, 0L, SEEK_SET);
    }
}

void
get_byte_from_file(int fd, char *byte)
{
    read(fd, byte, 1);
    if (lseek(fd, 0L, SEEK_CUR) == 32) {
        lseek(fd, 0L, SEEK_SET);
    }
}

// function returns distance between dad.....son
long
find_dist(off_t son_pos, off_t dad_pos)
{
    if (dad_pos > son_pos) {
        return 32 - dad_pos + son_pos;
    } else {
        return son_pos - dad_pos;
    }
}

int
main(void)
{
    int status;
    char file_name[] = "./tempXXXXXX";

    // there is a function in stdio.h tmpnam - to create a unique name for file
    // but in manual they say that it is better to use mkstemp or tmpfile
    // so I use mkstemp to get the name and to create this file
    
    int fd = mkstemp(file_name);
    close(fd);
    int fd_son = open(file_name, O_WRONLY);
    int fd_dad = open(file_name, O_RDONLY);
    unlink(file_name);

    pid_t pid;

    if ((pid = fork()) == 0) {
        // son is writing
        char byte;
        // while we can read from stdin
        while (read(STDIN_FILENO, &byte, 1) > 0) {
            off_t son_pos = lseek(fd_son, 0L, SEEK_CUR);
            // we are sitting one byte away from dad until he moves
            while (find_dist(son_pos, lseek(fd_dad, 0L, SEEK_CUR)) == 31) {
                usleep(1000);
            }
            put_byte_to_file(fd_son, &byte);
        }
        close(fd_son);
        close(fd_dad);
        exit(EXIT_SUCCESS);
    } else {
        // father is reading
        for (;;) {
            off_t dad_pos = lseek(fd_dad, 0L, SEEK_CUR);
            char byte;
            int going_out_of_for = 0;
            // we are waiting for son to move
            while (dad_pos == lseek(fd_son, 0L, SEEK_CUR)) {
                // we are using waitpid with WNOHANG not to wait for child to finish
                if (waitpid(pid, &status, WNOHANG) != 0) {
                    going_out_of_for = 1;
                    break;
                }
                usleep(1000);
            }
            if (going_out_of_for) {
                break;
            }
            get_byte_from_file(fd_dad, &byte);
            write(STDOUT_FILENO, &byte, 1);
        }
    }
    
    close(fd_son);
    close(fd_dad);

    return 0;
}