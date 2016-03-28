#!/bin/bash
set -e
./ut_cpp
./example_cpp
if [[ $# -ne 0 ]]; then
    ./example_d
fi
