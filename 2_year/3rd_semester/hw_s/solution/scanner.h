#ifndef SCANNER
#define SCANNER

enum TokenKind 
{
    T_EOF,
    T_NEWLINE,
    T_OPEN,
    T_CLOSE,
    T_SEQ,
    T_CONJ,
    T_DISJ,
    T_BACK,
    T_PIPE,
    T_IN,
    T_OUT,
    T_APPEND,
    T_WORD
};

typedef struct Token {
    enum TokenKind kind;
    char *text;
    size_t len;
    size_t capacity;
} Token;

int
init_scanner(FILE *);

void
free_scanner(void);

int
next_token(Token *);

void
free_token(Token *);

#endif