#include <stdio.h>

enum {ARRAY_LENGTH = 10000};

void
read_float_array(double *arr, int length)
{
    while (length > 0) {
        scanf("%lf", arr);
        arr++;
        length--;
    }
}

void
print_float_array(double *arr, int length)
{
    while (length > 0) {
        printf("%.1lf", *arr);
        ++arr;
        --length;
        if (length > 0) printf(" ");
    }
    printf("\n");
}

double *
point_to_first_neg(double *arr, int len) {
    double *pointer = arr;
    while ((*pointer >= 0) && (len > 0)) {
        ++pointer;
        --len;
    }
    return (*pointer < 0) ? pointer : NULL;
}

double *
point_to_last_pos(double *arr, int len) {
    double *pointer = arr, *pos_pointer = NULL;
    while (len > 0) {
        if (*pointer > 0) pos_pointer = pointer;
        ++pointer;
        --len;
    }
    return pos_pointer;
}

void
swap_first_neg_with_last_positive(
        double *arr_1,
        int len_1,
        double *arr_2,
        int len_2)
{
    double *pointer_to_neg;
    double *pointer_to_positive;

    pointer_to_neg = point_to_first_neg(arr_1, len_1);
    pointer_to_positive = point_to_last_pos(arr_2, len_2);

    if ((pointer_to_positive != NULL) && (pointer_to_neg != NULL)) {
        double temp = *pointer_to_neg;
        *pointer_to_neg = *pointer_to_positive;
        *pointer_to_positive = temp;
    }
}

int
main(void)
{
    int len_1, len_2;
    static double arr_1[ARRAY_LENGTH], arr_2[ARRAY_LENGTH];
    
    scanf("%i", &len_1);
    read_float_array(arr_1, len_1);
    
    scanf("%i", &len_2);
    read_float_array(arr_2, len_2);

    swap_first_neg_with_last_positive(arr_1, len_1, arr_2, len_2);

    print_float_array(arr_1, len_1);
    print_float_array(arr_2, len_2);

    return 0;
}