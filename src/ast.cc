#include "ast.hh"
#include <string>
#include <vector>

NodeBinOp::NodeBinOp(NodeBinOp::Op ope, Node *leftptr, Node *rightptr) {
    type = BIN_OP;
    op = ope;
    left = leftptr;
    right = rightptr;
}

std::string NodeBinOp::to_string() {
    std::string out = "(";
    switch(op) {
        case PLUS: out += '+'; break;
        case MINUS: out += '-'; break;
        case MULT: out += '*'; break;
        case DIV: out += '/'; break;
    }

    out += ' ' + left->to_string() + ' ' + right->to_string() + ')';

    return out;
}


// ternary
NodeTernaryOp::NodeTernaryOp(Node* cond, Node* true_exp, Node* false_exp) {
    type = TERN;
    condition = cond;
    this->true_exp = true_exp;
    this->false_exp = false_exp;
}

std::string NodeTernaryOp::to_string() {
    return "(?: " + condition->to_string() + " " + true_exp->to_string() + " " + false_exp->to_string() + ")";
}

NodeInt::NodeInt(int val) {
    type = INT_LIT;
    value = val;
}
NodeLong::NodeLong(long val) {
    type = INT_LIT;
    value = val;
}
NodeShort::NodeShort(short val) {
    type = INT_LIT;
    value = val;
}

std::string NodeInt::to_string() {
    return std::to_string(value);
}
std::string NodeLong::to_string() {
    return std::to_string(value);
}
std::string NodeShort::to_string() {
    return std::to_string(value);
}

NodeStmts::NodeStmts() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeStmts::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeStmts::to_string() {
    std::string out ={0};
    for(auto i : list) {
        out += " " + i->to_string();
    }


    return out;
}

NodeAssn::NodeAssn(std::string id, Node *expr) {
    type = ASSN;
    identifier = id;
    expression = expr;
}

std::string NodeAssn::to_string() {
    return "(let " + identifier + " " + expression->to_string() + ")";
}


//var ass
NodeVarAssign::NodeVarAssign(std::string var_name, Node *expression) {
    type = VARASS;
    this->var_name = var_name;
    this->expression = expression;
}

std::string NodeVarAssign::to_string() {
    return "(assign " + var_name + " " + expression->to_string() + ")";
}



NodeDebug::NodeDebug(Node *expr) {
    type = DBG;
    expression = expr;
}

std::string NodeDebug::to_string() {
    return "(dbg " + expression->to_string() + ")";
}

NodeIdent::NodeIdent(std::string ident) {
    type = IDENT;
    identifier = ident;
}

std::string NodeIdent::to_string() {
    return identifier;
}


// if else
NodeIf::NodeIf(Node *cond, Node *if_true, Node *if_false, int x1) {
    type = IF;
    condition = cond;
    true_block = if_true;
    false_block = if_false;
    x=x1;

}

std::string NodeIf::to_string() {
    std::string out = "(if-else " + condition->to_string();
    
    if (x==0) {
        out = true_block->to_string();
    }
    if (x==1) {
        out =false_block->to_string();
    }
    if(x==2)
    {
        out += " " + true_block->to_string();
        out += " " + false_block->to_string();
        out += ")";
    }

    return out;
}







NodeParam::NodeParam(Node* param) {
    type = PARAM;
    this->param = param;
}

std::string NodeParam::to_string() {
    return param->to_string();
}

NodeActualParam::NodeActualParam(Node* actparam) {
    type = ACTUALPARAM;
    this->actparam=actparam;
}

std::string NodeActualParam::to_string() {
    return actparam->to_string();
}






NodeParams::NodeParams() {
    type = PARAMS;
    list = std::vector<NodeParam*>();
}
void NodeParams::push_back(NodeParam *node) {
    list.push_back(node);
}

std::string NodeParams::to_string() {
    std::string out = "(";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';

    return out;
}

NodeActualParams::NodeActualParams() {
    type = ACTUALPARAMS;
    list = std::vector<NodeActualParam*>();
}
void NodeActualParams::push_back(NodeActualParam *node) {
    this->list.push_back(node);
}

std::string NodeActualParams::to_string() {
    std::string out = "(";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';

    return out;
}





NodeFuncDecl::NodeFuncDecl(std::string name, NodeParams *params, NodeStmts *body) {
    type = FUNC_DECL;
    this->name = name;
    this->params = params;
    this->body= body;
    
}

std::string NodeFuncDecl::to_string() {
    return "(defun " + name + " " + params->to_string() + " " + body->to_string() + ")";
}


NodeCallingFunc::NodeCallingFunc(std::string name, NodeActualParams *Actualparams) {
    type = CALLINGFUNC;
    this->name = name;
    this->Actualparams = Actualparams;
    
}

std::string NodeCallingFunc::to_string() {
    return "(CallingFunc " + name + " " + Actualparams->to_string() + " " + ")";
}


NodeRet::NodeRet(Node* expression)
{
    type=RET;
    this->expression=expression;
}

std::string NodeRet::to_string()
{
    return "(Ret "+expression->to_string()+" )";
}



