#include <iostream>

class MyIntArray
{
public:
    MyIntArray();
    ~MyIntArray();

    void append(int);
    void print_array();
    void bubble_sort();
private:
    static constexpr int STARTING_SIZE = 8;

    int *p;          // pointer to the beginning
    size_t capacity; // how many ints are on the heap
    size_t size;     // number of elems
};

MyIntArray::MyIntArray()
{
    p = new int[capacity = STARTING_SIZE]; 
    size = 0;
}

MyIntArray::~MyIntArray()
{
    if (p != NULL) {
        delete []p;
    }
}

void
MyIntArray::append(int num)
{
    int *temp;
    if (size == capacity) {
        temp = new int[capacity = capacity * 2];
        for (size_t i = 0; i < size; ++i) {
            temp[i] = p[i];
        }
        delete []p;
        p = temp;
    }
    p[size++] = num;
}

void
MyIntArray::print_array()
{
    for (size_t i = 0; i < size; ++i) {
        std::cout << p[i] << " ";
    }
    std::cout << std::endl;
}

void 
MyIntArray::bubble_sort()
{
    int temp;
    for (size_t i = 0; i < size; i++) {
        for (size_t j = 0; j + 1 < size - i; j++) {
            if (p[j] > p[j + 1]) {
                temp = p[j];
                p[j] = p[j + 1];
                p[j + 1] = temp;
            }
        }
    }
}

int
main(void)
{
    MyIntArray array;
    int num;
    while (std::cin >> num) {
        array.append(num);
    }

    array.bubble_sort();
    array.print_array();

    return 0;
}