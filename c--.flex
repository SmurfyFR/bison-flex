/* Flex for C-=2 */
%{
/* Here, C #include, declarations, #defines. No code. */
#include <stdio.h>
#include <string.h>
#include "c--.parser.h"
%}

%option noinput
%option nounput

/* Here, definitions */
integer       [0-9]+
identifier    [a-zA-Z][a-zA-Z0-9]*

%%

"while"       { return WHILE; }
"if"          { return IF; }
"else"        { return ELSE; }
{integer}     { yylval.i_val = atoi(yytext); return INTEGER; }
{identifier}  { yylval.s_val = strdup(yytext); return IDENTIFIER; }
"+"           { return yytext[0]; }
"-"           { return yytext[0]; }
"*"           { return yytext[0]; }
"/"           { return yytext[0]; }
"("           { return yytext[0]; }
")"           { return yytext[0]; }
"{"           { return yytext[0]; }
"}"           { return yytext[0]; }
"="           { return yytext[0]; }

"<"           { return yytext[0]; }
"<="          { return LESS_EQUAL; }
">"           { return yytext[0]; }
">="          { return GREATER_EQUAL; }
"=="          { return EQUALS; }
"!="          { return DIFFERENT; }

\n            { return '\n';}
[ \t]+        { /* empty action */ }
.             { printf("Invalid character %c\n", yytext[0]); }

%%

int yywrap()
{
    return 1;
}
