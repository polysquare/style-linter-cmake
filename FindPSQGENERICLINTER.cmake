# /FindPSQGENERICLINTER.cmake
#
# This CMake script will search for polysquare-generic-file-linter and set the
# following variables
#
# STYLE_GUIDE_LINT_FOUND : Whether or not polysquare-generic-file-linter
#                          is available on the target system
# STYLE_GUIDE_LINT_EXECUTABLE : Fully qualified path to the
#                               polysquare-generic-file-linter executable
# STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE : Fully qualified path to the
#                                          spellcheck-linter executable
# STYLE_GUIDE_LINT_POP_CACHE_EXECUTABLE : Fully qualified path to the
#                                         polysquare-generic-file-linter-
#                                         populate-cache executable
#
# The following variables will affect the operation of this script
# STYLE_GUIDE_LINT_SEARCH_PATHS : List of directories to search for
#                                 polysquare-generic-file-linter in,
#                                 before searching any system paths.
#
# See /LICENCE.md for Copyright information

include ("cmake/tooling-find-pkg-util/ToolingFindPackageUtil")

function (_style_guide_linter_not_found_msg EXECUTABLE RETURN_VALUE)

    set (MSG
         "The '${EXECUTABLE}' executable was not found in any search or "
         "system paths.\n.."
         "Please adjust STYLE_GUIDE_LINT_SEARCH_PATHS to the installation"
         " prefix of the '${EXECUTABLE}'\n executable or install "
         "'${EXECUTABLE}'")

    string (REPLACE ";" " " MSG "${MSG}")

    set (${RETURN_VALUE} "${MSG}" PARENT_SCOPE)

endfunction ()

function (style_guide_linter_find)

    if (DEFINED STYLE_GUIDE_LINT_FOUND)

        return ()

    endif ()

    # Set-up the directory tree of the polysquare-generic-file-linter
    # installation
    set (BIN_SUBDIR bin)
    set (STYLE_GUIDE_LINT_EXECUTABLE polysquare-generic-file-linter)
    set (STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE spellcheck-linter)
    set (STYLE_GUIDE_LINT_POP_CACHE_EXECUTABLE
         polysquare-generic-file-linter-populate-cache)

    psq_find_tool_executable ("${STYLE_GUIDE_LINT_EXECUTABLE}"
                              STYLE_GUIDE_LINT_EXECUTABLE
                              PATHS ${STYLE_GUIDE_LINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_find_tool_executable ("${STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE}"
                              STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE
                              PATHS ${STYLE_GUIDE_LINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_find_tool_executable ("${STYLE_GUIDE_LINT_POP_CACHE_EXECUTABLE}"
                              STYLE_GUIDE_LINT_POP_CACHE_EXECUTABLE
                              PATHS ${STYLE_GUIDE_LINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    _style_guide_linter_not_found_msg ("${STYLE_GUIDE_LINT_EXECUTABLE}"
                                       STYLE_GUIDE_LINT_EXECUTABLE_MSG)
    psq_report_not_found_if_not_quiet (StyleGuideLinter
                                       STYLE_GUIDE_LINT_EXECUTABLE
                                       ${STYLE_GUIDE_LINT_EXECUTABLE_MSG})

    psq_check_and_report_tool_version (StyleGuideLinter
                                       "latest"
                                       REQUIRED_VARS
                                       STYLE_GUIDE_LINT_EXECUTABLE)

    _style_guide_linter_not_found_msg ("${${POP_CACHE_EXECUTABLE_NAME}}"
                                       POPULATE_CACHE_EXECUTABLE_MSG)
    psq_report_not_found_if_not_quiet (StyleGuideLinterCachePopulate
                                       STYLE_GUIDE_LINT_POP_CACHE_EXECUTABLE
                                       ${POPULATE_CACHE_EXECUTABLE_MSG})

    psq_check_and_report_tool_version (StyleGuideLinterCachePopulate
                                       "latest"
                                       REQUIRED_VARS
                                       STYLE_GUIDE_LINT_POP_CACHE_EXECUTABLE)

    set (SPELLCHECK_EXECUTABLE_NAME STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE)
    _style_guide_linter_not_found_msg ("${${SPELLCHECK_EXECUTABLE_NAME}}"
                                       STYLE_GUIDE_LINT_EXECUTABLE_MSG)
    psq_report_not_found_if_not_quiet (SpellingLinter
                                       STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE
                                       ${SPELLCHECK_EXECUTABLE_MSG})

    psq_check_and_report_tool_version (SpellingLinter
                                       "latest"
                                       REQUIRED_VARS
                                       STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE)

    set (STYLE_GUIDE_LINT_FOUND # NOLINT:style/set_var_case
         ${StyleGuideLinter_FOUND}
         PARENT_SCOPE)

endfunction ()

style_guide_linter_find ()
