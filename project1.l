%{
#include "project1.tab.h"
#include <string.h>
extern int choice;
%}

%option yylineno

%%

"public"            { printf("token: PUBLIC\n"); return PUBLIC; }
"class"             { printf("token: CLASS\n"); return CLASS; }
"static"            { printf("token: STATIC\n"); return STATIC; }
"void"              { printf("token: VOID\n"); return VOID; }
"main"              { printf("token: MAIN\n"); return MAIN; }
"String"            { printf("token: STRING\n"); return STRING; }
"throw"             { printf("token: THROW\n"); return THROW; }
"new"               { printf("token: NEW\n"); return NEW; }
"throws"            { printf("token: THROWS\n"); return THROWS; }
"try"               { printf("token: TRY\n"); return TRY; }
"catch"             { printf("token: CATCH\n"); return CATCH; }
"for"               { printf("token: FOR\n"); return FOR; }
"int"               { printf("token: INT\n"); return INT; }
"float"             { printf("token: FLOAT\n"); return FLOAT;}
"double"            { printf("token: DOUBLE\n"); return DOUBLE;}
"boolean"           { printf("token: BOOLEAN\n"); return BOOLEAN;}
"return"            { printf("token: RETURN\n"); return RETURN; }
"finally"           { printf("token: FINALLY\n"); return FINALLY;}
"System.out.println" { printf("token: PRINTLN\n"); return PRINTLN; }
"ArithmeticException"  { printf("token: ARITHMETICE \n"); return ARITHMETICE; }
"NullPointerException" { printf("token: NULLPOINTERE \n"); return NULLPOINTERE; }
"ArrayIndexOutOfBoundsException" { printf("token: ARRAYIDXE \n"); return ARRAYIDXE; }
"null"                { printf("token: NUL \n"); return NUL; }  

[0-9]+              { yylval.sval = strdup(yytext); printf("token: NUMBER - %s\n", yytext); return NUMBER; }

"+"                 { printf("token: PLUS\n"); return PLUS; }
"-"                 { printf("token: MINUS\n"); return MINUS; }
"*"                 { printf("token: MULT\n"); return MULT; }
"/"                 { printf("token: DIV\n"); return DIV; }
"="                 { printf("token: ASSIGN\n"); return ASSIGN; }
"<"                 { printf("token: LESS\n"); return LESS; }
">"                 { printf("token: GREATER\n"); return GREATER; }
"<="                { printf("token: LESS_EQUAL\n"); return LESS_EQUAL; }
">="                { printf("token: GREATER_EQUAL\n"); return GREATER_EQUAL; }
"=="                { printf("token: EQUAL\n"); return EQUAL; }
"!="                { printf("token: NOT_EQUAL\n"); return NOT_EQUAL; }
"&&"                { printf("token: AND\n"); return AND; }
"||"                { printf("token: OR\n"); return OR; }
"!"                 { printf("token: NOT\n"); return NOT; }
"true"              { printf("token: TRUE\n"); return TRUE; }
"false"             { printf("token: FALSE\n"); return FALSE; }
"["                 { printf("token: OPEN_BRACKET\n"); return OPEN_BRACKET; }
"]"                 { printf("token: CLOSE_BRACKET\n"); return CLOSE_BRACKET; }

"("                 { printf("token: LPAREN\n"); return LPAREN; }
")"                 { printf("token: RPAREN\n"); return RPAREN; }
"{"                 { printf("token: LBRACE\n"); return LBRACE; }
"args"              { printf("token: ARGS\n"); return ARGS; } 
"}"                 { printf("token: RBRACE\n"); return RBRACE; }
";"                 { printf("token: SEMICOLON\n"); return SEMICOLON; }
","                 { printf("token: COMMA\n"); return COMMA; }
"exception_message" { printf("token: EXCEPTION_MESSAGE\n"); return EXCEPTION_MESSAGE; }

\"[^\"]*\" { yylval.sval = strdup(yytext); printf("token: STRING_LITERAL - %s\n", yytext); return STRING_LITERAL; }

[a-zA-Z][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); printf("token: IDENTIFIER - %s\n", yytext); return IDENTIFIER; } 

[ \t\n]             ; // Skip whitespace

.                   { 
                      printf("Unknown token: %s\n", yytext);
                      return 0;
                    } // Return any other character as is

%%

int yywrap() {
    return 1;
}
