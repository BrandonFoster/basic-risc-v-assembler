%option noyywrap

%{
#include "assembler.tab.h"
extern YYSTYPE yylval;
%}

%%
addi                return ADDI;
add                 return ADD;
sub                 return SUB;
lw                  return LW;
slli                return SLLI;
sw                  return SW;
beq                 return BEQ;
jal                 return J;
auipc               return AUIPC;
0b[0-1]+            yylval.l = strtol(yytext + 2, NULL, 2); return IMMEDIATE;
0x[0-9a-fA-F]+      yylval.l = strtol(yytext + 2, NULL, 16); return IMMEDIATE;
0[0-7]+             yylval.l = strtol(yytext + 1, NULL, 8); return IMMEDIATE;
x[0-9]+             yylval.l = strtol(yytext + 1, NULL, 10); return REGISTER;
[0-9]+              yylval.l = strtol(yytext, NULL, 10); return IMMEDIATE;
\r?\n               return NEWLINE;
\(                  return LEFT_PAREN;
\)                  return RIGHT_PAREN;
,                   return COMMA;
-                   return MINUS;
[ \t]+              ;
%%
