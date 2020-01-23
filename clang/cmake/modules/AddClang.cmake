function(clang_tablegen)
  # Syntax:
  # clang_tablegen output-file [tablegen-arg ...] SOURCE source-file
  # [[TARGET cmake-target-name] [DEPENDS extra-dependency ...]]
  #
  # Generates a custom command for invoking tblgen as
  #
  # tblgen source-file -o=output-file tablegen-arg ...
  #
  # and, if cmake-target-name is provided, creates a custom target for
  # executing the custom command depending on output-file. It is
  # possible to list more files to depend after DEPENDS.

  cmake_parse_arguments(CTG "" "SOURCE;TARGET" "" ${ARGN})

  if( NOT CTG_SOURCE )
    message(FATAL_ERROR "SOURCE source-file required by clang_tablegen")
  endif()

  set( LLVM_TARGET_DEFINITIONS ${CTG_SOURCE} )
  tablegen(CLANG ${CTG_UNPARSED_ARGUMENTS})

  if(CTG_TARGET)
    add_public_tablegen_target(${CTG_TARGET})
    set_target_properties( ${CTG_TARGET} PROPERTIES FOLDER "Clang tablegenning")
    set_property(GLOBAL APPEND PROPERTY CLANG_TABLEGEN_TARGETS ${CTG_TARGET})
  endif()
endfunction(clang_tablegen)

macro(add_clang_subdirectory name)
  add_llvm_subdirectory(CLANG TOOL ${name})
endmacro()

macro(add_clang_library name)
  cmake_parse_arguments(ARG
    "SHARED"
    ""
    "ADDITIONAL_HEADERS"
    ${ARGN})
  set(srcs)
  if(srcs OR ARG_ADDITIONAL_HEADERS)
    set(srcs
      ADDITIONAL_HEADERS
      ${srcs}
      ${ARG_ADDITIONAL_HEADERS} # It may contain unparsed unknown args.
      )
  endif()
  if(ARG_SHARED)
    set(ARG_ENABLE_SHARED SHARED)
  endif()
  llvm_add_library(${name} ${ARG_ENABLE_SHARED} ${ARG_UNPARSED_ARGUMENTS} ${srcs})

  if(TARGET ${name})
    target_link_libraries(${name} INTERFACE ${LLVM_COMMON_LIBS})

    if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY OR ${name} STREQUAL "libclang")

      if(${name} IN_LIST LLVM_DISTRIBUTION_COMPONENTS OR
          NOT LLVM_DISTRIBUTION_COMPONENTS)
        set(export_to_clangtargets EXPORT ClangTargets)
        set_property(GLOBAL PROPERTY CLANG_HAS_EXPORTS True)
      endif()

      install(TARGETS ${name}
        COMPONENT ${name}
        ${export_to_clangtargets}
        LIBRARY DESTINATION lib${LLVM_LIBDIR_SUFFIX}
        ARCHIVE DESTINATION lib${LLVM_LIBDIR_SUFFIX}
        RUNTIME DESTINATION bin)

      if (${ARG_SHARED} AND NOT CMAKE_CONFIGURATION_TYPES)
        add_llvm_install_targets(install-${name}
                                 DEPENDS ${name}
                                 COMPONENT ${name})
      endif()
    endif()
    set_property(GLOBAL APPEND PROPERTY CLANG_EXPORTS ${name})
  else()
    # Add empty "phony" target
    add_custom_target(${name})
  endif()

  set_target_properties(${name} PROPERTIES FOLDER "Clang libraries")
endmacro(add_clang_library)

macro(add_clang_executable name)
  add_llvm_executable( ${name} ${ARGN} )
  set_target_properties(${name} PROPERTIES FOLDER "Clang executables")
endmacro(add_clang_executable)

macro(add_clang_tool name)
  if (NOT CLANG_BUILD_TOOLS)
    set(EXCLUDE_FROM_ALL ON)
  endif()

  add_clang_executable(${name} ${ARGN})
  add_dependencies(${name} clang-headers)

  if (CLANG_BUILD_TOOLS)
    if(${name} IN_LIST LLVM_DISTRIBUTION_COMPONENTS OR
        NOT LLVM_DISTRIBUTION_COMPONENTS)
      set(export_to_clangtargets EXPORT ClangTargets)
      set_property(GLOBAL PROPERTY CLANG_HAS_EXPORTS True)
    endif()

    install(TARGETS ${name}
      ${export_to_clangtargets}
      RUNTIME DESTINATION bin
      COMPONENT ${name})

    if(NOT CMAKE_CONFIGURATION_TYPES)
      add_llvm_install_targets(install-${name}
                               DEPENDS ${name}
                               COMPONENT ${name})
    endif()
    set_property(GLOBAL APPEND PROPERTY CLANG_EXPORTS ${name})
  endif()
endmacro()

macro(add_clang_symlink name dest)
  add_llvm_tool_symlink(${name} ${dest} ALWAYS_GENERATE)
  # Always generate install targets
  llvm_install_symlink(${name} ${dest} ALWAYS_GENERATE)
endmacro()
