# |-------------------------------------------------------------
# | luadyn - Lua without lua54 shared library dependency
# | Copyright (c) Tine Samir 2025
# | See Copyright Notice in LICENSE.TXT
# |-------------------------------------------------------------
# | Makefile for Microsoft Visual C++ compiler (Windows) 
# | Usage (default release build)			 : nmake
# | Usage (debug build) 		  			 : nmake debug
# | Usage (clean all)	 				 	 : nmake clean
# |-------------------------------------------------------------

#-- unset to get error message in non debug compilation
VERBOSE= >nul 2>&1

PLATFORM=

!if ([cl /? 2>&1 | findstr /C:"x86" > nul] == 0)
PLATFORM=x86
!else
PLATFORM=x64
!endif


#---- Configuration
RM= del /Q
CC= cl
LD= link
LB = lib

!if "$(PLATFORM)" == "x64"
_ARCH = x64
!else
_ARCH = x86
!endif

#---- Source files
LUA_LIB=	lib\luadyn.lib
LUA_O=		src\lapi.obj src\lcode.obj src\lctype.obj src\ldebug.obj src\ldo.obj src\ldump.obj src\lfunc.obj src\lgc.obj src\llex.obj src\lmem.obj src\lobject.obj src\lopcodes.obj src\lparser.obj src\lstate.obj src\lstring.obj src\ltable.obj src\ltm.obj src\lundump.obj src\lvm.obj src\lzio.obj	src\linit.obj
LIB_O=		src\lauxlib.obj src\lbaselib.obj src\lcorolib.obj src\ldblib.obj src\lmathlib.obj src\loadlib.obj src\ltablib.obj src\lstrlib.obj src\liolib.obj src\loslib.obj src\lutf8lib.obj

BASE_O= 	$(LUA_O) $(LIB_O)

#--- Compiler flags

!if "$(BUILD)" == "debug"
CFLAGS = /nologo /DLUA_BUILD_AS_DLL /MD /DLUA_COMPAT_5_3 /I"." /Z7
VERBOSE= 
PROGRESS=
!else
CFLAGS = /nologo /DLUA_BUILD_AS_DLL /DLUA_COMPAT_5_3 /I"." /MD /Gy /GF /Oi /O1 /GA
PROGRESS= "■"
!endif

LIBFLAGS= /out:$(LUA_LIB)

all: static

default: static

debug:
	@$(MAKE) /nologo "BUILD=debug"

infolua:
	@echo|set /p dummy="▸  Building luadyn                 "

.c.obj:
	@$(CC) $(CFLAGS) /c /Fo$@ $< $(VERBOSE)
	@echo|set /p dummy=$(PROGRESS)

bin\lua.exe: infolua $(BASE_O)
	@$(CC) $(CFLAGS) src\lua.c $(BASE_O) /Fe:bin\lua.exe /link /ignore:4217 $(VERBOSE)
	@-$(RM) lua.obj >nul 2>&1
	@-$(RM) bin\lua.exp >nul 2>&1
	@-$(RM) bin\*.lib >nul 2>&1

export: bin\lua.exe
	@bin\lua.exe export\export_h.lua $(VERBOSE)

static: export
	@cmd /c echo.
	@echo|set /p dummy="▸  Building static luadyn.lib      "
	@$(CC) /c export\static.c $(CFLAGS) /Foexport\static.obj $(VERBOSE)
	@echo|set /p dummy=$(PROGRESS)
	@$(LB) $(BASE_O) export\static.obj $(LIBFLAGS) $(VERBOSE)
	@echo|set /p dummy=$(PROGRESS)

test: static
	@cmd /c echo.
	@echo|set /p dummy="▸  Building DLL test module        "
	@-$(CC) $(CFLAGS) /LD /I"./export/" calc\calc.c lib\luadyn.lib /link /ignore:4217 $(VERBOSE)
	@echo|set /p dummy=$(PROGRESS)
	@-$(RM) *.pdb >nul 2>&1
	@-$(RM) *.ilk >nul 2>&1
	@-$(RM) *.exp >nul 2>&1
	@-$(RM) *.obj >nul 2>&1
	@-$(RM) *.lib >nul 2>&1
	@cmd /c echo.
	
clean:
	@chcp 65001 >nul 2>&1
	@echo|set /p dummy="▸  Cleaning luadyn... "
	@-$(RM) $(BASE_O) >nul 2>&1
	@-$(RM) $(LUA_LIB) >nul 2>&1
	@-$(RM) export\lua_dyn.* >nul 2>&1 
	@-$(RM) export\static.obj >nul 2>&1
	@-$(RM) src\lua.exe >nul 2>&1
	@-$(RM) src\lua.obj >nul 2>&1
	@-$(RM) *.dll >nul 2>&1
	@-$(RM) *.obj >nul 2>&1
	@-$(RM) *.lib >nul 2>&1
	@-$(RM) *.exp >nul 2>&1
	@echo ✓