#ifndef ERRORS
#define ERRORS

enum 
{
    SUCCESS,
    E_NO_NEWLINE,
    E_WORD_EXPECTED_REDIRECT,
    E_CLOSE_EXPECTED,
    E_WORD_OR_OPEN_EXPECTED,
    ENUM_ERRORS_END = 5
};

const char *
error_message(int);

#endif