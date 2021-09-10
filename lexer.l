%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cgen.h"
#include "parser.tab.h"

extern FILE *yyin;
extern FILE *yyout;



int line_num = 1;

%}

%x ML_COMMENT

DIGIT   [0-9]
PRINT       [ -~]
ID      [a-zA-Z_][0-9a-zA-Z_]*
ICONST      [+-]?[0-9]{DIGIT}*
FCONST      [+-]?{DIGIT}*"."{DIGIT}+
CCONST      (\'{PRINT}\')|(\'\\[nftrbv]\')
STRING      \"{PRINT}*\"
NUMBER  [+-]?{DIGIT}{DIGIT}*
DECIMAL ([+-]?"."{NUMBER})|([+-]?{NUMBER}("."{NUMBER}?)?
REAL    {DECIMAL}([eE][+-]?{NUMBER})?

%%

"if"            { printf("\ntoken KEYWORD: if ");return KW_IF; }
"then"            { printf("\ntoken KEYWORD: then ");return KW_THEN; }
"else"      { printf("\ntoken KEYWORD: else ");return KW_ELSE; }
"fi"    { printf("\ntoken KEYWORD: fi ");return KW_FI; }
"while"       { printf("\ntoken KEYWORD: while ");return KW_WHILE; }
"loop"    { printf("\ntoken KEYWORD: loop ");return KW_LOOP; }
"pool"    { printf("\ntoken KEYWORD: pool ");return KW_POOL; }
"return"    { printf("\ntoken KEYWORD: return ");return KW_RETURN; }
"true"        { printf("\ntoken KEYWORD: true ");return KW_TRUE; }
"false"       { printf("\ntoken KEYWORD: false ");return KW_FALSE; }
"int"       { printf("\ntoken KEYWORD: int ");return KW_INT; }
"real"       { printf("\ntoken KEYWORD: real ");return KW_REAL; }
"string"       { printf("\ntoken KEYWORD: string ");return KW_STRING; }
"bool"       { printf("\ntoken KEYWORD: bool ");return KW_BOOL; }
"const"       { printf("\ntoken KEYWORD: const ");return KW_CONST; }
"let"       { printf("\ntoken KEYWORD: let ");return KW_LET; }
"break"       { printf("\ntoken KEYWORD: break ");return KW_BREAK; }
"not"       { printf("\ntoken KEYWORD: not ");return KW_NOT; }
"and"       { printf("\ntoken KEYWORD: and ");return KW_AND; }
"or"        { printf("\ntoken KEYWORD: or ");return KW_OR; }
"start"       { printf("\ntoken KEYWORD: start ");return KW_START; }


{ID}    { printf("\ntoken IDENTIFIER: %s ", yytext);return TK_IDENT; }


{STRING}  { printf("\ntoken CONST_STRING %s ", yytext); return TK_STRING; }
{ICONST}        { printf("\ntoken CONST_INT: %d ", atoi(yytext));return TK_INT; }
{FCONST}        { printf("\ntoken CONST_FLOAT %f ", atof(yytext));return TK_REAL; }
{CCONST}        {  printf("\ntoken CONST_STRING %s ", yytext);return TK_STRING; }


"+"         {printf("\ntoken PLUS_OP: + "); return '+';}
"-"           {printf("\ntoken MINUS_OP: - "); return '-';}
"*"           {printf("\ntoken MUL_OP: * "); return '*';}
"/"           {printf("\ntoken DIV_OP: / "); return '/';}
"="         {printf("\ntoken EQ_OP: = "); return '=';}
"!="          {printf("\ntoken NT_EQ_OP: != "); return TK_NOT_EQ;}
"<"           {printf("\ntoken LESS_OP: < "); return '<';}
"<="          {printf("\ntoken LESS_EQ_OP: <= "); return TK_LSS_EQ_THN;}
">"           {printf("\ntoken GREATER_OP: > "); return '>';}
">="          {printf("\ntoken GREATER_EQ_OP: >= "); return TK_GRT_EQ_THN;}
"=>"			{printf("\ntoken ARROW: => "); return TK_ARROW ;}
"<-"          {printf("\ntoken ASSIGN_OP: <- "); return TK_ASSGN ;}
"("       {printf("\ntoken LT_PAR_DLIM: ( "); return '(';}
")"           {printf("\ntoken RT_PAR_DLIM: ) "); return ')';}
"["           {printf("\ntoken LT_BRA_DLIM: [ "); return '[';}
"]"           {printf("\ntoken RT_BRA_DLIM: ] "); return ']';}
"{"           {printf("\ntoken LT_CRLY_BRA_DLIM: { "); return '{';}
"}"           {printf("\ntoken RT_CRLY_BRA_DLIM: } "); return '}';}
";"           {printf("\ntoken SEMICOLON_DLIM: ; "); return ';';}
":"           {printf("\ntoken COLON_DLIM: : "); return ':';}
","           {printf("\ntoken COMMA_DLIM: , "); return ',';}

[ \r\t]         /* skip whitespace */

"//".*                  { printf("Eat up comment at line %d\n", line_num); } 

"/*"                    { printf("Eat up comment from line %d ", line_num); BEGIN(ML_COMMENT); }
<ML_COMMENT>"*/"        { printf("to line %d\n", line_num); BEGIN(INITIAL); }
<ML_COMMENT>[^*\n]+     
<ML_COMMENT>"*"         
<ML_COMMENT>"\n"        { line_num += 1; }

<<EOF>>   return EOF;
.           { printf("\nUnrecognized token %s in line %d\n", yytext, line_num); exit;}

%%







