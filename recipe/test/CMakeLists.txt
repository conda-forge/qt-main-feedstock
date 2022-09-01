cmake_minimum_required (VERSION 3.0)

set (CMAKE_BUILD_TYPE "Release" CACHE STRING "build type")

project (qt-main-test CXX)

find_package (Qt6 CONFIG REQUIRED COMPONENTS Core)

add_executable (hello main.cpp)
target_link_libraries (hello Qt6::Core)

add_executable (test_qmimedatabase test_qmimedatabase.cpp)
target_link_libraries (test_qmimedatabase Qt6::Core)

enable_testing ()
add_test (NAME test_qmimedatabase COMMAND test_qmimedatabase)
