#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

void
print_number(int num, FILE *temp)
{
    if (num == 2) {
        printf("2\n");
        char we_have_written_2 = 1;
        fwrite(&we_have_written_2, sizeof we_have_written_2, 1, temp);
    } else {
        char flag;
        while (fseek(temp, (-1) * sizeof flag, SEEK_CUR) != 0) {
            usleep(1000);
        }
        printf("%i\n", num);
    }
    fclose(temp);
}

int
main(void)
{
    FILE *temp = tmpfile();
    int status;
    
    if (fork() == 0) {
        print_number(1, temp);
        exit(EXIT_SUCCESS);
    }
    if (fork() == 0) {
        print_number(2, temp);
        exit(EXIT_SUCCESS);
    }

    while (wait(&status) != -1);
    fclose(temp);

    return 0;
}