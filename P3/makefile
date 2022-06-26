all: parser

CC = g++
LEX = lex
YACC = yacc

parser: lex.l yacc.y
	$(LEX) lex.l
	$(YACC) -d yacc.y
	$(CC) y.tab.c -o main
