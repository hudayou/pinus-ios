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

set(MODULE_NAME "pinus")
set(MODULE_PREFIX "PINUS")

set(${MODULE_PREFIX}_SRCS
	Pinus.h
	Pinus.m)

include_directories(${WECHAT_INCLUDE_DIRS})
include_directories(${UPMP_INCLUDE_DIRS})
include_directories(${ALIPAY_INCLUDE_DIRS})

# import framework libraries
find_library(FOUNDATION_FRAMEWORK Foundation)
find_library(COREGRAPHICS_FRAMEWORK CoreGraphics)
find_library(SECURITY_FRAMEWORK Security)
find_library(UIKIT_FRAMEWORK UIKit)
find_library(SYSTEMCONFIGURATION_FRAMEWORK SystemConfiguration)
find_library(CFNETWORK_FRAMEWORK CFNetwork)
find_library(MOBILECORESERVICES_FRAMEWORK MobileCoreServices)

mark_as_advanced(FOUNDATION_FRAMEWORK COREGRAPHICS_FRAMEWORK
	SECURITY_FRAMEWORK UIKIT_FRAMEWORK SYSTEMCONFIGURATION_FRAMEWORK
	CFNETWORK_FRAMEWORK MOBILECORESERVICES_FRAMEWORK)
set(EXTRA_LIBS ${FOUNDATION_FRAMEWORK} ${COREGRAPHICS_FRAMEWORK}
	${SECURITY_FRAMEWORK} ${UIKIT_FRAMEWORK}
	${SYSTEMCONFIGURATION_FRAMEWORK} ${CFNETWORK_FRAMEWORK}
	${MOBILECORESERVICES_FRAMEWORK})

add_library(${MODULE_NAME} STATIC ${${MODULE_PREFIX}_SRCS})

set_target_properties(${MODULE_NAME} PROPERTIES XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)

set_target_properties(${MODULE_NAME} PROPERTIES PREFIX "lib")

set(${MODULE_PREFIX}_LIBS
	${WECHAT_LIBRARIES}
	${UPMP_LIBRARIES}
	${ALIPAY_LIBRARIES}
	${EXTRA_LIBS})

set(${MODULE_PREFIX}_LIBS ${${MODULE_PREFIX}_LIBS} sbjson)

target_link_libraries(${MODULE_NAME} ${${MODULE_PREFIX}_LIBS})
