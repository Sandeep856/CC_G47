#include "symbol.hh"

bool SymbolTable::contains(std::string key) {
    return table.find(key) != table.end();
}

void SymbolTable::insert(std::string key) {
    table.insert(key);
}

void SymbolTable::remove(std::string key)
{
    table.erase(key);
}