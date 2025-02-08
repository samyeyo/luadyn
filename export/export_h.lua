-- NOTE: This file is modified from the standard distribution.
-- It now only generates a .c file with the needed table in it.

-- Configuration part
local files = { "./src/lua.h", "./src/lauxlib.h", "./src/lualib.h" }
local dstHfile = "./export/lua_dyn.h"
local dstCfile = "./export/lua_dyn.c"
local headerdef = "LUA_DYNAMIC_H"

local outfile = assert(io.open(dstHfile, "w"))
local function out(...)
	outfile:write(string.format(...))
end

local function suffix(name)
	if name:match("^lua_") then name = name:sub(5) 
	elseif name:match("^luaL_") then name = name:sub(6).."L" 
	else name = name:sub(4)
	end
	name = name:sub(1,1):upper() .. name:sub(2)
	return name
end

out('/* Lua language header file, designed for dynamic loading. \n')
out('   This file is not part of the standard distribution, but was\n')
out('   generated from original files %s */\n\n', table.concat(files, ', '))
out('#ifndef %s\n#define %s\n\n#ifdef __cplusplus\nextern "C" {\n#endif\n', headerdef, headerdef)

out [[
#include "src/luaconf.h"

#define LUA_PREFIX staticlua
]]

-- for k,v in pairs(conf_defines) do
-- 	out('#define %s %s\n', k, v)
-- end
local fcts = {}
for _,file in ipairs(files) do
	local f = assert(io.open(file, "r"))
	local data = f:read("*all")
	data = data:gsub("/%*%*%*.-%*%*%*/", function(a) out('\n%s\n',a) return "" end) -- exports copyright
	data = data:gsub("/%*.-%*/", "") -- remove comments to simplify parsing
	data = data:gsub('#include ".-\n', "") -- remove local includes
	data = data:gsub("^%s*#ifndef [%w_]+\n#define [%w_]+\n(.*)#endif%s*", "%1") -- removes header sentinel
	data = data:gsub("#if defined%(LUA_COMPAT_GETN%)\n(.-)#else\n(.-)#endif", 
		function (doif, doelse)
			if  conf_defines.LUA_COMPAT_GETN then return doif else return doelse end
		end)

	data = data:gsub("#if(.-)#endif", "")
	data = data:gsub("\n\n+", "\n\n") -- remove extra new lines 
	-- if conf_defines.LUA_COMPAT_OPENLIB then
	-- 	data = data:gsub("luaI_openlib", "luaL_openlib") -- remapped function: care!
	-- end
	-- Some function declarations lacks the extra parenthesis around their name
	data = data:gsub("(LUA_API%s[^%(%)%;]*)(lua_%w+)%s*(%([^%(%)]+%);)", "%1 (%2) %3")
	-- Detect external functions and transforms them into typedefs
	data = data:gsub("LUA%w*_API%s+([%w_%*%s]-)%s*%(([%w_]+)%)%s*%((.-)%);", 
		function (type,name,arg) 
			fcts[#fcts+1] = name
			return string.format("typedef %s (__cdecl *%s_t) (%s);", type, name, arg)
		end)
	out("%s", data)
	f:close()
end
table.sort(fcts)
for _,f in pairs(fcts) do
	out('#define %-23s LUA_PREFIX.%s\n', f, suffix(f))
end
out '\ntypedef struct lua_All_functions\n{\n'
for _,f in pairs(fcts) do
	out('  %-23s %s;\n', f.."_t", suffix(f))
end
-- Write footer (verbatim string)
out '} lua_All_functions;\n\n'
out 'extern int luaL_loadfunctions();\n'
out 'extern lua_All_functions staticlua;\n\n'

out '#ifdef __cplusplus\n}\n#endif\n\n'
outfile:close()

outfile = assert(io.open(dstCfile, "w"))
-- Write C loader function (verbatim)
out ([[
static const char* const LuaFunctionNames[] = 
{
	"%s"
};
]], table.concat(fcts, '",\n\t"'), "")
out("lua_All_functions staticlua;")
outfile:close()
