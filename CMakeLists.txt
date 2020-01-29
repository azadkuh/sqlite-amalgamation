cmake_minimum_required(VERSION 3.8)
project(sqlite3
    VERSION   3
    LANGUAGES C
    )

include(GNUInstallDirs)

#------------------------------------------------------------------------------
# sqlite3 compile options, modules, ...
option(BUILD_ENABLE_DBSTAT_VTAB "enables dbstat virtual table"                 OFF)
option(BUILD_ENABLE_FTS3        "enables full text searches version 3"         OFF)
option(BUILD_ENABLE_FTS4        "enables full text searches version 3 & 4"     OFF)
option(BUILD_ENABLE_FTS5        "enables full text searches version 5"         OFF)
option(BUILD_ENABLE_GEOPOLY     "enables Geopoly extention"                    OFF)
option(BUILD_ENABLE_ICU         "enables international components for unicode" OFF)
option(BUILD_ENABLE_JSON1       "enables JSON SQL functins"                    ON)
option(BUILD_ENABLE_RBU         "enables resumable bulk update extension"      OFF)
option(BUILD_ENABLE_RTREE       "enables R*TRee index extension"               OFF)
option(BUILD_RECOMMENDED_OPTS   "compile by sqlite3 recommended options"       ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Release or Debug?" FORCE)
endif()

#------------------------------------------------------------------------------
# sqlite3 as static library:
add_library(${PROJECT_NAME} STATIC sqlite3.c)
target_compile_definitions(${PROJECT_NAME} PUBLIC # inject user's options
    $<BUILD_INTERFACE:
        $<$<BOOL:${BUILD_ENABLE_DBSTAT_VTAB}>:SQLITE_ENABLE_DBSTAT_VTAB>
        $<$<BOOL:${BUILD_ENABLE_FTS3}>:SQLITE_ENABLE_FTS3>
        $<$<BOOL:${BUILD_ENABLE_FTS4}>:SQLITE_ENABLE_FTS4>
        $<$<BOOL:${BUILD_ENABLE_FTS5}>:SQLITE_ENABLE_FTS5>
        $<$<BOOL:${BUILD_ENABLE_GEOPOLY}>:SQLITE_ENABLE_GEOPOLY>
        $<$<BOOL:${BUILD_ENABLE_ICU}>:SQLITE_ENABLE_ICU>
        $<$<BOOL:${BUILD_ENABLE_JSON1}>:SQLITE_ENABLE_JSON1>
        $<$<BOOL:${BUILD_ENABLE_RBU}>:SQLITE_ENABLE_RBU>
        $<$<BOOL:${BUILD_ENABLE_RTREE}>:SQLITE_ENABLE_RTREE>
        $<$<BOOL:${BUILD_RECOMMENDED_OPTS}>:
            SQLITE_DQS=0
            SQLITE_DEFAULT_MEMSTATUS=0
            SQLITE_DEFAULT_WAL_SYNCHRONOUS=1
            SQLITE_LIKE_DOESNT_MATCH_BLOBS
            SQLITE_MAX_EXPR_DEPTH=0
            SQLITE_OMIT_DECLTYPE
            SQLITE_OMIT_DEPRECATED
            SQLITE_OMIT_PROGRESS_CALLBACK
            SQLITE_OMIT_SHARED_CACHE
            SQLITE_USE_ALLOCA
        >
    >
    )
# platform/compiler specific settings
if(UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC Threads::Threads ${CMAKE_DL_LIBS})
elseif(WIN32 AND ${CMAKE_SIZEOF_VOID_P} LESS 8) # this is a 32bit windows
    option(BUILD_WITH_XPSDK "build for old 32bit (WinXP/2003) targets" OFF)
    if(BUILD_WITH_XPSDK)
        target_compile_definitions(${PROJECT_NAME} PUBLIC
            $<BUILD_INTERFACE:
                -DSQLITE_OS_WINRT=0 -D_WIN32_WINNT=0x0502 -DWINVER=0x0502
            >
            )
    endif()
endif()

add_library(sqlite3::sqlite3 ALIAS ${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} EXPORT sqlite3-config
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} # static lib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} # for msvc static lib!
    )
install(FILES
    sqlite3.h   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/sqlite3
    )
install(EXPORT  sqlite3-config
    NAMESPACE   sqlite3::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
    )

#------------------------------------------------------------------------------
# sqlite3 shell application:
option(BUILD_SHELL "build sqlite3 shell application" OFF)
if(BUILD_SHELL)
    add_executable(shell_app shell.c)
    set_target_properties(shell_app PROPERTIES OUTPUT_NAME sqlite3)
    target_link_libraries(shell_app PRIVATE sqlite3::sqlite3)
    if(MSVC)
        option(BUILD_SHELL_STATIC "build shell by static c/c++ runtime" ON)
        foreach(flag CMAKE_C_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_DEBUG)
            if(BUILD_SHELL_STATIC)
                string(REGEX REPLACE "/MD" "/MT" ${flag} "${${flag}}")
            else()
                string(REGEX REPLACE "/MT" "/MD" ${flag} "${${flag}}")
            endif()
            set(${flag} "${${flag}}" CACHE STRING "msvc flags" FORCE)
        endforeach()
    endif()
    install(TARGETS shell_app
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        )
endif()

