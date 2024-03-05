#include <iostream>

// (1 5) (3 2 5 5) (2 4 5 5)

class A 
{
public:
    A();
    A(A &);
    A(double);
    A(float, unsigned short);
    ~A();
    void m();
private:
    int data;
};

A::A()
{
    data = 0;
    std::cout << "1\n"; 
}

A::A(A &x)
{
    data = x.data;
    std::cout << "2\n";
}

A::A(double x)
{
    data = static_cast<int>(x);
    std::cout << "3\n";
}

A::A(float x, unsigned short y)
{
    data = static_cast<int>(y);
    std::cout << "4\n";
}

A::~A()
{
    std::cout << "5\n";
}

void A::m() 
{
    A *x1 = new A;
    delete x1;

    A *x2 = new A(3.14);
    A *x3 = new A(*x2);
    delete x2;
    delete x3;

    // we don't have any obj to copy from
    // so we will create a copy of the same obj
    A *x4 = new A(*this);
    A *x5 = new A(3.14, 5);
    delete x4;
    delete x5;
}