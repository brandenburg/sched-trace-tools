# #####################################################################
# User configuration.
# -- Nothing to configure at the moment.

# #####################################################################
# Internal configuration.
DEBUG_FLAGS  = '-Wall -g -Wdeclaration-after-statement'
INCLUDE_DIRS = 'include/'
# #####################################################################
# Build configuration.
from os import uname

# sanity check
(os, _, _, _, arch) = uname()
if os != 'Linux':
    print 'Error: Building sched_trace tools is only supported on Linux.'
    Exit(1)

# base config
env = Environment(
    CC = 'gcc',
    CCFLAGS = Split(DEBUG_FLAGS),
    CPPPATH = Split(INCLUDE_DIRS),
)

# Link with libcairo. For now without sched_trace support.
cairo = env.Clone()
cairo.ParseConfig('pkg-config --cflags --libs cairo')

# #####################################################################
# Targets: sched_trace tools
common = ['src/load.c', 'src/eheap.c', 'src/util.c']
env.Program('st_convert', ['src/st2pl.c'] + common)
env.Program('st_show', ['src/showst.c'] + common)

cairo.Program('cairo_test', ['src/cairo_test.c'])
