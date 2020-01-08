create_subdirectory_options(CLANG TOOL)

add_clang_subdirectory(diagtool)
add_clang_subdirectory(driver)
add_clang_subdirectory(clang-fuzzer)
# XXX WORKAROUND: missing libclang
#add_clang_subdirectory(clang-import-test)
#add_clang_subdirectory(c-index-test)
