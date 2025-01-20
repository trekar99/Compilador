/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

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

array				{letter}({letter}|{digit})*\[([0-9])+\]
identifier  		{letter}({letter}|{digit})*

integer		 		{digit}({digit})*
real 				{integer}\.{digit}*([eE][-+]?{digit}+)?
boolean				true|false
comment				\/\/.*\n|\#.*\n
multicomment		\/\*[^*]*\*+([^\/][^*]*\*+)*\/

%%
{comment}			{}
{multicomment}		{}

"repeat"  			{return REPEAT;}
"do"      			{return DO;}
"done"    			{return DONE;}
"if"      			{return IF;}
"then"    			{return THEN;}
"else"    			{return ELSE;}
"fi"      			{return FI;}
"while"   			{return WHILE;}
"until"   			{return UNTIL;}
"for"     			{return FOR;}
"in"      			{return IN;}
".."      			{return RANG;}
"switch"			{return SWITCH;}
"case"				{return CASE;}
"default"			{return DEFAULT;}
"break;"			{return BREAK;}
"fswitch"			{return FSWITCH;}

"+"                 { return ADD; }
":="                { return ASSIGN; }
"-"                 { return SUB; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"%"              	{ return MOD; }
"**"                { return POW; }
"("					{ return IN_PAR; }
")"					{ return OUT_PAR; }

"=="            	{ yylval.data.dest = "EQ"; return BOOLOP; }
">"             	{ yylval.data.dest = "GT"; return BOOLOP; }
">="            	{ yylval.data.dest = "GE"; return BOOLOP; }
"<"             	{ yylval.data.dest = "LT"; return BOOLOP; }
"<="            	{ yylval.data.dest = "LE"; return BOOLOP; }
"<>"            	{ yylval.data.dest = "NE"; return BOOLOP; }

"and"           	{ return AND; }
"or"            	{ return OR; }
"not"           	{ return NOT; }

{real}         		{ yylval.data.type = FLOAT; yylval.data.floatVal = atof(yytext); yylval.data.length = yyleng; 
						yylval.data.dest = (char *)malloc(sizeof(char)*yyleng+1); strncpy(yylval.data.dest, yytext, yyleng+1); return CONST; }
{integer} 			{ yylval.data.type = INTEGER; yylval.data.intVal = atoi(yytext); yylval.data.length = yyleng; 
						yylval.data.dest = (char *)malloc(sizeof(char)*yyleng+1); strncpy(yylval.data.dest, yytext, yyleng+1); return CONST; }

{boolean}			{ yylval.data.type = BOOLEAN;  yylval.data.boolVal = (strcmp(yytext, "true") == 0) ? 1 : 0; 
						yylval.data.dest = (strcmp(yytext, "true") == 0) ? "TRUE" : "FALSE"; return BOOL; }

{array}				{
						yylval.data.name = (char *)malloc(sizeof(char)*yyleng); strncpy(yylval.data.name,yytext,yyleng);

						char *ini = strstr(yytext, "[");
						char *end = strchr(ini + 1, ']');
						*end = '\0';

						yylval.data.length = atoi(ini + 1);

						var aux;
						if (sym_lookup(yytext, &aux) == SYMTAB_NOT_FOUND) return ID;
						else return ID;
					}

{identifier} 		{ 
						yylval.data.name = (char *)malloc(sizeof(char)*yyleng); strncpy(yylval.data.name,yytext,yyleng);
						yylval.data.length = -1; 

						var aux;
						if (sym_lookup(yytext, &aux) == SYMTAB_NOT_FOUND) return ID;
						else return ID;
					}

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
