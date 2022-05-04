# scapy-radio

Fork of [BastilleResearch/scapy-radio](https://github.com/BastilleResearch/scapy-radio) ported to GNU Radio 3.8 Ubuntu 20.04 LTS.

GNU Radio 3.9/3.10 and Ubuntu 22.04 LTS coming.


## Introduction

This tool is a modified version of scapy that aims at providing an quick and
efficient pentest tool with RF capabilities.

It includes:

* A modified version of scapy that can leverage GNU Radio to handle a SDR card
* GNU Radio blocks we have written to handle several protocols


## Supported radio protocols:

* 802.15.4 (used by Zigbee, Xbee, 6LoWPAN)


## Requirements

You need to have a full working GNU Radio 3.8 installation.

The provided GRC files have been fully tested with an Ettus B210 SDR but they
should work just as fine with any other UHD compatible device.

You can also edit the GRC files to replace UHD Sink/Source blocks by the
corresponding Osmocom blocks. Don't forget to set the parameters correctly.


## Installation

We tried to make the installation as easy as possible.

If you want to install everything, just launch:

`$ ./install.sh`

The script will prompt you for your password to install the tools system-wide
using `sudo` command.


## Usage

The tool can be launched by using the following in scapy interactive shell:

` >>> load_module("gnuradio")`

## Switch between protocol

Switching between radio protocols is as
simple as:

` >>> gnuradio_start_flowgraph("Zigbee")`

You can also specify the radio protocol directly to some "radio-enabled" functions:

` >>> sniffradio(flowgraph="Zigbee")`

## Radio commands

* `gnuradio_start_flowgraph(flowgraph, params=[], env=None, timeout=20)`: ---
* `gnuradio_stop_flowgraph()`: ---
* `gnuradio_pause_flowgraph(gr_host="localhost", gr_port=8080)`: ---
* `gnuradio_resume_flowgraph(gr_host="localhost", gr_port=8080)`: ---
* `gnuradio_get_vars(*args, gr_host="localhost", gr_port=8080)`: ---
* `gnuradio_set_vars(gr_host="localhost", gr_port=8080, **kwargs)`: ---
* `srradio(pkts, inter=0.1, *args, **kwargs)`: ---
* `sniffradio(opened_socket=None, flowgraph=None, *args, **kwargs)`: ---


