%{
    /*
        Analisador sintático da linguagem PIU
        Trabalho de Compiladores 2022.2
        Participantes:
            Lucas Ribeiro Penedo
            Douglas Dantas
            Paulo Matheus
    */
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdarg.h>
    #include <string.h>

    typedef enum { typeConstant, typeVariable, typeOpr, typeString } nodeType;

    typedef struct {
        union {
            int intConst;
            float floatConst;
        };
        int constType;
    } constantNode;

    typedef struct {
        char id;
        int varType;
    } variableNode;

    typedef struct {
        int oper;
        int nops;
        struct nodeTag* op[1];
    } oprNode;

    typedef struct nodeTag {
        nodeType type;

        union {
            constantNode constant;
            variableNode variable;
            oprNode opr;
            char* str;
        };
    } node;
    
    node* opr(int oper, int nops, ...);
    node* variable(char c, int type);
    node* constant(float value, int type);
    node* str(char* s);
    void freeNode(node* p);
    int ex(node* p);

    variableNode* variables[52];
    static int lbl;

    int yylex(void);
    void yyerror(char *s);
%}

%union {
    int i;
    float f;
    char c;
    char* s;
    struct nodeTag *p;
};

%token <i> INTEGER
%token <f> FLOAT
%token <c> VARIABLE
%token <s> STRING
%token WHILE IF PRINT INPUT TYPEINT TYPEFLOAT
%token SPRINT
%nonassoc ENDIF
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <p> stmt expr stmts

%%

program: stmts   { printf("#include <stdio.h>\n\nint main(void) {\n\n"); ex($1); printf(";\n\nreturn 0;\n\n}\n"); freeNode($1); exit(0); }
       |
       ;

stmts: stmt         { $$ = $1; }
     | stmts stmt   { $$ = opr(';', 2, $1, $2); }
     ;

stmt: ';'                              { $$ = opr(';', 2, NULL, NULL); }
    | expr ';'                         { $$ = $1; }
    | TYPEINT VARIABLE ';'             { $$ = opr(TYPEINT, 1, variable($2, INTEGER)); }
    | TYPEFLOAT VARIABLE ';'           { $$ = opr(TYPEFLOAT, 1, variable($2, FLOAT)); }
    | INPUT VARIABLE ';'               { $$ = opr(INPUT, 1, variable($2,0)); }
    | PRINT expr ';'                   { $$ = opr(PRINT, 1, $2); }
    | PRINT STRING ';'                 { $$ = opr(SPRINT, 1, str($2)); }
    | VARIABLE '=' expr ';'            { $$ = opr('=', 2, variable($1,0), $3); }
    | WHILE '(' expr ')' stmt          { $$ = opr(WHILE, 2, $3, $5); }
    | IF '(' expr ')' stmt %prec ENDIF { $$ = opr(IF, 2, $3, $5); }
    | IF '(' expr ')' stmt ELSE stmt   { $$ = opr(IF, 3, $3, $5, $7); }
    | '{' stmts '}'                    { $$ = $2; }
    ;

expr: INTEGER                 { $$ = constant($1, INTEGER); }
    | FLOAT                   { $$ = constant($1, FLOAT); }  
    | VARIABLE                { $$ = variable($1,0); }
    | '-' expr %prec UMINUS   { $$ = opr(UMINUS, 1, $2); }
    | expr '+' expr           { $$ = opr('+', 2, $1, $3); }
    | expr '-' expr           { $$ = opr('-', 2, $1, $3); }
    | expr '*' expr           { $$ = opr('*', 2, $1, $3); }
    | expr '/' expr           { $$ = opr('/', 2, $1, $3); }
    | expr '<' expr           { $$ = opr('<', 2, $1, $3); }
    | expr '>' expr           { $$ = opr('>', 2, $1, $3); }
    | expr GE expr            { $$ = opr(GE, 2, $1, $3); }
    | expr LE expr            { $$ = opr(LE, 2, $1, $3); }
    | expr NE expr            { $$ = opr(NE, 2, $1, $3); }
    | expr EQ expr            { $$ = opr(EQ, 2, $1, $3); }
    | '(' expr ')'            { $$ = $2; }
    ;

%%

node* constant(float value, int type) {
    node *p;

    p = malloc(sizeof(node));

    /* empilha constante */
    p->type = typeConstant;
    if(type==INTEGER)
        p->constant.intConst = (int)value;
    if(type==FLOAT)
        p->constant.floatConst = value;
    p->constant.constType = type;

    return p;
}

node* variable(char c, int type) {
    node *p;
    int idx = (c>='a')? (int)(c-'a'+26) : (int)(c-'A');

    p = malloc(sizeof(node));

    if(type!=0) {
        /* empilha variável */
        p->type = typeVariable;
        p->variable.id = c;
        p->variable.varType = type;
        variables[idx] = &(p->variable);
        return p;
    }

    p->type = typeVariable;
    p->variable = *(variables[idx]);
    return p;
}

node* opr(int oper, int nops, ...) {
    va_list ap;
    node *p;
    int i;

    p = malloc(sizeof(node) + (nops-1) * sizeof(node *));

    /* empilha operador */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, node*);
    va_end(ap);
    return p;
}

node* str(char* s) {
    node *p;

    p = malloc(sizeof(node));

    /* empilha string */
    p->type = typeString;
    p->str = malloc(strlen(s));
    strcpy(p->str, s);
    return p;
}

void freeNode(node *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

int ex(node* p) {

    char c;
    int idx;
    int lbl1, lbl2;

    if(!p) return 0;
    switch(p->type) {
    case typeConstant:
        switch(p->constant.constType) {
        case INTEGER:
            printf("%d", p->constant.intConst);
            break;
        case FLOAT:
            printf("%f", p->constant.floatConst);
            break;
        }
        break;
    case typeVariable:
        printf("%c", p->variable.id);
        break;
    case typeString:
        printf("%s", p->str);
        break;
    case typeOpr:
        switch(p->opr.oper) {
        case TYPEINT:
            /* declaração de variável int */
            printf("int %c", p->opr.op[0]->variable.id);
            break;
        case TYPEFLOAT:
            /* declaração de variável float */
            printf("float %c", p->opr.op[0]->variable.id);
            break;
        case WHILE:
            /* construção do while statement */
            printf("L%03d:\n", lbl1 = lbl++);
            printf("if(!");
            ex(p->opr.op[0]);
            printf(") goto L%03d;\n", lbl2 = lbl++);
            ex(p->opr.op[1]);
            printf(";\ngoto L%03d", lbl1);
            printf(";\nL%03d:", lbl2);
            break;
        case IF:
            /* inicia statement if */
            printf("if(!");
            ex(p->opr.op[0]);
            printf(") goto L%03d;\n", lbl1 = lbl++);
            ex(p->opr.op[1]);
            if (p->opr.nops > 2) {
                /* contrução do statement if-else */
                printf(";\ngoto L%03d;\n", lbl2 = lbl++);
                printf("L%03d:\n", lbl1);
                ex(p->opr.op[2]);
                printf(";\nL%03d:", lbl2);
            } else {
                /* contrução do statement if-then */
                printf(";\nL%03d:", lbl1);
            }
            break;
        case INPUT:
            /* contrução do scanf */
            c = p->opr.op[0]->variable.id;
            idx = (c>='a')? (int)(c-'a'+26) : (int)(c-'A');
            switch(variables[idx]->varType) {
            case INTEGER:
                printf("scanf(\"%%d\", &");
                break;
            case FLOAT:
                printf("scanf(\"%%f\", &");
                break;
            }
            ex(p->opr.op[0]);
            printf(")");
            break;
        case PRINT:
            /* contrução do printf */
            printf("printf(\"%%.2f\\n\", (float)");
            ex(p->opr.op[0]);
            printf(")");
            break;
        case SPRINT:
            printf("printf(\"");
            ex(p->opr.op[0]);
            printf("\")");
            break;
        case '=':
            /* atribuição */
            printf("%c = ", p->opr.op[0]->variable.id);
            ex(p->opr.op[1]);
            break;
        case UMINUS:
            printf("-");
            ex(p->opr.op[0]);
            break;
        case ';':
            /* fim de statement */
            ex(p->opr.op[0]);
            printf(";\n");
            ex(p->opr.op[1]);
            break;
        default:
            /* expressões */
            printf("(");
            ex(p->opr.op[0]);
            switch(p->opr.oper) {
            case '+':
            case '-':
            case '*':
            case '/':
            case '<':
            case '>':   printf(" %c ", p->opr.oper); break;
            case GE:    printf(" >= "); break;
            case LE:    printf(" <= "); break;
            case NE:    printf(" != "); break;
            case EQ:    printf(" == "); break;
            }
            ex(p->opr.op[1]);
            printf(")");
        }
    }
    return 0;
}


void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}