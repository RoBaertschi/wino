add_executable(wayland_protocol_learn "wayland-protocol-learn.c")

target_link_libraries(wayland_protocol_learn PRIVATE wino)

target_include_directories(
  wayland_protocol_learn PRIVATE "${wino_SOURCE_DIR}/example"
                                 "${wino_BINARY_DIR}/example")


macro(generate_wayland_protocol protocol_file)
  set(protocol_path "${wino_SOURCE_DIR}/deps/wayland/${protocol_file}")

  string(REGEX REPLACE "\\.xml$" "-client-protocol.h" header_file
                       ${protocol_file})
  string(REGEX REPLACE "\\.xml$" "-client-protocol-code.c" code_file
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

  target_sources(wayland_protocol_learn PRIVATE ${header_file} ${code_file})
endmacro()
generate_wayland_protocol("wayland.xml")
generate_wayland_protocol("xdg-shell.xml")

find_package(PkgConfig REQUIRED)
pkg_check_modules(Wayland REQUIRED wayland-client>=0.2.7)

target_link_libraries(wayland_protocol_learn PRIVATE ${Wayland_LIBRARIES})
