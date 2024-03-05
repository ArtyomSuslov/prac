#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>

enum 
{
    TIME_BEWEEN_SENDINGS = 5,
    MAX_NUM_LENGTH = 20
};

unsigned long long num;
int number_of_sigints = 0, number_of_sigalrms = 0;

void
print_time(int s)
{
    ++number_of_sigalrms;
}

void
print_num_every_5_sec(int s)
{
    ++number_of_sigints;
}

int
main(void)
{
    setbuf(stdin, 0);
    scanf("%llu", &num);
    
    signal(SIGINT, print_time);
    signal(SIGALRM, print_num_every_5_sec);
    
    alarm(TIME_BEWEEN_SENDINGS);
    
    while (num != 0) {
        --num;
        if (number_of_sigalrms) {
            unsigned int time_left = alarm(TIME_BEWEEN_SENDINGS);
            alarm(time_left);
            printf("%u\n", time_left);
            number_of_sigalrms--;
        }
        if (number_of_sigints) {
            printf("%llu\n", num);
            alarm(TIME_BEWEEN_SENDINGS);
            number_of_sigints--;
        }
    }

    return 0;
}