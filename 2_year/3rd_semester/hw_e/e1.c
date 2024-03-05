#include <stdio.h>

enum { ARRAY_LENGTH = 10000 };

double *
find_max_double_array(double *arr, int len)
{
    // In case we hase multiple max's we return the first one
    
    double *current_max = arr;
    if (arr == NULL) return NULL;
    for (int i = 0; i < len; ++i) {
        current_max = (*arr > *current_max) ? arr : current_max;
        ++arr;
    }
    return current_max;
}

void
swap_double_in_array(double *first_elem, double *second_elem)
{
    double temp = *first_elem;
    *first_elem = *second_elem;
    *second_elem = temp;
}

void
sort_double_array(double *arr, int len)
{
    for (int i = 0; i < len; ++i) {
        swap_double_in_array(find_max_double_array(arr, len - i), arr);
        ++arr;
    }
}

int
main(void)
{
    static double array_of_double[ARRAY_LENGTH];
    int arr_lenght;
    
    scanf("%i", &arr_lenght);
    for (int i = 0; i < arr_lenght; ++i) {
        scanf("%lf", &array_of_double[i]);
    }

    if (arr_lenght >= 18) {
        printf("%.1lf\n", *find_max_double_array(&array_of_double[4], 14));
    }
    
    sort_double_array(array_of_double, arr_lenght);
    for (int i = 0; i < arr_lenght; ++i) {
        printf("%.1lf ", array_of_double[i]);
    }
    return 0;
}