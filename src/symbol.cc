#include "symbol.hh"



bool SymbolTable::contains(std::string key) {
    return table.find(key) != table.end();
}

void SymbolTable::insert(std::string key) {
    table.insert(key);
}





void Scope::inserts(int scope, std::string key, int type)
{
    mps[scope].insert({key, type});
}
bool Scope::containss(int scope,std::string key, int type)
{
    
    return mps[scope].find({key, type})!=mps[scope].end();
}
bool Scope::containsss(int scope,std::string key, int type)
{   
    bool k=false;
    for(int i=scope;i>=0;i--)
    {
        k =  mps[i].find({key, type})!=mps[i].end();
        if(k) return k;
    }
    return k;
}
bool Scope::contain1(int scope,std::string key)
{   
    bool k=false;
    for(int i=scope;i>=0;i--)
    {
        k =  mps[i].find({key, 1})!=mps[i].end();
        k |= mps[i].find({key, 2})!=mps[i].end();
        k |=  mps[i].find({key, 3})!=mps[i].end();
        if(k) return k;
    }
    return k;
}
    
    









bool Mapp::containsm(std::string key) {
    return mp.find(key) != mp.end();
}
void Mapp::insertm(std::string key, int value) {
    mp[key]=value;
}
int Mapp::getm(std::string key) {
    if(containsm(key)) return mp[key];
    else return -1;
}