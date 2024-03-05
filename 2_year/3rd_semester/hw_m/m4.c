#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>

/*

        The main problem: 
    
    num_str might be in a process of decreasing
    when the signal comes and number is being printed

        To solve this problem we have 2 main paths:
    
    - 1) Create copy of this number before decreasing but
    this method is falling short when we remember that copying a
    string is not an atomic operation and it won't solve our problem

    + 2) Somehow organize our code to make sure that we are printing
    decreased number, for example, by adding flags that indicate that
    the number is decreased and it is ready to be printed
    
    (does it conflict with the condition of exercise that says 
    "print number the moment the signal arrives"?)

*/

enum 
{ 
    TIME_BEWEEN_SENDINGS = 5,
    MAX_NUM_LENGTH = 20
};

char *num_str;

int we_have_dec_number = 0;
int print_flag = 0;

char *
llu_to_str(unsigned long long number, char *buf)
{
    buf[MAX_NUM_LENGTH + 1] = 0;
    buf[MAX_NUM_LENGTH] = '\n';
    int i = MAX_NUM_LENGTH;
    while (number != 0) {
        buf[--i] = '0' + number % 10;
        number /= 10;
    }
    return &buf[i];
}

void
print_time(int s)
{
    unsigned long long time_left = alarm(TIME_BEWEEN_SENDINGS);
    alarm(time_left);
    char buf[MAX_NUM_LENGTH + 2];
    char *buf_p = llu_to_str(time_left, &buf[0]);
    write(STDOUT_FILENO, buf_p, strlen(buf_p));
}

void
print_num_every_5_sec(int s)
{
    if (we_have_dec_number) {
        write(STDOUT_FILENO, num_str, strlen(num_str));
    } else {
        print_flag = 1;
    }
    alarm(TIME_BEWEEN_SENDINGS);
}

// char *
// dec(char *num_str)
// {
//     char *last_digit = num_str + strlen(num_str) - 1;
//     if (*last_digit != '0') {
//         *last_digit -= 1;
//     } else {
//         while (last_digit-- != num_str) {
//             if (*last_digit != '0') {
//                 *last_digit -= 1;
//                 last_digit[1] = '9';
//                 break;
//             } else {
//                 last_digit[1] = '9';
//             }
//         }
//         if (last_digit == num_str && *num_str == '0') {
//             num_str++;
//         }
//     }
//     return num_str;
// }

int
main(int argc, char **argv)
{
    num_str = argv[1];

    signal(SIGINT, print_time);
    signal(SIGALRM, print_num_every_5_sec);
    
    alarm(TIME_BEWEEN_SENDINGS);
    
    while (*num_str != '0') {

        we_have_dec_number = 0;
        num_str = dec(num_str);
        we_have_dec_number = 1;

        if (print_flag) {
            write(STDOUT_FILENO, num_str, strlen(num_str));
            print_flag = 0;
        }
    }

    return 0;
}