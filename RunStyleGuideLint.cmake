# /RunStyleGuideLint.cmake
#
# A wrapper around polysquare-generic-file-linter which can treat a
# positive exit status as a non-error.
#
# See /LICENCE.md for Copyright information

set (STYLE_GUIDE_LINT_EXECUTABLE "" CACHE STRING "")
set (SOURCES "" CACHE STRING "")
set (OPTIONS "" CACHE STRING "")
set (VERBOSE "" CACHE STRING "")
set (WARN_ONLY "" CACHE STRING "")

if (NOT STYLE_GUIDE_LINT_EXECUTABLE)

    message (FATAL_ERROR "polysquare-generic-file-linter script not specified. "
                         "This is a bug in StyleGuideLint.cmake")

endif ()

if (NOT SOURCES)

    message (FATAL_ERROR "SOURCES not specified. "
                         "This is a bug in StyleGuideLint.cmake")

endif ()

# Convert from "," as a delimiter to ";"
string (REPLACE "," ";" OPTIONS "${OPTIONS}")
string (REPLACE "," ";" SOURCES "${SOURCES}")

set (STYLE_GUIDE_LINT_COMMAND_LINE
     "${STYLE_GUIDE_LINT_EXECUTABLE}"
     ${SOURCES}
     ${OPTIONS})

if (VERBOSE)
    string (REPLACE ";" " " STYLE_GUIDE_LINT_PRINTED_COMMAND_LINE
            "${STYLE_GUIDE_LINT_COMMAND_LINE}")
    message (STATUS "${STYLE_GUIDE_LINT_PRINTED_COMMAND_LINE}")
endif ()

execute_process (COMMAND
                 ${STYLE_GUIDE_LINT_COMMAND_LINE}
                 RESULT_VARIABLE RESULT
                 OUTPUT_VARIABLE OUTPUT
                 ERROR_VARIABLE ERROR
                 OUTPUT_STRIP_TRAILING_WHITESPACE
                 ERROR_STRIP_TRAILING_WHITESPACE)

if (NOT RESULT EQUAL 0)

    message ("${OUTPUT}")
    message ("${ERROR}")
    if (NOT WARN_ONLY)
        message (FATAL_ERROR
                 "${STYLE_GUIDE_LINT_EXECUTABLE} found issues with ${SOURCES}")
    endif ()

endif ()
