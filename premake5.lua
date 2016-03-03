workspace "sqlite3"
    configurations {"Release"}
    objdir "tmp"
    targetdir "xbin"
    language "C"

    filter "configurations:Release"
        optimize "On"
        if os.is("linux") or os.is("macosx") then
            buildoptions{"-O3 -g0 -Wall -Wextra -pedantic -Wcast-align -Wunused -Wno-unused-parameter"}

        elseif os.is("windows") then
            defines {"NDEBUG"}
            buildoptions{"-nologo -Zm200 -Zc:wchar_t -FS -O2 -MD -Zc:strictStrings -W3" }
        end

project "library"
    targetname "sqlite3"
    kind "StaticLib"
    files {"sqlite3.c"}
    location "tmp"

project "shell"
    targetname "sqlite3"
    kind "ConsoleApp"
    files {"shell.c"}
    links {"library"}
    location "tmp"
    if os.is("linux") then
        links{"pthtread", "dl"}
    end

