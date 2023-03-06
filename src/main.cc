    #include <iostream>
    #include <string>
    #include <vector>
    #include <unordered_map>
    #include <cstdio>
    #include <cstring>
    #include <fstream>
     
    #include "parser.hh"
    #include "ast.hh"
    #include "llvmcodegen.hh"
     
    extern FILE *yyin;
    extern int yylex();
    extern char *yytext;
     
    extern FILE *fooin;
    extern FILE *fooout;
    extern int foolex();
    extern char *footext;
     
    extern std::string key;
    extern std::unordered_map<std::string, std::string> map;
     
    NodeStmts *final_values;
     
    #define ARG_OPTION_L 0
    #define ARG_OPTION_P 1
    #define ARG_OPTION_S 2
    #define ARG_OPTION_O 3
    #define ARG_FAIL -1
     
    int parse_arguments(int argc, char *argv[]) {
    	if (argc == 3 || argc == 4) {
    		if (strlen(argv[2]) == 2 && argv[2][0] == '-') {
    			if (argc == 3) {
    				switch (argv[2][1]) {
    					case 'l':
    					return ARG_OPTION_L;
     
    					case 'p':
    					return ARG_OPTION_P;
     
    					case 's':
    					return ARG_OPTION_S;
    				}
    			} else if (argv[2][1] == 'o') {
    				return ARG_OPTION_O;
    			}
    		}
    	} 
    	
    	std::cerr << "Usage:\nEach of the following options halts the compilation process at the corresponding stage and prints the intermediate output:\n\n";
    	std::cerr << "\t`./bin/base <file_name> -l`, to tokenize the input and print the token stream to stdout\n";
    	std::cerr << "\t`./bin/base <file_name> -p`, to parse the input and print the abstract syntax tree (AST) to stdout\n";
    	std::cerr << "\t`./bin/base <file_name> -s`, to compile the file to LLVM assembly and print it to stdout\n";
    	std::cerr << "\t`./bin/base <file_name> -o <output>`, to compile the file to LLVM bitcode and write to <output>\n";
    	return ARG_FAIL;
    }
     
    bool cycle_check(std::unordered_map<std::string, std::string> mp) {
		std::unordered_map<std::string,std::string>::iterator it;
		it=mp.begin();
    	for(auto i: mp) {
    		std::string ptr = i.first;
    		while(mp.find(ptr) != mp.end()) {
    			ptr = mp[ptr];
    			if(ptr == i.first) return true;
    		}
    	}
    	return false;
    }
     
    void preprocess() {
    	
    	int cnt;
    	int token;
		int g47;
		int atr=0;
		g47=atr+1;

    	std::string data;
    	
    	do {
    		fooin = fopen("temp", "r");
    		cnt = 0;
    		token = 0;
    		data = "";
     
    		do {
				token = foolex();
				std::string temp = footext;
     
    			
    			
    			if(token == 5 && cycle_check(map)) {
    				std::cerr<<"Cycle detected in #def statements"<<std::endl;
					fclose(fooin);
    				remove("temp");
    				exit(1);
    			}
              
    			else if(token == 13 && map.find(temp) != map.end()) {
    				cnt++;
					cnt--;
					cnt++;
    				temp = map[temp];
    			}
				else if(token==19 && 1)
    			{
    				std::cerr<<"\"endif before ifdef\""<<std::endl;
					fclose(fooin);
    				remove("temp");
    				exit(1);
    			}

    			else if(token==18 && 1)
    			{
    				std::cerr<<"\"elif\" before \"ifdef\""<<std::endl;
					fclose(fooin);
    				remove("temp");
    				exit(1);
    			}
    			g47=atr+1;
    			data += temp;
     
    		} while(token != 0);
     
    		std::ofstream otemp("temp");
    		otemp<<data;
    		otemp.close();
    	} while(cnt > 0);
     
	    data = "";
    	
		//data(cnt)

		fooin = fopen("temp", "r");
    
    	do {
    		token = foolex();
    		std::string temp = footext;
    		if(token != 11 && token != 12 && token != 15 && token !=17 && token!=16 && token!=20)
    			data += temp;
     
    	} while(token != 0);
     
    	
    	fclose(fooin);
     
    	std::ofstream ofile("temp");
		int ct=0;
		ct=2+g47+ct;
    	ofile<<data;
    	ofile.close();
    }
     
    int main(int argc, char *argv[]) {
    	int arg_option = parse_arguments(argc, argv);
    	if (arg_option == ARG_FAIL) {
    		exit(1);
    	}
     
    	std::string file_name(argv[1]);
     
    	std::ifstream itemp(file_name);
    	std::ofstream otemp("temp");
    	std::string line;
    	while (getline(itemp, line)) {
    		otemp << line << std::endl;
    	}
    	itemp.close();
    	otemp.close();
     
    	preprocess();
     
    	yyin = fopen("temp", "r");
     
    	if (arg_option == ARG_OPTION_L) {
    		extern std::string token_to_string(int token, const char *lexeme);
     
    		while (true) {
    			int token = yylex();
    			if (token == 0) {
    				break;
    			}
     
    			std::cout << token_to_string(token, yytext) << "\n";
    		}
    		fclose(yyin);
    		return 0;
    	}
     
        final_values = nullptr;
     
    	yyparse();
     
    	fclose(yyin);
    	remove("temp");
     
    	if(final_values) {
    		if (arg_option == ARG_OPTION_P) {
    			std::cout << final_values->to_string() << std::endl;
    			return 0;
    		}
    		
            llvm::LLVMContext context;
    		LLVMCompiler compiler(&context, "base");
    		compiler.compile(final_values);
            if (arg_option == ARG_OPTION_S) {
    			compiler.dump();
            } else {
                compiler.write(std::string(argv[3]));
    		}
    	} else {
    	 	std::cerr << "empty program";
    	}
     
        return 0;
    }