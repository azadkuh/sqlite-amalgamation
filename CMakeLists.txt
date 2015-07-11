project(sqlite3)
cmake_minimum_required(VERSION 2.8)

add_library(${PROJECT_NAME} sqlite3.c)

if ( CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU" )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -g0 -Wall -Wextra -pedantic -Wcast-align -Wunused -Wno-unused-parameter")
elseif ( CMAKE_C_COMPILER_ID STREQUAL "MSVS" )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nologo -Zm200 -Zc:wchar_t -FS -O2 -MD -Zc:strictStrings -W3")
endif()


