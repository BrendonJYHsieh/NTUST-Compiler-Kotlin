%option noyywrap
%{

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
#define token(t){LIST; printf("<%s>\n",t);}
#define tokenDelimiter(t) {LIST; printf("<\'%s\'>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",t,i);}
#define tokenFloat(t,i) {LIST; printf("<%s:%g>\n",t,i);}
#define tokenString(t,s) {LIST; cout<<"<"<<t<<":"<<s<<">\n";}
#define tokenBool(t) {LIST; cout<<"<bool:"<<t<<"\n";}



string buffer="";
char buf[MAX_LINE_LENG];
%}

identifier [A-Za-z_][A-Za-z0-9_]*
delimiter \,|\:|\;|\->|\(|\)|\[|\}|\{|\}
keyword "bool"|"break"|"char"|"case"|"class"|"continue"|"declare"|"do"|"else"|"exit"|"false"|"for"|"fun"|"if"|"int"|"loop"|"print"|"println"|"return"|"string"|"val"|"var"|"while"
operator "+"|"-"|"*"|"/"|"%"|"<"|"<="|">="|">"|"=="|"!="|"&"|"|"|"!"|"="|"+="|"-="|"*="|"/="
string \".*\"
integer [0-9]+
float [0-9]+[.][0-9]+
bool "true"|"false"



%x COMMENT

%%


{keyword} {
	LIST;
	cout<<"<"<<s_toupper(yytext)<<">\n";
}

\n {
	LIST;
	printf("%d: %s",yylineno++,buf);
	buf[0]='\0';
}

[ \t] {LIST;} 

"/*" { BEGIN COMMENT; LIST;}
"//".* {LIST;}

{string} {
	tokenString("string",s_process(yytext));
}


{identifier} {
        insert(yytext);
	tokenString("id",yytext);
}


{delimiter} {
	tokenDelimiter(yytext);
}

{operator} {
	token("OPERATOR");
}

{integer} {
	tokenInteger("int",atoi(yytext));
}

{float} {

	tokenFloat("float",stof(yytext));
}

{bool}  {
        tokenBool(atoi(yytext));
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

