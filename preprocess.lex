%option prefix="prr"
%option noyywrap

%{
    #include <unordered_map>
    #include <string>
    #include <cstring>
    #include <tuple>
    
    std::unordered_map<std::string, std::string> m;

    std::pair<std::string, std::string> tokenise(char* prrtext);

%}



%%

"#def "[_A-Za-z]+[_A-Za-z0-9]*" "([^\n]*[\\][\n])*[^\n]*[\n] {auto p = tokenise(yytext); m[p.first] = p.second; return 1000;}

%%

std::pair<std::string, std::string> tokenise() {
    //Returns {key, val}
    char* tok1, *tok2, *tok3;
    tok1 = std::strtok(prrtext, " ");
    tok2 = std::strtok(NULL, " ");
    tok3 = tok2 + std::strlen(tok2) + 1;
    std::string s2 = std::string(tok2);
    std::string s3 = std::string(tok3);
    for(char& c: s3) {
        if(c=='\\') c = ' ';
    }
    return {s2, s3};
}

