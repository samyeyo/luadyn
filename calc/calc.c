#include <lua_dyn.h>

// The add function
int add(lua_State *L) {
    // Get the two numbers from the Lua stack
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    
    // Push the result onto the Lua stack
    lua_pushnumber(L, a + b);
    
    // Return the number of results
    return 1;
}

// The list of functions to be registered
static const struct luaL_Reg mylib [] = {
    {"add", add},
    {NULL, NULL} 
};

__declspec(dllexport) int luaopen_calc(lua_State *L) {    
    luaL_newlib(L, mylib);
    return 1;
}