#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

static void
solution(void)
{
    int number, max_local = 0, max_global = 0;
    char any_num_flag = 0, any_subseq_flag = 0;
    
    while (1) {
        any_num_flag = 0;
        
        while (1) {
            scanf("%i", &number);
            if (number == 0) {
                break;
            }
            if (!any_num_flag) {
                max_local = number;
                any_num_flag = 1;
            }
            else {
                max_local = (number > max_local) ? number : max_local;
            }
        }

        if (max_local < 0) {
            break;
        }
        else {
            if (!any_subseq_flag) {
                max_global = max_local;
                any_subseq_flag = 1;
            }
            else {
                max_global = (max_global > max_local) ? max_local : max_global;
            }
        }
    }
    
    if (!any_subseq_flag) {
        printf("EMPTY\n");
    }
    else {
        printf("%i\n", max_global);
    }
}

enum { MAX_LEN = 128 };

int
main(void)
{
    typedef struct {
        unsigned len;
        int input[MAX_LEN];
        const char *answer;
    } Test;

    static const char * const empty = "EMPTY\n";
    static Test tests[] = {
        { .len = 2, .input = { -1, 0, }, .answer = empty, },
        { .len = 4, .input = { 1, 0, -1, 0, }, .answer = "1\n", }, 
        { .len = 4, .input = { -1, 0, 1, 0, }, .answer = empty, },
        { .len = 5, .input = { 1, 2, 0, -1, 0, }, .answer = "2\n", },
        { .len = 5, .input = { 3, 2, 0, -1, 0, }, .answer = "3\n", },
        { .len = 6, .input = { 1, 0, 2, 0, -1, 0, }, .answer = "1\n", },
        { .len = 6, .input = { 3, 0, 2, 0, -1, 0, }, .answer = "2\n", },
        { .len = 7, .input = { 3, -1, 0, 2, 0, -1, 0, }, .answer = "2\n", },
        { .len = 7, .input = { 3, 0, 2, 0, -3, -2, 0, }, .answer = "2\n", },
        { .len = 9, .input = { 3, 0, 2, 0, -3, -2, 0, 1, 0 }, .answer = "2\n", },
    };

    for (unsigned i = 0; i < sizeof tests / sizeof *tests; ++i) {
        int fd[2], fd_in[2];
        if (pipe(fd) == -1) {
            perror("pipe-1");
            return 1;
        }
        if (pipe(fd_in) == -1) {
            perror("pipe-2");
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
        for (unsigned k = 0; k < tests[i].len; ++k) {
            fprintf(out, "%d\n", tests[i].input[k]);
        }
        fclose(out);
        close(fd_in[1]);

        FILE *in = fdopen(fd[0], "r");
        if (!in) {
            perror("fdopen-in");
            return 1;
        }

        char buf[MAX_LEN] = {0};
        if (!fgets(&buf[0], sizeof buf, in)) {
            printf("TEST %d FAILED: empty output\n", i);
            return 0;
        } else if (!strchr(&buf[0], '\n')) {
            printf("TEST %d FAILED: no newline\n", i);
            return 0;
        } else if (strcmp(buf, tests[i].answer) != 0) {
            printf("TEST %d FAILED: wrong text at output; "
                    "expected: %s; gotten: %s\n", i, tests[i].answer, buf);
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
