CC = gcc
BISON = bison
FLEX = flex
BFLAG = -d
OUT = sqlcheck

FILEL := $(wildcard *.l)
FILEB := $(wildcard *.y)


all: bison flex
	$(CC) -o $(OUT) *.tab.c *.yy.c sqlsave.c -ly -ll
bison: $(FILEB)
	$(BISON) $(BFLAG) $<
flex: $(FILEL)
	$(FLEX) $<
clean:
	rm *~ $(OUT) *.tab.* *.yy.c *.output *.save *.html
