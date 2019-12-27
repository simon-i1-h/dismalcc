create_subdirectory_options(CLANG TOOL)

add_clang_subdirectory(diagtool)
add_clang_subdirectory(driver)
add_clang_subdirectory(clang-diff)
add_clang_subdirectory(clang-format)
add_clang_subdirectory(clang-format-vs)
add_clang_subdirectory(clang-fuzzer)
add_clang_subdirectory(clang-import-test)
add_clang_subdirectory(clang-offload-bundler)

add_clang_subdirectory(c-index-test)

add_clang_subdirectory(clang-rename)
add_clang_subdirectory(clang-refactor)

if(CLANG_ENABLE_ARCMT)
  add_clang_subdirectory(arcmt-test)
  add_clang_subdirectory(c-arcmt-test)
endif()

if(CLANG_ENABLE_STATIC_ANALYZER)
  add_clang_subdirectory(clang-check)
  add_clang_subdirectory(clang-extdef-mapping)
  add_clang_subdirectory(scan-build)
  add_clang_subdirectory(scan-view)
endif()
