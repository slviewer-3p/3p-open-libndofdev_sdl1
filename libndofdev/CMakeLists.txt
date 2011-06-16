# -*- cmake -*-

cmake_minimum_required(VERSION 2.6)

project(libndofdev)

include_directories( include/ packages/include/ )

SET(CMAKE_BUILD_TYPE "Release")
SET(LIBRARY_OUTPUT_PATH "lib/release/" )
SET(EXECUTABLE_OUTPUT_PATH "bin" )


if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")

    ADD_DEFINITIONS("-m32 -pipe")

    set(libndofdev_SOURCE_FILES
        ndofdev.c
    )

    set(libndofdev_HEADER_FILES
    	${CMAKE_CURRENT_SOURCE_DIR}/include/ndofdev_external.h
    	${CMAKE_CURRENT_SOURCE_DIR}/packages/include/SDL/SDL.h
    )
    
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    message(FATAL_ERROR "Windows configuration not implemented.") 
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "Darwin configuration not implemented.") 
endif()

set_source_files_properties(${libndofdev_HEADER_FILES} PROPERTIES HEADER_FILE_ONLY TRUE)
list(APPEND libndofdev_SOURCE_FILES ${libndofdev_HEADER_FILES})

add_library (ndofdev STATIC ${libndofdev_SOURCE_FILES})

target_link_libraries(ndofdev
    ${libndofdev_LIBRARIES}
)
