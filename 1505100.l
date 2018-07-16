%option noyywrap

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "SymbolTable.h"
    #include "y.tab.h"

    int error_count = 0;
    int line_count = 1;

    extern string type_name;
    extern FILE *logout, *errorout;
    extern symbolTable table;
%}

%%

"\n" {
    ++line_count;
}

"if" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return IF;
}

"else" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return ELSE;
}

"do" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return DO;
}

"while" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return WHILE;
}

"switch" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return SWITCH;
}

"case" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return CASE;
}

"break" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return BREAK;
}

"default" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return DEFAULT;
}

"continue" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return CONTINUE;
}

"for" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return FOR;
}

"int" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return INT;
}

"float" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return FLOAT;
}

"double" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return DOUBLE;
}

"char" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return CHAR;
}

"return" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return RETURN;
}

"void" {
    symbolInfo *temp = new symbolInfo(yytext, "KEYWORD");
    temp->line_num = line_count, yylval.symbol = temp;
    return VOID;
}

"println" {
    symbolInfo *temp = new symbolInfo(yytext, "PRINTLN");
    temp->line_num = line_count, yylval.symbol = temp;
    return PRINTLN;
}

[0-9]+ {
    symbolInfo *temp = new symbolInfo(yytext, "CONST_INT");
    temp->line_num = line_count, temp->var_type = "int", yylval.symbol = temp;
    return CONST_INT;
}

([0-9]+(\.[0-9]+)?(E[+-]?[0-9]+)?)|(\.[0-9]+(E[+-]?[0-9]+)?) {
    symbolInfo *temp = new symbolInfo(yytext, "CONST_FLOAT");
    temp->line_num = line_count, temp->var_type = "float", yylval.symbol = temp;
    return CONST_FLOAT;
}

[_a-zA-Z][_a-zA-Z0-9]* {
    symbolInfo *temp = new symbolInfo(yytext, "ID");
    temp->line_num = line_count, temp->var_type = type_name, yylval.symbol = temp;
    return ID;
}

[+-] {
    symbolInfo *temp = new symbolInfo(yytext, "ADDOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return ADDOP;
}

[%*/] {
    symbolInfo *temp = new symbolInfo(yytext, "MULOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return MULOP;
}

[+]{2} {
    symbolInfo *temp = new symbolInfo(yytext, "INCOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return INCOP;
}

[-]{2} {
    symbolInfo *temp = new symbolInfo(yytext, "DECOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return DECOP;
}

("<"|"<="|">"|">="|"=="|"!=") {
    symbolInfo *temp = new symbolInfo(yytext, "RELOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return RELOP;
}

[=] {
    symbolInfo *temp = new symbolInfo(yytext, "ASSIGNOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return ASSIGNOP;
}

("&&"|"||") {
    symbolInfo *temp = new symbolInfo(yytext, "LOGICOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return LOGICOP;
}

("&"|"|"|"<<"|">>"|"^") {
    symbolInfo *temp = new symbolInfo(yytext, "BITOP");
    temp->line_num = line_count, yylval.symbol = temp;
    return BITOP;
}

[!] {
    symbolInfo *temp = new symbolInfo(yytext, "NOT");
    temp->line_num = line_count, yylval.symbol = temp;
    return NOT;
}

"[" {
    symbolInfo *temp = new symbolInfo(yytext, "LTHIRD");
    temp->line_num = line_count, yylval.symbol = temp;
    return LTHIRD;
}

"]" {
    symbolInfo *temp = new symbolInfo(yytext, "RTHIRD");
    temp->line_num = line_count, yylval.symbol = temp;
    return RTHIRD;
}

"{" {
    symbolInfo *temp = new symbolInfo(yytext, "LCURL");
    temp->line_num = line_count, yylval.symbol = temp;
    return LCURL;
}

"}" {
    symbolInfo *temp = new symbolInfo(yytext, "RCURL");
    temp->line_num = line_count, yylval.symbol = temp;
    return RCURL;
}

"(" {
    symbolInfo *temp = new symbolInfo(yytext, "LPAREN");
    temp->line_num = line_count, yylval.symbol = temp;
    return LPAREN;
}

")" {
    symbolInfo *temp = new symbolInfo(yytext, "RPAREN");
    temp->line_num = line_count, yylval.symbol = temp;
    return RPAREN;
}

[,] {
    symbolInfo *temp = new symbolInfo(yytext, "COMMA");
    temp->line_num = line_count, yylval.symbol = temp;
    return COMMA;
}

[;] {
    symbolInfo *temp = new symbolInfo(yytext, "SEMICOLON");
    temp->line_num = line_count, yylval.symbol = temp;
    return SEMICOLON;
}

\'(\\[ntafrbv0'"\\]|[^'\\\n])\' {
    char c;

    if (strlen(yytext) == 4) {
        if (yytext[2] == 'n')
            c = '\n';
        else if (yytext[2] == 't')
            c = '\t';
        else if (yytext[2] == 'a')
            c = '\a';
        else if (yytext[2] == 'f')
            c = '\f';
        else if (yytext[2] == 'r')
            c = '\r';
        else if (yytext[2] == 'v')
            c = '\v';
        else if (yytext[2] == '0')
            c = '\0';
        else if (yytext[2] == '\'')
            c = '\'';
        else if (yytext[2] == '\"')
            c = '\"';
        else if (yytext[2] == '\\')
            c = '\\';
    }
    else
        c = yytext[1];

    return CONST_CHAR;
}

\"([^\n"]|\\\n|\\\")*\" {
    int sz = 0, i = 1;
    char c, str[strlen(yytext) + 1];

    while (i < strlen(yytext) - 1) {
        if (yytext[i] == '\\' && yytext[i + 1] == '\\') {
            str[sz++] = yytext[i + 1], i += 2;
        }
        else if (yytext[i] == '\\') {
            if (yytext[i + 1] == 'n')
                c = '\n';
            else if (yytext[i + 1] == 't')
                c = '\t';
            else if (yytext[i + 1] == 'a')
                c = '\a';
            else if (yytext[i + 1] == 'f')
                c = '\f';
            else if (yytext[i + 1] == 'r')
                c = '\r';
            else if (yytext[i + 1] == 'v')
                c = '\v';
            else if (yytext[i + 1] == '0')
                c = '\0';
            else if (yytext[i + 1] == '\'')
                c = '\'';
            else if (yytext[i + 1] == '\"')
                c = '\"';
            else if (yytext[i + 1] == '\\')
                c = '\\';

            i += 2, str[sz++] = c;
        }
        else {
            c = yytext[i], ++i, str[sz++] = c;
        }
    }

    str[sz] = '\0';
    string ptr = str;

    return STRING;
}

\/\/(([^\n]|\\\n)*) {
}

\/\*([^*]|(\*)+[^\/])*(\*)+\/ {
}

[0-9]+[0-9a-zA-Z_]+ {
    ++error_count;
    fprintf(errorout, "Error at line %d: Invalid prefix on ID or invalid suffix on Number %s\n\n", line_count, yytext);
}

([.0-9]|[.]+)* {
    ++error_count;
    fprintf(errorout, "Error at line %d: Too many decimal point %s\n\n", line_count, yytext);
}

\'(\\[ntafrbv0'"\\]|[^'\\\n]){2}+\' {
    ++error_count;
    fprintf(errorout, "Error at line %d: Multi character error %s\n\n", line_count, yytext);
}

\'(\\[ntafrbv0'"\\]|[^'\\\n]) {
    ++error_count;
    fprintf(errorout, "Error at line %d: Unfinished character %s\n\n", line_count, yytext);
}

\'[^0-127]\' {
    ++error_count;
    fprintf(errorout, "Error at line %d: Undetermined character %s\n\n", line_count, yytext);
}

\'\' {
    ++error_count;
    fprintf(errorout, "Error at line %d: Empty constant error\n\n", line_count);
}

\"([^\n"]|\\\n|\\\")* {
    ++error_count;
    fprintf(errorout, "Error at line %d: Undetermined string %s\n\n", line_count, yytext);
}

\/\*([^*]|(\*)+[^\/])*\/ {
    ++error_count;
    fprintf(errorout, "Error at line %d: Undetermined comment %s\n\n", line_count, yytext);
}

\/\*([^*]|(\*)+[^\/])*(\*)* {
    ++error_count;
    fprintf(errorout, "Error at line %d: Undetermined comment %s\n\n", line_count, yytext);
}

%%
