cmake_minimum_required(VERSION 3.10)

set(TARGET_NAME ${APP_NAME})

##############################
# Config files:
##############################

#string.xml.in
set(APPLICATION_NAME ${APPLICATION_NAME})
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/android/templates/string.xml.in" "${CMAKE_CURRENT_SOURCE_DIR}/build/res/values/string.xml" @ONLY)

#AndroidManifest.xml.in
set(ANDROID_APK_PACKAGE ${APK_PACKAGE})
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/android/templates/AndroidManifest.xml.in" "${CMAKE_CURRENT_SOURCE_DIR}/build/manifest/AndroidManifest.xml" @ONLY)

#LoadLibraries.java.in
set(ANDROID_SHARED_LIBRARIES_TO_LOAD "${TARGET_NAME}")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/android/templates/LoadLibraries.java.in" "${CMAKE_CURRENT_SOURCE_DIR}/build/java/LoadLibraries.java" @ONLY)


##############################
# Build lib${TARGET_NAME}.so
##############################
project(${TARGET_NAME})

include_directories($ENV{JAVA_HOME}/include)
include_directories($ENV{JAVA_HOME}/include/linux)

# compile android glue code
set(${CMAKE_C_FLAGS}, "${CMAKE_C_FLAGS}")
add_library(native_app_glue STATIC $ENV{ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c)

# compile main app
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -Wall -Werror")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -u ANativeActivity_onCreate")
add_library(${TARGET_NAME} SHARED source/main.cpp)

# include directories
target_include_directories(${TARGET_NAME} PRIVATE $ENV{ANDROID_NDK}/sources/android/native_app_glue)

# add lib dependencies
target_link_libraries(${TARGET_NAME}
android
native_app_glue
EGL
GLESv2
log
)