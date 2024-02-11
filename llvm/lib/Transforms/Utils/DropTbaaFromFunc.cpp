//===-- DropTbaaFromFunc.cpp - Example Transformations --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/DropTbaaFromFunc.h"
#include "llvm/Support/CommandLine.h"
#include <string>

using namespace llvm;

cl::opt<std::string> DropTbaaFromFunc("drop-tbaa-from-func",
                                    llvm::cl::desc("Drop tbaa MD from all instructions in a function"),
                                    cl::init(""));

PreservedAnalyses DropTbaaFromFuncPass::run(Function &F,
                                      FunctionAnalysisManager &AM) {
  
  if (DropTbaaFromFunc.find(F.getName()) != std::string::npos) {
    for (BasicBlock& BB: F) {
      for (Instruction& I: BB) {
        I.eraseMetadata(LLVMContext::MD_tbaa);
      }
    }
  }
  return PreservedAnalyses::all();
}
