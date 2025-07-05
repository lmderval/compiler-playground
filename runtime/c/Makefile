CC=gcc
CFLAGS=-std=c99 -Wall -Wextra -Werror -Wvla -pedantic

AR=ar

OBJ=runtime.o
LIB=libruntime.a

all: $(LIB)

$(LIB): $(OBJ)
	$(AR) -rc $@ $^

clean:
	$(RM) $(OBJ) $(LIB)

.PHONY: all clean
