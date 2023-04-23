#ifndef SYMBOL_HH
#define SYMBOL_HH
#include<iostream>
#include <set>
#include <string>
#include <map>
#include <utility>
#include "ast.hh"

// Basic symbol table, just keeping track of prior existence and nothing else
struct SymbolTable {
    std::set<std::string> table;
    bool contains(std::string key);
    void insert(std::string key);
};

struct Scope
{
    std::map<int,std::set<std::pair<std::string,int>>> mps;
    void inserts(int scope, std::string key,int type);
    bool containss(int scope,std::string key,int type);
    bool containsss(int scope,std::string key,int type);
    bool contain1(int scope,std::string key);
};

struct Mapp
{
    std::map<std::string,int> mp;
    
    bool containsm(std::string key);
    void insertm(std::string key, int value);
    int getm(std::string key);
};

#endif