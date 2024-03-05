#include <stdlib.h>
#include "pseudo_class.h"

// we will access these static variables
// via 'get and put methods'

static int *nums = 0; // array pointer
static int c = 0;     // capacity
static int s = 0;     // actual size = number of elems

int 
get_s(void)
{
    return s;
}

int 
get_elem(int i)
{
    return nums[i];
}

void 
my_append(int n)
{
    if (c == s) {
        if (c == 0) {
            c = 100;
        } else {
            c = 2 * c;
        }
        nums = realloc(nums, c * sizeof *nums);
    }
    nums[s++] = n;
}

void 
pop(void)
{
    nums = realloc(nums, (--s) * sizeof *nums);
}