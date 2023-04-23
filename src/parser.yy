%define api.value.type { ParserValue }

%code requires {
#include <iostream>
#include<stdio.h>
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
Mapp mp;
Scope mpss;
int scope=0;

int yyerror(std::string msg);

}

%token TPLUS TDASH TSTAR TSLASH
%token <lexeme> TINT_LIT TIDENT
%token INT TLET TDBG TTERN TCOLON TFUN TRET TCOMMA
%token TSCOL TLPAREN TRPAREN TLBRACE TRBRACE TEQUAL TQUESTION TIF TELSE
%token TSHORT TINT TLONG

%type <node> Expr Stmt Expr1 Expr2 Expr3 Expr4 IfStmt FuncDef
%type <stmts> Program StmtList
%type <actualparamnode> ActualParam
%type<paramnode> ParamDecl
%type <ParamDecls> ParamList
%type <ActualParams> ExprList

%left TPLUS TDASH
%left TSTAR TSLASH
%right TTERN

%%

Program :                
        { final_values = nullptr; }
        | StmtList
        { final_values = $1; }
	    ;

StmtList : Stmt                
         { $$ = new NodeStmts(); $$->push_back($1); }
         | StmtList Stmt
         { $$->push_back($2); }
	     ;

Stmt : TLET TIDENT TCOLON TSHORT TEQUAL Expr3 TSCOL
     {
        if(mpss.containss(scope,$2,3)) {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else {
            //symbol_table.insert($2);
            mpss.inserts(scope,$2,3);
            $$ = new NodeAssn($2, $6);
            mp.insertm($2,3);
        }
     }
     ;

Expr3 : TINT_LIT             
        {   
            int a=stoi($1);
            if(a>=-32768&&a<32768){
                $$ = new NodeShort(stoi($1));
            }
            else
            {
                printf("short overflow!\n\n");
                $$ = new NodeShort(stoi($1));
            }
        }
        | TIDENT
        { 
            if(mpss.contain1(scope,$1))
                {
                    $$ = new NodeIdent($1);
                    if(mp.getm($1)==2) printf("Type error inserting Long in short type\n");
                    if(mp.getm($1)==1) printf("Type error inserting Int in short type\n");
                } 

            else
                yyerror("using undeclared variable.\n");
        }
        | Expr3 TPLUS Expr3
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value + right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::PLUS, left, right);
        }
     }
     | Expr3 TDASH Expr3
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value - right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MINUS, left, right);
        }
     }
     | Expr3 TSTAR Expr3
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value * right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MULT, left, right);
        }
     }
     | Expr3 TSLASH Expr3
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            if (right_int->value == 0) {
                yyerror("division by zero.\n");
                $$ = new NodeInt(0);
            } else {
                int result = left_int->value / right_int->value;
                $$ = new NodeInt(result);
            }
        } else {
            $$ = new NodeBinOp(NodeBinOp::DIV, left, right);
        }
     }
     | TLPAREN Expr3 TRPAREN { $$ = $2; }
     | Expr3 TQUESTION Expr3 TCOLON Expr3 %prec TTERN
     { $$ = new NodeTernaryOp($1, $3, $5); }
     | TIDENT TLPAREN ExprList TRPAREN 
     {
        if(mpss.contain1(scope,$1))
        {
            $$=new NodeCallingFunc($1,$3);
        }
        else{
            yyerror("Function Not defined");
        }
     }
     ; 

Stmt : TLET TIDENT TCOLON TLONG TEQUAL Expr2 TSCOL
     {
        if(mpss.containss(scope,$2,2)) {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else {
            
            //symbol_table.insert($2);
            mpss.inserts(scope,$2,2);
            $$ = new NodeAssn($2, $6);
            mp.insertm($2,2);
        }
     }
     ;

Expr2 : TINT_LIT               
     { $$ = new NodeLong(stoll($1)); }
     | TIDENT
     { 
        if(mpss.contain1(scope,$1))
            $$ = new NodeIdent($1); 
            
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr2 TPLUS Expr2
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value + right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::PLUS, left, right);
        }
     }
     | Expr2 TDASH Expr2
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value - right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MINUS, left, right);
        }
     }
     | Expr2 TSTAR Expr2
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value * right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MULT, left, right);
        }
     }
     | Expr2 TSLASH Expr2
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            if (right_int->value == 0) {
                yyerror("division by zero.\n");
                $$ = new NodeInt(0);
            } else {
                int result = left_int->value / right_int->value;
                $$ = new NodeInt(result);
            }
        } else {
            $$ = new NodeBinOp(NodeBinOp::DIV, left, right);
        }
     }
     | TLPAREN Expr2 TRPAREN { $$ = $2; }
     | Expr2 TQUESTION Expr2 TCOLON Expr2 %prec TTERN
     { $$ = new NodeTernaryOp($1, $3, $5); }
     | TIDENT TLPAREN ExprList TRPAREN 
     {
        if(mpss.contain1(scope,$1))
        {
            $$=new NodeCallingFunc($1,$3);
        }
        else{
            yyerror("Function Not defined");
        }
     }
     ;

Stmt : TLET TIDENT TCOLON TINT TEQUAL Expr1 TSCOL
     {
        if(mpss.containss(scope,$2,1)) {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else {
            
            //symbol_table.insert($2);
            mpss.inserts(scope,$2,1);
            $$ = new NodeAssn($2, $6);
            mp.insertm($2,1);
            
        }
     }
     ;

Expr1 : TINT_LIT               
     { $$ = new NodeInt(stoi($1)); }
     | TIDENT
     { 
        if(mpss.contain1(scope,$1))
            {$$ = new NodeIdent($1); 
            if(mp.getm($1)==2) printf("Type error inserting Long in int type\n");}
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr1 TPLUS Expr1
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value + right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::PLUS, left, right);
        }
     }
     | Expr1 TDASH Expr1
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value - right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MINUS, left, right);
        }
     }
     | Expr1 TSTAR Expr1
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value * right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MULT, left, right);
        }
     }
     | Expr1 TSLASH Expr1
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            if (right_int->value == 0) {
                yyerror("division by zero.\n");
                $$ = new NodeInt(0);
            } else {
                int result = left_int->value / right_int->value;
                $$ = new NodeInt(result);
            }
        } else {
            $$ = new NodeBinOp(NodeBinOp::DIV, left, right);
        }
     }
     | TLPAREN Expr1 TRPAREN { $$ = $2; }
     | Expr1 TQUESTION Expr1 TCOLON Expr1 %prec TTERN
     { $$ = new NodeTernaryOp($1, $3, $5); }
     | TIDENT TLPAREN ExprList TRPAREN 
     {
        if(mpss.contain1(scope,$1))
        {
            $$=new NodeCallingFunc($1,$3);
        }
        else{
            yyerror("Function Not defined");
        }
     }
     ;

Stmt : TDBG Expr TSCOL
     { 
        $$ = new NodeDebug($2);
     }
     ;

Stmt : TIDENT TEQUAL Expr TSCOL
     {
        if(mpss.contain1(scope,$1))
            $$ = new NodeVarAssign($1, $3);
        else
            yyerror("using undeclared variable.\n");
     }
     | IfStmt
     | FuncDef
     | TRET Expr
     {
        $$ = new NodeRet($2);
     }
     ;

IfStmt : TIF Expr Expr4 StmtList Expr4 TELSE Expr4 StmtList Expr4
        {  
           
            Node* left = $2;
            NodeInt* left_int = dynamic_cast<NodeInt*>(left);
            if (left_int)
            {
                int result = left_int->value;
                $$ = new NodeInt(result);
                if(result==0)
                {
                    $$ = new NodeIf($2, $4, $8, 1);
                }
                else
                {
                    $$ = new NodeIf($2, $4, $8, 0);
                }
            }
            else
            {
                $$ = new NodeIf($2, $4, $8, 2);
            }
        }
        ;

Expr4 :TLBRACE
      { scope++;}
      |TRBRACE
      { scope--;};


FuncDef : TFUN TIDENT TLPAREN ParamList TRPAREN TCOLON TINT TLBRACE StmtList TRBRACE
        {
            if(mpss.containss(scope,$2,1))
            {
                yyerror("dont redeclare function");
            }
            else
            {
                mpss.inserts(scope,$2,1);
                $$ =  new NodeFuncDecl($2, $4, $9);
            }
        }
        ;

FuncDef : TFUN TIDENT TLPAREN  TRPAREN TCOLON TINT TLBRACE StmtList TRBRACE
        {
            if(mpss.containss(scope,$2,1))
            {
                yyerror("dont redeclare function");
            }
            else
            {
                mpss.inserts(scope,$2,1);
                $$ =  new NodeFuncDecl($2, nullptr, $8);
            }
        }
        ;

FuncDef : TFUN TIDENT TLPAREN ParamList TRPAREN TCOLON TLONG TLBRACE StmtList TRBRACE
        {
            if(mpss.containss(scope,$2,2))
            {
                yyerror("dont redeclare function");
            }
            else
            {
                mpss.inserts(scope,$2,2);
                $$ =  new NodeFuncDecl($2, $4, $9);
            }
        }
        ;

FuncDef : TFUN TIDENT TLPAREN  TRPAREN TCOLON TLONG TLBRACE StmtList TRBRACE
        {
            if(mpss.containss(scope,$2,2))
            {
                yyerror("dont redeclare function");
            }
            else
            {
                mpss.inserts(scope,$2,2);
                $$ =  new NodeFuncDecl($2, nullptr, $8);
            }
        }
        ;

FuncDef : TFUN TIDENT TLPAREN ParamList TRPAREN TCOLON TSHORT TLBRACE StmtList TRBRACE
        {
            if(mpss.containss(scope,$2,3))
            {
                yyerror("dont redeclare function");
            }
            else
            {
                mpss.inserts(scope,$2,3);
                $$ =  new NodeFuncDecl($2, $4, $9);
            }
        }
        ;

FuncDef : TFUN TIDENT TLPAREN  TRPAREN TCOLON TSHORT TLBRACE StmtList TRBRACE
        {
            if(mpss.containss(scope,$2,3))
            {
                yyerror("dont redeclare function");
            }
            else
            {
                mpss.inserts(scope,$2,3);
                $$ =  new NodeFuncDecl($2, nullptr, $8);
            }
        }
        ;




ParamList : ParamDecl 
            { $$ = new NodeParams(); $$->push_back($1); }
            | ParamList TCOMMA ParamDecl{$$->push_back($3);}
            ;

ParamDecl : Expr TCOLON TINT
            {$$ = new NodeParam($1);}
            ;

ExprList :  ActualParam
           { $$ = new NodeActualParams(); $$->push_back($1);}
           | ExprList TCOMMA ActualParam{$$->push_back($3);}
           ;
        
ActualParam : Expr
            { $$ = new NodeActualParam($1);}
            ;






Expr : TINT_LIT               
     { $$ = new NodeInt(stoi($1)); }
     | TIDENT
     { 
        if(mpss.contain1(scope,$1))
            $$ = new NodeIdent($1); 
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr TPLUS Expr
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value + right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::PLUS, left, right);
        }
     }
     | Expr TDASH Expr
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value - right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MINUS, left, right);
        }
     }
     | Expr TSTAR Expr
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            int result = left_int->value * right_int->value;
            $$ = new NodeInt(result);
        } else {
            $$ = new NodeBinOp(NodeBinOp::MULT, left, right);
        }
     }
     | Expr TSLASH Expr
     {
        Node* left = $1;
        Node* right = $3;
        
        // Check if both operands are integer literals
        NodeInt* left_int = dynamic_cast<NodeInt*>(left);
        NodeInt* right_int = dynamic_cast<NodeInt*>(right);
        if (left_int && right_int) {
            if (right_int->value == 0) {
                yyerror("division by zero.\n");
                $$ = new NodeInt(0);
            } else {
                int result = left_int->value / right_int->value;
                $$ = new NodeInt(result);
            }
        } else {
            $$ = new NodeBinOp(NodeBinOp::DIV, left, right);
        }
     }
     | TLPAREN Expr TRPAREN { $$ = $2; }
     | Expr TQUESTION Expr TCOLON Expr %prec TTERN
     { $$ = new NodeTernaryOp($1, $3, $5); }
     | TIDENT TLPAREN ExprList TRPAREN 
     {
        if(mpss.contain1(scope,$1))
        {
            $$=new NodeCallingFunc($1,$3);
        }
        else{
            yyerror("Function Not defined");
        }
     }
     ;

%%

int yyerror(std::string msg) {
    std::cerr << "Error! " << msg << std::endl;
    exit(1);
}
