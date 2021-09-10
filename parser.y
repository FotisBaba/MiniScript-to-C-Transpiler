%{					
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>	
#include "teaclib.h"	
#include "cgen.c"

extern int yylex(void);
extern int line_num;
%}

%union
{
	char* str;
	double real;
	int intNum;
}


%token <str> TK_IDENT
%token TK_ASSGN
%token TK_SEMICOLON
%token TK_LEFT_PAR
%token TK_RIGHT_PAR
%token TK_LEFT_BRA
%token TK_RIGHT_BRA
%token TK_COMMA
%token TK_COLON
%token <intNum> TK_INT
%token <real> TK_REAL
%token <intNum> TK_BOOL
%token <str> TK_STRING
%token TK_GRT_EQ_THN
token TK_LSS_EQ_THN
%token TK_NOT_EQ
 
%token KW_IF
%token KW_THEN
%token KW_ELSE
%token KW_FI
%token KW_WHILE
%token KW_LOOP
%token KW_POOL
%token KW_TRUE
%token KW_FALSE
%token KW_INT
%token KW_STRING
%token KW_REAL
%token KW_BOOL
%token KW_CONST
%token KW_LET
%token KW_BREAK
%token KW_RETURN
%token KW_NOT
%token KW_AND
%token KW_OR
%token KW_START

%left 	OR_OP
%left 	AND_OP
%left 	'=' '<' TK_NOT_EQ TK_LESS_EQ_THN
%left 	'+' '-'
%left 	'*' '/' '%'
%right 	'!' KW_NOT

%token 	TK_ARROW

%start 	program

%type 	<str> decl_list body 
%type 	<str> let_decl_body const_decl_body let_decl_list const_decl_list let_decl_init const_decl_init decl_id func_decl 
%type 	<str> stmt if_else_stmt else_stmt while_loop_stmt assgn_stmt return_stmt
%type 	<str> stmts func_var_decl func_var func_call func_call_var func_call_body
%type 	<str> type_spec start_func decl
%type 	<str> expr let_decl const_decl_id 

%%					

program: decl_list KW_CONST KW_START TK_ASSGN '(' ')' ':' KW_INT TK_ARROW '{' body '}' { 
/* We have a successful parse! 
  Check for any errors and generate output. 
*/
	if(yyerror_count==0) {
    // include the teaclib.h file
	  puts(c_prologue); 
	  printf("/* program */ \n\n");
	  printf("%s\n\n", $1);
	  printf("int main() {\n%s\n} \n", $11);
	}
}
;

expr: /* empty */			{$$ = template("");}
| TK_IDENT					{$$ = template("%s", $1);}
| TK_INT					{$$ = template("%s", $1);}
| TK_REAL 					{$$ = template("%s", $1);}
| TK_BOOL 					{$$ = template("%s", $1);}
| TK_STRING 				{$$ = template("%s", $1);}
| '(' expr ')' 				{$$ = template("(%s)", $2);}
| KW_NOT expr 				{$$ = template("!%s", $2);}
| '+' expr					{$$ = template("%s", $2);}
| '-' expr 					{$$ = template("-%s", $2);}
| expr '/' expr 			{$$ = template("%s / %s", $1, $3);}
| expr '*' expr 			{$$ = template("%s * %s", $1, $3);}
| expr '%' expr 			{$$ = template("%s % %s", $1, $3);}
| expr '+' expr 			{$$ = template("%s + %s", $1, $3);}
| expr '-' expr 			{$$ = template("%s - %s", $1, $3);}
| expr '=' expr 			{$$ = template("%s == %s", $1, $3);}
| expr TK_NOT_EQ expr 		{$$ = template("%s != %s", $1, $3);}
| expr '<' expr 			{$$ = template("%s < %s", $1, $3);}
| expr TK_LESS_EQ_THN expr 	{$$ = template("%s <= %s", $1, $3);}
| expr KW_AND expr 			{$$ = template("%s && %s", $1, $3);}
| expr KW_OR expr 			{$$ = template("%s || %s", $1, $3);}
;




decl_list: decl_list decl 					   { $$ = template("%s %s", $1, $2); }
| decl  									   { $$ = template(" %s ", $1); }
;

let_decl_body: let_decl_list ':' type_spec ';' {  $$ = template("%s %s;", $3, $1); }
;

let_decl_list: let_decl_list ',' let_decl_init { $$ = template("%s, %s", $1, $3 );}
| const_decl_init      						   { $$ = template(" %s ", $1); }
;

let_decl_init: decl_id 						   { $$ = template(" %s ", $1); }
| decl_id TK_ASSGN expr 					   { $$ = template("%s = %s", $1, $3); }
; 

decl: KW_CONST const_decl_body 				   { $$ = template(" %s", $2); }
| KW_LET let_decl_body 						   { $$ = template(" %s", $2); }
;

const_decl_body: const_decl_list ':' type_spec ';' 		{  $$ = template("%s %s;", $3, $1); }
;

const_decl_list: const_decl_list ',' const_decl_init    { $$ = template("%s, %s", $1, $3 );}
| const_decl_init 										{ $$ = template(" %s ", $1); }
;

const_decl_init: decl_id 								{ $$ = template(" %s ", $1); }
| decl_id TK_ASSGN expr 								{ $$ = template("%s = %s", $1, $3); 
}
; 

decl_id: TK_IDENT 										{ $$ = template(" %s ", $1); } 
| TK_IDENT '['']' 										{ $$ = template("*%s", $1); }
;







func_decl: KW_CONST TK_IDENT TK_ASSGN '(' func_var_decl ')' ':' type_spec TK_ARROW '{' body '}' {$$ = template("%s %s ( %s ) { %s }", $8, $2, $5, $11);}
;


func_var_decl: func_var ',' func_var_decl			{ $$ = template("%s, %s", $1, $3);}
| func_var 											{ $$ = template(" %s ", $1); } 
;



func_var: decl_id ':' type_spec 					{ $$ = template("%s, %s", $1, $3);}
;

func_call: TK_IDENT TK_ASSGN func_call_body			{ $$ = template("%s = %s", $1, $3);}
|func_call_body										{ $$ = template(" %s ", $1); } 
;

func_call_body: TK_IDENT '(' func_call_var ')' ';'	{ $$ = template(" %s(%s); ", $1, $3); } 
| TK_IDENT '(' ')' ';'								{ $$ = template(" %s(); ", $1); } 
;



func_call_var: func_call_var ',' expr				{ $$ = template(" %s, %s ", $1, $3); } 
| expr 												{ $$ = template(" %s ", $1); } 
;






type_spec: KW_INT 									{ $$ = template("int");}
| KW_REAL 											{ $$ = template("double");}
| KW_BOOL 											{ $$ = template("int");}
| KW_STRING											{ $$ = template("char*");}
;


assgn_stmt: TK_IDENT TK_ASSGN expr ';'				{ $$ = template("%s = %s;", $1, $3);}
;


if_else_stmt: KW_IF expr KW_THEN stmts KW_FI  		{ $$ = template("if %s { %s }", $2, $4);}
| KW_IF expr KW_THEN stmts else_stmt 				{ $$ = template("if %s { %s } %s", $2, $4, $5);}


else_stmt: KW_ELSE stmts KW_FI 						{ $$ = template("else{ %s }", $2);}



while_loop_stmt: KW_WHILE expr KW_LOOP stmts KW_POOL {$$ = template("while ( %s ){%s}", $2, $4);}
;

return_stmt: KW_RETURN expr ';' 					{$$ = template("return %s;", $2);}
;

start_func: KW_CONST KW_START TK_ASSGN '(' ')' ':' KW_INT TK_ARROW '{' body '}' {$$ = template("int main( %s )", $10);}
;


body: 											{$$ = template("");}
| stmts 										{$$ = template("%s", $1);}
;


stmts: 											{$$ = template("");}
| stmt											{$$ = template("%s", $1);}
| stmts stmt									{$$ = template("%s %s", $1, $2);}
;

stmt: assgn_stmt								{$$ = template("%s", $1);}
| if_else_stmt									{$$ = template("%s", $1);}
| while_loop_stmt								{$$ = template("%s", $1);}
| return_stmt 									{$$ = template("%s", $1);}
| func_decl										{$$ = template("%s", $1);}
| decl_list 									{$$ = template("%s", $1);}
;


%%					
void main(){
	if(yyparse()!= 0)
		printf("Rejected!\n");
}

