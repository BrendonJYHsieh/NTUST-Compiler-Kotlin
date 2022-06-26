%option noyywrap
%{
#include "y.tab.h"
#include<iostream>
#include<string>
#include<cctype>
#include<vector>
using namespace std;

vector<string> symbol;

string  s_toupper(string input){
	for(int i=0;i<input.size();i++){
		input[i] = toupper(input[i]);
	}
	return input;
}
string s_process(string input){
	input.erase(input.begin(),input.begin()+1);
	input.erase(input.end()-1);
	for(int i=0;i<input.size()-1;i++){
		if(input[i]=='\"'&&input[i+1]=='\"'){
			input.erase(input.begin()+i,input.begin()+i+1);
		}
	}
	return input;
}
void insert(string input){
	bool check=false;
	for(int i=0;i<symbol.size();i++){
		if(symbol[i]==input){
			check = true;
			break;
		}
	}
	if(!check){
		symbol.push_back(input);
	}	
}



#define MAX_LINE_LENG 256
#define LIST strcat(buf,yytext);
#define token(t){LIST; cout<<"<"<<t<<">\n"; } 
#define tokenDelimiter(t) {LIST; cout<<"<DELIMITER:\'"<<t<<"\'>\n"; }
#define tokenInteger(t,i) {LIST; cout<<"<INT:"<<i<<">\n"; }
#define tokenFloat(t,i) {LIST; cout<<"<FLOAT:"<<i<<">\n"; }
#define tokenString(t) {LIST; cout<<"<STRING:"<<t<<">\n"; }
#define tokenID(t) {LIST; cout<<"<ID:"<<t<<">\n"; }
#define tokenBool(t) {LIST; cout<<"<BOOL:"<<t<<">\n"; }
#define tokenOP(t) {LIST; cout<<"<OPERATOR:\'"<<t<<"\'>\n"; }


string buffer="";
char buf[MAX_LINE_LENG];
%}

identifier [A-Za-z_][A-Za-z0-9_]*
delimiter \,|\:|\;|\->|\(|\)|\[|\}|\{|\}
keyword "bool"|"break"|"char"|"case"|"class"|"continue"|"declare"|"do"|"else"|"exit"|"float"|"for"|"fun"|"if"|"int"|"loop"|"print"|"println"|"return"|"string"|"val"|"var"|"while"
operator "+"|"-"|"*"|"/"|"%"|"<"|"<="|">="|">"|"=="|"!="|"&"|"|"|"!"|"="|"+="|"-="|"*="|"/="
string \".*\"
integer [0-9]+
float [0-9]+[.][0-9]+
bool "false"|"true"

%x COMMENT

%%


{keyword} {
	//yylval = yytext;
	token(s_toupper(yytext));
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
	//yylval = atoi(yytext);
	tokenBool(yytext);
}

{string} {
	//yylval = yytext;
	tokenString(s_process(yytext));
}


{identifier} {
        insert(yytext);
	tokenID(yytext);
	//return ID;
}


{delimiter} {
	//yylval = yytext;
	tokenDelimiter(yytext);
}

{operator} {
	tokenOP(yytext);
}

{integer} {
	//yylval = atoi(yytext);
	tokenInteger(INT,atoi(yytext));
}

{float} {
	//yylval = stof(yytext);
	tokenFloat(FLOAT,stof(yytext));
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

#define READ

#ifdef READ
int main(int argc, char *argv[]){
	argv++,argc--;
	#ifdef test
	yyin = fopen("./input.txt","r");
	
	#else
	if(argc){
		yyin = fopen(argv[0],"r");
	}
	else{
		yyin = stdin;
	}
	#endif
	yylex();
	fclose(yyin);
	cout<<"Symbol Table:"<<endl;
	for(int i=0;i<symbol.size();i++){
		cout<<symbol[i]<<endl;
	}
	return 0;
}
#endif

