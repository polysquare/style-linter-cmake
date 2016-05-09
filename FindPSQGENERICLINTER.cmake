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
#
# The following variables will affect the operation of this script
# STYLE_GUIDE_LINT_SEARCH_PATHS : List of directories to search for
#                                 polysquare-generic-file-linter in,
#                                 before searching any system paths.
#
# See /LICENCE.md for Copyright information

include ("cmake/tooling-find-pkg-util/ToolingFindPackageUtil")

function (style_guide_linter_find)

    if (DEFINED STYLE_GUIDE_LINT_FOUND)

        return ()

    endif ()

    # Set-up the directory tree of the polysquare-generic-file-linter
    # installation
    set (BIN_SUBDIR bin)
    set (STYLE_GUIDE_LINT_EXECUTABLE polysquare-generic-file-linter)
    set (STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE spellcheck-linter)

    psq_find_tool_executable ("${STYLE_GUIDE_LINT_EXECUTABLE}"
                              STYLE_GUIDE_LINT_EXECUTABLE
                              PATHS ${STYLE_GUIDE_LINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_find_tool_executable ("${STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE}"
                              STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE
                              PATHS ${STYLE_GUIDE_LINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_report_not_found_if_not_quiet (StyleGuideLinter
                                       STYLE_GUIDE_LINT_EXECUTABLE
                                       "The 'polysquare-generic-file-linter' "
                                       "executable was not found "
                                       "in any search or system paths.\n.."
                                       "Please adjust "
                                       "STYLE_GUIDE_LINT_SEARCH_PATHS "
                                       "to the installation prefix of the"
                                       "'polysquare-generic-file-linter'\n.. "
                                       "executable or install"
                                       "polysquare-generic-file-linter")

    psq_check_and_report_tool_version (StyleGuideLinter
                                       "latest"
                                       REQUIRED_VARS
                                       STYLE_GUIDE_LINT_EXECUTABLE)

    psq_report_not_found_if_not_quiet (SpellingLinter
                                       STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE
                                       "The 'spellcheck-linter' "
                                       "executable was not found "
                                       "in any search or system paths.\n.."
                                       "Please adjust "
                                       "STYLE_GUIDE_LINT_SEARCH_PATHS "
                                       "to the installation prefix of the"
                                       "'spellcheck-linter'\n.. "
                                       "executable or install"
                                       "spellcheck-linter")

    psq_check_and_report_tool_version (SpellingLinter
                                       "latest"
                                       REQUIRED_VARS
                                       STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE)


    set (STYLE_GUIDE_LINT_FOUND # NOLINT:style/set_var_case
         ${StyleGuideLinter_FOUND}
         PARENT_SCOPE)

endfunction ()

style_guide_linter_find ()
