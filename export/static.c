#include "lua_dyn.h"
#include <windows.h>

#include "lua_dyn.c"

int luaL_loadfunctions() {
#ifdef WIN32
	void *hModule = (void*)GetModuleHandle(NULL);
#else
	void *hModule = NULL;
#endif
	int i;
	void** pfunctions = (void**)&staticlua;
	if(sizeof(LuaFunctionNames) != sizeof(staticlua) || hModule == NULL)
		return 0;
	for(i=0;i<sizeof(LuaFunctionNames) / sizeof(LuaFunctionNames[0]);i++)
	{
		pfunctions[i] = GetProcAddress((HMODULE)hModule, LuaFunctionNames[i]);
		if(pfunctions[i] == NULL)
			return 0;
	}
	return 1;
}

//-- Dynamic functions linking at init
static int __init(void) {
  luaL_loadfunctions();
  return 0;
}
typedef int(*_crt_cb)(void);
#ifdef _M_X64
  __pragma(comment(linker, "/include:" "_initu"))
  #pragma section(".CRT$XIU", long, read)
#else
  __pragma(comment(linker, "/include:" "_initu"))
#endif
#pragma data_seg(".CRT$XIU")
_crt_cb _initu[] = { &__init };
#pragma data_seg()
