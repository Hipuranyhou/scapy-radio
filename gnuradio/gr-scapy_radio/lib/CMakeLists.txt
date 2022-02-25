# Copyright 2011,2012 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

########################################################################
# Setup library
########################################################################
include(GrPlatform) #define LIB_SUFFIX

list(APPEND scapy_radio_sources
    add_gr_header_impl.cc
    strip_gr_header_impl.cc
)

set(scapy_radio_sources "${scapy_radio_sources}" PARENT_SCOPE)
if(NOT scapy_radio_sources)
	MESSAGE(STATUS "No C++ sources... skipping lib/")
	return()
endif(NOT scapy_radio_sources)

add_library(gnuradio-scapy_radio SHARED ${scapy_radio_sources})
target_link_libraries(gnuradio-scapy_radio gnuradio::gnuradio-runtime)
target_include_directories(gnuradio-scapy_radio
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
    PUBLIC $<INSTALL_INTERFACE:include>
  )
set_target_properties(gnuradio-scapy_radio PROPERTIES DEFINE_SYMBOL "gnuradio_scapy_radio_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-scapy_radio PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
include(GrMiscUtils)
GR_LIBRARY_FOO(gnuradio-scapy_radio)

########################################################################
# Build and register unit test
########################################################################
include(GrTest)

# If your unit tests require special include paths, add them here
#include_directories()
# List all files that contain Boost.UTF unit tests here
list(APPEND test_scapy_radio_sources
)
# Anything we need to link to for the unit tests go here
list(APPEND GR_TEST_TARGET_DEPS gnuradio-scapy_radio)

if(NOT test_scapy_radio_sources)
    MESSAGE(STATUS "No C++ unit tests... skipping")
    return()
endif(NOT test_scapy_radio_sources)

foreach(qa_file ${test_scapy_radio_sources})
    GR_ADD_CPP_TEST("scapy_radio_${qa_file}"
        ${CMAKE_CURRENT_SOURCE_DIR}/${qa_file}
    )
endforeach(qa_file)

