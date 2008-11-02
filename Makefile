ARCH=$(shell uname -m | sed -e s/i.86/i386/)

INC = -Iinclude/ -I../liblitmus2008/include -I../litmus2008/include

ifeq ($(ARCH),sparc64)
  CFLAGS= -Wall -pthread -mcpu=v9 -m64  -g ${INC}
else
  CFLAGS= -Wall -pthread -g ${INC}
endif

LITMUS_LIB = ../liblitmus2008/liblitmus.a

LIB = eheap.o load.o ${LITMUS_LIB}

.PHONY : all clean

vpath %.h include/
vpath %.c src/

APPS =  st2asy st2pl showst

all: ${APPS}

st2asy: st2asy.o ${LIB}
	gcc ${CFLAGS}  -o st2asy st2asy.o ${LIB}

st2pl: st2pl.o ${LIB}
	gcc ${CFLAGS}  -o st2pl st2pl.o ${LIB}

showst: showst.o eheap.o load.o ${LIB}
	gcc ${CFLAGS}  -o showst showst.o ${LIB}

clean:
	rm -f *.o ${APPS}

