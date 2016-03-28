#!/bin/bash
set -e
./ut_cpp
./example_cpp
[[ $# -ne 0 ]] && ./example_d
