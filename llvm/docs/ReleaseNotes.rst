========================
LLVM 8.0.0 Release Notes
========================

.. contents::
    :local:

.. warning::
   These are in-progress notes for the upcoming LLVM 8 release.
   Release notes for previous releases can be found on
   `the Download Page <https://releases.llvm.org/download.html>`_.


Introduction
============

This document contains the release notes for the LLVM Compiler Infrastructure,
release 8.0.0.  Here we describe the status of LLVM, including major improvements
from the previous release, improvements in various subprojects of LLVM, and
some of the current users of the code.  All LLVM releases may be downloaded
from the `LLVM releases web site <https://llvm.org/releases/>`_.

For more information about LLVM, including information about the latest
release, please check out the `main LLVM web site <https://llvm.org/>`_.  If you
have questions or comments, the `LLVM Developer's Mailing List
<https://lists.llvm.org/mailman/listinfo/llvm-dev>`_ is a good place to send
them.

Note that if you are reading this file from a Subversion checkout or the main
LLVM web page, this document applies to the *next* release, not the current
one.  To see the release notes for a specific release, please see the `releases
page <https://llvm.org/releases/>`_.

Non-comprehensive list of changes in this release
=================================================
.. NOTE
   For small 1-3 sentence descriptions, just add an entry at the end of
   this list. If your description won't fit comfortably in one bullet
   point (e.g. maybe you would like to give an example of the
   functionality, or simply have a lot to talk about), see the `NOTE` below
   for adding a new subsection.

* The **llvm-cov** tool can now export lcov trace files using the
  `-format=lcov` option of the `export` command.

* The add_llvm_loadable_module CMake macro has been removed.  The
  add_llvm_library macro with the MODULE argument now provides the same
  functionality.  See `Writing an LLVM Pass
  <WritingAnLLVMPass.html#setting-up-the-build-environment>`_.

* For MinGW, references to data variables that might need to be imported
  from a dll are accessed via a stub, to allow the linker to convert it to
  a dllimport if needed.

* Added support for labels as offsets in ``.reloc`` directive.

.. NOTE
   If you would like to document a larger change, then you can add a
   subsection about it right here. You can copy the following boilerplate
   and un-indent it (the indentation causes it to be inside this comment).

   Special New Feature
   -------------------

   Makes programs 10x faster by doing Special New Thing.

Changes to the LLVM IR
----------------------


Changes to the AArch64 Target
-----------------------------

* Added support for the ``.arch_extension`` assembler directive, just like
  on ARM.


Changes to the ARM Backend
--------------------------

 During this release ...


Changes to the Hexagon Target
-----------------------------

* Added support for Hexagon/HVX V66 ISA.

Changes to the MIPS Target
--------------------------

* Improved support of GlobalISel instruction selection framework.

* Implemented emission of ``R_MIPS_JALR`` and ``R_MICROMIPS_JALR``
  relocations. These relocations provide hints to a linker for optimization
  of jumps to protected symbols.

* ORC JIT has been supported for MIPS and MIPS64 architectures.

* Assembler now suggests alternative MIPS instruction mnemonics when
  an invalid one is specified.

* Improved support for MIPS N32 ABI.

* Added new instructions (``pll.ps``, ``plu.ps``, ``cvt.s.pu``,
  ``cvt.s.pl``, ``cvt.ps``, ``sigrie``).

* Numerous bug fixes and code cleanups.

Changes to the PowerPC Target
-----------------------------

 During this release ...

Changes to the X86 Target
-------------------------

* Machine model for AMD bdver2 (Piledriver) CPU was added. It is used to support
  instruction scheduling and other instruction cost heuristics.

Changes to the AMDGPU Target
-----------------------------

 During this release ...

Changes to the AVR Target
-----------------------------

 During this release ...

Changes to the WebAssembly Target
---------------------------------

The WebAssembly target is no longer "experimental"! It's now built by default,
rather than needing to be enabled with LLVM_EXPERIMENTAL_TARGETS_TO_BUILD.

The object file format and core C ABI are now considered stable. That said,
the object file format has an ABI versioning capability, and one anticipated
use for it will be to add support for returning small structs as multiple
return values, once the underlying WebAssembly platform itself supports it.
Additionally, multithreading support is not yet included in the stable ABI.


Changes to the OCaml bindings
-----------------------------



Changes to the C API
--------------------


Changes to the DAG infrastructure
---------------------------------

External Open Source Projects Using LLVM 8
==========================================

LDC - the LLVM-based D compiler
-------------------------------

`D <http://dlang.org>`_ is a language with C-like syntax and static typing. It
pragmatically combines efficiency, control, and modeling power, with safety and
programmer productivity. D supports powerful concepts like Compile-Time Function
Execution (CTFE) and Template Meta-Programming, provides an innovative approach
to concurrency and offers many classical paradigms.

`LDC <http://wiki.dlang.org/LDC>`_ uses the frontend from the reference compiler
combined with LLVM as backend to produce efficient native code. LDC targets
x86/x86_64 systems like Linux, OS X, FreeBSD and Windows and also Linux on ARM
and PowerPC (32/64 bit). Ports to other architectures like AArch64 and MIPS64
are underway.

Zig Programming Language
------------------------

`Zig <https://ziglang.org>`_  is a system programming language intended to be
an alternative to C. It provides high level features such as generics, compile
time function execution, and partial evaluation, while exposing low level LLVM
IR features such as aliases and intrinsics. Zig uses Clang to provide automatic
import of .h symbols, including inline functions and simple macros. Zig uses
LLD combined with lazily building compiler-rt to provide out-of-the-box
cross-compiling for all supported targets.


Additional Information
======================

A wide variety of additional information is available on the `LLVM web page
<https://llvm.org/>`_, in particular in the `documentation
<https://llvm.org/docs/>`_ section.  The web page also contains versions of the
API documentation which is up-to-date with the Subversion version of the source
code.  You can access versions of these documents specific to this release by
going into the ``llvm/docs/`` directory in the LLVM tree.

If you have any questions or comments about LLVM, please feel free to contact
us via the `mailing lists <https://llvm.org/docs/#mailing-lists>`_.
