#!/bin/bash

set -euo pipefail

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TOP_DIR="$THIS_DIR"/..

mkdir -p "$TOP_DIR"/objs/example_cpp.objs/example/{cpp,d,deps,src}
mkdir -p "$TOP_DIR"/objs/example_cpp.objs/example/cpp/{mocks,test}
mkdir -p "$TOP_DIR"/objs/ut_cpp.objs/tests
