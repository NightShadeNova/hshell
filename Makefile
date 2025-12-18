CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -I./src -I.
LDFLAGS = -lreadline 

TARGET = my_shell
C_SRC = src/main.cpp
C_OBJ = $(C_SRC:.cpp=.o)

RUST_DIR = rust_builtins
RUST_TARGET_DIR = $(CURDIR)/$(RUST_DIR)/target/debug

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    LIB_EXT = dylib
else
    LIB_EXT = so
endif

RUST_LIB_PATH = $(RUST_TARGET_DIR)/librust_builtins.$(LIB_EXT)
RUST_SYSTEM_LIBS = -ldl -lpthread -lm 

.PHONY: all clean rust_build

all: $(TARGET)

clean:
	rm -f $(TARGET) $(C_OBJ)
	cd $(RUST_DIR) && cargo clean

$(TARGET): $(C_OBJ) $(RUST_LIB_PATH)
	$(CXX) $(CXXFLAGS) $(C_OBJ) -o $(TARGET) $(LDFLAGS) \
	-L$(RUST_TARGET_DIR) -lrust_builtins \
	-Wl,-rpath,$(RUST_TARGET_DIR) \
	$(RUST_SYSTEM_LIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(RUST_LIB_PATH): rust_build

rust_build:
	@echo "--- Compiling Rust Builtins ---"
	@(cd $(RUST_DIR) && cargo build)
	@echo "--- Rust Compilation Complete ---"

