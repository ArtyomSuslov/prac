#include <stdio.h>

enum { MATRIX_SIZE = 100 };

void
print_matrix(double (*array)[MATRIX_SIZE], int x, int y)
{
    for (int i = 0; i < x; ++i) {
        for (int j = 0; j < y; ++j) {
            printf("%.1lf ", array[i][j]);
        }
        printf("\n");
    }
}

void
multiply_two_matrix(
        const double (*multiplier_1)[MATRIX_SIZE],
        const double (*multiplier_2)[MATRIX_SIZE],
        double (*result)[MATRIX_SIZE],
        int r_1,  // number of lines in 1st multiplier
        int c_1,  // number of columns in 1st multiplier
        int c_2)  // number of columns in 2nd multiplier
{
    for (int i = 0; i < r_1; ++i) {
        for (int j = 0; j < c_2; ++j) {
            result[i][j] = 0;
            for (int k = 0; k < c_1; ++k) {
                result[i][j] += multiplier_1[i][k] * multiplier_2[k][j];
            }
        }
    }
}

int
main(void)
{
    static double matr_multip_1[MATRIX_SIZE][MATRIX_SIZE];
    static double matr_multip_2[MATRIX_SIZE][MATRIX_SIZE];
    static double matr_result[MATRIX_SIZE][MATRIX_SIZE];
    
    //r - rows, c - columns
    int r_1, c_1, r_2, c_2;
    
    scanf("%i %i", &r_1, &c_1);
    for (int i = 0; i < r_1; ++i) {
        for (int j = 0; j < c_1; ++j) {
            scanf("%lf", &matr_multip_1[i][j]);
        }
    }
    scanf("%i %i", &r_2, &c_2);
    for (int i = 0; i < r_2; ++i) {
        for (int j = 0; j < c_2; ++j) {
            scanf("%lf", &matr_multip_2[i][j]);
        }
    }

    multiply_two_matrix(matr_multip_1, matr_multip_2, matr_result, r_1, c_1, c_2);
    print_matrix(matr_result, r_1, c_2);

    return 0;
}