#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/types.h>

enum { BUF_SIZE = 1024 };

int
my_fgetc(int fd, char *symb, int flush_buf)
{
    static char buf[BUF_SIZE];
    static ssize_t read_chars = 0, cur_pos = 0;

    if (flush_buf) {
        read_chars = 0;
        cur_pos = 0;
        return 1;
    }

    if (read_chars == 0) {
        read_chars = read(fd, &buf[0], BUF_SIZE);
        cur_pos = 0;
        if (read_chars == 0) {
            return 0;
        }
    }
    *symb = buf[cur_pos++];
    read_chars--;
    return 1;
}

void
my_fputc(int fd, char *symb, int flush_buf)
{
    static char buf[BUF_SIZE];
    static ssize_t chars_in_buf = 0;

    if (flush_buf || chars_in_buf == BUF_SIZE) {
        write(fd, &buf[0], chars_in_buf);
        chars_in_buf = 0;
        if (flush_buf) {
            return;
        }
    }
    buf[chars_in_buf++] = *symb;
}

int
main(int argc, char **argv)
{
    // our file
    char *file_name = argv[1];
    int fd = open(file_name, O_RDONLY);
    
    // temp file
    char temp_file_name[] = "./tempXXXXXX";
    int temp_fd = mkstemp(temp_file_name);
    unlink(temp_file_name);

    char symb;

    for (int i = 1; i <= 3; ++i) {
        while (my_fgetc(fd, &symb, 0)) {
            if (symb == '\n' && i != 3) {
                if (i == 1) {
                    my_fputc(temp_fd, &symb, 0);
                }
                break;
            }
            if (i != 2) {
                my_fputc(temp_fd, &symb, 0);
            }
        }
    }
    // flushing the remaining buffer
    my_fputc(temp_fd, NULL, 1);
    
    // clearing fgetc's buffers
    my_fgetc(0, NULL, 1);

    lseek(temp_fd, 0L, SEEK_SET);
    close(fd);
    fd = open(file_name, O_WRONLY | O_TRUNC);
    
    while (my_fgetc(temp_fd, &symb, 0)) {
        my_fputc(fd, &symb, 0);
    }
    my_fputc(fd, NULL, 1);

    close(fd);
    close(temp_fd);

    return 0;
}