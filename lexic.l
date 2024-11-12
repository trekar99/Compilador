%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./symtab/symtab.h"
#include "syntactic.h"
extern FILE *yyin;

%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

letter 				[a-zA-Z]
digit 				[0-9]

identifier  		{letter}({letter}|{digit})*
	
integer		 		{digit}({digit})*
real 				{integer}\.{digit}*([eE][-+]?{digit}+)?
boolean				true|false
string			    \".[^"\n]*\"
comment				\/\/.*\n|\#.*\n
multicomment		\/\*[^*]*\*+([^\/][^*]*\*+)*\/

EOL      		 	"\n"

%%

"+"                 { return ADD; }
":="                { return ASSIGN; }
"-"                 { return SUB; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"%"              	{ return MOD; }
"**"                { return POW; }

"and"          		{ return AND; }
"or"            	{ return OR; }
"not"           	{ return NOT; }

"=="            	{ return EQ; }
">"           	  	{ return GT; }
">="           	 	{ return GE; }
"<"             	{ return LT; }
"<="            	{ return LE; }
"<>"            	{ return NE; }

"sin"				{ return SIN; }
"cos"				{ return COS; }
"tan"				{ return TAN; }

"PI"				{ return PI; }
"E"					{ return E; }

"len"				{ return LEN; }
"substr"			{ return SUBSTR; }

"dec"				{ return DEC; }
"bin"				{ return BIN; }
"oct"				{ return OCT; }
"hex"				{ return HEX; }

","					{ return COMMA; }
"("					{ return IN_PAR; }
")"					{ return OUT_PAR; }

{real}         		{ yylval.data.type = FLOAT; yylval.data.floatVal = atof(yytext); yylval.data.length = yyleng; return CONST; }
{integer} 			{ yylval.data.type = INTEGER; yylval.data.intVal = atoi(yytext); yylval.data.length = yyleng; return CONST; }
{boolean}			{ yylval.data.type = BOOLEAN;  yylval.data.boolVal = (strcmp(yytext, "true") == 0) ? 1 : 0; return BOOL; }
{string} 			{ yylval.data.type = STRING; yylval.data.length = yyleng - 2; yylval.data.stringVal = (char *)malloc(sizeof(char)*yylval.data.length); 
						memcpy( yylval.data.stringVal, &(yytext[1]), yylval.data.length); return CONST; }

{identifier} 		{ 
						yylval.data.name = (char *)malloc(sizeof(char)*yyleng); strncpy(yylval.data.name,yytext,yyleng);
						yylval.data.length = yyleng; 

						var aux;
						if (sym_lookup(yytext, &aux) == SYMTAB_NOT_FOUND) return ID;
						else return (aux.type == BOOLEAN) ? BOOL_ID : ID;
						
					}

{comment}			{ printf( "%s", yytext ); }
{multicomment}		{}


"\n"				{ return EOL; }

" "					{}

.		    		{ printf( " Unknown character. \n" ); }

%%

int init_analisi_lexic(char *file_name){
	yyin=fopen(file_name,"r");
	return (yyin == NULL) ? EXIT_FAILURE : EXIT_SUCCESS;
}

int end_analisi_lexic(){ return (fclose(yyin) == 0) ? EXIT_SUCCESS : EXIT_FAILURE; }

/*
	yylex(): rutina del analisi léxico.
	yytext: contiene el token.
	yyleng: longitud del token.
	yylval: valor del token.
	yyin: fichero input. Default: *yyin=stdin;
	yyout: fichero output. Default: *yyout=stdout;
	
	yyparse(): solicita nuevo token
*/
