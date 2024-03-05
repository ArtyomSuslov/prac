#include <iostream>

constexpr int STARTING_ARR_SIZE = 8;

void
my_copy(int *copy_from, int *copy_to, size_t len)
{
    for (size_t i = 0; i < len; ++i) {
        copy_to[i] = copy_from[i];
    }
}

void 
bubble_sort(int *arr, size_t len)
{
    int temp;
    for (size_t i = 0; i < len; i++) {
        for (size_t j = 0; j + 1 < len - i; j++) {
            if (arr[j] > arr[j + 1]) {
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

int
main(void)
{
    int num;
    size_t capacity = 0, size = 0;
    int *array = new int[capacity = capacity ? capacity : STARTING_ARR_SIZE];
    int *temp = NULL;
    
    while (std::cin >> num) {
        if (size == capacity) {
            temp = new int[capacity = capacity * 2];
            my_copy(array, temp, size);
            delete []array;
            array = temp;
        }
        array[size++] = num;
    }

    bubble_sort(array, size);

    for (size_t i = 0; i < size; ++i) {
        std::cout << array[i] << " ";
    }
    std::cout << std::endl;

    delete []array;

    return 0;
}