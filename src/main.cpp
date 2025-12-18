#include <iostream>
#include <string>
#include <vector>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sstream>
#include <stdlib.h>
#include "hshell/rust_builtins/rust_builtins.h"

std::vector<std::string> parseCommand(std::string& inp_line){
    std::vector<std::string> args;
    std::istringstream iss(inp_line);
    std::string arg;
    while(iss >> arg){
        args.push_back(arg);
    }
    return args;
}

extern "C" int rustexe(const char** argv, int argc);
int exec_rust(std::vector<std::string>& tokens);

void exe(std::vector<std::string>& tokens){
    std::vector<char*> c_args;

    for(const auto& token:tokens){
        c_args.push_back(const_cast<char*>(token.c_str()));
    }
    c_args.push_back(NULL);

    pid_t pid = fork();
    if (pid == -1){
        perror("Fork failed");
    }
    else if (pid == 0){
        if (execvp(c_args[0], c_args.data()) == -1) perror("Exec failed");
        exit(EXIT_FAILURE);
    }
    else if (pid > 0){
        int status;
        if (waitpid(pid, &status, 0) == -1) perror("waitpid error");
    }
}

void shell_loop(){
    std::string inp_line;
    while(true){
        std::cout << "hybrid_shell~";

        std::getline(std::cin, inp_line);
        if (inp_line.empty()) continue;

        std::vector<std::string> tokens = parseCommand(inp_line);
        if(tokens.empty()) break;
        if (tokens[0] == "exit" || tokens[0] == "Exit") break;
        
        exe(tokens);
    }
}

int main(){
    shell_loop();
}