#ifndef PARSER
#define PARSER

int
init_parser(FILE *);

void
free_parser(void);

int
next_command(Command *);

#endif