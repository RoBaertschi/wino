cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(
  wino
  VERSION 0.0.1
  LANGUAGES C)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

string(COMPARE EQUAL "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_SOURCE_DIR}"
               STANDALONE)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_subdirectory(src)
add_subdirectory(example)
