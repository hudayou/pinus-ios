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

set(MODULE_NAME "sbjson")
set(MODULE_PREFIX "SBJSON")

set(${MODULE_PREFIX}_SRCS
	JSON.h
	NSObject+SBJSON.h
	NSObject+SBJSON.m
	NSString+SBJSON.h
	NSString+SBJSON.m
	SBJSON.h
	SBJSON.m
	SBJsonBase.h
	SBJsonBase.m
	SBJsonParser.h
	SBJsonParser.m
	SBJsonWriter.h
	SBJsonWriter.m)

add_library(${MODULE_NAME} STATIC ${${MODULE_PREFIX}_SRCS})

set_target_properties(${MODULE_NAME} PROPERTIES XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)

set_target_properties(${MODULE_NAME} PROPERTIES PREFIX "lib")
