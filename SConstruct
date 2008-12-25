# #####################################################################
# User configuration.
LITMUS_KERNEL = '../litmus2008'
LIBLITMUS     = '../liblitmus2008'

# #####################################################################
# Internal configuration.
DEBUG_FLAGS  = '-Wall -g -Wdeclaration-after-statement'
INCLUDE_DIRS = 'include/  %s/include/ %s/include/' % (LITMUS_KERNEL, LIBLITMUS)

# #####################################################################
# Build configuration.
from os import uname

# sanity check
(os, _, _, _, arch) = uname()
if os != 'Linux':
    print 'Error: Building sched_trace tools is only supported on Linux.'
    Exit(1)

if arch not in ('sparc64', 'i686'):
    print 'Error: Building sched_trace tools is only supported on i686 and sparc64.'
    Exit(1)

st = Environment(
    CC = 'gcc',
    CPPPATH = Split(INCLUDE_DIRS),
    CCFLAGS = Split(DEBUG_FLAGS),
    LIBS    =  'st',
    LIBPATH = LIBLITMUS
)

if arch == 'sparc64':
    # build 64 bit sparc v9 binaries
    v9 = Split('-mcpu=v9 -m64')
    st.Append(CCFLAGS = v9, LINKFLAGS = v9)

# #####################################################################
# Targets: sched_trace tools
common = ['src/load.c', 'src/eheap.c']
st.Program('st_convert', ['src/st2pl.c'] + common)
st.Program('st_show', ['src/showst.c'] + common)
