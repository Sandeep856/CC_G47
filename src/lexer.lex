%option noyywrap

%{
#include "parser.hh"
#include <string>

extern int yyerror(std::string msg);
%}

%%

"+"       { return TPLUS; }
"-"       { return TDASH; }
"*"       { return TSTAR; }
"/"       { return TSLASH; }
";"       { return TSCOL; }
"("       { return TLPAREN; }
")"       { return TRPAREN; }
"{"       { return TLBRACE; }
"}"       { return TRBRACE; }
","       { return TCOMMA;}
"fun"     { return TFUN; }
"ret"     { return TRET;}
"if"      { return TIF; }
"else"    { return TELSE; }
"?"       { return TQUESTION; }  
":"       { return TCOLON; }
"="       { return TEQUAL; }
"short"   { return TSHORT; } 
"int"     { return TINT; }  
"long"    { return TLONG; }  

"dbg"     { return TDBG; }
"let"     { return TLET; }
[0-9]+    { yylval.lexeme = std::string(yytext); return TINT_LIT; }
[a-zA-Z]+ { yylval.lexeme = std::string(yytext); return TIDENT; }
[ \t\n]   { /* skip */ }
.         { yyerror("unknown char"); }

%%

std::string token_to_string(int token, const char *lexeme) {
    std::string s;
    switch (token) {
        case TPLUS: s = "TPLUS"; break;
        case TDASH: s = "TDASH"; break;
        case TSTAR: s = "TSTAR"; break;
        case TSLASH: s = "TSLASH"; break;
        case TSCOL: s = "TSCOL"; break;
        case TLPAREN: s = "TLPAREN"; break;
        case TRPAREN: s = "TRPAREN"; break;
        case TLBRACE: s = "TLBRACE"; break;
        case TRBRACE: s = "TRBRACE"; break;
        case TRET: s= "TRET";break;
        case TCOMMA: s="TCOMMA";break;
        case TFUN: s = "TFUN"; break;
        case TIF: s = "TIF"; break;
        case TELSE: s = "TELSE"; break;
        case TEQUAL: s = "TEQUAL"; break;
        case TSHORT: s = "TSHORT"; break;
        case TINT: s = "TINT"; break;
        case TLONG: s = "TLONG"; break;
        case TDBG: s = "TDBG"; break;
        case TLET: s = "TLET"; break;
        case TINT_LIT: s = "TINT_LIT"; s.append("  ").append(lexeme); break;
        case TIDENT: s = "TIDENT"; s.append("  ").append(lexeme); break;
    }

    return s;
}