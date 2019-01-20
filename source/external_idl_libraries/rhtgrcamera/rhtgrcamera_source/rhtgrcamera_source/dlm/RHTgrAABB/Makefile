#
# Unix makefile for IDLTOCPP DLM.
#
# 


# 	The following macro might need to be edited if the location
#	of IDL is not the standard location on your system.
IDL_DIR = /usr/local/rsi/idl


# The following macros establish general defaults. They are overridden
# in the "all" rule as needed to satisfy a given platform's requirements.

CC		= gcc
C_FLAGS		= -I$(IDL_DIR)/external -c $(CFLAGS)
LD 		= ld 
SHELL		= /bin/sh
X_CFLAGS	=
X_LD_FLAGS	=
SO_EXT		=so

.c.o :
	$(CC) $(C_FLAGS) $(X_CFLAGS) $*.c


# The following is the default entry point. This section will determine 
# what system we are on and call make again with the correct flags set.

all : 
	@echo "OS type detected: "`uname`
	@case `uname` in \
	   "SunOS") if [ `/bin/uname -p` != i386 ]; then \
			echo "" ;\
			echo "We can build either a 32-bit or a 64-bit" ;\
			echo "version of this DLM. Please use the command" ;\
			echo "          make sunOS32" ;\
			echo "for a 32-bit version, or" ;\
			echo "          make sunOS64" ;\
			echo "for the 64-bit version. It is important that" ;\
			echo "you build the correct version for the IDL" ;\
			echo "binary you are using. Otherwise the DLM will" ;\
			echo "fail to load." ;\
		    else \
	                if [ $(CC) = gcc ]; then \
                            make RHTgrAABB \
                            "X_CFLAGS=-fpic" \
                            "X_LD_FLAGS=-shared" \
                            "LD=gcc"; \
	                else \
	                    make RHTgrAABB \
                            "X_CFLAGS=-K pic" \
                            "X_LD_FLAGS=-B symbolic -z nodefs -G"; \
                        fi \
		    fi \
		;; \
	   "AIX") make RHTgrAABB \
			"LD=cc" \
			"SO_EXT=a" \
			"X_CFLAGS=" \
			"X_LD_FLAGS= -bM:SRE -bnoentry -btextro -bE:RHTgrAABB.export -bI:$(IDL_DIR)/external/idl.export" ;;\
       "Darwin") make RHTgrAABB \
			"X_CFLAGS= -no-cpp-precomp -dynamic -fPIC -fno-common -D_REENTRANT " \
			"CC = gcc"\
			"LD = gcc"\
			"X_LD_FLAGS= -flat_namespace -undefined suppress -bundle";;\
	   "HP-UX") make RHTgrAABB  \
			"SO_EXT= sl" \
			"X_CFLAGS=+z -Aa +e -D_HPUX_SOURCE" \
			"X_LD_FLAGS= -b -Brestricted +s" ;; \
	   "IRIX" )  make IDLtoC \
			"X_CFLAGS=-n32" \
		       "X_LD_FLAGS=-n32 -Bsymbolic -shared -all -rdata_shared" ;;\
	   "IRIX64" )  make RHTgrAABB \
			"X_CFLAGS=-n32" \
		       "X_LD_FLAGS=-n32 -Bsymbolic -shared -all -rdata_shared" ;;\
	   "OSF1" )  make RHTgrAABB \
			"X_CFLAGS=-float -kPIC" \
			"X_LD_FLAGS=-expect_unresolved '*' -shared -all" ;;\
	   "Linux" ) make RHTgrAABB \
			"X_CFLAGS= -fPIC" \
			"X_LD_FLAGS= -shared -Bsymbolic --warn-once" ;; \
	   *) echo "This system is not supported" ;; \
       esac


sunOS32 :
	if [ $(CC) = gcc ]; then \
            make RHTgrAABB "X_CFLAGS=-fPIC -m32" "X_LD_FLAGS=-shared" "LD=gcc"; \
	    #make RHTgrAABB "X_CFLAGS=-fPIC -m32 -mcpu=v9" "X_LD_FLAGS=-shared" "LD=gcc"; \
	else \
	    make RHTgrAABB "X_CFLAGS=-K pic" "X_LD_FLAGS=-B symbolic -z nodefs -G"; \
        fi \

sunOS64 :
	if [ $(CC) = gcc ]; then \
            make RHTgrAABB "X_CFLAGS=-fPIC -m64 -mcpu=v9" "X_LD_FLAGS=-shared -m64" "LD=gcc"; \
	else \
	    make RHTgrAABB "X_CFLAGS=-K pic -xtarget=ultra -xarch=v9" "X_LD_FLAGS=-B symbolic -z nodefs -G"; \
        fi \




# The following is the entry point for the recursive build

RHTgrAABB : RHTgrAABB.$(SO_EXT)
	@date

RHTgrAABB.$(SO_EXT) : RHTgrAABB.o
	 
	-$(LD) $(X_LD_FLAGS) -o RHTgrAABB.$(SO_EXT) RHTgrAABB.o 
		
# adding a separator and then above line makes most of the link warnings go away
# on linux		

clean : 
	rm -f *.o RHTgrAABB.so RHTgrAABB.sl RHTgrAABB.a \
		so_locations
