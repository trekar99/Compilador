######################################################################
# Compiladors I
# Germán Puerto
# Makefile
# Curs 07/08
######################################################################
# General defines
CC = gcc
LEX = flex
LIB = -lc -lfl -lm

ELEX = example.l

OBJ = example.o
SRC = example.c

BIN = example

LFLAGS = -n -o $*.c
CFLAGS = -ansi -Wall -g
######################################################################
all : $(SRC)
	$(CC) -o $(BIN) $(CFLAGS) $< $(LIB)
$(SRC) : $(ELEX)
	$(LEX) $(LFLAGS) $<
clean :
	rm -f $(BIN) $(OBJ) $(SRC)
