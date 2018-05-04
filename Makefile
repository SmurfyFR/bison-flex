#
# This Makefile can be used on MacOSX
#

BISON=bison
FLEX=flex
CC=gcc
CFLAGS=-Wall -g
LD=gcc

BUILT_SOURCES=c--.parser.h c--.parser.c c--.scanner.c
OBJS=c--.parser.o c--.scanner.o ast.o symtab.o
BIN=c--

all: $(BIN)

Debug: all

Release: all

%.parser.c %.parser.h: %.bison
	$(BISON) --defines=$*.parser.h -o$*.parser.c $*.bison

%.scanner.c: %.flex
	$(FLEX) -o$*.scanner.c $*.flex

%.o: %.c
	$(CC) $(CFLAGS) -c $*.c

$(BIN): $(OBJS)
	$(LD) $^ -o $@

# Extra dependencies
c--.scanner.o: c--.parser.h
ast.o: ast.h

clean:
	-rm $(BUILT_SOURCES) $(OBJS) $(BIN)

cleanDebug: clean

cleanRelease: clean

.PRECIOUS: $(BUILT_SOURCES)
