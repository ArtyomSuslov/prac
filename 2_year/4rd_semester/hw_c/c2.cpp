#include <iostream>

class UniquePtr
{
public:
    UniquePtr();
    UniquePtr(UniquePtr &);
    UniquePtr(UniquePtr &&);
    ~UniquePtr();
    
    // static method make doesn't have "this"
    // so it has only one argument
    static UniquePtr make(int);

    // one for reading, the othe one for writing
    char &get(int);
    const char &get(int) const;

private:
    char *p;
    int size;
    // we put this constructor in the private part so nobody
    // can create and posses memory exept for the make method
    UniquePtr(int);
};

UniquePtr::UniquePtr()
{
    p = nullptr;
    size = 0;
}

UniquePtr::UniquePtr(UniquePtr &obj)
{
    p = obj.p;
    size = obj.size;
    obj.p = nullptr;
    obj.size = 0;
}

UniquePtr::UniquePtr(UniquePtr &&obj)
{
    p = obj.p;
    size = obj.size;
    obj.p = nullptr;
    obj.size = 0;
}

UniquePtr::~UniquePtr()
{
    if (p) {
        delete []p;
    }
}

UniquePtr
UniquePtr::make(int size)
{
    return UniquePtr(size);
}

char &
UniquePtr::get(int i)
{
    return p[i];
}

const char &
UniquePtr::get(int i) const
{
    return p[i];
}

UniquePtr::UniquePtr(int n)
{
    size = n;
    if (n) {
        p = new char[size];
    } else {
        p = nullptr;
    }
}
