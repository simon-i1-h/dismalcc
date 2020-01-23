set(LLD_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(LLD_INCLUDE_DIR ${LLD_SOURCE_DIR}/include )
set(LLD_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Compute the LLD version from the LLVM version.
string(REGEX MATCH "[0-9]+\\.[0-9]+(\\.[0-9]+)?" LLD_VERSION
  ${PACKAGE_VERSION})
message(STATUS "LLD version: ${LLD_VERSION}")

string(REGEX REPLACE "([0-9]+)\\.[0-9]+(\\.[0-9]+)?" "\\1" LLD_VERSION_MAJOR
  ${LLD_VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9]+)(\\.[0-9]+)?" "\\1" LLD_VERSION_MINOR
  ${LLD_VERSION})

# Determine LLD revision and repository.
# TODO: Figure out a way to get the revision and the repository on windows.
if ( NOT CMAKE_SYSTEM_NAME MATCHES "Windows" )
  execute_process(COMMAND ${CMAKE_SOURCE_DIR}/utils/GetSourceVersion ${LLD_SOURCE_DIR}
                  OUTPUT_VARIABLE LLD_REVISION)

  execute_process(COMMAND ${CMAKE_SOURCE_DIR}/utils/GetRepositoryPath ${LLD_SOURCE_DIR}
                  OUTPUT_VARIABLE LLD_REPOSITORY)
  if ( LLD_REPOSITORY )
    # Replace newline characters with spaces
    string(REGEX REPLACE "(\r?\n)+" " " LLD_REPOSITORY ${LLD_REPOSITORY})
    # Remove leading spaces
    STRING(REGEX REPLACE "^[ \t\r\n]+" "" LLD_REPOSITORY "${LLD_REPOSITORY}" )
    # Remove trailing spaces
    string(REGEX REPLACE "(\ )+$" "" LLD_REPOSITORY ${LLD_REPOSITORY})
  endif()

  if ( LLD_REVISION )
    # Replace newline characters with spaces
    string(REGEX REPLACE "(\r?\n)+" " " LLD_REVISION ${LLD_REVISION})
    # Remove leading spaces
    STRING(REGEX REPLACE "^[ \t\r\n]+" "" LLD_REVISION "${LLD_REVISION}" )
    # Remove trailing spaces
    string(REGEX REPLACE "(\ )+$" "" LLD_REVISION ${LLD_REVISION})
  endif()
endif ()

# Configure the Version.inc file.
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/include/lld/Common/Version.inc.in
  ${CMAKE_CURRENT_BINARY_DIR}/include/lld/Common/Version.inc)


if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed. CMake would overwrite "
"the makefiles distributed with LLVM. Please create a directory and run cmake "
"from there, passing the path to this source directory as the last argument. "
"This process created the file `CMakeCache.txt' and the directory "
"`CMakeFiles'. Please delete them.")
endif()

list (APPEND CMAKE_MODULE_PATH "${LLD_SOURCE_DIR}/cmake/modules")

include(AddLLD)

option(LLD_BUILD_TOOLS
  "Build the lld tools. If OFF, just generate build targets." ON)

include_directories(BEFORE
  ${CMAKE_CURRENT_BINARY_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  )

if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)
  install(DIRECTORY include/
    DESTINATION include
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN ".svn" EXCLUDE
    )
endif()

add_subdirectory(Common)
add_subdirectory(lib)
add_subdirectory(tools/lld)

if (LLVM_INCLUDE_TESTS)
  add_subdirectory(test)
  add_subdirectory(unittests)
endif()

add_subdirectory(docs)
add_subdirectory(COFF)
add_subdirectory(ELF)
add_subdirectory(MinGW)
