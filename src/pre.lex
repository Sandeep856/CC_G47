/* just like Unix wc */
%option noyywrap
%option prefix="foo"
 
%x comment
%x comment2
%x DEFINE
%x DEFINE2
%x UNDEF
%x IFDEF
%x WORK
%x ENDIF
%x SKIP
 
%{
#include <string>
#include<iostream>
#include <unordered_map>
#include<cstdio>
using namespace std;
 
string key;
unordered_map<string, string> map;
int temp=0;
%}
%%
 
"#def " {BEGIN(DEFINE); return 1;}
<DEFINE>[a-zA-Z][a-zA-Z0-9]* {key = yytext; map[key]="1"; return 1;}
<DEFINE>[\n]+ {BEGIN(INITIAL); return 1;}
<DEFINE>" " {BEGIN(DEFINE2); return 1;}
<DEFINE2>[^\\\n]+ {if(map[key] == "1") map[key] = ""; map[key] += yytext; return 5;}
<DEFINE2>"\\\n" {return 1;}
<DEFINE2>[\n]+ {BEGIN(INITIAL); return 1;}
 
"#undef " {BEGIN(UNDEF); return 2;}
<UNDEF>[a-zA-Z][a-zA-Z0-9]* {map.erase(yytext); return 2;}
<UNDEF>[ \n]+ {BEGIN(INITIAL); return 2;}
 
"#ifdef "   { temp=1;  BEGIN(IFDEF);  return 6;}
<IFDEF>[a-zA-Z][a-zA-Z0-9]* {
    key= yytext;
    if(map.find(yytext) != map.end()) {
        temp=2;
        BEGIN(WORK);
    } else {
        BEGIN(ENDIF);
    }
    return 6;
}  
<IFDEF>[ \n]+ {BEGIN(INITIAL); return 6;}
<WORK>[ \n]+ {BEGIN(INITIAL);  return 6;}
<ENDIF>^[^#][^e][^l][^i][^f].*
<ENDIF>^[^#][^e][^n][^d][^i][^f].*
<ENDIF>^[^#][^e][^l][^s][^e].*
 
<ENDIF>"#elif "  {BEGIN(IFDEF); return 7;}
<ENDIF>"#endif" {BEGIN(INITIAL); return 7;}
<ENDIF>"#else" {BEGIN(INITIAL); return 7;}
 
"#endif"   {if(temp==0)    return 9;   temp=0;    BEGIN(INITIAL);}
 
"#elif"    {
    if(temp==0)    return 8;  
    if(temp==2){
        BEGIN(SKIP);    return 10;
    }        
    BEGIN(INITIAL);}
 
"#else" {
    if(temp==2){
        BEGIN(SKIP);    return 10;
    }
    BEGIN(INITIAL);}
 
<SKIP>^[^#][^e][^n][^d][^i][^f].* 
<SKIP>#endif {BEGIN(INITIAL);} 
 
"/*"         BEGIN(comment);
<comment>[^*]*   
<comment>"*"+[^*/]* 
<comment>"*"+"/"  {BEGIN(INITIAL);}
 
"//"    BEGIN(comment2);
<comment2>.
<comment2>[ \n]+ {BEGIN(INITIAL);}
[\n ] {return 4;}
[a-zA-Z][a-zA-Z0-9]* {return 3;}
. {return 4;}
%%