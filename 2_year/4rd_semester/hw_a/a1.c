#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <fcntl.h>

int
main(int argc, char **argv)
{
    int fd = open(argv[1], O_RDWR, 0666);
    char byte;
    ssize_t read_ret = read(fd, &byte, sizeof byte);

    if (read_ret == sizeof byte) {
        byte ^= 10; // inverting 2nd and 4th bits
        lseek(fd, 0L, SEEK_SET);
        write(fd, &byte, sizeof byte);
    }

    close(fd);
    return 0;
}