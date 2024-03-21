# Most code taken from glfw ->
# https://github.com/glfw/glfw/blob/master/src/CMakeLists.txt MIT i think

add_library(wino "${wino_SOURCE_DIR}/include/wino/wino.h" posix_shm.c enums.c wino.c)

find_package(PkgConfig REQUIRED)

target_include_directories(
  wino
  PUBLIC "$<BUILD_INTERFACE:${wino_SOURCE_DIR}/include>"
         ${CMAKE_CURRENT_BINARY_DIR}
         "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")


target_include_directories(wino PRIVATE "${wino_SOURCE_DIR}/src"
                                        "${CMAKE_CURRENT_BINARY_DIR}")

if (LINUX)
  target_compile_definitions(wino PUBLIC WINO_LINUX)
elseif(${WIN32})
  target_compile_definitions(wino PUBLIC WINO_WIN32)
elseif(${APPLE})
  target_compile_definitions(wino PUBLIC WINO_APPLE)
endif()

include(CheckIncludeFiles)

check_include_files(unistd.h HAVE_UNISTD_H)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in
               ${CMAKE_CURRENT_BINARY_DIR}/config.h)

target_sources(wino PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/config.h)

# On Linux we only support wayland, as X11 is already slowly dying and it is just not worth adding support for something outdated
if(LINUX)
  find_program(WAYLAND_SCANNER_EXE NAMES wayland-scanner)
  if(NOT WAYLAND_SCANNER_EXE)
    message(FATAL_ERROR "Executable wayland-scanner was not found.")
  endif()

  macro(generate_wayland_protocol protocol_file)
    set(protocol_path "${wino_SOURCE_DIR}/deps/wayland/${protocol_file}")

    string(REGEX REPLACE "\\.xml$" "-client-protocol.h" header_file
                         ${protocol_file})
    string(REGEX REPLACE "\\.xml$" "-client-protocol-code.h" code_file
                         ${protocol_file})

    add_custom_command(
      OUTPUT ${header_file}
      DEPENDS "${protocol_path}"
      COMMAND "${WAYLAND_SCANNER_EXE}" ARGS client-header "${protocol_path}"
              ${header_file}
      VERBATIM)

    add_custom_command(
      OUTPUT ${code_file}
      DEPENDS "${protocol_path}"
      COMMAND "${WAYLAND_SCANNER_EXE}" ARGS private-code "${protocol_path}"
              ${code_file}
      VERBATIM)

    target_sources(wino PRIVATE ${header_file} ${code_file})
  endmacro()
  generate_wayland_protocol("wayland.xml")
  generate_wayland_protocol("xdg-shell.xml")

  pkg_check_modules(Wayland REQUIRED wayland-client>=0.2.7)
  target_include_directories(wino PRIVATE ${Wayland_LIBRARIES})

endif()
