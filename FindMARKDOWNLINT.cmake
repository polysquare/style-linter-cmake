# /FindMARKDOWNLINT.cmake
#
# This CMake script will search for markdownlint and set the following
# variables
#
# STYLE_GUIDE_LINT_MARKDOWN_FOUND : Whether or not markdownlint is available on
#                                   the target system
# STYLE_GUIDE_LINT_MDL_VERSION : Version of markdownlint
# STYLE_GUIDE_LINT_MDL_EXECUTABLE : Fully qualified path to the markdownlint
#                                   executable
#
# The following variables will affect the operation of this script
# MDL_SEARCH_PATHS : List of directories to search for markdownlint in, before
#                    searching any system paths. This should be the prefix
#                    to which markdownlint was installed, and not the path
#                    that contains the markdownlint binary. Eg /opt/ not
#                    /opt/bin/
#
# See /LICENCE.md for Copyright information

include ("cmake/tooling-find-pkg-util/ToolingFindPackageUtil")

function (style_guide_lint_mdl_find)

    if (DEFINED MDL_FOUND)

        return ()

    endif ()

    # Set-up the directory tree of the mdl; installation
    set (BIN_SUBDIR bin)
    set (MDL_EXECUTABLE_NAME mdl)

    psq_find_tool_executable (${MDL_EXECUTABLE_NAME}
                              STYLE_GUIDE_LINT_MDL_EXECUTABLE
                              PATHS ${MDL_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_report_not_found_if_not_quiet (MDL STYLE_GUIDE_LINT_MDL_EXECUTABLE
                                       "The 'mdl' executable was not found"
                                       "in any search or system paths.\n.."
                                       "Please adjust MDL_SEARCH_PATHS"
                                       "to the installation prefix of the"
                                       "'mdl'\n.. executable or install"
                                       "markdownlint")

    if (STYLE_GUIDE_LINT_MDL_EXECUTABLE)

        psq_find_tool_extract_version ("${STYLE_GUIDE_LINT_MDL_EXECUTABLE}"
                                       STYLE_GUIDE_LINT_MDL_VERSION
                                       VERSION_ARG "--version")

    endif ()

    psq_check_and_report_tool_version (MDL
                                       "${MDL_VERSION}"
                                       REQUIRED_VARS
                                       STYLE_GUIDE_LINT_MDL_EXECUTABLE
                                       STYLE_GUIDE_LINT_MDL_VERSION)

    set (STYLE_GUIDE_LINT_MARKDOWN_FOUND # NOLINT:style/set_var_case
         ${MDL_FOUND}
         PARENT_SCOPE)

endfunction ()

style_guide_lint_mdl_find ()
