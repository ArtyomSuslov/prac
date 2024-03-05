#include <stdio.h>

enum { ARR_SIZE = 13 };
enum { INODE_SIZE = 0x100000 };

struct Inode
{
    long array[ARR_SIZE];
    unsigned file_size;
};

struct FileSys
{
    struct Inode file[INODE_SIZE];
    unsigned inode_root_number;
};

struct FileSys our_file;

int
main(void)
{
    our_file.file[10].file_size = 2;
    our_file.file[10].array[0] = 1038;
    our_file.file[10].array[1] = 37465;

    return 0;
}