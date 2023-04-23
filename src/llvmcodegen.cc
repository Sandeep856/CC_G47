#include "llvmcodegen.hh"
#include "ast.hh"
#include <iostream>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/Constant.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Bitcode/BitcodeWriter.h>
#include <vector>

#define MAIN_FUNC compiler->module.getFunction("main")

/*
The documentation for LLVM codegen, and how exactly this file works can be found
ins `docs/llvm.md`
*/

void LLVMCompiler::compile(Node *root) {
    /* Adding reference to print_i in the runtime library */
    // void printi();
    FunctionType *printi_func_type = FunctionType::get(
        builder.getVoidTy(),
        {builder.getInt64Ty()},
        false
    );
    Function::Create(
        printi_func_type,
        GlobalValue::ExternalLinkage,
        "printi",
        &module
    );
    /* we can get this later 
        module.getFunction("printi");
    */

    /* Main Function */
    // int main();
    FunctionType *main_func_type = FunctionType::get(
         builder.getInt64Ty(),{}, false /* is vararg */
    );
    Function *main_func = Function::Create(
        main_func_type,
        GlobalValue::ExternalLinkage,
        "main",
        &module
    );

    // create main function block
    BasicBlock *main_func_entry_bb = BasicBlock::Create(
        *context,
        "entry",
        main_func
    );

    // move the builder to the start of the main function block
    builder.SetInsertPoint(main_func_entry_bb);

    root->llvm_codegen(this);

    // return 0;
    builder.CreateRet(builder.getInt64(0));
}

void LLVMCompiler::dump() {
    outs() << module;
}

void LLVMCompiler::write(std::string file_name) {
    std::error_code EC;
    raw_fd_ostream fout(file_name, EC, sys::fs::OF_None);
    WriteBitcodeToFile(module, fout);
    fout.flush();
    fout.close();
}

//  ┌―――――――――――――――――――――┐  //
//  │ AST -> LLVM Codegen │  //
//  └―――――――――――――――――――――┘   //

// codegen for statements
Value *NodeStmts::llvm_codegen(LLVMCompiler *compiler) {
    Value *last = nullptr;
    for(auto node : list) {
        last = node->llvm_codegen(compiler);
    }

    return last;
}

Value *NodeDebug::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);

    Function *printi_func = compiler->module.getFunction("printi");
    compiler->builder.CreateCall(printi_func, {expr});

    return expr;
}

Value *NodeInt::llvm_codegen(LLVMCompiler *compiler) {
    return compiler->builder.getInt64(value);
}
Value *NodeLong::llvm_codegen(LLVMCompiler *compiler) {
    return compiler->builder.getInt64(value);
}
Value *NodeShort::llvm_codegen(LLVMCompiler *compiler) {
    return compiler->builder.getInt64(value);
}

Value *NodeBinOp::llvm_codegen(LLVMCompiler *compiler) {
    Value *left_expr = left->llvm_codegen(compiler);
    Value *right_expr = right->llvm_codegen(compiler);

    switch(op) {
        case PLUS:
        return compiler->builder.CreateAdd(left_expr, right_expr, "addtmp");
        case MINUS:
        return compiler->builder.CreateSub(left_expr, right_expr, "minustmp");
        case MULT:
        return compiler->builder.CreateMul(left_expr, right_expr, "multtmp");
        case DIV:
        return compiler->builder.CreateSDiv(left_expr, right_expr, "divtmp");
    }
}

Value *NodeIf::llvm_codegen(LLVMCompiler *compiler) {
        
        Value *cond_val = condition->llvm_codegen(compiler);
        if (!cond_val) {
            return nullptr;
        }

        // Convert the condition value to a boolean
        cond_val = compiler->builder.CreateICmpNE(cond_val, ConstantInt::get(Type::getInt64Ty(*(compiler->context)),0),"ifcond");

        // Create basic blocks for the true and false cases
        Function *function = compiler->builder.GetInsertBlock()->getParent();
        BasicBlock *true_bb = BasicBlock::Create(*compiler->context, "if_true", function);
        BasicBlock *false_bb = BasicBlock::Create(*compiler->context, "if_false");
        BasicBlock *merge_bb = BasicBlock::Create(*compiler->context, "if_merge");

        // Branch to the true or false block depending on the condition
        compiler->builder.CreateCondBr(cond_val, true_bb, false_bb);

        // Generate code for the true block
        compiler->builder.SetInsertPoint(true_bb);
        
        Value *true_val = true_block->llvm_codegen(compiler);
        if (!true_val) {
            return nullptr;
        }
        compiler->builder.CreateBr(merge_bb);
        true_bb = compiler->builder.GetInsertBlock();

        // Generate code for the false block
        function->getBasicBlockList().push_back(false_bb);
        compiler->builder.SetInsertPoint(false_bb);
        
        Value *false_val = false_block->llvm_codegen(compiler);
        if (!false_val) {
            return nullptr;
        }
        compiler->builder.CreateBr(merge_bb);
        false_bb = compiler->builder.GetInsertBlock();

        // Generate code for the merge block
        function->getBasicBlockList().push_back(merge_bb);
        compiler->builder.SetInsertPoint(merge_bb);
        PHINode *phi_node = compiler->builder.CreatePHI(compiler->builder.getInt64Ty(), 2, "iftmp");
        phi_node->addIncoming(true_val, true_bb);
        phi_node->addIncoming(false_val, false_bb);

        return phi_node;
        //return nullptr;
    }


Value *NodeAssn::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin()
    );

    AllocaInst *alloc = temp_builder.CreateAlloca(compiler->builder.getInt64Ty(), 0, identifier);
    

    compiler->locals[identifier] = alloc;

    return compiler->builder.CreateStore(expr, alloc);
}

Value *NodeIdent::llvm_codegen(LLVMCompiler *compiler) {
    AllocaInst *alloc = compiler->locals[identifier];

    // if your LLVM_MAJOR_VERSION >= 14
    return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);
}

Value *NodeTernaryOp::llvm_codegen(LLVMCompiler *compiler) {
    //implement later
    return nullptr;
}
Value *NodeVarAssign::llvm_codegen(LLVMCompiler *compiler) {
    //implement later
    return nullptr;
}


Value *NodeParam::llvm_codegen(LLVMCompiler *compiler)
{
    // Since this is a parameter, we don't need to generate LLVM code for it.
    // It will be used when generating code for function declarations.
    return nullptr;
}

Value *NodeParams::llvm_codegen(LLVMCompiler *compiler)
{
    // Since this is a list of parameters, we don't need to generate LLVM code for it.
    // It will be used when generating code for function declarations.
    return nullptr;
}
// llvm::Value *LLVMCompiler::createCallInst(llvm::Function *func, std::vector<llvm::Value *> args) {
//     // Create a call instruction
//     llvm::CallInst *call_inst = llvm::CallInst::Create(func, args, "", current_block);
//     current_block->getInstList().push_back(call_inst);
//     return call_inst;
// }
Value *NodeFuncDecl::llvm_codegen(LLVMCompiler *compiler)
{
    // std::vector<Type*> Ints(params->list.size(),
    //                          Type::getInt32Ty(*compiler->context));
    // FunctionType *ftype = FunctionType::get(Type::getInt32Ty(*compiler->context),Ints,false);
    // llvm::Twine nameTwine(name);
    // Function *func = Function::Create(ftype, Function::ExternalLinkage,nameTwine, compiler->module);
    // BasicBlock *bblock = BasicBlock::Create(*compiler->context, "entry", func);

    //compiler->builder.SetInsertPoint(bblock);
    
    // for (NodeParam *p : params->list)
    // {
    //     llvm::Twine pparamTwine(p->param->to_string());
    //     AllocaInst *alloca = compiler->builder.CreateAlloca(Type::getInt32Ty(*compiler->context), nullptr, pparamTwine);
    //     compiler->builder.CreateStore(p->param->llvm_codegen(compiler), alloca,false);
    //     compiler->locals[(p->param)->to_string()] = alloca;
    // }

     Value* ret=body->llvm_codegen(compiler);

    // if (Value *RetVal = body->llvm_codegen(compiler))
    // {
    //     //Finish off the function.
    //     compiler->builder.CreateRet(RetVal);

    //     //Validate the generated code, checking for consistency.

    //     return func;
    // }
    return ret;
}

Value *NodeActualParam::llvm_codegen(LLVMCompiler *compiler)
{
    // Generate LLVM code for the actual parameter expression.
    return nullptr;
}

Value *NodeActualParams::llvm_codegen(LLVMCompiler *compiler)
{
    // std::vector<llvm::Value *> args;
    // for (auto param : list)
    // {
    //     args.push_back(param->llvm_codegen(compiler));
    // }
    return nullptr;
}

Value *NodeCallingFunc::llvm_codegen(LLVMCompiler *compiler)
{
    // Function *callee = compiler->module.getFunction(name);
    // if (!callee)
    // {
    //     std::cerr << "Error: Unknown function " << this->name << std::endl;
    //     return nullptr;
    // }

    // std::vector<llvm::Value *> args;
    // for (NodeActualParam *p : Actualparams->list)
    // {
    //     args.push_back(p->actparam->llvm_codegen(compiler));
    //     // if (!args.back())
    //     //     return nullptr;
    // }

    // llvm::Value *ret_val = compiler->builder.CreateCall(callee, args, "calltmp");
    // return compiler->builder.CreateIntCast(ret_val, llvm::Type::getInt32Ty(*compiler->context), true);

    return compiler->builder.getInt64(5);
}

Value *NodeRet::llvm_codegen(LLVMCompiler *compiler)
{
    Value *ret_val = nullptr;
    if (expression != nullptr)
    {
        ret_val = expression->llvm_codegen(compiler);
    }
    //compiler->builder.CreateRet(ret_val);
    return ret_val;
}

#undef MAIN_FUNC