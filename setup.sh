#!/bin/bash

# Copyright (C) Airbus DS CyberSecurity, 2014
# Authors: Jean-Michel Picod, Arnaud Lebrun, Jonathan Christofer Demay

base="$(pwd)"

apply_patches() {
  [ ! -d "${base}/patch/${1}" ] && return 
  [ $(ls -A "${base}/patch/${1}" | wc -l) -eq 0 ] && return 
  for p in ${base}/patch/${1}/*.patch; do
    patch -p0 <"${p}"
  done
}

get_gr_block() {
  cd "${base}/gnuradio"
  block_name="$(basename ${1} | cut -d. -f1)"
  git clone "${1}"
  cd "${block_name}"
  git checkout maint-3.8
  cd ..
  apply_patches "${block_name}"
  cd "${base}"
}

scapy_install() {
  cd "${base}"
  git clone https://github.com/secdev/scapy.git
  apply_patches scapy 
  cd scapy
  sudo python3 setup.py install
  cd "${base}"
}

grc_install() {
  cd "${base}"
  mkdir -p "${HOME}/.scapy/radio/"
  [ $(ls -A "gnuradio/grc" | wc -l) -eq 0 ] && return
  for i in gnuradio/grc/*.grc; do
    mkdir -p "${HOME}/.scapy/radio/$(basename ${i} .grc)"
    cp "${i}" "${HOME}/.scapy/radio/"
    if grcc -o "${HOME}/.scapy/radio/$(basename ${i} .grc)" "${i}"; then
      # gnuradio 3.8 xmlrpc is not python3, we fix it for you :-)
      sed -i 's/import SimpleXMLRPCServer/from xmlrpc.server import SimpleXMLRPCServer/g' "${HOME}/.scapy/radio/$(basename ${i} .grc)/top_block.py"
      sed -i 's/SimpleXMLRPCServer.SimpleXMLRPCServer/SimpleXMLRPCServer/g' "${HOME}/.scapy/radio/$(basename ${i} .grc)/top_block.py"
    fi
  done
}

gr_block_install() {
  cd "${1}"
  mkdir -p build && cd build 
  cmake .. && make && sudo make install && sudo ldconfig
  cd "${base}"
}

blocks_install() {
  cd "${base}"
  while IFS= read -r block; do
    get_gr_block "${block}"
  done <"gnuradio/blocks.txt"
  for d in gnuradio/gr-*; do
    gr_block_install "${d}"
  done
}
if [ $# -eq 0 ]; then
  scapy_install
  blocks_install
  grc_install
else
  while [ $# -ne 0 ]; do
    case $1 in
      scapy)
	scapy_install
	;;
      grc)
	grc_install
	;;
      blocks)
	blocks_install
	;;
      *)
	echo "Invalid option: $1"
    esac
    shift
  done
fi

