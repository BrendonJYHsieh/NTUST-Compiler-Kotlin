%option noyywrap
%{
#include "y.tab.h"

string  s_toupper(string input){
	for(int i=0;i<input.size();i++){
		input[i] = toupper(input[i]);
	}
	return input;
}
string s_process(string input){
	for(int i=0;i<input.size()-1;i++){
		if(input[i]=='\"'&&input[i+1]=='\"'){
			input.erase(input.begin()+i,input.begin()+i+1);
		}
	}
	return input;
}

#define MAX_LINE_LENG 256
#define LIST strcat(buf,yytext);
#define tokenKeyword(t){LIST; } 
#define tokenDelimiter(t) {LIST; }
#define tokenInteger(t,i) {LIST; }
#define tokenString(t) {LIST; }
#define tokenChar(t) {LIST; }
#define tokenIdentifier(t) {LIST; }
#define tokenBool(t) {LIST; }
#define tokenOperator(t) {LIST; }


string buffer="";
char buf[MAX_LINE_LENG];
%}

identifier [A-Za-z_][A-Za-z0-9_]*
string \"(\$\{.*\}|\\.|[^\"\\])*\"
integer [0-9]+
bool "false"|"true"

%x COMMENT

%%

"bool" {
    tokenKeyword(s_toupper(yytext));
    return BOOL;
}
"break" {
    tokenKeyword(s_toupper(yytext));
    return BREAK;
}
"char" {
    tokenKeyword(s_toupper(yytext));
    return CHAR;
}
"class" {
    tokenKeyword(s_toupper(yytext));
    return CLASS;
}
"continue" {
    tokenKeyword(s_toupper(yytext));
    return CONTINUE;
}
"do" {
    tokenKeyword(s_toupper(yytext));
    return DO;
}
"else" {
    tokenKeyword(s_toupper(yytext));
    return ELSE;
}
"for" {
    tokenKeyword(s_toupper(yytext));
    return FOR;
}
"fun" {
    tokenKeyword(s_toupper(yytext));
    return FUN;
}
"if" {
    tokenKeyword(s_toupper(yytext));
    return IF;
}
"int" {
    tokenKeyword(s_toupper(yytext));
    return INT;
}
"print" {
    tokenKeyword(s_toupper(yytext));
    return PRINT;
}
"println" {
    tokenKeyword(s_toupper(yytext));
    return PRINTLN;
}
"return" {
    tokenKeyword(s_toupper(yytext));
    return RETURN;
}
"string" {
    tokenKeyword(s_toupper(yytext));
    return STRING;
}
"val" {
    tokenKeyword(s_toupper(yytext));
    return VAL;
}
"var" {
    tokenKeyword(s_toupper(yytext));
    return VAR;
}
"while" {
    tokenKeyword(s_toupper(yytext));
    return WHILE;
}
"in" {
    tokenKeyword(s_toupper(yytext));
    return IN;
}


"\," {
    tokenDelimiter(yytext);
    return COMMA;
}
"\:" {
    tokenDelimiter(yytext);
    return COLON;
}
"\(" {
    tokenDelimiter(yytext);
    return LEFT_PARENTHESES;
}
"\)" {
    tokenDelimiter(yytext);
    return RIGHT_PARENTHESES;
}
"\{" {
    tokenDelimiter(yytext);
    return LEFT_CURLY;
}
"\}" {
    tokenDelimiter(yytext);
    return RIGHT_CURLY;
}
"\[" {
    tokenDelimiter(yytext);
    return LEFT_SQUARE;
}
"\]" {
    tokenDelimiter(yytext);
    return RIGHT_SQUARE;
}
"+" {
    tokenOperator(yytext);
    return PLUS;
}
"-" {
    tokenOperator(yytext);
    return MINUS;
}
"*" {
    tokenOperator(yytext);
    return MULTIPLY;
}
"/" {
    tokenOperator(yytext);
    return DIVIDE;
}
"%" {
    tokenOperator(yytext);
    return MODULE;
}
"<" {
    tokenOperator(yytext);
    return LESSTHAN;
}
"<=" {
    tokenOperator(yytext);
    return LESSTHAN_EQUAL;
}
">=" {
    tokenOperator(yytext);
    return GREATERTHAN_EQUAL;
}
">" {
    tokenOperator(yytext);
    return GREATERTHAN;
}
"==" {
    tokenOperator(yytext);
    return EQUAL;
}
"!=" {
    tokenOperator(yytext);
    return NOT_EQUAL;
}
"&" {
    tokenOperator(yytext);
    return AND;
}
"|" {
    tokenOperator(yytext);
    return OR;
}
"!" {
    tokenOperator(yytext);
    return NOT;
}
"=" {
    tokenOperator(yytext);
    return ASSIGN;
}
"+=" {
    tokenOperator(yytext);
    return PLUS_ASSIGN;
}
"-=" {
    tokenOperator(yytext);
    return MINUS_ASSIGN;
}
"*=" {
    tokenOperator(yytext);
    return MULTIPLY_ASSIGN;
}
"/=" {
    tokenOperator(yytext);
    return DIVIDE_ASSIGN;
}

"\.\." {
    tokenOperator(yytext);
    return TO;
}

\n {
	LIST;
	printf("%d: %s",yylineno++,buf);
	buf[0]='\0';
}

[ \t] {LIST;} 

"/*" { BEGIN COMMENT; LIST;}
"//".* {LIST;}

{bool}	{	
	yylval.sval = (char*) malloc(strlen(yytext));	
	strcpy(yylval.sval,yytext);
	tokenBool(yytext);
	return BOOL_CONSTANT;
}

\'[A-z]\' {
	yylval.sval = (char*) malloc(strlen(yytext));	
	strcpy(yylval.sval,yytext);
	tokenChar(yytext);
	return CHAR_CONSTANT;
}

{string} {
	yylval.sval = (char*) malloc(strlen(yytext));	
	strcpy(yylval.sval,yytext);
	tokenString(s_process(yytext));
	return STRING_CONSTANT;
}

{identifier} {
	yylval.sval = (char*) malloc(strlen(yytext));	
	strcpy(yylval.sval,yytext);
	tokenIdentifier(yytext);
	return ID;
}

{integer} {
	yylval.sval = (char*) malloc(strlen(yytext));	
	strcpy(yylval.sval,yytext);
	tokenInteger(INT,atoi(yytext));
	return INT_CONSTANT;
}

<COMMENT>\n {
	LIST;
	printf("%d: %s",yylineno++,buf);
	buf[0]='\0';
	}
<COMMENT>. {
	LIST;
	}
<COMMENT>"*/" {
	LIST;
	BEGIN 0;
	}

%%

