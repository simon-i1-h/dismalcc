# Discover the projects that use CMake in the subdirectories.
# Note that explicit cmake invocation is required every time a new project is
# added or removed.
file(GLOB entries *)
foreach(entry ${entries})
  if(IS_DIRECTORY ${entry} AND EXISTS ${entry}/CMakeLists.txt)
    if((NOT ${entry} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR}/compiler-rt) AND
       (NOT ${entry} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR}/dragonegg) AND
       (NOT ${entry} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR}/test-suite) AND
       (NOT ${entry} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR}/debuginfo-tests))
      get_filename_component(entry_name "${entry}" NAME)
      add_llvm_external_project(${entry_name})
    endif()
  endif()
endforeach(entry)

# Also add in libc++ and compiler-rt trees if present (and we have
# a sufficiently recent version of CMake where required).
if(${LLVM_BUILD_RUNTIME})
  if(NOT LLVM_BUILD_EXTERNAL_COMPILER_RT)
    add_llvm_external_project(compiler-rt)
  endif()
endif()

add_llvm_external_project(dragonegg)

if(LLVM_INCLUDE_TESTS)
  add_llvm_external_project(debuginfo-tests)
endif()
