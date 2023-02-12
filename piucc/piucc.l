%{
    /*
        Analisador léxico da linguagem PIU
        Trabalho de Compiladores 2022.2
        Participantes:
            Lucas Ribeiro Penedo
            Douglas Dantas
            Paulo Matheus
    */
    #include <stdlib.h>
    #include "y.tab.h"

    char buf[1024];
    char *s;

    void yyerror(char *);
%}

%x string

variable [A-Za-z]
integer ([1-9][0-9]*)|0
float {integer}\.[0-9]*

%%

{variable}      { yylval.c = *yytext; return VARIABLE; }

{integer}       { yylval.i = atoi(yytext); return INTEGER; }

{float}         { yylval.f = atof(yytext); return FLOAT; }

\"              { BEGIN string; s = buf; }
<string>\\n     { *s++ = '\\'; *s++ = 'n'; }
<string>\\t     { *s++ = '\\'; *s++ = 't'; }
<string>\\\"    { *s++ = '\\'; *s++ = '\"'; }
<string>\"      { *s = 0; BEGIN 0; yylval.s = buf; return STRING; }
<string>\n      { printf("invalid string"); exit(1); }
<string>.       { *s++ = *yytext; }

[-()<>=+*/;{}.] { return *yytext; }

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"while"         return WHILE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;
"input"         return INPUT;
"int"           return TYPEINT;
"float"         return TYPEFLOAT;

[ \t\n]+        ;       /* ignore whitespace */

.               {printf("%s\n",yytext); yyerror("Unknown character");}

%%

int yywrap(void) {
    return 1;
}