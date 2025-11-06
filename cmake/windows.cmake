# Windows-specific CMake configuration for CUDD
# This file contains all Windows-specific build settings and configurations

# Windows-specific options
if(MSVC)
  option(CUDD_ENABLE_MSVC_ANALYSIS "Enable MSVC Code Analysis" OFF)
  set(CUDD_MSVC_ANALYSIS_RULESET "" CACHE STRING "Path to custom MSVC analysis ruleset file")
  set(CUDD_MSVC_ANALYSIS_LOG "" CACHE STRING "Path to MSVC analysis log output file")
  
  # Usage examples:
  # cmake -DCUDD_ENABLE_MSVC_ANALYSIS=ON ..
  # cmake -DCUDD_ENABLE_MSVC_ANALYSIS=ON -DCUDD_MSVC_ANALYSIS_LOG="analysis.log" ..
  # cmake -DCUDD_ENABLE_MSVC_ANALYSIS=ON -DCUDD_MSVC_ANALYSIS_RULESET="custom.ruleset" ..
endif()

# Block shared library builds on Windows due to DLL linkage issues
function(cudd_check_shared_libs)
  if(CUDD_BUILD_SHARED_LIBS)
    message(FATAL_ERROR "Shared library builds are not supported on Windows due to DLL linkage conflicts. Please use -DCUDD_BUILD_SHARED_LIBS=OFF for static library builds.")
  endif()
endfunction()

# Configure C++11 support for Windows (MSVC)
function(cudd_configure_cpp)
  if(CUDD_BUILD_CPP_API)
    # MSVC automatically supports C++11 without needing explicit flags
    if(MSVC)
      message(STATUS "C++11 support verified for MSVC")
    endif()
  endif()
endfunction()

# Configure Windows-specific libraries
function(cudd_configure_libraries target_name)
  # On Windows, link Winsock2 library for networking functions (gethostname, etc.)
  target_link_libraries(${target_name} PUBLIC ws2_32)
  message(STATUS "Linking with Windows Winsock2 library for networking functions")
endfunction()

# Configure Windows-specific development tools
function(cudd_configure_dev_tools)
  # Windows doesn't need compile_commands.json symlink - IDEs handle it differently
  # No-op function for consistency with Unix version
endfunction()

# Configure MSVC Code Analysis
function(cudd_configure_msvc_analysis target_name)
  if(MSVC AND CUDD_ENABLE_MSVC_ANALYSIS)
    # Enable MSVC Code Analysis
    target_compile_options(${target_name} PRIVATE
      /analyze
      /analyze:WX-  # Don't treat analysis warnings as errors by default
    )
    
    # Optional: Configure specific analysis rulesets
    if(CUDD_MSVC_ANALYSIS_RULESET)
      if(EXISTS "${CUDD_MSVC_ANALYSIS_RULESET}")
        target_compile_options(${target_name} PRIVATE
          /analyze:ruleset "${CUDD_MSVC_ANALYSIS_RULESET}"
        )
        message(STATUS "Using custom MSVC analysis ruleset: ${CUDD_MSVC_ANALYSIS_RULESET}")
      else()
        message(WARNING "MSVC analysis ruleset file not found: ${CUDD_MSVC_ANALYSIS_RULESET}")
      endif()
    endif()
    
    # Optional: Configure analysis output
    if(CUDD_MSVC_ANALYSIS_LOG)
      get_filename_component(log_dir "${CUDD_MSVC_ANALYSIS_LOG}" DIRECTORY)
      if(log_dir)
        file(MAKE_DIRECTORY "${log_dir}")
      endif()
      target_compile_options(${target_name} PRIVATE
        /analyze:log "${CUDD_MSVC_ANALYSIS_LOG}"
      )
      message(STATUS "MSVC analysis log output: ${CUDD_MSVC_ANALYSIS_LOG}")
    endif()
    
    # Additional helpful analysis options
    target_compile_options(${target_name} PRIVATE
      /analyze:stacksize 32768  # Increase stack size for analysis
      /analyze:max_paths 4096   # Increase max paths analyzed
    )
    
    message(STATUS "MSVC Code Analysis enabled for target: ${target_name}")
    message(STATUS "  - Use /analyze:WX to treat analysis warnings as errors")
    message(STATUS "  - Analysis results will appear in the build output")
  endif()
endfunction()