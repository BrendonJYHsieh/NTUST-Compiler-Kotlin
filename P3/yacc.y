%{
#define YYDEBUG 1
#define INT_TYPE 0
#define BOOL_TYPE 1
#define CHAR_TYPE 2
#define STRING_TYPE 3
#define FUNC_TYPE 4
#define VOID 5

#include<stdio.h>
#include<cstring>
#include<fstream>
#include<iostream>
#include<string>
#include<vector>
#include<cmath>
#include<map>
using namespace std;

fstream file;

struct SYMBOL
{
    string name;
    int index = -1;
    int type = -1;
    int ival = 0;
    int layer = 0;
    int function_return_type = -1;
    string sval ="";
    string cval = "";
    bool bval = 0;
    vector<int> args;
    bool Is_val = false;
};

struct TABLE
{
    vector<SYMBOL>table;
    int count=0;
};

class SYMBOL_TABLE
{
public:
    SYMBOL_TABLE() {};
    ~SYMBOL_TABLE() {};
    vector<TABLE>tables;
    vector<int>args_catch;
    vector<int>state_stack;
    string classname;
    int current_layer;
    int counter=0;
    int state_counter=0;

    bool opr = false;
    bool def = false;

    void push_table() {
        TABLE tmp;
        tables.push_back(tmp);
        current_layer = tables.size()-1;
    }

    void dump_table() {
        cout << "*********<SYMBOL TABLE - START>*********" << endl;
        for (int i = 0; i < tables[current_layer].table.size(); i++) {
            SYMBOL tmp = tables[current_layer].table[i];
            if (tmp.type == 0 || tmp.type == 1 || tmp.type == 2 || tmp.type == 3) {
                if(tmp.Is_val==true){
                    cout << "<\"" << tmp.name << "\", const, " << type_to_string(tmp.type) << ", value: " << tmp.ival<< ">" << endl;
                }
                else{
                    cout << "<\"" << tmp.name << "\", variable, " << type_to_string(tmp.type) << ", index: " << tmp.index << ">" << endl;
                }
            }
            else if (tmp.type == 4) {
                cout << "<\"" << tmp.name << "\", " << type_to_string(tmp.type) << ", Args(";
                for(int i=tmp.args.size()-1; i>=0 ; i--){
                    cout<<type_to_string(tmp.args[i]);
                    if(i!=0){
                        cout<<", ";
                    }
                }
                cout<<")>" << endl;
            }
        }
        cout << "**********<SYMBOL TABLE - END>**********" << endl << endl;;
        tables.pop_back();
        current_layer = tables.size()-1;
    }

    string type_to_string(int num) {
        if(num==-1){
            return "void";
        }
        if (num == 0) {
            return "int";
        }
        else if (num == 1) {
            return "boolean";
        }
        else if (num == 2) {
            return "char";
        }
        else if (num == 3) {
            return "string";
        }
        else if (num == 4) {
            return "FUNC_TYPE";
        }
    }

    void insert_id_type(const char* c_id, int c_type,bool Is_val = false,bool fun =false) {
        SYMBOL tmp;
        string id(c_id);
        tmp.name = id;
        tmp.type = c_type;
        tmp.Is_val = Is_val;
        tmp.layer = current_layer;
        if(tmp.Is_val == false){
            tmp.index = tables[current_layer].count++;
            if(current_layer==0){
                if(tmp.type == INT_TYPE){
                    file<<"\tfield static int "<< tmp.name<<endl;
                }
                else if(tmp.type == BOOL_TYPE) {
                    file<<"\tfield static boolean "<< tmp.name<<endl;
                }
            }
            else{
                if(!fun){
                    if(tmp.type == INT_TYPE){
                        file<<"\tsipush "<< tmp.ival <<endl;
                    }
                    else if(tmp.type == BOOL_TYPE) {
                        file<<"\ticonst_"<< tmp.bval <<endl;
                    }
                    file<<"\tistore "<< tmp.index<<endl;
                }
            }
            
        }
        tables[current_layer].table.push_back(tmp);
        def = false;
    }

    void insert_id_value(const char* c_id, const char* c_value, bool Is_val = false) {
        SYMBOL tmp;
        string id(c_id);
        string value(c_value);
        tmp.name = id;
        tmp.type = return_type(c_value);
        tmp.Is_val = Is_val;
        tmp.layer = current_layer;
        
        if (tmp.type == INT_TYPE) {
            tmp.ival = stoi(value);
        }
        else if(tmp.type == BOOL_TYPE) {
            if (value == "true") {
                tmp.bval = true;
            }
            else {
                tmp.bval = false;
            }
        }
        else if (tmp.type == CHAR_TYPE) {
            value.erase(value.begin());
            value.erase(value.end()-1);
            tmp.cval = value;
        }
        else if(tmp.type == STRING_TYPE){
            tmp.sval = value;
        }

        if(tmp.Is_val == false){
            tmp.index = tables[current_layer].count++;
            if(current_layer==0){
                file<<"\tfield static ";
                if(tmp.type == INT_TYPE){
                    file<<"int "<< tmp.name<<" = "<<tmp.ival <<endl;
                }
                else if(tmp.type == BOOL_TYPE) {
                    file<<"boolean "<< tmp.name<<" = "<<tmp.bval <<endl;
                }
            }
            else{
                if(tmp.type == INT_TYPE){
                    file<<"\tsipush "<< tmp.ival <<endl;
                }
                else if(tmp.type == BOOL_TYPE) {
                    file<<"\ticonst_"<< tmp.bval <<endl;
                }
                file<<"\tistore "<< tmp.index<<endl;
            }
            
        }
        tables[current_layer].table.push_back(tmp);
        def = false;
    }
    void insert_id_type_value(const char* c_id, int c_type, const char* c_value, bool Is_val = false) {
        SYMBOL tmp;
        string id(c_id);
        string value(c_value);
        tmp.name = id;
        tmp.layer = current_layer;
        tmp.type = c_type;
        tmp.Is_val = Is_val;

        if (tmp.type == INT_TYPE) {
            tmp.ival = stoi(value);
        }
        else if (tmp.type == BOOL_TYPE) {
            if (value == "true") {
                tmp.bval = true;
            }
            else {
                tmp.bval = false;
            }
        }
        else if (tmp.type == CHAR_TYPE) {
            value.erase(value.begin());
            value.erase(value.end()-1);
            tmp.cval = value;
        }
        else if(tmp.type == STRING_TYPE){
            tmp.sval = value;
        }
        if(tmp.Is_val == false){
            tmp.index = tables[current_layer].count++;
            if(current_layer==0){
                file<<"\tfield static ";
                if(tmp.type == INT_TYPE){
                    file<<"int "<< tmp.name<<" = "<<tmp.ival <<endl;
                }
                else if(tmp.type == BOOL_TYPE) {
                    file<<"boolean "<< tmp.name<<" = "<<tmp.bval <<endl;
                }
            }
            else{
                if(tmp.type == INT_TYPE){
                    file<<"\tsipush "<< tmp.ival <<endl;
                }
                else if(tmp.type == BOOL_TYPE) {
                    file<<"\ticonst_"<< tmp.bval <<endl;
                }
                file<<"\tistore "<< tmp.index<<endl;
            }
            
        }
        tables[current_layer].table.push_back(tmp);
        def = false;
    }
    int return_type(const char* c_value) {
        string value(c_value);
        if (value[0] == '\"'&& value[value.size()-1]== '\"') {
            return STRING_TYPE;
        }
        else if (value[0] == '\'' && value[value.size() - 1] == '\'') {
            return CHAR_TYPE;
        }
        else {
            if (value == "true"|| value == "false") {
                return BOOL_TYPE;
            }
            else {
                return INT_TYPE;
            }
        }
    }
    SYMBOL* lookup(const char* c_id) {
        string id(c_id);
        for (int i = current_layer; i >= 0; i--) {
            for (int j = 0; j < tables[i].table.size(); j++) {
                if (tables[i].table[j].name == id) {
                    return &tables[i].table[j];
                }
            }
        }
        return NULL;
    }
    SYMBOL* check(const char* c_id) {
        string id(c_id);
        for (int j = 0; j < tables[current_layer].table.size(); j++) {
            if (tables[current_layer].table[j].name == id) {
                return &tables[current_layer].table[j];
            }
        }
        return NULL;
    }
    char* strcopy(string input){
        char* tmp = (char*) malloc(input.size());	 
	    strcpy(tmp,input.c_str());
        return tmp;
    }
};

extern "C" {
    int yyparse();
    int yylex(void);
    int yywrap(void){return 1;};
    SYMBOL_TABLE st;
}

#include "lex.yy.c"
void yyerror(string s){cout<<"Semantic Error in line:"<<yylineno<<" <<"<<s<<">>"<<endl;} 


%}

%union {
	char*	sval;
	int 	ival;
}

/* tokens */
/* DELIMITER */
%token COMMA ","
%token COLON ":" 
%token LEFT_PARENTHESES "("
%token RIGHT_PARENTHESES ")"
%token LEFT_CURLY "{"
%token RIGHT_CURLY "}"

/* OPERATOR */
%token PLUS "+" 
%token MINUS "-" 
%token MULTIPLY "*"
%token DIVIDE "/" 
%token MODULE "%"
%token ASSIGN "="
%token LESSTHAN "<"
%token LESSTHAN_EQUAL "<="
%token GREATERTHAN_EQUAL ">="
%token GREATERTHAN ">"
%token EQUAL "=="
%token NOT_EQUAL "!="
%token AND "&"
%token OR "|"
%token NOT "!"
%token PLUS_ASSIGN "+="
%token MINUS_ASSIGN "-="
%token MULTIPLY_ASSIGN "*="
%token DIVIDE_ASSIGN "/="
%token TO ".."
%token LEFT_SQUARE "["
%token RIGHT_SQUARE "]"
/* KEYWORD */
%token BREAK CLASS CONTINUE DO ELSE FOR FUN IF PRINT PRINTLN RETURN VAL VAR WHILE IN
/* DATATYPE */
%token BOOL CHAR INT STRING 
%token <sval> ID

/* CONSTANT */
%token <sval> INT_CONSTANT 
%token <sval> BOOL_CONSTANT
%token <sval> CHAR_CONSTANT 
%token <sval> STRING_CONSTANT

%type <sval> expression 
%type <sval> FUN_ 
%type <ival> datatype

%left OR
%left AND
%left NOT
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULE
%left UMINUS 

// Program will start from a class
%start class

%nonassoc IFX
%nonassoc ELSE 


%%
// My parser will push a table when it encounters "{", so I need to push a table to push the class's ID into symbol table.
class: 	CLASS ID { file<<"class "<<$2; st.classname = string($2); file<<"{"<<endl; } block { file<<"}"<<endl;} 
	;	

statement:
    statement statement 
	| general_expression 
    | %empty
	;

// All kinds of expressions
general_expression:
	assignment_expression { st.opr = false; }
	| if_expression 
	| for_expression 
	| while_expression
	| variable_defination
    | function_expression 
	| expression
	| CONTINUE 
	| BREAK
	| PRINT { st.opr = true; file<<"\tgetstatic java.io.PrintStream java.lang.System.out"<<endl; } expression {
        if(st.return_type($3) == INT_TYPE){
            file<<"\tinvokevirtual void java.io.PrintStream.print(int)"<<endl;
        }
        else if(st.return_type($3) == BOOL_TYPE){
            file<<"\tinvokevirtual void java.io.PrintStream.print(boolean)"<<endl;
        }
        else if(st.return_type($3) == STRING_TYPE){
            file<<"\tinvokevirtual void java.io.PrintStream.print(java.lang.String)"<<endl;
        }
        st.opr = false;
    }
	| PRINTLN { st.opr = true; file<<"\tgetstatic java.io.PrintStream java.lang.System.out"<<endl; } expression {
        if(st.return_type($3) == INT_TYPE){
            file<<"\tinvokevirtual void java.io.PrintStream.println(int)"<<endl;
        }
        else if(st.return_type($3) == BOOL_TYPE){
            file<<"\tinvokevirtual void java.io.PrintStream.println(boolean)"<<endl;
        }
        else if(st.return_type($3) == STRING_TYPE){
            file<<"\tinvokevirtual void java.io.PrintStream.println(java.lang.String)"<<endl;
        }
        st.opr = false;
    }
    | RETURN expression {
        if(st.return_type($2)==INT_TYPE){
            file<<"\tireturn"<<endl;
        }
    }
	;

// All kinds of assignment expression
assignment_expression:
    ID { SYMBOL* tmp = st.lookup($1); if(tmp->Is_val==false) st.opr=true;  } 
        "="  expression {
        SYMBOL* tmp = st.lookup($1);
        if(tmp!=NULL){
            if(tmp->type == st.return_type($4)){
                if(tmp->Is_val==true){
                    if(tmp->type == INT_TYPE){
                        string a($4);
                        tmp->ival = stoi(a);
                    }
                    else if(tmp->type == BOOL_TYPE){
                        if(strcmp($4,"true")==0){
                            tmp->bval = true;
                        }
                        else{
                            tmp->bval = false;
                        }
                    }
                    else if(tmp->type == STRING_TYPE){
                        string value($4);
                        tmp->sval = value;
                    }
                }
                else {
                    if(tmp->layer!=0){
                        file<<"\tistore "<< tmp->index<<endl; 
                    }
                    else{
                        if(tmp->type == INT_TYPE){
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                        else if(tmp->type == BOOL_TYPE){
                            file<<"\tputstatic boolean "<< st.classname<<"."<<tmp->name<<endl;
                        }
                    }
                    st.opr = false;
                }
            }
            else{
                yyerror("Type confliction");
                YYABORT;
            }
        }
        else{
            yyerror("The variable has not been defined");
            YYABORT;
        }
    }	
	| ID { 
            SYMBOL* tmp = st.lookup($1); 
            if(tmp!=NULL){
                if(tmp->type == INT_TYPE){
                    if(tmp->Is_val==false){
                        st.opr=true;
                        if(tmp->layer==0){
                            file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                        }
                        else{
                            file<<"\tiload "<<tmp->index<<endl;
                        }
                    }
                }
                else{
                    yyerror("Type confliction");
                    YYABORT;
                }
            }
            else{
                yyerror("The variable has not been defined");
                YYABORT;
            }
        }  "+=" expression {
        SYMBOL* tmp = st.lookup($1);
        if(tmp!=NULL){
            if(tmp->type == st.return_type($4) && tmp->type  == INT_TYPE){
                string a($4);
                if(tmp->Is_val==true){
                    if(tmp->type == INT_TYPE){
                        tmp->ival = tmp->ival + stoi(a);
                    }
                }
                else {
                    if(tmp->layer!=0){
                        file<<"\tiadd"<<endl;
                        file<<"\tistore "<< tmp->index<<endl; 
                    }
                    else{
                        if(tmp->type == INT_TYPE){
                            file<<"\tiadd"<<endl;
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                    }
                    st.opr = false;
                }
            }
            else{
                yyerror("Type confliction");
                YYABORT;
            }
        }
        else{
            yyerror("The variable has not been defined");
            YYABORT;
        }
    }
	| ID { 
            SYMBOL* tmp = st.lookup($1); 
            if(tmp!=NULL){
                if(tmp->type == INT_TYPE){
                    if(tmp->Is_val==false){
                        st.opr=true;
                        if(tmp->layer==0){
                            file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                        }
                        else{
                            file<<"\tiload "<<tmp->index<<endl;
                        }
                    }
                }
                else{
                    yyerror("Type confliction");
                    YYABORT;
                }
            }
            else{
                yyerror("The variable has not been defined");
                YYABORT;
            }
        }  "-=" expression {
        SYMBOL* tmp = st.lookup($1);
        if(tmp!=NULL){
            if(tmp->type == st.return_type($4) && tmp->type  == INT_TYPE){
                string a($4);
                if(tmp->Is_val==true){
                    if(tmp->type == INT_TYPE){
                        tmp->ival = tmp->ival - stoi(a);
                    }
                }
                else {
                    if(tmp->layer!=0){
                        file<<"\tisub"<<endl;
                        file<<"\tistore "<< tmp->index<<endl; 
                    }
                    else{
                        if(tmp->type == INT_TYPE){
                            file<<"\tisub"<<endl;
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                    }
                    st.opr = false;
                }
            }
            else{
                yyerror("Type confliction");
                YYABORT;
            }
        }
        else{
            yyerror("The variable has not been defined");
            YYABORT;
        }
    }
	| ID { 
            SYMBOL* tmp = st.lookup($1); 
            if(tmp!=NULL){
                if(tmp->type == INT_TYPE){
                    if(tmp->Is_val==false){
                        st.opr=true;
                        if(tmp->layer==0){
                            file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                        }
                        else{
                            file<<"\tiload "<<tmp->index<<endl;
                        }
                    }
                }
                else{
                    yyerror("Type confliction");
                    YYABORT;
                }
            }
            else{
                yyerror("The variable has not been defined");
                YYABORT;
            }
        }  "*=" expression {
        SYMBOL* tmp = st.lookup($1);
        if(tmp!=NULL){
            if(tmp->type == st.return_type($4) && tmp->type  == INT_TYPE){
                string a($4);
                if(tmp->Is_val==true){
                    if(tmp->type == INT_TYPE){
                        tmp->ival = tmp->ival * stoi(a);
                    }
                }
                else {
                    if(tmp->layer!=0){
                        file<<"\timul"<<endl;
                        file<<"\tistore "<< tmp->index<<endl; 
                    }
                    else{
                        if(tmp->type == INT_TYPE){
                            file<<"\timul"<<endl;
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                    }
                    st.opr = false;
                }
            }
            else{
                yyerror("Type confliction");
                YYABORT;
            }
        }
        else{
            yyerror("The variable has not been defined");
            YYABORT;
        }
    }
	| ID { 
            SYMBOL* tmp = st.lookup($1); 
            if(tmp->Is_val==false) {
                st.opr=true;
            }
            if(tmp!=NULL){
                if(tmp->type == INT_TYPE){
                    if(tmp->Is_val==false){
                        if(tmp->layer==0){
                            file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                        }
                        else{
                            file<<"\tiload "<<tmp->index<<endl;
                        }
                    }
                }
                else{
                    yyerror("Type confliction");
                    YYABORT;
                }
            }
            else{
                yyerror("The variable has not been defined");
                YYABORT;
            }
        }  "/=" expression {
        SYMBOL* tmp = st.lookup($1);
        if(tmp!=NULL){
            if(tmp->type == st.return_type($4) && tmp->type  == INT_TYPE){
                string a($4);
                if(tmp->Is_val==true){
                    if(tmp->type == INT_TYPE){
                        tmp->ival = tmp->ival / stoi(a);
                    }
                }
                else {
                    if(tmp->layer!=0){
                        file<<"\tidiv"<<endl;
                        file<<"\tistore "<< tmp->index<<endl; 
                    }
                    else{
                        if(tmp->type == INT_TYPE){
                            file<<"\tidiv"<<endl;
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                    }
                    st.opr = false;
                }
            }
            else{
                yyerror("Type confliction");
                YYABORT;
            }
        }
        else{
            yyerror("The variable has not been defined");
            YYABORT;
        }
    }
    | ID "+" "+" { 
            SYMBOL* tmp = st.lookup($1); 
            if(tmp!=NULL){
                if(tmp->type == INT_TYPE){
                    if(tmp->Is_val==false){
                        if(tmp->layer==0){
                            file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                            file<<"\tsipush 1"<<endl;
                            file<<"\tiadd"<<endl;
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                        else{
                            file<<"\tiload "<<tmp->index<<endl;
                            file<<"\tsipush 1"<<endl;
                            file<<"\tiadd"<<endl;
                            file<<"\tistore "<< tmp->index<<endl; 
                        }
                    }
                    else{
                        tmp->ival++;
                    }
                }
                else{
                    yyerror("Type confliction");
                    YYABORT;
                }
            }
            else{
                yyerror("The variable has not been defined");
                YYABORT;
            }
        }
    | ID "-" "-" { 
            SYMBOL* tmp = st.lookup($1); 
            if(tmp!=NULL){
                if(tmp->type == INT_TYPE){
                    if(tmp->Is_val==false){
                        if(tmp->layer==0){
                            file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                            file<<"\tsipush 1"<<endl;
                            file<<"\tisub"<<endl;
                            file<<"\tputstatic int "<< st.classname<<"."<<tmp->name<<endl;
                        }
                        else{
                            file<<"\tiload "<<tmp->index<<endl;
                            file<<"\tsipush 1"<<endl;
                            file<<"\tisub"<<endl;
                            file<<"\tistore "<< tmp->index<<endl; 
                        }
                    }
                    else{
                        tmp->ival--;
                    }
                }
                else{
                    yyerror("Type confliction");
                    YYABORT;
                }
            }
            else{
                yyerror("The variable has not been defined");
                YYABORT;
            }
        }
    | ID "[" expression "]" "=" expression {
        string a($3);
        string b($6);
        file<<"\tload "<<$1<<endl;
        file<<"\tbipush "<<a<<endl;
        file<<"\tbipush "<<b<<endl;
        file<<"\tiastore"<<endl;
    }
	;

// All kinds of expressions
expression:
	expression "+" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tiadd"<<endl;
                $$ = st.strcopy("0");
            }
            else{
                string a($1);
                string b($3);
                int sum = stoi(a) + stoi(b);
                $$ = new char[100];
                sprintf($$, "%d", sum);
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    } 
	| expression "-" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                $$ = st.strcopy("0");
            }
            else{
                string a($1);
                string b($3);
                int sum = stoi(a) - stoi(b);
                $$ = new char[100];
                sprintf($$, "%d", sum);
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    } 
	| expression "*" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\timul"<<endl;
                $$ = st.strcopy("0");
            }
            else{
                string a($1);
                string b($3);
                int sum = stoi(a) * stoi(b);
                $$ = new char[100];
                sprintf($$, "%d", sum);
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    } 
	| expression "/" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tidiv"<<endl;
                $$ = st.strcopy("0");
            }
            else{
                string a($1);
                string b($3);
                int sum = stoi(a) / stoi(b);
                $$ = new char[100];
                sprintf($$, "%d", sum);
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    } 
	| expression "%" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tirem"<<endl;
                $$ = st.strcopy("0");
            }
            else{
                string a($1);
                string b($3);
                int sum = stoi(a) % stoi(b);
                $$ = new char[100];
                sprintf($$, "%d", sum);
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    } 
    | "-" expression %prec UMINUS {
        if(st.return_type($2)==INT_TYPE){
            if(st.opr==true){
                file<<"\tineg"<<endl;
                $$ = st.strcopy("0");
            }
            else{
                string a($2);
                int sum = -stoi(a);
                $$ = new char[100];
                sprintf($$, "%d", sum);
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression "&" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == BOOL_TYPE){
            if(st.opr==true){
                file<<"\tiand"<<endl;
                $$ = st.strcopy("false");
            }
            else{
                if(strcmp($1,"true")==0&&strcmp($3,"true")==0){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    } 
	| expression "|" expression {
        cout<<"test:"<<$1<<" "<<$3<<endl;
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == BOOL_TYPE){
            if(st.opr==true){
                file<<"\tior"<<endl;
                $$ = st.strcopy("false");
            }
            else{
                if(strcmp($1,"false")==0&&strcmp($3,"false")==0){
                    $$ = st.strcopy("false");
                }
                else{
                    $$ = st.strcopy("true");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
    | "!" expression {
        if(st.return_type($2)==BOOL_TYPE){
            if(st.opr==true){
                file<<"\ticonst_1"<<endl;
                file<<"\tixor"<<endl;
                $$ = st.strcopy("false");
            }
            else{
                if(strcmp($2,"true")==0){
                    $$ = st.strcopy("false");
                }
                else{
                    $$ = st.strcopy("true");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression "<" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                file<<"\tiflt L"<<st.counter<<endl;
                file<<"\ticonst_0"<<endl;
                file<<"\tgoto L"<< st.counter+1<<endl;
                file<<"L"<<st.counter<<": iconst_1"<<endl;
                file<<"L"<<st.counter+1<<":"<<endl;
                st.counter +=2;
                $$ = st.strcopy("false");
            }
            else{
                string a($1);
                string b($3);
                if(stoi(a)<stoi(b)){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression "<=" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                file<<"\tifle L"<<st.counter<<endl;
                file<<"\ticonst_0"<<endl;
                file<<"\tgoto L"<< st.counter+1<<endl;
                file<<"L"<<st.counter<<": iconst_1"<<endl;
                file<<"L"<<st.counter+1<<":"<<endl;
                st.counter +=2;
                $$ = st.strcopy("false");
            }
            else{
                string a($1);
                string b($3);
                if(stoi(a)<=stoi(b)){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression ">" expression {
        cout<<">:"<<$1<<" "<<$3<<endl;
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                file<<"\tifgt L"<<st.counter<<endl;
                file<<"\ticonst_0"<<endl;
                file<<"\tgoto L"<< st.counter+1<<endl;
                file<<"L"<<st.counter<<": iconst_1"<<endl;
                file<<"L"<<st.counter+1<<":"<<endl;
                st.counter +=2;
                $$ = st.strcopy("false");
            }
            else{
                string a($1);
                string b($3);
                if(stoi(a)>stoi(b)){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression ">=" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                file<<"\tifge L"<<st.counter<<endl;
                file<<"\ticonst_0"<<endl;
                file<<"\tgoto L"<< st.counter+1<<endl;
                file<<"L"<<st.counter<<": iconst_1"<<endl;
                file<<"L"<<st.counter+1<<":"<<endl;
                st.counter +=2;
                $$ = st.strcopy("false");
            }
            else{
                string a($1);
                string b($3);
                if(stoi(a)>=stoi(b)){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression "==" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                file<<"\tifeq L"<<st.counter<<endl;
                file<<"\ticonst_0"<<endl;
                file<<"\tgoto L"<< st.counter+1<<endl;
                file<<"L"<<st.counter<<": iconst_1"<<endl;
                file<<"L"<<st.counter+1<<":"<<endl;
                st.counter +=2;
                $$ = st.strcopy("false");
            }
            else{
                string a($1);
                string b($3);
                if(stoi(a)==stoi(b)){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| expression "!=" expression {
        if(st.return_type($1) == st.return_type($3) && st.return_type($1) == INT_TYPE){
            if(st.opr==true){
                file<<"\tisub"<<endl;
                file<<"\tifne L"<<st.counter<<endl;
                file<<"\ticonst_0"<<endl;
                file<<"\tgoto L"<< st.counter+1<<endl;
                file<<"L"<<st.counter<<": iconst_1"<<endl;
                file<<"L"<<st.counter+1<<":"<<endl;
                st.counter +=2;
                $$ = st.strcopy("false");
            }
            else{
                string a($1);
                string b($3);
                if(stoi(a)!=stoi(b)){
                    $$ = st.strcopy("true");
                }
                else{
                    $$ = st.strcopy("false");
                }
            }
        }
        else{
            yyerror("Type confliction");
            YYABORT;
        }
    }
	| "(" expression ")" { $$ = $2; }
	| CHAR_CONSTANT 		{ $$ = $1; }
	| BOOL_CONSTANT 		{
        $$ = $1;
        if(st.current_layer!=0&&!st.def){
            if(strcmp($1,"true")==0){
                file<<"\ticonst_1"<<endl;
            }
            else{
                file<<"\ticonst_0"<<endl;
            }
        }
    }
	| STRING_CONSTANT 		{ 
        $$ = $1; 
        if(st.current_layer!=0&&!st.def){
            file<<"\tldc "<< $1 <<endl;
        }
    }
	| INT_CONSTANT			{
        $$ = $1;
        if(st.current_layer!=0&&!st.def){
            string s($1);
            file<<"\tsipush "<< s <<endl;
        }
    }
	| ID "(" args_ ")" {
        SYMBOL* tmp = st.lookup($1);
        file<<"\tinvokestatic "<< st.type_to_string(tmp->function_return_type) <<" "<<st.classname<<"."<<tmp->name<<"(";
        for(int i=tmp->args.size()-1;i>=0;i--){
            file<<st.type_to_string(tmp->args[i]);
            if(i!=0){
                file<<",";
            }
        }
        file<<")"<<endl;
    }
	| ID {
        SYMBOL* tmp = st.lookup($1);
        if(tmp!=NULL){
            if(tmp->Is_val==true){
                if(tmp->type == INT_TYPE){
                    sprintf($$,"%d",tmp->ival);
                    file<<"\tsipush "<< tmp->ival<<endl;
                }
                else if(tmp->type == BOOL_TYPE){
                    if(tmp->bval == true){
                        $$ = st.strcopy("true");
                        file<<"\ticonst_1"<<endl;
                    }
                    else{
                        $$ = st.strcopy("false");
                        file<<"\ticonst_0"<<endl;
                    }
                }
                else if(tmp->type == STRING_TYPE){
                    file<<"\tldc "<<tmp->sval<<endl;
                    $$ = st.strcopy(tmp->sval);
                }
                else if(tmp->type == CHAR_TYPE){
                    
                }
            }
            else{
                if(tmp->type == INT_TYPE){
                    sprintf($$,"%d",tmp->ival);
                    if(tmp->layer!=0){
                        file<<"\tiload "<< tmp->index<<endl;
                    }
                    else{
                        file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
                    }
                }
                else if(tmp->type == BOOL_TYPE){
                    if(tmp->bval == true){
                        $$ = st.strcopy("true");
                        if(tmp->layer!=0){
                            file<<"\tiload "<< tmp->index<<endl;
                        }
                        else{
                            file<<"\tgetstatic boolean "<<st.classname<<"."<<tmp->name<<endl;
                        } 
                    }
                    else{
                        $$ = st.strcopy("false");
                        if(tmp->layer!=0){
                            file<<"\tiload "<< tmp->index<<endl;
                        }
                        else{
                            file<<"\tgetstatic boolean "<<st.classname<<"."<<tmp->name<<endl;
                        } 
                    }
                }
            }
        }
        else{
            yyerror("The variable has not been defined");
            YYABORT;
        }
    }
    | ID "[" expression "]" {
        $$ = st.strcopy("0");
        string a($3);
        file<<"\taload "<<$1<<endl;
        file<<"\tbipush "<<a<<endl;
        file<<"\tiaload"<<endl;
    }
	;



block: "{" { st.push_table(); } statement "}" { st.dump_table(); }

block_: "{" statement "}" { st.dump_table(); }

if_expression:
	IF D "(" expression ")" B block ELSE C general_expression G
	| IF D "(" expression ")" B block ELSE C block G
	| IF D "(" expression ")" B general_expression ELSE C block G
	| IF D "(" expression ")" B general_expression ELSE C general_expression G
    | IF D "(" expression ")" B block F %prec IFX 
	| IF D "(" expression ")" B general_expression F %prec IFX 
	;
B: %empty {
    st.opr = false;
    st.state_stack.push_back(st.state_counter++);
    file<<"\tifeq IFfalse"<<st.state_stack[st.state_stack.size()-1]<<endl;
 }
 ;
C: %empty {
    file<<"\tgoto IFexit"<<st.state_stack[st.state_stack.size()-1]<<endl;
    file<<"IFfalse"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
 }
 ;
D: %empty { st.opr = true; };

F: %empty { 
    file<<"\t"<<"nop"<<endl;
    file<<"IFfalse"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl; 
    st.state_stack.pop_back();
    }

G: %empty { 
    file<<"\t"<<"nop"<<endl;
    file<<"IFexit"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
    st.state_stack.pop_back();
    }
    


while_expression:
	WHILE { 
        st.state_stack.push_back(st.state_counter++);
        file<<"Wbegin"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
        st.def = false; 
        st.opr = true;
        } "(" expression ")" { 
        st.opr = false;
        file<<"\tifeq Wend"<<st.state_stack[st.state_stack.size()-1]<<endl; 
        } block {
            file<<"\tgoto Wbegin"<<st.state_stack[st.state_stack.size()-1]<<endl;
            file<<"\t"<<"nop"<<endl;
            file<<"Wend"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
            st.state_stack.pop_back();
        }
    | DO {
        st.def = false;
        st.state_stack.push_back(st.state_counter++);
        file<<"Wbegin"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl; 
        } block WHILE { st.opr = true; } "(" expression ")" {
            st.opr = false;
            file<<"\tifeq Wend"<<st.state_stack[st.state_stack.size()-1]<<endl;
            file<<"\tgoto Wbegin"<<st.state_stack[st.state_stack.size()-1]<<endl;
            file<<"\t"<<"nop"<<endl;
            file<<"Wend"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
            st.state_stack.pop_back();
        }
	;

for_expression:
	FOR E "(" ID IN expression ".." expression ")" {
        st.def = false;
        if(st.return_type($6)==st.return_type($8)||st.return_type($6)==INT_TYPE){
            st.state_stack.push_back(st.state_counter++);
            string a($6);
            string b($8);
            SYMBOL* tmp = st.lookup($4);
            file<<"\tsipush "<<stoi(a)<<endl;
            if(tmp->layer==0){
                file<<"\tputstatic int "<<st.classname<<"."<<tmp->name<<endl;
            }
            else{
                file<<"\tistore "<<tmp->index<<endl;
            }   
            file<<"Fbegin"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
            if(stoi(a)>stoi(b)){
                file<<"\tsipush "<<stoi(b)<<endl;
            }
            if(tmp->layer==0){
                file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
            }
            else{
                file<<"\tiload "<<tmp->index<<endl;
            }   
            if(stoi(a)<stoi(b)){
                file<<"\tsipush "<<stoi(b)<<endl;
            }
            file<<"\tisub"<<endl;
            file<<"\tifle L"<<st.counter<<endl;
            file<<"\ticonst_0"<<endl;
            file<<"\tgoto L"<<st.counter+1<<endl;
            file<<"L"<<st.counter<<":"<<endl;
            file<<"\ticonst_1"<<endl;
            file<<"L"<<st.counter+1<<":"<<endl;
            file<<"\tifeq Fend"<<st.state_stack[st.state_stack.size()-1]<<endl;
            st.counter+=2;
        }
    } block { 
        SYMBOL* tmp = st.lookup($4);
        string a($6);
        string b($8);
        if(tmp->layer==0){
                file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
            }
            else{
                file<<"\tiload "<<tmp->index<<endl;
            }  
        file<<"\tsipush 1"<<endl;
        if(stoi(a)<stoi(b)){
            file<<"\tiadd"<<endl;
        }
        else{
            file<<"\tisub"<<endl;
        }
        if(tmp->layer==0){
            file<<"\tputstatic int "<<st.classname<<"."<<tmp->name<<endl;
        }
        else{
            file<<"\tistore "<<tmp->index<<endl;
        }  
        file<<"\tgoto Fbegin"<<st.state_stack[st.state_stack.size()-1]<<endl;
        file<<"\t"<<"nop"<<endl;
        file<<"Fend"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl; 
        st.state_stack.pop_back();
        }
	| FOR E "(" ID IN expression ".." expression ")" {
        st.def = false;
        if(st.return_type($6)==st.return_type($8)||st.return_type($6)==INT_TYPE){
            st.state_stack.push_back(st.state_counter++);
            string a($6);
            string b($8);
            SYMBOL* tmp = st.lookup($4);
            file<<"\tsipush "<<stoi(a)<<endl;
            if(tmp->layer==0){
                file<<"\tputstatic int "<<st.classname<<"."<<tmp->name<<endl;
            }
            else{
                file<<"\tistore "<<tmp->index<<endl;
            }   
            file<<"Fbegin"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl;
            if(stoi(a)>stoi(b)){
                file<<"\tsipush "<<stoi(b)<<endl;
            }
            if(tmp->layer==0){
                file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
            }
            else{
                file<<"\tiload "<<tmp->index<<endl;
            }   
            if(stoi(a)<stoi(b)){
                file<<"\tsipush "<<stoi(b)<<endl;
            }
            file<<"\tisub"<<endl;
            file<<"\tifle L"<<st.counter<<endl;
            file<<"\ticonst_0"<<endl;
            file<<"\tgoto L"<<st.counter+1<<endl;
            file<<"L"<<st.counter<<":"<<endl;
            file<<"\ticonst_1"<<endl;
            file<<"L"<<st.counter+1<<":"<<endl;
            file<<"\tifeq Fend"<<st.state_stack[st.state_stack.size()-1]<<endl;
            st.counter+=2;
        }
    } general_expression { 
        SYMBOL* tmp = st.lookup($4);
        string a($6);
        string b($8);
        if(tmp->layer==0){
                file<<"\tgetstatic int "<<st.classname<<"."<<tmp->name<<endl;
            }
            else{
                file<<"\tiload "<<tmp->index<<endl;
            }  
        file<<"\tsipush 1"<<endl;
        if(stoi(a)<stoi(b)){
            file<<"\tiadd"<<endl;
        }
        else{
            file<<"\tisub"<<endl;
        }
        if(tmp->layer==0){
            file<<"\tputstatic int "<<st.classname<<"."<<tmp->name<<endl;
        }
        else{
            file<<"\tistore "<<tmp->index<<endl;
        }  
        file<<"\tgoto Fbegin"<<st.state_stack[st.state_stack.size()-1]<<endl;
        file<<"\t"<<"nop"<<endl;
        file<<"Fend"<<st.state_stack[st.state_stack.size()-1]<<":"<<endl; 
        st.state_stack.pop_back();
        }
	;
E: %empty { st.def = true; }
function_expression:
	FUN_ "(" args ")" {
        if(strcmp($1,"main")==0){
            file<<"\tmethod public static void main(java.lang.String[]";

        }
        else{
            file<<"\tmethod public static void "<<$1<< "(";
        }
        for(int i=st.args_catch.size()-1;i>=0;i--){
            file<<st.type_to_string(st.args_catch[i]);
            if(i!=0){
                file<<",";
            }
        }
        file<<")"<<endl;
        file<<"\tmax_stack 15"<<endl;
        file<<"\tmax_locals 15"<<endl;
        file<<"\t{"<<endl; 
     } block_ {
        SYMBOL* symbol = st.lookup($1);
        string id($1);
        if(symbol!=NULL){
            for(int i=0;i<st.args_catch.size();i++){
                symbol->args.push_back(st.args_catch[i]);
            }
        }
        file<<"\t\treturn"<<endl;
        file<<"\t}"<<endl;
        st.opr=false;
    }
	| FUN_ "(" args ")" ":" datatype {
        file<<"\tmethod public static "<< st.type_to_string($6)<<" " << $1 <<"(";
        for(int i=st.args_catch.size()-1;i>=0;i--){
            file<<st.type_to_string(st.args_catch[i]);
            if(i!=0){
                file<<",";
            }
        }
        file<<")"<<endl;
        file<<"\tmax_stack 15"<<endl;
        file<<"\tmax_locals 15"<<endl;
        file<<"\t{"<<endl; 
    } block_ {
        SYMBOL* symbol = st.lookup($1);
        symbol->function_return_type = $6;
        string id($1);
        if(symbol!=NULL){
            for(int i=0;i<st.args_catch.size();i++){
                symbol->args.push_back(st.args_catch[i]);
            }
        }
        file<<"\t}"<<endl;
        st.opr=false;
    }
	;

FUN_ :
    FUN ID { 
        st.insert_id_type($2,4,true); 
        st.push_table(); 
        st.args_catch.clear();
        $$ = $2;
        st.opr=true;
        st.def=false;
    }
    ;
variable_defination:
	VAL A ID "=" expression { 
            if(st.check($3)==NULL){
                st.insert_id_value($3, $5, true); 
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
    }
	| VAL A ID ":" datatype "=" expression { 
            if(st.check($3)==NULL){
                st.insert_id_type_value($3, $5, $7, true);
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
        }
	| VAR A ID { 
            if(st.check($3)==NULL){
                st.insert_id_type($3, INT_TYPE);
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
        }						
	| VAR A ID "=" expression { 
            if(st.check($3)==NULL){
                st.insert_id_value($3, $5); 
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
        }	
	| VAR A ID ":" datatype { 
            if(st.check($3)==NULL){
                st.insert_id_type($3, $5);  
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
        }	
	| VAR A ID ":" datatype "=" expression { 
            if(st.check($3)==NULL){
                st.insert_id_type_value($3, $5, $7);
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
        }
    | VAR A ID ":" INT "[" expression "]" {
        string a($7);
        file<<"\tint[] "<<$3<<endl;
        file<<"\tbipush "<<stoi(a)<<endl;
        file<<"\tnewarray int"<<endl;
        file<<"\tstore "<<$3<<endl;
    }
	; 
// Preventing JavaByteCode generate when program defines.
A: %empty { st.def = true; };

args_:
    args_ "," args_ 
	| expression 
    | %empty
	;
	
args:
	args "," args
   	| ID ":" datatype { 
            if(st.check($1)==NULL){
                st.insert_id_type($1,$3,false,true);
                st.args_catch.push_back($3);
            }
            else{
                yyerror("The variable has been defined");
                YYABORT;
            }
        }
	| %empty
	;

datatype: 
    INT        { $$ = 0; }
	| BOOL     { $$ = 1; }
	| CHAR     { $$ = 2; }
	| STRING   { $$ = 3; }
	;
%%

int main()
{
    //yydebug = 3;
    file.open("output.jasm",ios::out|ios::trunc);
    yyparse();
    return 0;
}