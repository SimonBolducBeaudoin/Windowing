NAME = Windowing
PYLIB_EXT = $(if $(filter $(OS),Windows_NT),.pyd,.so)
TARGET_STATIC = lib$(NAME).a
TARGET_PYLIB = ../Python/$(NAME)$(PYLIB_EXT)

WINDOWING = ../Windowing
SPECIAL_FUNC = ../Special_functions
NUMERICAL_INT = ../Numerical_integration

IDIR = includes
ODIR = obj
LDIR = lib
SDIR = src

WINDOWING_OBJ = $(wildcard $(WINDOWING)/$(ODIR)/*.o)

EXTERNAL_INCLUDES = -I$(NUMERICAL_INT)/$(IDIR) -I$(SPECIAL_FUNC)/$(IDIR) -I$(WINDOWING)/$(IDIR)

IDIR = includes
ODIR = obj
LDIR = lib
SDIR = src

SRC  = $(wildcard $(SDIR)/*.cpp)
OBJ  = $(patsubst $(SDIR)/%.cpp,$(ODIR)/%.o,$(SRC))
ASS  = $(patsubst $(SDIR)/%.cpp,$(ODIR)/%.s,$(SRC))
DEPS = $(OBJ:.o=.d)

CXX = $(OS:Windows_NT=x86_64-w64-mingw32-)g++
OPTIMIZATION = -O3 -march=native
CPP_STD = -std=c++14
WARNINGS = -Wall
MINGW_COMPATIBLE = $(OS:Windows_NT=-DMS_WIN64 -D_hypot=hypot)
DEPS_FLAG = -MMD -MP

POSITION_INDEP = -fPIC
SHARED = -shared

MATH = -lm

LINKS = $(MATH)

STATIC_LIB = ar cr $(TARGET_STATIC) $(OBJ) 

INCLUDES = $(MATH) $(EXTERNAL_INCLUDES)
COMPILE = $(CXX) $(CPP_STD) $(OPTIMIZATION) $(POSITION_INDEP) $(WARNINGS) -c -o $@ $< $(INCLUDES) $(DEPS_FLAG) $(MINGW_COMPATIBLE)
ASSEMBLY = $(CXX) $(CPP_STD) $(OPTIMIZATION) $(POSITION_INDEP) $(WARNINGS) -S -o $@ $< $(INCLUDES) $(DEPS_FLAG) $(MINGW_COMPATIBLE)

compile_objects : $(OBJ)

assembly : $(ASS)

all : $(TARGET_PYLIB) $(TARGET_STATIC) $(OBJ) $(ASS)

static_library : $(TARGET_STATIC)

$(TARGET_STATIC) : $(OBJ)
	@ echo " "
	@ echo "---------Compiling static library $(TARGET_STATIC)---------"
	$(STATIC_LIB)

$(ODIR)/%.o : $(SDIR)/%.cpp
	@ echo " "
	@ echo "---------Compile object $@ from $<--------"
	$(COMPILE)
	
$(ODIR)/%.s : $(SDIR)/%.cpp
	@ echo " "
	@ echo "---------Assembly $@ from $<--------"
	$(ASSEMBLY)
	
-include $(DEPS)

clean:
	@rm -f $(TARGET_PYLIB) $(TARGET_STATIC) $(OBJ) $(ASS) $(DEPS)
	 	 
.PHONY: all , clean , python_debug_library , compile_objects , assembly