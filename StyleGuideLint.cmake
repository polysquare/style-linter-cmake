# /StyleGuideLint.cmake
#
# Lint specified files for style guide violations.
#
# See /LICENCE.md for Copyright information

include (CMakeParseArguments)
include ("cmake/tooling-cmake-util/PolysquareToolingUtil")

set (_STYLE_GUIDE_LINT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

macro (style_guide_lint_validate CONTINUE)

    if (NOT DEFINED STYLE_GUIDE_LINT_FOUND)

        set (CMAKE_MODULE_PATH
             ${CMAKE_MODULE_PATH} # NOLINT:correctness/quotes
             "${_STYLE_GUIDE_LINT_LIST_DIR}")
        find_package (PSQGENERICLINTER ${ARGN})

    endif ()

    set (${CONTINUE} ${STYLE_GUIDE_LINT_FOUND})

endmacro ()

macro (style_guide_lint_markdown_validate CONTINUE)

    if (NOT DEFINED STYLE_GUIDE_LINT_MARKDOWN_FOUND)

        set (CMAKE_MODULE_PATH
             ${CMAKE_MODULE_PATH} # NOLINT:correctness/quotes
             "${_STYLE_GUIDE_LINT_LIST_DIR}")
        find_package (MARKDOWNLINT ${ARGN})

    endif ()

    set (${CONTINUE} ${STYLE_GUIDE_LINT_MARKDOWN_FOUND})

endmacro ()

function (_style_guide_lint_get_commandline COMMANDLINE_RETURN)

    set (CURRENT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    set (STYLE_GUIDE_LINT_COMMON_OPTIONS
         "--spellcheck-cache=${CURRENT_BINARY_DIR}/style_guide_linter_cache"
         "--log-technical-terms-to=${CURRENT_BINARY_DIR}/technical_terms")

    set (COMMANDLINE_OPTION_ARGS WARN_ONLY)
    set (COMMANDLINE_MULTIVAR_ARGS SOURCES
                                   BLACKLIST
                                   WHITELIST)

    cmake_parse_arguments (COMMANDLINE
                           "${COMMANDLINE_OPTION_ARGS}"
                           ""
                           "${COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (COMMANDLINE_WARN_ONLY)
        set (WARN_ONLY_STATE ON)
    else ()
        set (WARN_ONLY_STATE OFF)
    endif ()

    set (COMMANDLINE_OPTIONS
         ${STYLE_GUIDE_LINT_COMMON_OPTIONS})

    if (COMMANDLINE_BLACKLIST)
        list (APPEND COMMANDLINE_OPTIONS --blacklist ${COMMANDLINE_BLACKLIST})
    endif ()

    if (COMMANDLINE_WHITELIST)
        list (APPEND COMMANDLINE_OPTIONS --whitelist ${COMMANDLINE_WHITELIST})
    endif ()

    string (REPLACE ";" "," COMMANDLINE_OPTIONS "${COMMANDLINE_OPTIONS}")
    string (REPLACE ";" "," COMMANDLINE_SOURCES "${COMMANDLINE_SOURCES}")

    set (${COMMANDLINE_RETURN}
         "${CMAKE_COMMAND}"
         "-DVERBOSE=OFF"
         "-DWARN_ONLY=${WARN_ONLY_STATE}"
         "-DSTYLE_GUIDE_LINT_EXECUTABLE=${STYLE_GUIDE_LINT_EXECUTABLE}"
         "-DSOURCES=${COMMANDLINE_SOURCES}"
         "-DOPTIONS=${COMMANDLINE_OPTIONS}"
         -P
         "${_STYLE_GUIDE_LINT_LIST_DIR}/RunStyleGuideLint.cmake"
         PARENT_SCOPE)

endfunction ()

function (_style_guide_lint_get_spelling_commandline COMMANDLINE_RETURN)

    set (CURRENT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    set (SPELLING_COMMON_OPTIONS
         "--spellcheck-cache=${CURRENT_BINARY_DIR}/style_guide_linter_cache"
         "--technical-terms=${CURRENT_BINARY_DIR}/technical_terms")

    set (COMMANDLINE_OPTION_ARGS WARN_ONLY)
    set (COMMANDLINE_MULTIVAR_ARGS SOURCES)

    cmake_parse_arguments (COMMANDLINE
                           "${COMMANDLINE_OPTION_ARGS}"
                           ""
                           "${COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (COMMANDLINE_WARN_ONLY)
        set (WARN_ONLY_STATE ON)
    else ()
        set (WARN_ONLY_STATE OFF)
    endif ()

    set (COMMANDLINE_OPTIONS
         ${SPELLING_COMMON_OPTIONS})
    string (REPLACE ";" "," COMMANDLINE_OPTIONS "${COMMANDLINE_OPTIONS}")
    string (REPLACE ";" "," COMMANDLINE_SOURCES "${COMMANDLINE_SOURCES}")

    set (EXECUTABLE "${STYLE_GUIDE_LINT_SPELLCHECK_EXECUTABLE}")
    set (${COMMANDLINE_RETURN}
         "${CMAKE_COMMAND}"
         "-DVERBOSE=OFF"
         "-DWARN_ONLY=${WARN_ONLY_STATE}"
         "-DSTYLE_GUIDE_LINT_EXECUTABLE=${EXECUTABLE}"
         "-DSOURCES=${COMMANDLINE_SOURCES}"
         "-DOPTIONS=${COMMANDLINE_OPTIONS}"
         -P
         "${_STYLE_GUIDE_LINT_LIST_DIR}/RunStyleGuideLint.cmake"
         PARENT_SCOPE)

endfunction ()

function (_style_guide_lint_get_markdownlint_commandline COMMANDLINE_RETURN)

    set (COMMANDLINE_OPTION_ARGS WARN_ONLY)
    set (COMMANDLINE_MULTIVAR_ARGS SOURCES)

    cmake_parse_arguments (COMMANDLINE
                           "${COMMANDLINE_OPTION_ARGS}"
                           ""
                           "${COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (COMMANDLINE_WARN_ONLY)
        set (WARN_ONLY_STATE ON)
    else ()
        set (WARN_ONLY_STATE OFF)
    endif ()

    set (COMMANDLINE_OPTIONS
         ${SPELLING_COMMON_OPTIONS})
    string (REPLACE ";" "," COMMANDLINE_OPTIONS "${COMMANDLINE_OPTIONS}")
    string (REPLACE ";" "," COMMANDLINE_SOURCES "${COMMANDLINE_SOURCES}")

    set (${COMMANDLINE_RETURN}
         "${CMAKE_COMMAND}"
         "-DVERBOSE=OFF"
         "-DWARN_ONLY=${WARN_ONLY_STATE}"
         "-DSTYLE_GUIDE_LINT_EXECUTABLE=${STYLE_GUIDE_LINT_MDL_EXECUTABLE}"
         "-DSOURCES=${COMMANDLINE_SOURCES}"
         -P
         "${_STYLE_GUIDE_LINT_LIST_DIR}/RunStyleGuideLint.cmake"
         PARENT_SCOPE)

endfunction ()

function (_style_guide_lint_check_each_source TARGET)

    set (ADD_NORMAL_CHECK_OPTION_ARGS WARN_ONLY)
    set (ADD_NORMAL_CHECK_MULTIVAR_ARGS BLACKLIST
                                        WHITELIST
                                        SOURCES
                                        DEPENDS)

    cmake_parse_arguments (ADD_CHECKS
                           "${ADD_NORMAL_CHECK_OPTION_ARGS}"
                           ""
                           "${ADD_NORMAL_CHECK_MULTIVAR_ARGS}"
                           ${ARGN})

    # Get a commandline, using options specified in OPTIONS
    cmake_forward_arguments (ADD_CHECKS
                             GET_COMMANDLINE_FORWARD_OPTIONS
                             OPTION_ARGS WARN_ONLY
                             MULTIVAR_ARGS BLACKLIST
                                           WHITELIST)

    # Now run the tool on the source, passing everything after DEPENDS
    cmake_forward_arguments (ADD_CHECKS
                             RUN_TOOL_ON_SOURCE_FORWARD
                             MULTIVAR_ARGS DEPENDS)

    foreach (SOURCE ${ADD_CHECKS_SOURCES})
        _style_guide_lint_get_commandline (STYLE_GUIDE_LINT_COMMAND
                                           SOURCES "${SOURCE}"
                                           ${GET_COMMANDLINE_FORWARD_OPTIONS})
        psq_run_tool_on_source (${TARGET} "${SOURCE}"
                                "style-guide-linter"
                                COMMAND ${STYLE_GUIDE_LINT_COMMAND}
                                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                                ${RUN_TOOL_ON_SOURCE_FORWARD})
        set_property (GLOBAL APPEND
                      PROPERTY STYLE_GUIDE_LINT_SPELLING_CHECK_SOURCES
                      "${SOURCE}")
    endforeach ()

endfunction ()

function (_style_guide_lint_spellcheck_each_source TARGET)

    set (ADD_SPELLING_CHECK_OPTION_ARGS WARN_ONLY)
    set (ADD_SPELLING_CHECK_MULTIVAR_ARGS BLOCK_REGEXPS
                                          SOURCES
                                          DEPENDS)

    cmake_parse_arguments (ADD_CHECKS
                           "${ADD_SPELLING_CHECK_OPTION_ARGS}"
                           ""
                           "${ADD_SPELLING_CHECK_MULTIVAR_ARGS}"
                           ${ARGN})

    # Get a commandline, using options specified in OPTIONS
    cmake_forward_arguments (ADD_CHECKS
                             FORWARD_OPTIONS
                             OPTION_ARGS WARN_ONLY)

    # Now run the tool on the source, passing everything after DEPENDS
    list (APPEND ADD_CHECKS_DEPENDS  # NOLINT:unused/var_in_func
          "${CMAKE_CURRENT_BINARY_DIR}/technical_terms")
    cmake_forward_arguments (ADD_CHECKS
                             RUN_TOOL_ON_SOURCE_FORWARD
                             MULTIVAR_ARGS DEPENDS)

    foreach (SOURCE ${ADD_CHECKS_SOURCES})
        _style_guide_lint_get_spelling_commandline (STYLE_GUIDE_LINT_COMMAND
                                                    SOURCES "${SOURCE}"
                                                    ${FORWARD_OPTIONS})
        psq_run_tool_on_source (${TARGET} "${SOURCE}"
                                "spellcheck-linter"
                                COMMAND ${STYLE_GUIDE_LINT_COMMAND}
                                ${RUN_TOOL_ON_SOURCE_FORWARD}
                                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
    endforeach ()

endfunction ()

function (_style_guide_lint_markdownlint_each_source TARGET)

    set (ADD_SPELLING_CHECK_OPTION_ARGS WARN_ONLY)
    set (ADD_SPELLING_CHECK_MULTIVAR_ARGS BLOCK_REGEXPS
                                          SOURCES
                                          DEPENDS)

    cmake_parse_arguments (ADD_CHECKS
                           "${ADD_SPELLING_CHECK_OPTION_ARGS}"
                           ""
                           "${ADD_SPELLING_CHECK_MULTIVAR_ARGS}"
                           ${ARGN})

    # Get a commandline, using options specified in OPTIONS
    cmake_forward_arguments (ADD_CHECKS
                             FORWARD_OPTIONS
                             OPTION_ARGS WARN_ONLY)

    # Now run the tool on the source, passing everything after DEPENDS
    cmake_forward_arguments (ADD_CHECKS
                             RUN_TOOL_ON_SOURCE_FORWARD
                             MULTIVAR_ARGS DEPENDS)

    foreach (SOURCE ${ADD_CHECKS_SOURCES})
        _style_guide_lint_get_markdownlint_commandline (STYLE_GUIDE_LINT_COMMAND
                                                        SOURCES "${SOURCE}"
                                                        ${FORWARD_OPTIONS})
        psq_run_tool_on_source (${TARGET} "${SOURCE}"
                                "markdownlint"
                                COMMAND ${STYLE_GUIDE_LINT_COMMAND}
                                ${RUN_TOOL_ON_SOURCE_FORWARD}
                                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
    endforeach ()

endfunction ()

function (style_guide_lint_create_global_spelling_check TARGET)

    set (CREATE_GLOBAL_SPELLING_CHECK_OPTION_ARGS WARN_ONLY)
    set (CREATE_GLOBAL_SPELLING_CHECK_MULTIVAR_ARGS BLOCK_REGEXPS
                                                    DEPENDS)

    cmake_parse_arguments (CREATE_GLOBAL_SPELLING_CHECK
                           "${CREATE_GLOBAL_SPELLING_CHECK_OPTION_ARGS}"
                           ""
                           "${CREATE_GLOBAL_SPELLING_CHECK_MULTIVAR_ARGS}"
                           ${ARGN})

    # Note - the name CREATE_GLOBAL_SPELLING_CHECK_SOURCES is important. It must
    # be that name so that it gets forwarded by cmake_forward_arguments later.
    get_property (CREATE_GLOBAL_SPELLING_CHECK_SOURCES
                  GLOBAL PROPERTY STYLE_GUIDE_LINT_SPELLING_CHECK_SOURCES)

    psq_assert_set (CREATE_GLOBAL_SPELLING_CHECK_SOURCES
                    "Add sources with style_guide_lint_target_sources or "
                    "style_guide_lint_sources first before calling "
                    "style_guide_lint_create_global_spelling_check")

    cmake_forward_arguments (CREATE_GLOBAL_SPELLING_CHECK
                             GET_COMMANDLINE_FORWARD_OPTIONS
                             OPTION_ARGS WARN_ONLY
                             MULTIVAR_ARGS BLOCK_REGEXPS
                                           SOURCES)

    _style_guide_lint_get_commandline (STYLE_GUIDE_LINT_COMMAND
                                       ${GET_COMMANDLINE_FORWARD_OPTIONS}
                                       WHITELIST "file/spelling_error")

    set (STAMPFILE "${CMAKE_CURRENT_BINARY_DIR}/code-spelling.stamp")
    add_custom_command (OUTPUT "${STAMPFILE}"
                               "${CMAKE_CURRENT_BINARY_DIR}/technical_terms"
                        COMMAND ${STYLE_GUIDE_LINT_COMMAND}
                        COMMAND "${CMAKE_COMMAND}" -E touch "${STAMPFILE}"
                        DEPENDS
                        ${CREATE_GLOBAL_SPELLING_CHECK_SOURCES}
                        ${CREATE_GLOBAL_SPELLING_CHECK_DEPENDS}
                        COMMENT
                        "Checking spelling in source code comments and strings"
                        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")

    add_custom_target (${TARGET} SOURCES ${STAMPFILE})

endfunction ()

# style_guide_lint_sources
#
# Run polysquare-generic-file-linter on all the specified sources on a target
# called TARGET. Note that this does not check TARGET's sources, but rather
# checks the specified sources once TARGET is run.
#
# TARGET : Target to check sources on
# [Optional] WARN_ONLY : Don't error out, just warn on potential problems.
# [Optional] CHECK_GENERATED : Check generated files too.
# [Optional] WHITELIST : Only run these checks
# [Optional] BLACKLIST : Don't run these checks
# [Optional] DEPENDS : Targets or source files to depend on.
function (style_guide_lint_sources TARGET)

    style_guide_lint_validate (STYLE_GUIDE_LINT_AVAILABLE)

    if (NOT STYLE_GUIDE_LINT_AVAILABLE)

        add_custom_target (${TARGET})
        return ()

    endif ()

    set (OPTIONAL_OPTIONS
         WARN_ONLY
         CHECK_GENERATED
         ADD_TO_ALL)
    set (MULTIVALUE_OPTIONS
         SOURCES
         WHITELIST
         BLACKLIST
         DEPENDS)
    cmake_parse_arguments (STYLE_GUIDE_LINT
                           "${OPTIONAL_OPTIONS}"
                           ""
                           "${MULTIVALUE_OPTIONS}"
                           ${ARGN})

    psq_handle_check_generated_option (STYLE_GUIDE_LINT FILTERED_CHECK_SOURCES
                                       SOURCES ${STYLE_GUIDE_LINT_SOURCES})

    psq_assert_set (FILTERED_CHECK_SOURCES
                    "SOURCES must be set to either native sources "
                    "or generated sources with the CHECK_GENERATED flag set "
                    "when using style_guide_lint_sources")

    # Disable spellcheck for individual files
    list (APPEND STYLE_GUIDE_LINT_BLACKLIST  # NOLINT:unused/var_in_func
          "file/spelling_error")

    cmake_forward_arguments (STYLE_GUIDE_LINT ADD_CHECKS_TO_TARGET_FORWARD
                             OPTION_ARGS WARN_ONLY
                             MULTIVAR_ARGS BLACKLIST
                                           WHITELIST
                                           DEPENDS
                                           SOURCES)

    add_custom_target (${TARGET} SOURCES ${STYLE_GUIDE_LINT_SOURCES})

    _style_guide_lint_check_each_source (${TARGET}
                                         ${ADD_CHECKS_TO_TARGET_FORWARD})

endfunction ()

# style_guide_lint_spellcheck_sources
#
# Run spellcheck-linter over all of the sources for a particular TARGET
# reporting any warnings or errors on stderr.
#
# TARGET : Target to check sources on
# [Optional] WARN_ONLY : Don't error out, just warn on potential problems.
# [Optional] BLOCK_REGEXPS : Regular expressions to ignore
# [Optional] DEPENDS : Targets or source files to depend on.
function (style_guide_lint_spellcheck_sources TARGET)

    style_guide_lint_validate (STYLE_GUIDE_LINT_AVAILABLE)

    if (NOT STYLE_GUIDE_LINT_AVAILABLE)

        add_custom_target (${TARGET})
        return ()

    endif ()

    set (OPTIONAL_OPTIONS WARN_ONLY)
    set (MULTIVALUE_OPTIONS SOURCES
                            BLOCK_REGEXPS
                            DEPENDS)
    cmake_parse_arguments (STYLE_GUIDE_LINT_SPELLCHECK
                           "${OPTIONAL_OPTIONS}"
                           ""
                           "${MULTIVALUE_OPTIONS}"
                           ${ARGN})

    psq_assert_set (STYLE_GUIDE_LINT_SPELLCHECK_SOURCES
                    "SOURCES must be set "
                    "when using style_guide_lint_spellcheck_sources")

    cmake_forward_arguments (STYLE_GUIDE_LINT_SPELLCHECK
                             ADD_CHECKS_TO_TARGET_FORWARD
                             OPTION_ARGS WARN_ONLY
                             MULTIVAR_ARGS BLOCK_REGEXPS
                                           DEPENDS
                                           SOURCES)

    add_custom_target (${TARGET} SOURCES ${STYLE_GUIDE_LINT_SOURCES})

    _style_guide_lint_spellcheck_each_source (${TARGET}
                                              ${ADD_CHECKS_TO_TARGET_FORWARD})

endfunction ()

# style_guide_lint_markdownlint_sources
#
# Run markdownlint over all of the sources for a particular TARGET
# reporting any warnings or errors on stderr.
#
# TARGET : Target to check sources on
# [Optional] WARN_ONLY : Don't error out, just warn on potential problems.
# [Optional] DEPENDS : Targets or source files to depend on.
function (style_guide_lint_markdownlint_sources TARGET)

    style_guide_lint_markdown_validate (STYLE_GUIDE_LINT_AVAILABLE)

    if (NOT STYLE_GUIDE_LINT_AVAILABLE)

        add_custom_target (${TARGET})
        return ()

    endif ()

    set (OPTIONAL_OPTIONS WARN_ONLY)
    set (MULTIVALUE_OPTIONS SOURCES
                            BLOCK_REGEXPS
                            DEPENDS)
    cmake_parse_arguments (STYLE_GUIDE_LINT_SPELLCHECK
                           "${OPTIONAL_OPTIONS}"
                           ""
                           "${MULTIVALUE_OPTIONS}"
                           ${ARGN})

    psq_assert_set (STYLE_GUIDE_LINT_SPELLCHECK_SOURCES
                    "SOURCES must be set "
                    "when using style_guide_lint_markdownlint_sources")

    cmake_forward_arguments (STYLE_GUIDE_LINT_SPELLCHECK
                             ADD_CHECKS_TO_TARGET_FORWARD
                             OPTION_ARGS WARN_ONLY
                             MULTIVAR_ARGS BLOCK_REGEXPS
                                           DEPENDS
                                           SOURCES)

    add_custom_target (${TARGET} SOURCES ${STYLE_GUIDE_LINT_SOURCES})

    _style_guide_lint_markdownlint_each_source (${TARGET}
                                                ${ADD_CHECKS_TO_TARGET_FORWARD})

endfunction ()

# style_guide_lint_target_sources
#
# Run polysquare-generic-file-linter on all the sources for a particular TARGET,
# reporting any warnings or errors on stderr
#
# TARGET : Target to check sources on
# [Optional] WARN_ONLY : Don't error out, just warn on potential problems.
# [Optional] CHECK_GENERATED : Check generated files too.
# [Optional] WHITELIST : Only run these checks
# [Optional] BLACKLIST : Don't run these checks
# [Optional] DEPENDS : Targets or source files to depend on.
function (style_guide_lint_target_sources TARGET)

    psq_strip_extraneous_sources (files_to_check ${TARGET})
    style_guide_lint_sources (${TARGET}
                              SOURCES ${files_to_check}
                              ${ARGN})

endfunction ()
