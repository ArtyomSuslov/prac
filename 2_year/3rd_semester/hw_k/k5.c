#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/types.h>

enum { BUF_SIZE = 1024 };

int
main(int argc, char **argv)
{
    argc--;
    argv++;

    // our file
    char *file_name = argv[0];
    int fd = open(file_name, O_RDONLY);
    
    // temp file
    char temp_file_name[] = "./tempXXXXXX";
    int temp_fd = mkstemp(temp_file_name);
    unlink(temp_file_name);
    
    // maybe put buf out of main's stack
    static char buf[BUF_SIZE + 1];

    // some flags
    int after_second_line = 0;
    int we_are_reading_second_line = 0;

    ssize_t number_of_read_chars;

    // pointer to '\n'
    char *new_line_p, *buf_p = &buf[0];

    while ((number_of_read_chars = read(fd, &buf[0], BUF_SIZE)) > 0) {
        
        buf_p = &buf[0];
        buf[number_of_read_chars] = 0;
        
        if (after_second_line) {
            write(temp_fd, &buf[0], number_of_read_chars);
            continue;
        }

        new_line_p = strchr(buf_p, '\n');
        
        if (new_line_p != NULL && !we_are_reading_second_line) {
            we_are_reading_second_line = 1;
            write(temp_fd, buf_p, new_line_p - buf_p + 1);

            buf_p = new_line_p + 1;
            new_line_p = strchr(buf_p, '\n');

            if (new_line_p != NULL) {
                buf_p = new_line_p + 1;
                write(temp_fd, buf_p, number_of_read_chars - (buf_p - &buf[0]));
                after_second_line = 1;
            }
        
        } else if (new_line_p != NULL && we_are_reading_second_line) {
            buf_p = new_line_p + 1;
            write(temp_fd, buf_p, number_of_read_chars - (new_line_p - buf + 1));
            after_second_line = 1;
        
        } else if (!we_are_reading_second_line) {
            write(temp_fd, buf_p, number_of_read_chars);
        }
    }

    lseek(temp_fd, 0L, SEEK_SET);
    close(fd);
    fd = open(file_name, O_WRONLY | O_TRUNC);
    
    for (;;) {
        number_of_read_chars = read(temp_fd, &buf[0], BUF_SIZE);
        buf[number_of_read_chars] = 0;
        
        if (number_of_read_chars == 0) {
            break;
        } else {
            write(fd, &buf[0], number_of_read_chars);
        }
    }

    close(fd);
    close(temp_fd);

    return 0;
}