CFLAGS = -O2 -ftrapv -fsanitize=undefined -Wall -Werror -Wformat-security -Wignored-qualifiers -Winit-self -Wswitch-default -Wfloat-equal -Wshadow -Wpointer-arith -Wtype-limits -Wempty-body -Wlogical-op -Wstrict-prototypes -Wold-style-declaration -Wold-style-definition -Wmissing-parameter-type -Wmissing-field-initializers -Wnested-externs -Wno-pointer-sign -Wcast-qual -Wwrite-strings -std=gnu11 -g -lm


all: solution

solution: pseudo_class.o prog.o
	gcc -fsanitize=undefined $^ -o $@

prog.o: pseudo_class.h pseudo_class.c prog.c
	gcc $(CFLAGS) prog.c -c

pseudo_class.o: pseudo_class.h pseudo_class.c
	gcc $(CFLAGS) pseudo_class.c -c

clean:
	rm -f solution *.o