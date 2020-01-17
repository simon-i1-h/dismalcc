//===- include/Core/Instrumentation.h - Instrumentation API ---------------===//
//
//                             The LLVM Linker
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// Provide an Instrumentation API that optionally uses VTune interfaces.
///
//===----------------------------------------------------------------------===//

#ifndef LLD_CORE_INSTRUMENTATION_H
#define LLD_CORE_INSTRUMENTATION_H

#include "llvm/Support/Compiler.h"
#include <utility>

namespace lld {
class Domain {
public:
  Domain(const char *name) {}
};

class StringHandle {
public:
  StringHandle(const char *name) {}
};

class ScopedTask {
public:
  ScopedTask(const Domain &d, const StringHandle &s) {}
  void end() {}
};

class Marker {
public:
  Marker(const Domain &d, const StringHandle &s) {}
};

inline const Domain &getDefaultDomain() {
  static Domain domain("org.llvm.lld");
  return domain;
}
} // end namespace lld.

#endif
