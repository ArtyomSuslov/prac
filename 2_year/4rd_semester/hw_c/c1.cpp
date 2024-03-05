#include <iostream>

class IntArray
{
public:
    IntArray(int);
    ~IntArray();

    int &item(size_t) const;
    friend void print_intarray(const IntArray &);
private:
    int *arr;
    size_t size;
};

IntArray::IntArray(int len)
{
    arr = new int[len];
    size = len;
}

IntArray::~IntArray()
{
    delete []arr;
}

int &
IntArray::item(size_t num) const
{
    if (num >= size) {
        delete []arr;
        std::cout << "Out of bound" << std::endl;
        exit(0);
    }
    return arr[num];
}

void
print_intarray(const IntArray &array)
{
    for (size_t i = 0; i < array.size - 1; ++i) {
        std::cout << array.arr[i] << " ";
    }
    std::cout << array.arr[array.size - 1] << std::endl;
}

constexpr size_t ARRAY_SIZE = 10;

int
main()
{
    IntArray p(ARRAY_SIZE);

    int num;
    for (size_t i = 0; i < ARRAY_SIZE; ++i) {
        std::cin >> num;
        p.item(i) = num;
    }

    print_intarray(p);

    return 0;
}