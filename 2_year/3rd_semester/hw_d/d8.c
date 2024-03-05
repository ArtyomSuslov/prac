#include <stdio.h>
#include <ctype.h>

const char *
where_is_1st_number(const char *arr, int *num_len)
{
    *num_len = 0;
    int start_read_flag = 0, maybe_a_number = 0;
    const char *temp = NULL, *maybe_here = NULL;
    while (*arr) {
        if (isdigit(*arr)) {
            if (!start_read_flag && *arr != '0') {
                temp = arr;
                *num_len += 1;
                start_read_flag = 1;
                maybe_a_number = 0;
            } else if (start_read_flag) {
                *num_len += 1;
            } else {
                maybe_a_number = 1;
                maybe_here = arr;
            }
        } else if (start_read_flag) {
            break;
        }
        arr++;
    }
    if (maybe_a_number) {
        *num_len = 1;
        return maybe_here;
    }
    return temp;
}

int
main(void)
{
    char str[82];
    fgets(str, 82, stdin);

    int len = 0;
    const char *pointer = where_is_1st_number(str, &len);
    int max_len = 0;
    const char *max_num = NULL;

    while (pointer != NULL) {
        if (len < max_len) {
        } else if (max_num == NULL || len > max_len) {
            max_num = pointer;
            max_len = len;
        } else {
            const char *for_str = pointer, *for_max = max_num;
            for (int i = 0; i < len; ++i) {
                if (*for_str++ > *for_max++) {
                    max_num = pointer;
                    max_len = len;
                    break;
                }
            }
        }
        pointer = where_is_1st_number(pointer + len, &len);
    }

    if (max_num != NULL) {
        if (max_len == 1 && *max_num == '0') {
            printf("0");
        } else {
            for (int i = 0; i < max_len; ++i) printf("%c", *max_num++);
        }
    }

    return 0;
}