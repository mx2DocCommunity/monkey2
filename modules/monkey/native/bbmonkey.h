
#ifndef BB_MONKEY_H
#define BB_MONKEY_H

#include "bbstd.h"
#include "bbtypes.h"
#include "bbassert.h"
#include "bbmemory.h"
#include "bbstring.h"
#include "bbdebug.h"
#include "bbgc.h"
#include "bbarray.h"
#include "bbfunction.h"
#include "bbobject.h"
#include "bbinit.h"

extern int bb_argc;
extern char **bb_argv;

extern void bb_print( bbString str );

extern void bb_printf( const char *fmt,...);

template<class X,class Y> int bbCompare( X x,Y y ){
	if( y>x ) return -1;
	return x>y;
}

#endif
