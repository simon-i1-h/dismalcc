cmake_minimum_required(VERSION 3.4.3)

if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()

set(BACKEND_PACKAGE_STRING "${PACKAGE_STRING}")

# Make sure that our source directory is on the current cmake module path so that
# we can include cmake files from this directory.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

if(LLVM_ENABLE_LIBXML2)
  # Don't look for libxml if we're using MSan, since uninstrumented third party
  # code may call MSan interceptors like strlen, leading to false positives.
  if(NOT LLVM_USE_SANITIZER MATCHES "Memory.*")
    set (LIBXML2_FOUND 0)
    find_package(LibXml2 2.5.3 QUIET)
    if (LIBXML2_FOUND)
      set(CLANG_HAVE_LIBXML 1)
    endif()
  endif()
endif()

include(CheckIncludeFile)
check_include_file(sys/resource.h CLANG_HAVE_RLIMITS)

set(CLANG_RESOURCE_DIR "" CACHE STRING
  "Relative directory from the Clang binary to its resource files.")

set(C_INCLUDE_DIRS "" CACHE STRING
  "Colon separated list of directories clang will search for headers.")

set(GCC_INSTALL_PREFIX "" CACHE PATH "Directory where gcc is installed." )
set(DEFAULT_SYSROOT "" CACHE PATH
  "Default <path> to all compiler invocations for --sysroot=<path>." )

set(ENABLE_LINKER_BUILD_ID OFF CACHE BOOL "pass --build-id to ld")

set(ENABLE_X86_RELAX_RELOCATIONS OFF CACHE BOOL
    "enable x86 relax relocations by default")

set(ENABLE_EXPERIMENTAL_NEW_PASS_MANAGER FALSE CACHE BOOL
  "Enable the experimental new pass manager by default.")

# TODO: verify the values against LangStandards.def?
set(CLANG_DEFAULT_STD_C "" CACHE STRING
  "Default standard to use for C/ObjC code (IDENT from LangStandards.def, empty for platform default)")
set(CLANG_DEFAULT_STD_CXX "" CACHE STRING
  "Default standard to use for C++/ObjC++ code (IDENT from LangStandards.def, empty for platform default)")

set(CLANG_DEFAULT_LINKER "" CACHE STRING
  "Default linker to use (linker name or absolute path, empty for platform default)")

set(CLANG_DEFAULT_CXX_STDLIB "" CACHE STRING
  "Default C++ stdlib to use (\"libstdc++\" or \"libc++\", empty for platform default")
if (NOT(CLANG_DEFAULT_CXX_STDLIB STREQUAL "" OR
        CLANG_DEFAULT_CXX_STDLIB STREQUAL "libstdc++" OR
        CLANG_DEFAULT_CXX_STDLIB STREQUAL "libc++"))
  message(WARNING "Resetting default C++ stdlib to use platform default")
  set(CLANG_DEFAULT_CXX_STDLIB "" CACHE STRING
    "Default C++ stdlib to use (\"libstdc++\" or \"libc++\", empty for platform default" FORCE)
endif()

set(CLANG_DEFAULT_RTLIB "" CACHE STRING
  "Default runtime library to use (\"libgcc\" or \"compiler-rt\", empty for platform default)")
if (NOT(CLANG_DEFAULT_RTLIB STREQUAL "" OR
        CLANG_DEFAULT_RTLIB STREQUAL "libgcc" OR
        CLANG_DEFAULT_RTLIB STREQUAL "compiler-rt"))
  message(WARNING "Resetting default rtlib to use platform default")
  set(CLANG_DEFAULT_RTLIB "" CACHE STRING
    "Default runtime library to use (\"libgcc\" or \"compiler-rt\", empty for platform default)" FORCE)
endif()

set(CLANG_DEFAULT_OBJCOPY "objcopy" CACHE STRING
  "Default objcopy executable to use.")

set(CLANG_DEFAULT_OPENMP_RUNTIME "libomp" CACHE STRING
  "Default OpenMP runtime used by -fopenmp.")

# OpenMP offloading requires at least sm_35 because we use shuffle instructions
# to generate efficient code for reductions and the atomicMax instruction on
# 64-bit integers in the implementation of conditional lastprivate.
set(CLANG_OPENMP_NVPTX_DEFAULT_ARCH "sm_35" CACHE STRING
  "Default architecture for OpenMP offloading to Nvidia GPUs.")
string(REGEX MATCH "^sm_([0-9]+)$" MATCHED_ARCH "${CLANG_OPENMP_NVPTX_DEFAULT_ARCH}")
if (NOT DEFINED MATCHED_ARCH OR "${CMAKE_MATCH_1}" LESS 35)
  message(WARNING "Resetting default architecture for OpenMP offloading to Nvidia GPUs to sm_35")
  set(CLANG_OPENMP_NVPTX_DEFAULT_ARCH "sm_35" CACHE STRING
    "Default architecture for OpenMP offloading to Nvidia GPUs." FORCE)
endif()

set(CLANG_VENDOR ${PACKAGE_VENDOR} CACHE STRING
  "Vendor-specific text for showing with version information.")

if( CLANG_VENDOR )
  add_definitions( -DCLANG_VENDOR="${CLANG_VENDOR} " )
endif()

set(CLANG_REPOSITORY_STRING "" CACHE STRING
  "Vendor-specific text for showing the repository the source is taken from.")

if(CLANG_REPOSITORY_STRING)
  add_definitions(-DCLANG_REPOSITORY_STRING="${CLANG_REPOSITORY_STRING}")
endif()

set(CLANG_VENDOR_UTI "org.llvm.clang" CACHE STRING
  "Vendor-specific uti.")

# The libdir suffix must exactly match whatever LLVM's configuration used.
set(CLANG_LIBDIR_SUFFIX "${LLVM_LIBDIR_SUFFIX}")

set(CLANG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(CLANG_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

if( CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR AND NOT MSVC_IDE )
  message(FATAL_ERROR "In-source builds are not allowed. "
"Please create a directory and run cmake "
"from there, passing the path to this source directory as the last argument. "
"This process created the file `CMakeCache.txt' and the directory "
"`CMakeFiles'. Please delete them.")
endif()

# If CLANG_VERSION_* is specified, use it, if not use LLVM_VERSION_*.
if(NOT DEFINED CLANG_VERSION_MAJOR)
  set(CLANG_VERSION_MAJOR ${LLVM_VERSION_MAJOR})
endif()
if(NOT DEFINED CLANG_VERSION_MINOR)
  set(CLANG_VERSION_MINOR ${LLVM_VERSION_MINOR})
endif()
if(NOT DEFINED CLANG_VERSION_PATCHLEVEL)
  set(CLANG_VERSION_PATCHLEVEL ${LLVM_VERSION_PATCH})
endif()
# Unlike PACKAGE_VERSION, CLANG_VERSION does not include LLVM_VERSION_SUFFIX.
set(CLANG_VERSION "${CLANG_VERSION_MAJOR}.${CLANG_VERSION_MINOR}.${CLANG_VERSION_PATCHLEVEL}")
message(STATUS "Clang version: ${CLANG_VERSION}")

# Configure the Version.inc file.
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/include/clang/Basic/Version.inc.in
  ${CMAKE_CURRENT_BINARY_DIR}/include/clang/Basic/Version.inc)

# Add appropriate flags for GCC
if (LLVM_COMPILER_IS_GCC_COMPATIBLE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common -Woverloaded-virtual")
  if (NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")
  endif ()

  # Enable -pedantic for Clang even if it's not enabled for LLVM.
  if (NOT LLVM_ENABLE_PEDANTIC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic -Wno-long-long")
  endif ()

  check_cxx_compiler_flag("-Werror -Wnested-anon-types" CXX_SUPPORTS_NO_NESTED_ANON_TYPES_FLAG)
  if( CXX_SUPPORTS_NO_NESTED_ANON_TYPES_FLAG )
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-nested-anon-types" )
  endif()
endif ()

include(CMakeParseArguments)
include(AddClang)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

include_directories(BEFORE
  ${CMAKE_CURRENT_BINARY_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  )

if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)
  install(DIRECTORY include/clang include/clang-c
    DESTINATION include
    FILES_MATCHING
    PATTERN "*.def"
    PATTERN "*.h"
    PATTERN "config.h" EXCLUDE
    PATTERN ".svn" EXCLUDE
    )

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/clang
    DESTINATION include
    FILES_MATCHING
    PATTERN "CMakeFiles" EXCLUDE
    PATTERN "*.inc"
    PATTERN "*.h"
    )

  install(PROGRAMS utils/bash-autocomplete.sh
    DESTINATION share/clang
    )
endif()

add_definitions( -D_GNU_SOURCE )

option(CLANG_BUILD_TOOLS
  "Build the Clang tools. If OFF, just generate build targets." ON)

option(CLANG_ENABLE_PROTO_FUZZER "Build Clang protobuf fuzzer." OFF)

# Clang version information
set(CLANG_EXECUTABLE_VERSION
    "${CLANG_VERSION_MAJOR}" CACHE STRING
    "Major version number that will be appended to the clang executable name")
set(LIBCLANG_LIBRARY_VERSION
    "${CLANG_VERSION_MAJOR}" CACHE STRING
    "Major version number that will be appended to the libclang library")
mark_as_advanced(CLANG_EXECUTABLE_VERSION LIBCLANG_LIBRARY_VERSION)

option(CLANG_INCLUDE_TESTS
       "Generate build targets for the Clang unit tests."
       ${LLVM_INCLUDE_TESTS})

add_subdirectory(utils/TableGen)

add_subdirectory(include)

# All targets below may depend on all tablegen'd files.
get_property(CLANG_TABLEGEN_TARGETS GLOBAL PROPERTY CLANG_TABLEGEN_TARGETS)
add_custom_target(clang-tablegen-targets DEPENDS ${CLANG_TABLEGEN_TARGETS})
set_target_properties(clang-tablegen-targets PROPERTIES FOLDER "Misc")
list(APPEND LLVM_COMMON_DEPENDS clang-tablegen-targets)

# Force target to be built as soon as possible. Clang modules builds depend
# header-wise on it as they ship all headers from the umbrella folders. Building
# an entire module might include header, which depends on intrinsics_gen.
if(LLVM_ENABLE_MODULES AND NOT CLANG_BUILT_STANDALONE)
  list(APPEND LLVM_COMMON_DEPENDS intrinsics_gen)
endif()

add_subdirectory(lib)
add_subdirectory(tools)
add_subdirectory(runtime)

if( CLANG_INCLUDE_TESTS )
  add_subdirectory(unittests)
  list(APPEND CLANG_TEST_DEPS ClangUnitTests)
  list(APPEND CLANG_TEST_PARAMS
    clang_unit_site_config=${CMAKE_CURRENT_BINARY_DIR}/test/Unit/lit.site.cfg
    )
  add_subdirectory(test)

  if(CLANG_BUILT_STANDALONE)
    # Add a global check rule now that all subdirectories have been traversed
    # and we know the total set of lit testsuites.
    get_property(LLVM_LIT_TESTSUITES GLOBAL PROPERTY LLVM_LIT_TESTSUITES)
    get_property(LLVM_LIT_PARAMS GLOBAL PROPERTY LLVM_LIT_PARAMS)
    get_property(LLVM_LIT_DEPENDS GLOBAL PROPERTY LLVM_LIT_DEPENDS)
    get_property(LLVM_LIT_EXTRA_ARGS GLOBAL PROPERTY LLVM_LIT_EXTRA_ARGS)
    get_property(LLVM_ADDITIONAL_TEST_TARGETS
                 GLOBAL PROPERTY LLVM_ADDITIONAL_TEST_TARGETS)
    add_lit_target(check-all
      "Running all regression tests"
      ${LLVM_LIT_TESTSUITES}
      PARAMS ${LLVM_LIT_PARAMS}
      DEPENDS ${LLVM_LIT_DEPENDS} ${LLVM_ADDITIONAL_TEST_TARGETS}
      ARGS ${LLVM_LIT_EXTRA_ARGS}
      )
  endif()
  add_subdirectory(utils/perf-training)
endif()

option(CLANG_INCLUDE_DOCS "Generate build targets for the Clang docs."
  ${LLVM_INCLUDE_DOCS})
if( CLANG_INCLUDE_DOCS )
  add_subdirectory(docs)
endif()

add_subdirectory(cmake/modules)

if(CLANG_STAGE)
  message(STATUS "Setting current clang stage to: ${CLANG_STAGE}")
endif()

if (CLANG_ENABLE_BOOTSTRAP)
  include(ExternalProject)

  add_custom_target(clang-bootstrap-deps DEPENDS clang)

  if(NOT CLANG_STAGE)
    set(CLANG_STAGE stage1)
  endif()

  string(REGEX MATCH "stage([0-9]*)" MATCHED_STAGE "${CLANG_STAGE}")
  if(MATCHED_STAGE)
    if(NOT LLVM_BUILD_INSTRUMENTED)
      math(EXPR STAGE_NUM "${CMAKE_MATCH_1} + 1")
      set(NEXT_CLANG_STAGE stage${STAGE_NUM})
    else()
      set(NEXT_CLANG_STAGE stage${CMAKE_MATCH_1})
    endif()
  else()
    set(NEXT_CLANG_STAGE bootstrap)
  endif()

  if(BOOTSTRAP_LLVM_BUILD_INSTRUMENTED)
    set(NEXT_CLANG_STAGE ${NEXT_CLANG_STAGE}-instrumented)
  endif()
  message(STATUS "Setting next clang stage to: ${NEXT_CLANG_STAGE}")


  set(STAMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/${NEXT_CLANG_STAGE}-stamps/)
  set(BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${NEXT_CLANG_STAGE}-bins/)

  if(BOOTSTRAP_LLVM_ENABLE_LLD)
    add_dependencies(clang-bootstrap-deps lld)
  endif()

  # If the next stage is LTO we need to depend on LTO and possibly lld or LLVMgold
  if(BOOTSTRAP_LLVM_ENABLE_LTO OR LLVM_ENABLE_LTO AND NOT LLVM_BUILD_INSTRUMENTED)
    if(APPLE)
      add_dependencies(clang-bootstrap-deps LTO)
      # on Darwin we need to set DARWIN_LTO_LIBRARY so that -flto will work
      # using the just-built compiler, and we need to override DYLD_LIBRARY_PATH
      # so that the host object file tools will use the just-built libLTO.
      # However if System Integrity Protection is enabled the DYLD variables
      # will be scrubbed from the environment of any base system commands. This
      # includes /bin/sh, which ninja uses when executing build commands. To
      # work around the envar being filtered away we pass it in as a CMake
      # variable, and have LLVM's CMake append the envar to the archiver calls.
      set(LTO_LIBRARY -DDARWIN_LTO_LIBRARY=${LLVM_SHLIB_OUTPUT_INTDIR}/libLTO.dylib
        -DDYLD_LIBRARY_PATH=${LLVM_LIBRARY_OUTPUT_INTDIR})
    elseif(NOT WIN32)
      add_dependencies(clang-bootstrap-deps llvm-ar llvm-ranlib)
      if(NOT BOOTSTRAP_LLVM_ENABLE_LLD AND LLVM_BINUTILS_INCDIR)
        add_dependencies(clang-bootstrap-deps LLVMgold)
      endif()
      set(${CLANG_STAGE}_AR -DCMAKE_AR=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-ar)
      set(${CLANG_STAGE}_RANLIB -DCMAKE_RANLIB=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-ranlib)
    endif()
  endif()

  if(CLANG_BOOTSTRAP_EXTRA_DEPS)
    add_dependencies(clang-bootstrap-deps ${CLANG_BOOTSTRAP_EXTRA_DEPS})
  endif()

  add_custom_target(${NEXT_CLANG_STAGE}-clear
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${NEXT_CLANG_STAGE}-cleared
    )
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${NEXT_CLANG_STAGE}-cleared
    DEPENDS clang-bootstrap-deps
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${STAMP_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAMP_DIR}
    COMMENT "Clobberring ${NEXT_CLANG_STAGE} build and stamp directories"
    )

  if(CMAKE_VERBOSE_MAKEFILE)
    set(verbose -DCMAKE_VERBOSE_MAKEFILE=On)
  endif()

  set(_BOOTSTRAP_DEFAULT_PASSTHROUGH
    PACKAGE_VERSION
    PACKAGE_VENDOR
    LLVM_VERSION_MAJOR
    LLVM_VERSION_MINOR
    LLVM_VERSION_PATCH
    CLANG_VERSION_MAJOR
    CLANG_VERSION_MINOR
    CLANG_VERSION_PATCHLEVEL
    LLVM_VERSION_SUFFIX
    LLVM_BINUTILS_INCDIR
    CLANG_REPOSITORY_STRING
    CMAKE_MAKE_PROGRAM
    CMAKE_OSX_ARCHITECTURES
    LLVM_ENABLE_PROJECTS
    LLVM_ENABLE_RUNTIMES)

  # We don't need to depend on compiler-rt/libcxx if we're building instrumented
  # because the next stage will use the same compiler used to build this stage.
  if(NOT LLVM_BUILD_INSTRUMENTED)
    if(TARGET compiler-rt)
      add_dependencies(clang-bootstrap-deps compiler-rt)
    endif()
    if(TARGET cxx-headers)
      add_dependencies(clang-bootstrap-deps cxx-headers)
    endif()
  endif()

  set(C_COMPILER "clang")
  set(CXX_COMPILER "clang++")

  set(COMPILER_OPTIONS
    -DCMAKE_CXX_COMPILER=${LLVM_RUNTIME_OUTPUT_INTDIR}/${CXX_COMPILER}
    -DCMAKE_C_COMPILER=${LLVM_RUNTIME_OUTPUT_INTDIR}/${C_COMPILER}
    -DCMAKE_ASM_COMPILER=${LLVM_RUNTIME_OUTPUT_INTDIR}/${C_COMPILER}
    -DCMAKE_ASM_COMPILER_ID=Clang)

  if(BOOTSTRAP_CMAKE_SYSTEM_NAME)
    set(${CLANG_STAGE}_CONFIG -DLLVM_CONFIG_PATH=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-config)
    set(${CLANG_STAGE}_TABLEGEN
      -DLLVM_TABLEGEN=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-tblgen
      -DCLANG_TABLEGEN=${LLVM_RUNTIME_OUTPUT_INTDIR}/clang-tblgen)
    if(BOOTSTRAP_CMAKE_SYSTEM_NAME STREQUAL "Linux")
      if(BOOTSTRAP_LLVM_ENABLE_LLD)
        set(${CLANG_STAGE}_LINKER -DCMAKE_LINKER=${LLVM_RUNTIME_OUTPUT_INTDIR}/ld.lld)
      endif()
      if(NOT BOOTSTRAP_LLVM_ENABLE_LTO)
        add_dependencies(clang-bootstrap-deps llvm-ar llvm-ranlib)
        set(${CLANG_STAGE}_AR -DCMAKE_AR=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-ar)
        set(${CLANG_STAGE}_RANLIB -DCMAKE_RANLIB=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-ranlib)
      endif()
      add_dependencies(clang-bootstrap-deps llvm-objcopy llvm-strip)
      set(${CLANG_STAGE}_OBJCOPY -DCMAKE_OBJCOPY=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-objcopy)
      set(${CLANG_STAGE}_STRIP -DCMAKE_STRIP=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-strip)
    endif()
  endif()

  if(BOOTSTRAP_LLVM_BUILD_INSTRUMENTED)
    add_dependencies(clang-bootstrap-deps llvm-profdata)
    set(PGO_OPT -DLLVM_PROFDATA=${LLVM_RUNTIME_OUTPUT_INTDIR}/llvm-profdata)
  endif()

  if(LLVM_BUILD_INSTRUMENTED)
    add_dependencies(clang-bootstrap-deps generate-profdata)
    set(PGO_OPT -DLLVM_PROFDATA_FILE=${CMAKE_CURRENT_BINARY_DIR}/utils/perf-training/clang.profdata)
    # Use the current tools for LTO instead of the instrumented ones
    list(APPEND _BOOTSTRAP_DEFAULT_PASSTHROUGH
      CMAKE_CXX_COMPILER
      CMAKE_C_COMPILER
      CMAKE_ASM_COMPILER
      CMAKE_AR
      CMAKE_RANLIB
      DARWIN_LTO_LIBRARY
      DYLD_LIBRARY_PATH)

    set(COMPILER_OPTIONS)
    set(LTO_LIBRARY)
    set(LTO_AR)
    set(LTO_RANLIB)
  endif()

  # Find all variables that start with BOOTSTRAP_ and populate a variable with
  # them.
  get_cmake_property(variableNames VARIABLES)
  foreach(variableName ${variableNames})
    if(variableName MATCHES "^BOOTSTRAP_")
      string(SUBSTRING ${variableName} 10 -1 varName)
      string(REPLACE ";" "|" value "${${variableName}}")
      list(APPEND PASSTHROUGH_VARIABLES
        -D${varName}=${value})
    endif()
    if(${variableName} AND variableName MATCHES "LLVM_EXTERNAL_.*_SOURCE_DIR")
      list(APPEND PASSTHROUGH_VARIABLES
        -D${variableName}=${${variableName}})
    endif()
  endforeach()

  # Populate the passthrough variables
  foreach(variableName ${CLANG_BOOTSTRAP_PASSTHROUGH} ${_BOOTSTRAP_DEFAULT_PASSTHROUGH})
    if(DEFINED ${variableName})
      if("${${variableName}}" STREQUAL "")
        set(value "")
      else()
        string(REPLACE ";" "|" value "${${variableName}}")
      endif()
      list(APPEND PASSTHROUGH_VARIABLES
        -D${variableName}=${value})
    endif()
  endforeach()

  ExternalProject_Add(${NEXT_CLANG_STAGE}
    DEPENDS clang-bootstrap-deps
    PREFIX ${NEXT_CLANG_STAGE}
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    STAMP_DIR ${STAMP_DIR}
    BINARY_DIR ${BINARY_DIR}
    EXCLUDE_FROM_ALL 1
    CMAKE_ARGS
                # We shouldn't need to set this here, but INSTALL_DIR doesn't
                # seem to work, so instead I'm passing this through
                -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                ${CLANG_BOOTSTRAP_CMAKE_ARGS}
                ${PASSTHROUGH_VARIABLES}
                 -DCLANG_STAGE=${NEXT_CLANG_STAGE}
                ${COMPILER_OPTIONS}
                ${${CLANG_STAGE}_CONFIG}
                ${${CLANG_STAGE}_TABLEGEN}
                ${LTO_LIBRARY} ${verbose} ${PGO_OPT}
                ${${CLANG_STAGE}_LINKER}
                ${${CLANG_STAGE}_AR}
                ${${CLANG_STAGE}_RANLIB}
                ${${CLANG_STAGE}_OBJCOPY}
                ${${CLANG_STAGE}_STRIP}
    INSTALL_COMMAND ""
    STEP_TARGETS configure build
    USES_TERMINAL_CONFIGURE 1
    USES_TERMINAL_BUILD 1
    USES_TERMINAL_INSTALL 1
    LIST_SEPARATOR |
    )

  # exclude really-install from main target
  set_target_properties(${NEXT_CLANG_STAGE} PROPERTIES _EP_really-install_EXCLUDE_FROM_MAIN On)
  ExternalProject_Add_Step(${NEXT_CLANG_STAGE} really-install
    COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target install
    COMMENT "Performing install step for '${NEXT_CLANG_STAGE}'"
    DEPENDEES build
    USES_TERMINAL 1
  )
  ExternalProject_Add_StepTargets(${NEXT_CLANG_STAGE} really-install)
  add_custom_target(${NEXT_CLANG_STAGE}-install DEPENDS ${NEXT_CLANG_STAGE}-really-install)

  if(NOT CLANG_BOOTSTRAP_TARGETS)
    set(CLANG_BOOTSTRAP_TARGETS check-llvm check-clang check-all)
  endif()
  foreach(target ${CLANG_BOOTSTRAP_TARGETS})
    # exclude from main target
    set_target_properties(${NEXT_CLANG_STAGE} PROPERTIES _EP_${target}_EXCLUDE_FROM_MAIN On)

    ExternalProject_Add_Step(${NEXT_CLANG_STAGE} ${target}
      COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target ${target}
      COMMENT "Performing ${target} for '${NEXT_CLANG_STAGE}'"
      DEPENDEES configure
      USES_TERMINAL 1
    )

    if(target MATCHES "^stage[0-9]*")
      add_custom_target(${target} DEPENDS ${NEXT_CLANG_STAGE}-${target})
    endif()

    ExternalProject_Add_StepTargets(${NEXT_CLANG_STAGE} ${target})
  endforeach()
endif()

if (LLVM_ADD_NATIVE_VISUALIZERS_TO_SOLUTION)
  add_subdirectory(utils/ClangVisualizers)
endif()
add_subdirectory(utils/hmaptool)

configure_file(
  ${CLANG_SOURCE_DIR}/include/clang/Config/config.h.cmake
  ${CLANG_BINARY_DIR}/include/clang/Config/config.h)
