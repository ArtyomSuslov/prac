#include <stdio.h>
#include "pseudo_class.h"

#if 0

    Encapsulation is a way to:
1) link the data to the code that manages this data;
2) protect data from modification by other code;

    In our case, the variables num, c, s can be modified 
from the outside by including this file to others. 
To fix it, I moved all this data to a separate ".c" 
file and made them static so that other files that 
will include that one would not have access to them.

    For indirect interaction with this data from the 
outside, we will use the get_ and set_ functions

#endif

void
read_numbers(int max)
{
    int n;
    while (get_s() < max && scanf("%d", &n) == 1) {
        my_append(n);
    }
}

void
shrink_numbers(void)
{
    while (get_s() >= 2 && get_elem(get_s() - 1) == get_elem(get_s() - 2)) {
        pop();
    }
}

void
print_numbers(void)
{
    for (int k = 0; k < get_s(); ++k) {
        printf("%d\n", get_elem(k));
    }
}

int
main(void)
{
    read_numbers(20);
    shrink_numbers();
    read_numbers(200);
    print_numbers();
}