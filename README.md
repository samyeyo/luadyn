# Luadyn 🚀

**Luadyn** is a lightweight project that enables the use of Lua 5.4 interpreter on Windows platform without dependency on the `lua54.dll` library.

Luadyn achieves this by dynamically linking Lua functions at runtime for binary modules, providing greater flexibility and portability for Lua-based projects.
Whether you're embedding Lua in an application or distributing Lua modules, Luadyn simplifies the process by removing the need for the external `lua54.dll` library, while still being able to use binary modules, making your deployments cleaner and more self-contained.

---

## Features

- **No Dependency on Lua 5.4 Shared Library**: Luadyn eliminates the need for the `lua54.dll` library.
- **Lua binary modules support**: Lua binary modules are dynamically linked at runtime to the interpreter, providing flexibility and reducing the overhead of static linking (binary modules must be linked to `luadyn.lib` instead of `lua54.lib`)
- **Portable**: Luadyn makes it easier to distribute Lua-based applications or modules without worrying about external dependencies.
- **Compatible with Lua 5.4**: Fully compatible with Lua 5.4, ensuring you can leverage the latest features of the language.

---

## How It Works

Luadyn dynamically loads the Lua interpreter associated C functions at runtime, bypassing the need for the Lua 5.4 dynamic library. This is achieved through Windows-specific dynamic linking mechanisms. The Lua interpreter must be compiled with the `/DLUA_BUILD_AS_DLL` flag to export its functions.

By abstracting the dynamic linking process, Luadyn provides a seamless experience for running Lua scripts and modules in environments where the Lua shared library is not available.

---

## Installation

To use Luadyn, simply clone this repository and build the project in a `Visual Studio Native Tools Command Prompt` console :

```bash
git clone https://github.com/yourusername/luadyn.git
cd luadyn
nmake
```

The build process will generate the Lua interpreter (in the `.\bin` folder) and the library `luadyn.lib` (in the `.\lib` folder) to be linked to Lua binary modules instead of `lua54.lib`

---

### Loading Lua Binary Modules

Luadyn allows you to load Lua binary modules (e.g.`.dll` files) without the need of `lua54.dll`. Just link your binary module with  `luadyn.lib` instead of `lua54.lib`. 
To test Luadyn, you can  use the sample `calc.dll` module that can be compiled using :

```bash
nmake test
```

Then, enter the following command to use this module :

```bash
bin\lua -e "calc = require('calc'); print(calc.add(5, 5))"
```

If it outputs `10.0`, the binary module have been successfully loaded without the `lua54.dll` library.

---

## Why Use Luadyn?

- **Simplified Deployment**: Distribute Lua applications without worrying about `lua54.dll` dependencies.
- **Flexibility**: Dynamically link Lua at runtime, making it easier to adapt to different environments.
- **Lightweight**: Luadyn is designed to be minimal and efficient, adding no unnecessary overhead to your projects.

---

## License

Luadyn is released under the [MIT License](LICENSE). Feel free to use, modify, and distribute it as needed.

---

## Acknowledgments

- Thanks to Patrick Rapin for its work, on wich Luadyn is based (https://lua-users.org/wiki/EasyManualLibraryLoad)
