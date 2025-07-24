cmake_minimum_required(VERSION 3.10)

project(cudd
  VERSION 4.0.0
  DESCRIPTION "CUDD Decision Diagram Library"
  HOMEPAGE_URL "https://github.com/cuddorg/cudd"
  LANGUAGES C CXX
)

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds not allowed.")
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ============================================================================ #
# Settings
# ============================================================================ #

option(CUDD_BUILD_CPP_API "Build C++ API" ON)
option(CUDD_BUILD_SHARED_LIBS "Build CUDD as a shared library" OFF)
option(CUDD_BUILD_WITH_STATS "Build CUDD with statistics" OFF)
option(CUDD_BUILD_TESTS "Build CUDD tests" OFF)
option(CUDD_BUILD_WITH_SYSTEM_QSORT "Build with system qsort" OFF)

# option(BUILD_API_DOCS "Build API documentation with Doxygen" OFF)
# option(BUILD_USER_GUIDES "Build user guides with LaTeX" OFF)
# option(BUILD_NANOTRAV_EXAMPLE "Build Nanotrav Example" OFF)

if(CUDD_BUILD_CPP_API)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
  if(NOT COMPILER_SUPPORTS_CXX11)
    message(FATAL_ERROR "${CMAKE_CXX_COMPILER} has no C++11 support.")
  endif()
  include(CheckCXXSourceCompiles)
  set(HAVE_MODERN_CXX TRUE)
  set(HAVE_WORKING_THREAD TRUE)
endif()

# ============================================================================ #
# Compiler Settings
# ============================================================================ #

include(CheckCXXCompilerFlag)

if(CUDD_BUILD_WITH_SYSTEM_QSORT)
  set(USE_SYSTEM_QSORT TRUE)
endif()

# set(__USE_MINGW_ANSI_STDIO ON) # TODO: Test.

find_package(Threads)
if(CMAKE_USE_PTHREADS_INIT)
  add_definitions(-DHAVE_PTHREADS=1)
  set(HAVE_PTHREADS TRUE)
  add_definitions("-pthread")
  # target_link_libraries(${name} ${CMAKE_THREAD_LIBS_INIT})
endif()

include(CheckIncludeFile)

CHECK_INCLUDE_FILE("float.h" HAVE_FLOAT_H)
if(NOT (HAVE_FLOAT_H))
  message(FATAL_ERROR "'float.h' missing.")
endif()

CHECK_INCLUDE_FILE("inttypes.h" HAVE_INTTYPES_H)
if(NOT (HAVE_INTTYPES_H))
  message(FATAL_ERROR "'inttypes.h' missing.")
endif()

CHECK_INCLUDE_FILE("limits.h" HAVE_LIMITS_H)
if(NOT (HAVE_LIMITS_H))
  message(FATAL_ERROR "'limits.h' missing.")
endif()

CHECK_INCLUDE_FILE("stddef.h" HAVE_STDDEF_H)
if(NOT (HAVE_STDDEF_H))
  message(FATAL_ERROR "'stddef.h' missing.")
endif()

CHECK_INCLUDE_FILE("stdlib.h" HAVE_STDLIB_H)
if(NOT (HAVE_STDLIB_H))
  message(FATAL_ERROR "'stdlib.h' missing.")
endif()

CHECK_INCLUDE_FILE("string.h" HAVE_STRING_H)
if(NOT (HAVE_STRING_H))
  message(FATAL_ERROR "'string.h' missing.")
endif()

CHECK_INCLUDE_FILE("assert.h" HAVE_ASSERT_H)
if(NOT (HAVE_ASSERT_H))
  message(FATAL_ERROR "'assert.h' missing.")
endif()

CHECK_INCLUDE_FILE("math.h" HAVE_MATH_H)
if(NOT (HAVE_MATH_H))
  message(FATAL_ERROR "'math.h' missing.")
endif()

CHECK_INCLUDE_FILE("unistd.h" HAVE_UNISTD_H)
CHECK_INCLUDE_FILE("sys/time.h" HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE("sys/times.h" HAVE_SYS_TIMES_H)
CHECK_INCLUDE_FILE("sys/resource.h" HAVE_SYS_RESOURCE_H)
CHECK_INCLUDE_FILE("sys/wait.h" HAVE_SYS_WAIT_H)
CHECK_INCLUDE_FILE("sys/stat.h" HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILE("dlfcn.h" HAVE_DLFCN_H) # libtool
CHECK_INCLUDE_FILE("memory.h" HAVE_MEMORY_H)
CHECK_INCLUDE_FILE("strings.h" HAVE_STRINGS_H)

set(STDC_HEADERS TRUE) # TODO: Test

CHECK_INCLUDE_FILE("stdbool.h" HAVE__BOOL)

include(CheckTypeSize)
CHECK_TYPE_SIZE(size_t SIZE_T)
CHECK_TYPE_SIZE(uint16_t UINT16_T)
CHECK_TYPE_SIZE(uint32_t UINT32_T)
CHECK_TYPE_SIZE(ptrdiff_t PTRDIFF_T)
CHECK_TYPE_SIZE(int SIZEOF_INT)
CHECK_TYPE_SIZE(long SIZEOF_LONG)
CHECK_TYPE_SIZE("void*" SIZEOF_VOID_P)
CHECK_TYPE_SIZE("long double" SIZEOF_LONG_DOUBLE)

include(CheckFunctionExists)

set(CMAKE_REQUIRED_INCLUDES "math.h")
set(CMAKE_REQUIRED_LIBRARIES m)

CHECK_FUNCTION_EXISTS(pow HAVE_POW)
if(NOT (HAVE_POW))
  message(FATAL_ERROR "'pow' function missing.")
endif()

CHECK_FUNCTION_EXISTS(sqrt HAVE_SQRT)
if(NOT (HAVE_SQRT))
  message(FATAL_ERROR "'sqrt' function missing.")
endif()

CHECK_FUNCTION_EXISTS(strchr HAVE_STRCHR)
if(NOT (HAVE_STRCHR))
  message(FATAL_ERROR "'strchr' function missing.")
endif()

CHECK_FUNCTION_EXISTS(strstr HAVE_STRSTR)
if(NOT (HAVE_STRSTR))
  message(FATAL_ERROR "'strstr' function missing.")
endif()

CHECK_FUNCTION_EXISTS(powl HAVE_POWL)
CHECK_FUNCTION_EXISTS(gethostname HAVE_GETHOSTNAME)
CHECK_FUNCTION_EXISTS(getrlimit HAVE_GETRLIMIT)
CHECK_FUNCTION_EXISTS(getrusage HAVE_GETRUSAGE)
CHECK_FUNCTION_EXISTS(sysconf HAVE_SYSCONF)

include(CheckCSourceCompiles)
CHECK_C_SOURCE_COMPILES(
  "#include <math.h>
  int main() { double x = INFINITY; }
  " HAVE_IEEE_754)


### ============================================================================ #
# CUDD Library
### ============================================================================ #

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.in
               ${CMAKE_CURRENT_BINARY_DIR}/src/config.h)

# Public header directories
set(CUDD_PUBLIC_HEADERS
  "${CMAKE_CURRENT_SOURCE_DIR}/include/cudd/cudd.h"
)
set(CUDD_SOURCES
  "src/cuddAddAbs.c"
  "src/cuddBddCorr.c"
  "src/cuddGenetic.c"
  "src/cuddReorder.c"
  "src/cuddZddGroup.c"
  "src/cuddAddApply.c"
  "src/cuddBddIte.c"
  "src/cuddGroup.c"
  "src/cuddSat.c"
  "src/cuddZddIsop.c"
  "src/cuddAddFind.c"
  "src/cuddBridge.c"
  "src/cuddHarwell.c"
  "src/cuddSign.c"
  "src/cuddZddLin.c"
  "src/cuddAddInv.c"
  "src/cuddCache.c"
  "src/cuddInit.c"
  "src/cuddSolve.c"
  "src/cuddZddMisc.c"
  "src/cuddAddIte.c"
  "src/cuddCheck.c"
  "src/cuddInteract.c"
  "src/cuddSplit.c"
  "src/cuddZddPort.c"
  "src/cuddAddNeg.c"
  "src/cuddClip.c"
  "src/cuddLCache.c"
  "src/cuddSubsetHB.c"
  "src/cuddZddReord.c"
  "src/cuddAddWalsh.c"
  "src/cuddCof.c"
  "src/cuddLevelQ.c"
  "src/cuddSubsetSP.c"
  "src/cuddZddSetop.c"
  "src/cuddAndAbs.c"
  "src/cuddCompose.c"
  "src/cuddLinear.c"
  "src/cuddSymmetry.c"
  "src/cuddZddSymm.c"
  "src/cuddAnneal.c"
  "src/cuddDecomp.c"
  "src/cuddLiteral.c"
  "src/cuddTable.c"
  "src/cuddZddUtil.c"
  "src/cuddApa.c"
  "src/cuddEssent.c"
  "src/cuddMatMult.c"
  "src/cuddUtil.c"
  "src/cuddAPI.c"
  "src/cuddExact.c"
  "src/cuddPriority.c"
  "src/cuddWindow.c"
  "src/cuddApprox.c"
  "src/cuddExport.c"
  "src/cuddRead.c"
  "src/cuddZddCount.c"
  "src/cuddBddAbs.c"
  "src/cuddGenCof.c"
  "src/cuddRef.c"
  "src/cuddZddFuncs.c"
  "src/epd.c"
  "src/mtrBasic.c"
  "src/mtrGroup.c"
  "src/st.c"
  "src/util/cpu_stats.c"
  "src/util/cpu_time.c"
  "src/util/cstringstream.c"
  "src/util/datalimit.c"
  "src/util/pathsearch.c"
  "src/util/pipefork.c"
  "src/util/prtime.c"
  "src/util/safe_mem.c"
  "src/util/strsav.c"
  "src/util/texpand.c"
  "src/util/ucbqsort.c"
)

if(CUDD_BUILD_CPP_API)
  set(CUDD_PUBLIC_HEADERS
    "${CMAKE_CURRENT_SOURCE_DIR}/include/cudd/cudd.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/cudd/cuddObj.hh"
    ${CUDD_PUBLIC_HEADERS}
  )
  set(CUDD_SOURCES
    "src/cudd.cpp"
    ${CUDD_SOURCES}
  )
endif()

###
### CUDD Target
###

# Define the cudd library target
if(CUDD_BUILD_SHARED_LIBS)
  add_library(cudd SHARED ${CUDD_SOURCES})
else()
  add_library(cudd STATIC ${CUDD_SOURCES})
endif()

# Link the math library (libm)
find_library(MATH_LIBRARY m REQUIRED)
target_link_libraries(cudd PUBLIC ${MATH_LIBRARY})

# Include directories (build and install time)
target_include_directories(cudd PUBLIC
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/extras/dddmp/include>
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/extras/dddmp/src>
  $<INSTALL_INTERFACE:include>
)

# Define properties for the library
set_target_properties(cudd PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
  POSITION_INDEPENDENT_CODE ON
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN ON
  PUBLIC_HEADER "${CUDD_PUBLIC_HEADERS}"
)

# Optional compilation flags
if(CUDD_BUILD_WITH_STATS)
  target_compile_definitions(cudd PUBLIC DD_STATS)
endif()

###
### Export and Install
###

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

generate_export_header(cudd
  EXPORT_MACRO_NAME CUDD_API
)

# Install the cudd library
install(TARGETS cudd
  EXPORT cuddTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Runtime 
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Development
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cudd COMPONENT Development
)

# Install version/config files for find_package
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/cuddConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cuddConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cuddConfig.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/cudd
)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/cuddConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/cuddConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/cudd
)

# DDDMP Target
if(CUDD_BUILD_DDDMP)
  add_subdirectory(extras/dddmp)
endif()

# Test Build
include(CTest)
if(CUDD_BUILD_TESTS)
  add_subdirectory(extras/nanotrav)
endif()

# Compile Commands
if (PROJECT_IS_TOP_LEVEL AND UNIX)
    # Create symlink to compile_commands.json for IDE to pick it up
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E create_symlink
            ${CMAKE_BINARY_DIR}/compile_commands.json
            ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
    )
endif()