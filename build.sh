#!/bin/sh -ex

DIR=build

cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PROJECTS="llvm;clang;lld" -DLLVM_BINUTILS_INCDIR=/usr/include -S ./llvm -B $DIR 
ninja -C $DIR

