cmake_minimum_required(VERSION 3.8)
project(sqlite3
    VERSION 3
    LANGUAGES C
    )

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


# other build options
option(BUILD_RECOMMENDED_OPTS "build by recommended compile-time options" ON)
option(BUILD_STATIC_RUNTIME   "build by static c/c++ runtime"             ON)
option(BUILD_SHELL            "build sqlite3 shell application"           OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Release or Debug?" FORCE)
endif()
#------------------------------------------------------------------------------

macro(make_target_build_options tgt)
    target_compile_options(${tgt} PRIVATE
        $<IF:$<C_COMPILER_ID:MSVC>,-W3,-Wall -Wextra -pedantic>
        )
    if(UNIX)
        find_package(Threads REQUIRED)
        target_link_libraries(${tgt} PUBLIC Threads::Threads ${CMAKE_DL_LIBS})
    elseif(WIN32)
        target_compile_definitions(${tgt} PUBLIC
            -DWIN32_LEAN_AND_MEAN -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS
            )
    endif()
    if(${BUILD_STATIC_RUNTIME})
        if(MSVC)
            foreach(flag CMAKE_C_FLAGS CMAKE_C_FLAGS_RELEASE CMAKE_C_FLAGS_DEBUG)
                string(REGEX REPLACE "/MD" "/MT" ${flag} "${${flag}}")
                set(${flag} "${${flag}}" CACHE STRING "msvc flags" FORCE)
            endforeach()
            target_compile_options(${tgt} PUBLIC
                "$<$<CONFIG:Release>:-MT>"
                "$<$<CONFIG:Debug>:-MTd>"
                )
        elseif(${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
            set_target_properties(${tgt} PROPERTIES LINK_FLAGS "-s -static-libgcc")
        endif()
    endif()
endmacro()

#------------------------------------------------------------------------------
include(GNUInstallDirs)
#------------------------------------------------------------------------------

add_library(${PROJECT_NAME} sqlite3.c)
target_compile_definitions(${PROJECT_NAME} PUBLIC
    $<$<BOOL:${BUILD_ENABLE_DBSTAT_VTAB}>:SQLITE_ENABLE_DBSTAT_VTAB>
    $<$<BOOL:${BUILD_ENABLE_FTS3}>:SQLITE_ENABLE_FTS3>
    $<$<BOOL:${BUILD_ENABLE_FTS4}>:SQLITE_ENABLE_FTS4>
    $<$<BOOL:${BUILD_ENABLE_FTS5}>:SQLITE_ENABLE_FTS5>
    $<$<BOOL:${BUILD_ENABLE_GEOPOLY}>:SQLITE_ENABLE_GEOPOLY>
    $<$<BOOL:${BUILD_ENABLE_ICU}>:SQLITE_ENABLE_ICU>
    $<$<BOOL:${BUILD_ENABLE_JSON1}>:SQLITE_ENABLE_JSON1>
    $<$<BOOL:${BUILD_ENABLE_RBU}>:SQLITE_ENABLE_RBU>
    $<$<BOOL:${BUILD_ENABLE_RTREE}>:SQLITE_ENABLE_RTREE>
    )
if (BUILD_RECOMMENDED_OPTS)
    target_compile_definitions(${PROJECT_NAME} PUBLIC
        SQLITE_DQS=0
        SQLITE_DEFAULT_MEMSTATUS=0
        SQLITE_LIKE_DOESNT_MATCH_BLOBS
        SQLITE_MAX_EXPR_DEPTH=0
        SQLITE_OMIT_DECLTYPE
        SQLITE_OMIT_DEPRECATED
        SQLITE_USE_ALLOCA
        )
endif()
target_include_directories(${PROJECT_NAME} PUBLIC $<INSTALL_INTERFACE:include>)
set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER sqlite3.h)
make_target_build_options(${PROJECT_NAME})
add_library(sqlite3::sqlite3 ALIAS ${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} EXPORT Sqlite3Config
    ARCHIVE       DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY       DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/sqlite3
    )
install(EXPORT Sqlite3Config
    NAMESPACE sqlite3::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
    )
export(TARGETS ${PROJECT_NAME} FILE Sqlite3Config.cmake)

if (BUILD_SHELL)
    add_executable(sqlite3_shell shell.c)
    set_target_properties(sqlite3_shell PROPERTIES OUTPUT_NAME sqlite3)
    target_link_libraries(sqlite3_shell PRIVATE sqlite3::sqlite3)
    install(TARGETS sqlite3_shell RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
