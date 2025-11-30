
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -I./src
LDFLAGS = -lreadline 

TARGET = my_shell
C_SRC = src/main.cpp
C_OBJ = $(C_SRC:.cpp=.o)

RUST_DIR = rust_builtins
RUST_TARGET_DIR = $(RUST_DIR)/target/debug
RUST_LIB_PATH = $(RUST_TARGET_DIR)/librust_builtins.so

RUST_SYSTEM_LIBS = -ldl -lrt -lpthread -lm 

.PHONY: all clean rust_build

all: $(TARGET)
clean:
	rm -f $(TARGET) $(C_OBJ)
	rm -rf $(RUST_DIR)/target


$(TARGET): $(C_OBJ) $(RUST_LIB_PATH)
	
	$(CXX) $(CXXFLAGS) $(C_OBJ) -o $(TARGET) $(LDFLAGS) \
	-L$(RUST_TARGET_DIR) -lrust_builtins $(RUST_SYSTEM_LIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(RUST_LIB_PATH): 
	@echo "--- Compiling Rust Builtins ---"
	@(cd $(RUST_DIR) && cargo build)
	@echo "--- Rust Compilation Complete ---"