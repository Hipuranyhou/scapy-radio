#!/bin/bash

# Copyright (C) Airbus DS CyberSecurity, 2014
# Authors: Jean-Michel Picod, Arnaud Lebrun, Jonathan Christofer Demay

print_status() {
  [ ! -t 1 ] && return
  [ -z "$(tput colors)" ] && return
  echo "$(tput rev)$(tput bold) ${1} $(tput sgr0)"
}

apply_patches() {
  print_status "Patching ${1}"
  [ ! -d "${base_dir}/patch/${1}" ] && return
  oifs="$IFS"
  IFS=$'\n'
  for p in $(find "${base_dir}/patch/${1}" -type f); do
    patch -p0 <"${p}"
  done
  IFS="${oifs}"
}

gr_block_name() {
  echo "$(basename -s .git "${1}")"
}

gr_block_get() {
  block_name="$(gr_block_name "${1}")"
  print_status "Getting ${block_name}"
  git clone "${1}"
  cd "${block_name}"
  git checkout maint-3.8
  cd ..
}

gr_block_install() {
  cd "${1}"
  mkdir -p build && cd build
  print_status "Configuring ${1}"
  cmake ..
  print_status "Building ${1}"
  make
  print_status "Installing ${1}"
  sudo make install && sudo ldconfig
  cd ../..
}

# "consts"
base_dir="$(pwd)"
build_dir="${base_dir}/build"
grc_dir="${HOME}/.config/scapy/radio/flowgraphs"

# prepare directories
mkdir -p "${build_dir}" "${grc_dir}"

# install scapy
cd "${build_dir}"
print_status "SCAPY"
cp -r ../scapy .
apply_patches scapy
cd scapy
print_status "Building and installing scapy"
sudo python3 setup.py install
cd "${base_dir}"

# install gnuradio blocks
cd "${build_dir}"
print_status "GNURADIO BLOCKS"
while IFS= read -r block_url; do
  block_name="$(gr_block_name "${block_url}")"
  gr_block_get "${block_url}"
  apply_patches "${block_name}"
  gr_block_install "${block_name}"
done <../gnuradio/blocks.txt
cp -r ../gnuradio/gr-scapy_radio .
apply_patches gr-scapy_radio
gr_block_install gr-scapy_radio
cd "${base_dir}"

# install gnuradio flowgraphs
cd gnuradio/grc
print_status "GNURADIO FLOWGRAPHS"
oifs="$IFS"
IFS=$'\n'
for g in $(find . -type f -name "*.grc"); do
  grc_name="$(basename -s .grc "${g}")"
  grc_path="${grc_dir}/${grc_name}"
  print_status "Building and installing ${grc_name}"
  mkdir -p "${grc_path}"
  cp "${g}" "${grc_path}"
  if grcc -o "${grc_path}" "${g}"; then
    # gnuradio 3.8 xmlrpc is not python3, we fix it for you :-)
    sed -i 's/import SimpleXMLRPCServer/from xmlrpc.server import SimpleXMLRPCServer/g' "${grc_path}/top_block.py"
    sed -i 's/SimpleXMLRPCServer.SimpleXMLRPCServer/SimpleXMLRPCServer/g' "${grc_path}/top_block.py"
  fi
done
IFS="${oifs}"
cd "${base_dir}"

