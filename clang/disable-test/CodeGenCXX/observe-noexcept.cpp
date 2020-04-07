// RUN: %clang_cc1 -triple  powerpc64le-unknown-unknown -std=c++11 -fexceptions -fcxx-exceptions -O0 -emit-llvm %s -o - | FileCheck %s

// Check that regions that install a terminate scope in the exception stack can
// correctly generate complex arithmetic.

// CHECK-LABEL: ffcomplex
void ffcomplex (int a) {
  double _Complex dc = (double)a;

  // CHECK: call { double, double } @__muldc3(double %{{.+}}, double %{{.+}}, double %{{.+}}, double %{{.+}})
  dc *= dc;
  // CHECK: ret void
}

// Check if we are observing the function pointer attribute regardless what is
// in the exception specification of the callees.
void fnoexcp(void) noexcept;

// CHECK-LABEL: foo
void foo(int a, int b) {

  void (*fptr)(void) noexcept = fnoexcp;
  // CHECK: ret void
}
