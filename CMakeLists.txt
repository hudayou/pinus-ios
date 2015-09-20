# Pinus: A PingPlusPlus SDK Implementation
# Pinus cmake build script
#
# Copyright 2014 Jacky Hu <hudayou@hotmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required(VERSION 2.8)

project(Pinus C CXX)

set(CMAKE_COLOR_MAKEFILE ON)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Include our extra modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/)

# Include cmake modules
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

# Default to release build type
if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Release")
endif()

if(NOT DEFINED BUILD_SHARED_LIBS)
	set(BUILD_SHARED_LIBS OFF)
endif()

if(NOT DEFINED EXPORT_ALL_SYMBOLS)
    set(EXPORT_ALL_SYMBOLS FALSE)
endif()

# Compiler-specific flags
if(CMAKE_COMPILER_IS_GNUCC)
	if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "i686")
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
		else()
			set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=i686")
		endif()
	else()
		if(CMAKE_POSITION_INDEPENDENT_CODE)
			if(${CMAKE_VERSION} VERSION_LESS 2.8.9)
				set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
			endif()
		endif()
	endif()

	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")

	CHECK_C_COMPILER_FLAG (-Wno-unused-result Wno-unused-result)
	if(Wno-unused-result)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-result")
	endif()
	CHECK_C_COMPILER_FLAG (-Wno-unused-but-set-variable Wno-unused-but-set-variable)
	if(Wno-unused-but-set-variable)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-but-set-variable")
	endif()
	CHECK_C_COMPILER_FLAG(-Wno-deprecated-declarations Wno-deprecated-declarations)
	if(Wno-deprecated-declarations)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-deprecated-declarations")
	endif()
	CHECK_CXX_COMPILER_FLAG(-Wno-deprecated-declarations Wno-deprecated-declarationsCXX)
	if(Wno-deprecated-declarationsCXX)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
	endif()

	if(NOT EXPORT_ALL_SYMBOLS)
		message(STATUS "GCC default symbol visibility: hidden")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
	endif()
	if(BUILD_TESTING)
		CHECK_C_COMPILER_FLAG(-Wno-format Wno-format)
		if(Wno-format)
			set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-format")
		endif()
	endif()
	if(CMAKE_BUILD_TYPE STREQUAL "Release")
		set(CMAKE_C_FLAGS_RELEASE "-DNDEBUG")
		set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

		CHECK_C_COMPILER_FLAG (-Wno-builtin-macro-redefined Wno-builtin-macro-redefined)
		if(Wno-builtin-macro-redefined)
			set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -Wno-builtin-macro-redefined")
			set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -D__FILE__='\"$(subst ${CMAKE_BINARY_DIR}/,,$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<)))\"'")
		endif()

		CHECK_CXX_COMPILER_FLAG (-Wno-builtin-macro-redefined Wno-builtin-macro-redefinedCXX)
		if(Wno-builtin-macro-redefinedCXX)
			set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Wno-builtin-macro-redefined")
			set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -D__FILE__='\"$(subst ${CMAKE_BINARY_DIR}/,,$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<)))\"'")
		endif()
	else()
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
	endif()
endif()

if("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-parameter")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-macros -Wno-padded")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-c11-extensions -Wno-gnu")
	CHECK_C_COMPILER_FLAG(-Wno-deprecated-declarations Wno-deprecated-declarations)
	if(Wno-deprecated-declarations)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-deprecated-declarations")
	endif()
	CHECK_CXX_COMPILER_FLAG(-Wno-deprecated-declarations Wno-deprecated-declarationsCXX)
	if(Wno-deprecated-declarationsCXX)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
	endif()
endif()

set(EXTERNAL_WECHAT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/wechat")
set(WECHAT_LIBRARIES "${EXTERNAL_WECHAT_PATH}/lib/libWeChatSDK.a")
set(WECHAT_INCLUDE_DIRS "${EXTERNAL_WECHAT_PATH}/include")
mark_as_advanced(WECHAT_LIBRARIES WECHAT_INCLUDE_DIRS)

set(EXTERNAL_UPMP_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/upmp")
set(UPMP_LIBRARIES "${EXTERNAL_UPMP_PATH}/lib/libUPPayPlugin.a")
set(UPMP_INCLUDE_DIRS "${EXTERNAL_UPMP_PATH}/include")
mark_as_advanced(UPMP_LIBRARIES UPMP_INCLUDE_DIRS)

set(EXTERNAL_ALIPAY_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/alipay")
set(ALIPAY_LIBRARIES "${EXTERNAL_ALIPAY_PATH}/lib/AlixPaylib_arc.a")
set(ALIPAY_INCLUDE_DIRS "${EXTERNAL_ALIPAY_PATH}/include")
mark_as_advanced(ALIPAY_LIBRARIES ALIPAY_INCLUDE_DIRS)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/pinus)

add_subdirectory(pinus)
add_subdirectory(json)
add_subdirectory(example)
