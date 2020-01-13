find_first_existing_vc_file(llvm_vc "${LLVM_MAIN_SRC_DIR}")

# The VC revision include that we want to generate.
set(version_inc "${CMAKE_CURRENT_BINARY_DIR}/VCSRevision.h")

file(WRITE "${version_inc}.undef" "#undef LLVM_REVISION\n")
# Make sure ${version_inc} doesn't define a revision
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${version_inc}.undef" "${version_inc}")
file(REMOVE "${version_inc}.undef")

# Mark the generated header as being generated.
set_source_files_properties("${version_inc}"
  PROPERTIES GENERATED TRUE
             HEADER_FILE_ONLY TRUE)

add_custom_target(llvm_vcsrevision_h DEPENDS "${version_inc}")
set_target_properties(llvm_vcsrevision_h PROPERTIES FOLDER "Misc")
