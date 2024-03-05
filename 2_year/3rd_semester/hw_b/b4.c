#include <stdio.h>
#include <limits.h>
#include <unistd.h>
#include <sys/wait.h>

unsigned long long
ror(unsigned long long a, unsigned n)
{
    unsigned long long temp_1, temp_2;

    temp_1 = (a >> n);
    temp_2 = (a << (sizeof(a) * 8 - n));

    return temp_1 | temp_2; 
}

static void
solution(void)
{
    unsigned N, M;
    scanf("%u%u", &N, &M);
    unsigned long long circle = 0;
    unsigned current = 0, current_n = N, current_m;
    for (unsigned i = N; i > 0; i--) 
    {
        circle <<= 1; 
        circle |= 1;
    };
    while (current_n != 0)
    {
        current_m = M - 1;
        while (1) 
        {
            if ((circle & 1) == 1) 
            {
                if (current_m == 0) break;
                circle = ror(circle, 1);
                current += 1;
                current_m -= 1;
            }
            else
            {
                if (current == N) 
                {
                    current = 0; 
                    circle = ror(circle, sizeof(circle) * 8 - N); 
                    continue;
                }
                else 
                {
                    current += 1; 
                    circle = ror(circle, 1); 
                    continue;
                };
            }
        };

        circle -= 1;
        printf("%u\n", current);
        circle = ror(circle, 1);
        current += 1;
        
        current_n -= 1;
    }
}

enum { MAX_LEN = 128 };

int
main(void)
{
    typedef struct {
        unsigned N, M;
        int answer[MAX_LEN];
    } Test;

    static Test tests[] = {
        { .N = 1, .M = 1, .answer = {0}, },
        { .N = 2, .M = 1, .answer = {0, 1}, },
        { .N = 2, .M = 2, .answer = {1, 0}, },
        { .N = 3, .M = 2, .answer = {1, 0, 2}, },
        { .N = 7, .M = 3, .answer = {2, 5, 1, 6, 4, 0, 3}, },
        { .N = CHAR_BIT * sizeof (long long), .M = 1, },
    };

    Test *llmax = &tests[sizeof tests / sizeof *tests - 1];
    for (unsigned i = 0; i < llmax->N; ++i) {
        llmax->answer[i] = i;
    }

    for (unsigned i = 0; i < sizeof tests / sizeof *tests; ++i) {
        int fd[2], fd_in[2];
        if (pipe(fd) == -1) {
            perror("pipe1");
            return 1;
        }
        if (pipe(fd_in) == -1) {
            perror("pipe2");
            return 1;
        }
        if (fork() == 0) {
            dup2(fd[1], 1);
            dup2(fd_in[0], 0);
            close(fd[0]);
            close(fd[1]);
            close(fd_in[0]);
            close(fd_in[1]);
            solution();
            return 0;
        }
        close(fd[1]);
        close(fd_in[0]);
        FILE *out = fdopen(fd_in[1], "w");
        if (!out) {
            perror("fdopen-out");
            return 1;
        }
        fprintf(out, "%u %u", tests[i].N, tests[i].M);
        fclose(out);
        close(fd_in[1]);

        FILE *in = fdopen(fd[0], "r");
        if (!in) {
            perror("fdopen-in");
            return 1;
        }

        for (unsigned k = 0; k < tests[i].N; ++k) {
            int d;
            if (fscanf(in, "%d", &d) != 1) {
                printf("TEST %d FAILED: not a decimal at position %d\n", i, k);
                return 0;
            }
            if (d != tests[i].answer[k]) {
                printf("TEST %d FAILED: WRONG OUTPUT at position %d: "
                    "expected %d, gotten %d\n", i, k, tests[i].answer[k], d);
                return 0;
            }
        }
        if (fscanf(in, " %*c") >= 0) {
            printf("TEST %d FAILED: EXCESS TEXT AT THE END\n", i);
            return 0;
        }
        fclose(in);
        close(fd[0]);
        int status;
        wait(&status);
        if (! WIFEXITED(status)) {
            perror("wait");
            return 1;
        }
    }

    printf("OK\n");
}
