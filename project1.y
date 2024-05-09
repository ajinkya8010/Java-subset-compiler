%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "project1.tab.h"

extern int yylex();
extern FILE *yyin;
extern int yylineno;
extern int choice;


void yyerror(const char *s);
char filename[FILENAME_MAX];

/*#define MAX_SYMBOLS 100
typedef struct {
    char name[50];
    char type[50]; // For simplicity, type is stored as a string
} SymbolTableEntry;*/

#define MAX_SYMBOLS 100
typedef struct {
    char name[50];
    char type[50]; // For simplicity, type is stored as a string
    char size[50];      // Size of the variable
    int line;      // Line of declaration
} SymbolTableEntry;


SymbolTableEntry symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

/*void insertSymbol(char* name, char* type) {
    if (symbolCount < MAX_SYMBOLS) {
        strcpy(symbolTable[symbolCount].name, name);
        strcpy(symbolTable[symbolCount].type, type);
        symbolCount++;
    }
    else {
        printf("Symbol table overflow\n");
        exit(1);
    }
}*/

void insertSymbol(char* name, char* type, char* size, int line) {
    if (symbolCount < MAX_SYMBOLS) {
        strcpy(symbolTable[symbolCount].name, name);
        strcpy(symbolTable[symbolCount].type, type);
        strcpy(symbolTable[symbolCount].size, size);
        symbolTable[symbolCount].line = line;
        symbolCount++;
    }
    else {
        printf("Symbol table overflow\n");
        exit(1);
    }
}


void printIndent(int level) {
    for (int i = 0; i < level; i++) {
        printf("  ");
    }
}

/*void printSymbolTable() {
    printf("Symbol Table:\n");
    printf("Name\tType\n");
    for (int i = 0; i < symbolCount; i++) {
        printf("%s\t%s\n", symbolTable[i].name, symbolTable[i].type);
    }
}*/

void printSymbolTable() {
    printf("Symbol Table:\n");
    printf("+-------------------------------------------------------------------+\n");
    printf("|   Name                           |    Type    |   Size   |  Line  |\n");
    printf("+-------------------------------------------------------------------+\n");
    for (int i = 0; i < symbolCount; i++) {
        printf("| %-33s| %-10s| %-10s| %-7d|\n", 
               symbolTable[i].name, 
               symbolTable[i].type, 
               symbolTable[i].size, 
               symbolTable[i].line);
    }
    printf("+-------------------------------------------------------------------+\n");
}


%}

%union {
    char *sval;
    int ival;
}

%token <sval> STRING_LITERAL EXCEPTION_MESSAGE IDENTIFIER
%token PUBLIC CLASS STATIC VOID MAIN STRING SEMICOLON
%token LPAREN RPAREN LBRACE RBRACE OPEN_BRACKET CLOSE_BRACKET ARGS
%token THROWS TRY CATCH FOR INT RETURN PRINTLN NUMBER FINALLY FLOAT BOOLEAN DOUBLE
%token PLUS MINUS MULT DIV ASSIGN LESS GREATER LESS_EQUAL GREATER_EQUAL
%token EQUAL NOT_EQUAL AND OR NOT TRUE FALSE COMMA
%token THROW NEW INT_IDENTIFIER INT_DIV NULL_POINTER_EXCEPTION NUL
%token GENERIC_EXCEPTION // Added token for catching any exception
%token ARITHMETICE NULLPOINTERE ARRAYIDXE
%token <sval> TYPE

%left PLUS MINUS
%left MULT DIV

%%

start : class_declaration { printf("Parse tree root\n"); };

class_declaration : PUBLIC CLASS IDENTIFIER LBRACE main_method RBRACE {insertSymbol($3,"class","-",yylineno);}
                | PUBLIC CLASS IDENTIFIER LBRACE function_definition main_method RBRACE {insertSymbol($3,"class","-",yylineno);}
                | PUBLIC CLASS IDENTIFIER LBRACE main_method function_definition RBRACE {insertSymbol($3,"class","-",yylineno);}
                | PUBLIC CLASS IDENTIFIER LBRACE function_definition main_method function_definition RBRACE {insertSymbol($3,"class","-",yylineno);} ;

main_method : PUBLIC STATIC VOID MAIN LPAREN STRING OPEN_BRACKET CLOSE_BRACKET ARGS RPAREN LBRACE statement_list RBRACE { printIndent(1); printf("Main method\n"); insertSymbol("main", "method","-",yylineno); };

statement_list : /* empty */ { printIndent(1); printf("Statement list (empty)\n"); }
               | statement_list statement { printIndent(1); printf("Statement list\n"); }
               ;

statement : /*SEMICOLON { printIndent(2); printf("Semicolon statement\n"); }*/
            try_catch_finally_statement { printIndent(2); printf("Try-catch-finally statement\n"); }
          | throw_statement { printIndent(2); printf("Throw statement\n"); insertSymbol("throw", "statement","-",yylineno); }
          | PRINTLN LPAREN STRING_LITERAL RPAREN SEMICOLON { printIndent(2); printf("Println statement\n"); }
          | PRINTLN LPAREN STRING_LITERAL PLUS IDENTIFIER RPAREN SEMICOLON { printIndent(2); printf("Println statement with identifier\n"); }
          | PRINTLN LPAREN IDENTIFIER OPEN_BRACKET NUMBER CLOSE_BRACKET RPAREN SEMICOLON { printIndent(2); printf("Println statement with array\n"); }
          | function_definition { printIndent(2); printf("Function definition\n"); }
          | variable_declaration { printIndent(2); printf("Variable declaration\n"); }
          | RETURN IDENTIFIER operator IDENTIFIER SEMICOLON { printIndent(2); printf("Return statement\n"); }
          | variable_initialization { printIndent(2); printf("Variable initialization\n"); }
          | array_dec_and_ini {printIndent(2); printf("Array dec and initialization\n");}
          ;

try_catch_finally_statement : try_catch_statement finally_statement 
                            | try_catch_statement 
                            | try_finally_statement 
                            ;

try_catch_statement : TRY LBRACE statement_list RBRACE catch_statements { printIndent(2); printf("Try-catch statement\n"); };

try_finally_statement : TRY LBRACE statement_list RBRACE FINALLY LBRACE statement_list RBRACE { printIndent(2); printf("Try-finally statement\n"); };

finally_statement: FINALLY LBRACE statement_list RBRACE { printIndent(2); printf("Finally statement\n"); };

catch_statements : /* empty */ { printIndent(2); printf("Catch statements (empty)\n"); }
                 | catch_statements catch_statement { printIndent(2); printf("Catch statements\n"); }
                 ;

exception_name: ARITHMETICE|NULLPOINTERE|ARRAYIDXE; 

catch_statement : CATCH LPAREN exception_name IDENTIFIER RPAREN LBRACE statement_list RBRACE { printIndent(3); printf("Catch statement\n"); };

throw_statement : THROW NEW IDENTIFIER LPAREN STRING_LITERAL RPAREN SEMICOLON { printIndent(3); printf("Throw statement (new identifier)\n"); insertSymbol("new", "exception","-",yylineno); }
                | THROW IDENTIFIER SEMICOLON { printIndent(3); printf("Throw statement (identifier)\n"); insertSymbol($2, "exception","-",yylineno); }
                ;

function_definition : PUBLIC function_type IDENTIFIER LPAREN parameters RPAREN LBRACE statement_list RBRACE { printIndent(2); printf("Method definition\n"); insertSymbol($3, "method","-",yylineno); };

function_type : STATIC returnType { printIndent(3); printf("Method type (static)\n"); } | returnType { printIndent(3); printf("Method type\n"); };

returnType : INT { printIndent(3); printf("Return type (int)\n"); } | STRING { printIndent(3); printf("Return type (string)\n"); };

parameters : /* empty */ { printIndent(3); printf("Parameters (empty)\n"); }
           | parameter_list { printIndent(3); printf("Parameters\n"); }
           ;

parameter_list : parameter { printIndent(4); printf("Parameter list\n"); }
               | parameter_list COMMA parameter { printIndent(4); printf("Parameter list (comma)\n"); }
               ;

parameter : INT IDENTIFIER { printIndent(4); printf("Parameter\n"); }
            |FLOAT IDENTIFIER { printIndent(4); printf("Parameter\n"); }
            |STRING IDENTIFIER { printIndent(4); printf("Parameter\n"); }
            |BOOLEAN IDENTIFIER { printIndent(4); printf("Parameter\n"); }
            |DOUBLE IDENTIFIER { printIndent(4); printf("Parameter\n"); }
            ;

//type : INT { printIndent(4); printf("Primitive type (int)\n"); } | FLOAT { printIndent(4); printf("Primitive type (float)\n"); } | DOUBLE { printIndent(4); printf("Primitive type (double)\n"); } | BOOLEAN { printIndent(4); printf("Primitive type (boolean)\n"); } | STRING { printIndent(4); printf("Type (string)\n"); };

operator: PLUS { printIndent(4); printf("Operator (plus)\n"); } | MINUS { printIndent(4); printf("Operator (minus)\n"); } | DIV { printIndent(4); printf("Operator (div)\n"); } | MULT { printIndent(4); printf("Operator (mult)\n"); };


variable_declaration :INT IDENTIFIER ASSIGN literal SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "int","4",yylineno); }
                    | INT IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "int","4",yylineno); }
                    | INT IDENTIFIER ASSIGN literal operator literal SEMICOLON { printIndent(3); printf("Variable declaration with operator\n"); insertSymbol($2, "int","4",yylineno); }
                    | INT IDENTIFIER ASSIGN literal operator IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration with operator\n"); insertSymbol($2, "int","4",yylineno); }
                    | FLOAT IDENTIFIER ASSIGN literal SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "float","4",yylineno); }
                    | FLOAT IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "float","4",yylineno); }
                    | FLOAT IDENTIFIER ASSIGN literal operator literal SEMICOLON { printIndent(3); printf("Variable declaration with operator\n"); insertSymbol($2, "float","4",yylineno);}
                    | FLOAT IDENTIFIER ASSIGN literal operator IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration with operator\n"); insertSymbol($2, "float","4",yylineno); }
                    | DOUBLE IDENTIFIER ASSIGN literal SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2,"double","8",yylineno); }
                    | DOUBLE IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2,"double","8",yylineno);  }
                    | DOUBLE IDENTIFIER ASSIGN literal operator literal SEMICOLON { printIndent(3); printf("Variable declaration with operator\n"); insertSymbol($2,"double","8",yylineno);  }
                    | DOUBLE IDENTIFIER ASSIGN literal operator IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration with operator\n");insertSymbol($2,"double","8",yylineno);  }
                    | STRING IDENTIFIER ASSIGN literal SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "string","-",yylineno); }
                    | STRING IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "string","-",yylineno); }
                    | BOOLEAN IDENTIFIER ASSIGN literal SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "boolean","1",yylineno); }
                    | BOOLEAN IDENTIFIER SEMICOLON { printIndent(3); printf("Variable declaration\n"); insertSymbol($2, "boolean","-",yylineno); }
                    ;

variable_initialization: IDENTIFIER ASSIGN literal SEMICOLON { printIndent(3); printf("Variable initialization\n"); }
                    | IDENTIFIER ASSIGN literal operator literal SEMICOLON { printIndent(3); printf("Variable initialization\n"); }
                    | IDENTIFIER ASSIGN IDENTIFIER operator IDENTIFIER SEMICOLON { printIndent(3); printf("Variable initialization\n"); }
                    | IDENTIFIER ASSIGN literal operator IDENTIFIER SEMICOLON { printIndent(3); printf("Variable initialization\n"); }
                    | IDENTIFIER ASSIGN ARGS OPEN_BRACKET NUMBER CLOSE_BRACKET SEMICOLON { printIndent(3); printf("Variable initialization\n"); }
                    ;


array_dec_and_ini : INT OPEN_BRACKET CLOSE_BRACKET IDENTIFIER ASSIGN LBRACE literal_list RBRACE SEMICOLON { 
                        printf("Array declaration and initialization\n"); 
                        insertSymbol($4, "int","-",yylineno);
                    }
                   | INT OPEN_BRACKET CLOSE_BRACKET IDENTIFIER ASSIGN NUL SEMICOLON { 
                        printf("Array declaration with null initialization\n"); 
                         insertSymbol($4, "int","0",yylineno);
                    }
                   | FLOAT OPEN_BRACKET CLOSE_BRACKET IDENTIFIER ASSIGN LBRACE literal_list RBRACE SEMICOLON { 
                        printf("Array declaration and initialization\n"); 
                        insertSymbol($4, "float","-",yylineno);
                    }
                   | FLOAT OPEN_BRACKET CLOSE_BRACKET IDENTIFIER ASSIGN NUL SEMICOLON { 
                        printf("Array declaration with null initialization\n"); 
                         insertSymbol($4, "float","0",yylineno);
                    }
                    | STRING OPEN_BRACKET CLOSE_BRACKET IDENTIFIER ASSIGN LBRACE literal_list RBRACE SEMICOLON { 
                        printf("Array declaration and initialization\n"); 
                        insertSymbol($4, "string","-",yylineno);
                    }
                   | STRING OPEN_BRACKET CLOSE_BRACKET IDENTIFIER ASSIGN NUL SEMICOLON { 
                        printf("Array declaration with null initialization\n"); 
                         insertSymbol($4, "string","0",yylineno);
                    }
                   ;

literal_list : literal { printf("Literal list\n"); }
            | literal_list COMMA literal { printf("Literal list\n"); }
            ;



literal : STRING_LITERAL { printIndent(4); printf("Literal (string)\n"); }
        | NUMBER { printIndent(4); printf("Literal (number)\n"); }
        | TRUE { printIndent(4); printf("Literal (true)\n"); }
        | FALSE { printIndent(4); printf("Literal (false)\n"); }
        ;

%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;
    
    int choice;
    printf("Enter 1 for lexical analysis, 2 for syntax check, 3 for semantic analysis, or 4 for parse tree: ");
    scanf("%d", &choice);

    switch (choice) {
    case 1:
        printf("Performing lexical analysis...\n");
        while (yylex()) {}
        break;
    case 2:
        printf("Performing syntax check...\n");
        if (yyparse() != 0) {
        yyerror("Syntax error");
        }else{
            yyerror("");
        }
        break;
    case 3:
        printf("Performing semantic analysis...\n");
        yyparse();
        printSymbolTable();
        break;
    case 4:
        printf("Displaying parse tree...\n");
        yyparse();
        break;
    default:
        printf("Invalid choice.\n");
        break;
}
    fclose(file);

    return 0;
}

void yyerror(const char *s) {
    if (strlen(s) > 0) {
        fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
        FILE *file = fopen(filename, "r");
        if (file) {
            int line_num = 1;
            char line[1024];
            while (fgets(line, sizeof(line), file)) {
                if (line_num == yylineno) {
                    fprintf(stderr, "Line %d: %s\n", yylineno, line);
                    break;
                }
                line_num++;
            }
            fclose(file);
        }
    } else {
        printf("NO ERROR FOUND\n");
    }
}

