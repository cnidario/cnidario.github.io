---
title: Compilando GNU Assembler con emscripten
author: cnidario
date: 2019-12-07
---
[Emscripten](https://emscripten.org/) es un toolchain que permite compilar programas de C y C++ para el navegador.

Con él podemos:

- Compilar código C y C++ a Javascript o WebAssembly
- Compilar cualquier código que pueda ser traducido a LLVM bitcode a Javascript
- Compilar runtimes escritos en C/C++ de otros lenguajes y luego correr código en esos lenguajes de un modo indirecto (ej. Python, Lua)

En este post compilaremos el programa [GNU Assembler](https://ftp.gnu.org/old-gnu/Manuals/gas-2.9.1/html_node/as_3.html) de binutils para la plataforma ARM.

# Instalando emscripten

Clonamos el repo, instalamos las tools y las activamos 
``` {.console}
git clone https://github.com/juj/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source emsdk_env.sh
cd ..
```
# Compilación con emscripten

Emscripten se integra con los sistemas de build de [Make](https://www.gnu.org/software/make/) & [autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html) y [CMake](https://cmake.org/). Compila el código a LLVM bitcode 
para traducirlo después a Javascript. Introduce su propio runtime que abstraerá la funcionalidad estándar de C/C++.

El proceso para compilar GNU Assembler es el siguiente:
``` {.console}
wget http://ftp.gnu.org/gnu/binutils/binutils-2.33.1.tar.xz
tar -xf binutils-2.33.1.tar.xz
mkdir -p build
cd build
```
Binutils puede configurarse con 3 plataformas

  - *build* es donde se compila el programa
  - *host* es donde correrá
  - *target* es la plataforma para la que ensamblará, en nuestro caso ARM Linux

``` {.console}
emconfigure ../binutils-2.33.1/configure --disable-doc --build=x86 --host=wasm32 --target=arm-linux
emmake make -j4 CFLAGS="-DHAVE_PSIGNAL=1 -DELIDE_CODE -D__GNU_LIBRARY__"
mkdir -p ../root
emmake make install DESTDIR="$(pwd)/../root"
```
El último paso es compilar el LLVM bitcode a Javascript. Generando el fichero `as.js` para incluír en nuestro documento HTML.

Las opciones `--pre-js` y `--post-js` permiten introducir código custom entre la inicialización del runtime.
```{.console}
ln -s as ../root/usr/local/arm-linux/bin/as.bc
emcc ../root/usr/local/arm-linux/bin/as.bc -O3 -g3 -s FORCE_FILESYSTEM=1 -s MODULARIZE=1 -s 'EXPORT_NAME=AS' -o as.js --pre-js ../src/pre-js.js --post-js ../src/post-js.js
```
# Uso desde Javascript

Veamos el ejemplo mínimo:
```{.javascript}
AS().then(function(Module) {
    Module.FS.writeFile('input.s', '.section .text\n_start:\nmov r7, #0\n');
    Module.callMain(['-o', 'output.o', 'input.s']);
    var result = Module.FS.readFile('output.o');
});
```
- Instanciamos el módulo que devuelve una `Promise`
- Accedemos al sistema de ficheros virtual con `FS.writeFile` y `FS.readFile`.
- Llamamos al programa con el método `callMain([arg1, arg2, ...])`

`{{< iframe /extra/emscripten-gas-example.html >}}`

