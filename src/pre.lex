/* just like Unix wc */
%option noyywrap
%option prefix="foo"
 
%x comment
%x comment2
%x UNDEF
%x IFDEF
%x WORK
%x ENDIF
%x SKIP
%x DEFINE
%x DEFINE2

 
 
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
 
"#def " {BEGIN(DEFINE); return 11;}
<DEFINE>[a-zA-Z][a-zA-Z0-9]* {key = yytext; map[key]="1"; return 11;}
<DEFINE>[\n]+ {BEGIN(INITIAL); return 11;}
<DEFINE>" " {BEGIN(DEFINE2); return 11;}
<DEFINE2>[^\\\n]+ {if(map[key] == "1") map[key] = ""; map[key] += yytext; return 15;}
<DEFINE2>"\\\n" {return 11;}
<DEFINE2>[\n]+ {BEGIN(INITIAL); return 11;}
 
"#undef " {BEGIN(UNDEF); return 12;}
<UNDEF>[a-zA-Z][a-zA-Z0-9]* {map.erase(yytext); return 12;}
<UNDEF>[ \n]+ {BEGIN(INITIAL); return 12;}
 
"#ifdef "   { temp=1;  BEGIN(IFDEF);  return 16;}
<IFDEF>[a-zA-Z][a-zA-Z0-9]* {
    key= yytext;
    if(map.find(yytext) != map.end()) {
        temp=2;
        BEGIN(WORK);
    } else {
        BEGIN(ENDIF);
    }
    return 16;
}  
<IFDEF>[ \n]+ {BEGIN(INITIAL); return 16;}
<WORK>[ \n]+ {BEGIN(INITIAL);  return 16;}
<ENDIF>^[^#][^e][^l][^i][^f].*
<ENDIF>^[^#][^e][^n][^d][^i][^f].*
<ENDIF>^[^#][^e][^l][^s][^e].*
 
<ENDIF>"#else" {BEGIN(INITIAL); return 17;}
<ENDIF>"#elif "  {BEGIN(IFDEF); return 17;}
<ENDIF>"#endif" {BEGIN(INITIAL); return 17;}

 
"#endif"   {if(temp==0)    return 19;   temp=0;    BEGIN(INITIAL);}
 
"#elif"    {
    if(temp==0)    return 18;  
    if(temp==2){
        BEGIN(SKIP);    return 20;
    }        
    BEGIN(INITIAL);}
 
"#else" {
    if(temp==2){
        BEGIN(SKIP);    return 20;
    }
    BEGIN(INITIAL);} 


"/*"         BEGIN(comment);

<SKIP>^[^#][^e][^n][^d][^i][^f].* 
<SKIP>#endif {BEGIN(INITIAL);}
 

<comment>[^*]*   
<comment>"*"+[^*/]* 
<comment>"*"+"/"  {BEGIN(INITIAL);}
  
"//"    BEGIN(comment2);
<comment2>.
<comment2>[ \n]+ {BEGIN(INITIAL);}
[\n ] {return 14;}
[a-zA-Z][a-zA-Z0-9]* {return 13;}
. {return 14;}
%%