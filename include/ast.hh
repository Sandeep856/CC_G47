#ifndef AST_HH
#define AST_HH

#include <llvm/IR/Value.h>
#include <string>
#include <vector>

struct LLVMCompiler;

/**
Base node class. Defined as `abstract`.
*/
struct Node {
    enum NodeType {
        BIN_OP, INT_LIT, STMTS, ASSN, DBG, IDENT, TERN, VARASS, IF, PARAMS, PARAM, FUNC_DECL, ACTUALPARAM, ACTUALPARAMS,CALLINGFUNC, RET
    } type;

    virtual std::string to_string() = 0;
    virtual llvm::Value *llvm_codegen(LLVMCompiler *compiler) = 0;
};

/**
    Node for list of statements
*/
struct NodeStmts : public Node {
    std::vector<Node*> list;

    NodeStmts();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};
/**
    Node for binary operations
*/
struct NodeBinOp : public Node {
    enum Op {
        PLUS, MINUS, MULT, DIV
    } op;

    Node *left, *right;

    NodeBinOp(Op op, Node *leftptr, Node *rightptr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};
/*
Node for ternary Operator
*/
struct NodeTernaryOp:public Node
{
    Node * condition;
    Node* true_exp;
    Node * false_exp;
    NodeTernaryOp(Node* cond,Node* true_exp,Node* false_exp);
    std::string to_string();
    llvm::Value* llvm_codegen(LLVMCompiler *compiler);
};
/**
    Node for integer literals
*/

struct NodeInt : public Node {
    int value;

    NodeInt(int val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};
struct NodeLong : public Node {
    long value;

    NodeLong(long val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};
struct NodeShort : public Node {
    short value;

    NodeShort(short val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for variable assignments
*/
struct NodeAssn : public Node {
    std::string identifier;
    Node *expression;

    NodeAssn(std::string id, Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};
/**
    Node for variable assignments
*/
struct NodeVarAssign : public Node {
    std::string var_name;
    Node *expression;

    NodeVarAssign(std::string name, Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for `dbg` statements
*/
struct NodeDebug : public Node {
    Node *expression;

    NodeDebug(Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for idnetifiers
*/
struct NodeIdent : public Node {
    std::string identifier;

    NodeIdent(std::string ident);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
Node for `if` statements
*/
struct NodeIf : public Node {
    Node *condition;
    Node *true_block;
    Node *false_block;
    int  x;

    NodeIf(Node *condition, Node *true_block, Node *false_block, int x);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};









struct NodeParam : public Node {
    Node* param;
    NodeParam(Node* param);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeParams : public Node {
    std::vector<NodeParam*> list;

    NodeParams();
    void push_back(NodeParam* node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeFuncDecl : public Node 
{
    std::string name;
    NodeParams* params;
    NodeStmts *body;

    NodeFuncDecl(std::string name, NodeParams* params, NodeStmts *body);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeActualParam : public Node 
{
    Node* actparam;

    NodeActualParam(Node*  actparam);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeActualParams : public  Node
{
    std::vector<NodeActualParam*> list;

    NodeActualParams();
    void push_back(NodeActualParam* node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeCallingFunc : public Node
{
    std::string name;
    NodeActualParams* Actualparams;
    NodeCallingFunc(std::string name, NodeActualParams* Actualparams);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeRet:public Node
{
    Node* expression;
    NodeRet(Node* expression);
    std::string to_string();
    llvm::Value* llvm_codegen(LLVMCompiler* compiler);
};


#endif