create_subdirectory_options(CLANG TOOL)

# XXX temporarily disable
#add_clang_subdirectory(diagtool)
#add_clang_subdirectory(clang-fuzzer)
add_clang_subdirectory(driver)
# XXX WORKAROUND: missing libclang
#add_clang_subdirectory(clang-import-test)
#add_clang_subdirectory(c-index-test)
