# /CMakeLists.txt
#
# Main entry point for StyleGuideLint tests.
#
# See /LICENCE.md for Copyright information

include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

include ("cmake/cmake-module-common/Common" OPTIONAL)
include (StyleGuideLint)

if (NOT CMAKE_SCRIPT_MODE_FILE)

    style_guide_lint_validate (HAVE_STYLE_GUIDE_LINT)

else ()

    # Set these variables such that the conditions to add tests always pass
    # as we're not in the pre-configure phase, which is the only place
    # we'd want them to fail.
    set (HAVE_STYLE_GUIDE_LINT TRUE)

endif ()

set (_CUR_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (CMAKE_FILES
     "${_CUR_LIST_DIR}/StyleGuideLint.cmake"
     "${_CUR_LIST_DIR}/RunStyleGuideLint.cmake"
     "${_CUR_LIST_DIR}/FindPSQGENERICLINTER.cmake"
     "${_CUR_LIST_DIR}/FindMARKDOWNLINT.cmake")
set (MARKDOWN_FILES
     "${CMAKE_CURRENT_LIST_DIR}/LICENCE.md"
     "${CMAKE_CURRENT_LIST_DIR}/README.md")

if (COMMAND cmake_module_add_common_targets)

    cmake_module_add_common_targets (NAMESPACE "style_guide_lint"
                                     CMAKE_FILES ${CMAKE_FILES}
                                     DOCUMENTATION_FILES ${MARKDOWN_FILES})

endif ()
