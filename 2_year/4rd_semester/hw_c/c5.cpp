#include <iostream>

class A 
{
public:
    void get_0() const;
    static int x;
};

void
A::get_0() const
{
    std::cout << "I AM THE BEST STUDENT!\n";
}