project(sqlite3)
cmake_minimum_required(VERSION 2.8)

if ( CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU" )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -g0 -Wall -Wextra -pedantic -Wcast-align -Wunused -Wno-unused-parameter")
elseif ( CMAKE_C_COMPILER_ID STREQUAL "MSVS" )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nologo -Zc:wchar_t -FS -O2 -MD -Zc:strictStrings -W3")
endif()

add_library(sqlite3 STATIC sqlite3.c)

add_executable(sqlite3_shell shell.c)
target_link_libraries(sqlite3_shell sqlite3)
set_target_properties(sqlite3_shell PROPERTIES OUTPUT_NAME sqlite3)
if("${CMAKE_SYSTEM}" MATCHES "Linux")
    target_link_libraries(sqlite3_shell pthread dl)
endif()
