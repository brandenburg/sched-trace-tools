ARCH=$(shell uname -m | sed -e s/i.86/i386/)

INC = -Iinclude/ -I../liblitmus2008/include -I../litmus2008/include

ifeq ($(ARCH),sparc64)
  CFLAGS= -Wall -pthread -mcpu=v9 -m64  -g ${INC}
else
  CFLAGS= -Wall -pthread -g ${INC}
endif

LITMUS_LIB = ../liblitmus2008/liblitmus.a

LIB = ${LITMUS_LIB}

.PHONY : all clean

vpath %.h include/
vpath %.c src/

APPS =  st2asy showst

all: ${APPS}

st2asy: st2asy.o ${LIB}
	gcc ${CFLAGS} -lpthread  -o st2asy st2asy.o ${LIB}

showst: showst.o ${LIB}
	gcc ${CFLAGS} -lpthread  -o showst showst.o ${LIB}

clean:
	rm -f *.o ${APPS}

