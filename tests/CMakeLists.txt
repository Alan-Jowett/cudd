include(FetchContent)
set(CUDD_CATCH2_VERSION "3.11.0" CACHE STRING "Catch2 version to fetch for tests")
FetchContent_Declare(
  Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG v${CUDD_CATCH2_VERSION}
)
FetchContent_MakeAvailable(Catch2)

add_executable(
  cudd_tests
  main.test.cpp
)

target_link_libraries(cudd_tests PRIVATE
  Catch2::Catch2WithMain
  cudd::cudd
)

include(Catch)
catch_discover_tests(cudd_tests)
