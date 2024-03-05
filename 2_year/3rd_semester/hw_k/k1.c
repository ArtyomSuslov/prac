#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

int
main(int argc, char **argv)
{
    argc--;
    argv++;

    int fd = open(argv[0], O_RDWR);

    char two_bytes[2];
    if (read(fd, &two_bytes[0], 2) == 2) {
        two_bytes[1] = two_bytes[0];
        lseek(fd, 0L, SEEK_SET);
        write(fd, &two_bytes[0], 2);
    }

    close(fd);

    return 0;
}