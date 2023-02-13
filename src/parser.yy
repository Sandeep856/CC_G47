%define api.value.type { ParserValue }

%code requires {
#include <iostream>
#include <vector>
#include <string>

#include "parser_util.hh"
#include "symbol.hh"

}

%code {

#include <cstdlib>

extern int yylex();
extern int yyparse();

extern NodeStmts* final_values;

SymbolTable symbol_table;

int yyerror(std::string msg);

}

%token TPLUS TDASH TSTAR TSLASH
%token <lexeme> TINT_LIT TIDENT
%token INT TLET TDBG TDEF TUDF
%token TSCOL TLPAREN TRPAREN TEQUAL
%type <node> Expr Stmt
%type <stmts> Program StmtList

%left TPLUS TDASH
%left TSTAR TSLASH

%%

Program :                
        { final_values = nullptr; }
        | StmtList TSCOL 
        { final_values = $1; }
	    ;

StmtList : Stmt                
         { $$ = new NodeStmts(); $$->push_back($1); }
	     | StmtList TSCOL Stmt 
         { $$->push_back($3); }
	     ;

Stmt : TLET TIDENT TEQUAL Expr
     {
        if(symbol_table.contains($2)) {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else {
            symbol_table.insert($2);

            $$ = new NodeAssn($2, $4);
        }
     }
     | TDBG Expr
     { 
        $$ = new NodeDebug($2);
     }
     ;

Stmt : TDEF TIDENT Expr
        {
            symbol_table.insert($2);

            $$ = new NodeAssn($2, $3);
        }
        | TDBG Expr
        { 
            $$ = new NodeDebug($2);
        }
        ;

Stmt : TUDF TIDENT 
        {
            if(symbol_table.contains($2)) {
                symbol_table.remove($2);
            
        } else {
            yyerror("tried to use undeclared variable.\n");
        }
        }
        | TDBG Expr
        { 
            $$ = new NodeDebug($2);
        }
        ;

Expr : TINT_LIT               
     { $$ = new NodeInt(stoi($1)); }
     | TIDENT
     { 
        if(symbol_table.contains($1))
            $$ = new NodeIdent($1); 
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr TPLUS Expr
     { $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3); }
     | Expr TDASH Expr
     { $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3); }
     | Expr TSTAR Expr
     { $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3); }
     | Expr TSLASH Expr
     { $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3); }
     | TLPAREN Expr TRPAREN { $$ = $2; }
     ;

%%

int yyerror(std::string msg) {
    std::cerr << "Error! " << msg << std::endl;
    exit(1);
}