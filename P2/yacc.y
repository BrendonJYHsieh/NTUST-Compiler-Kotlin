%{
#define Trace(t)        printf(t)
#include<stdio.h>
extern "C" {
    int yyparse();
    int yylex(void);
    void yyerror(char *s){fprintf(stderr, "%s\n", s);}
    int yywrap(void){return 1;}
}


%}

/* tokens */


%token DELIMITER
%token OPERATOR
%token KEYWORD
%token ID
%token INT_CONSTANT
%token BOOL_CONSTANT
%token FLOAT_CONSTANT
%token STRING_CONSTANT
%token SEMICOLON

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS 

%%

id: 		ID{
  		Trace("ID\n");
		};

operator:	OPERATOR{
		Trace("OPERATOR\n");
		};

semi:           SEMICOLON
                {
                Trace("Reducing to semi\n");
                };
%%

#include "lex.yy.c"

int main()
{
    yyparse();
    return 0;
}

