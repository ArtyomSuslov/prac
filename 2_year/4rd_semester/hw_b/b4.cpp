#include <iostream>
#include <cstring>


class String 
{
public:
    String();
    String(const char);
    String(const char *);
    String(const String &);
    ~String();

    const char *get() const;
    void append(const String &);
    int compare(const String &) const;
    void assign(const String &);

private:
    char *s;
    size_t len;
};

String::String()
{
    s = new char[1];
    s[0] = '\0';
    len = 0;
}

String::String(const char sym)
{
    s = new char[2];
    s[0] = sym;
    s[1] = '\0';
    len = 1;
}

String::String(const char *arr)
{
    s = new char[strlen(arr) + 1];
    strcpy(s, arr);
    len = strlen(arr);
}

String::String(const String &str)
{
    s = new char[str.len + 1];
    strcpy(s, str.s);
    len = str.len;
}

String::~String()
{
    delete []s;
}

const char *
String::get() const
{
    return s;
}

void
String::append(const String &str)
{
    char *temp = new char[len + str.len + 1];
    strcpy(temp, s);
    strcat(temp, str.s);
    delete []s;
    s = temp;
    len = len + str.len;
}

int 
String::compare(const String &str) const
{
    return strcmp(s, str.s);
}

void 
String::assign(const String &str)
{
    delete []s;
    s = new char[str.len + 1];
    strcpy(s, str.s);
    len = str.len;
}

#if 1
int
main()
{
    String str;
    str.append("12345\n");
    str.append('a');
    String str2;
    str2.assign("abcde\n");
    str.assign(str2);
    std::cout << str.get();

    return 0;
}
#endif