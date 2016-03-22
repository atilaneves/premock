from reggae import *


flags = '-Wall -Werror -std=c++14 -g'
prod_objs = object_files(src_files=["prod.cpp"],
                         flags=flags + ' -include mock.hpp')
test_objs = object_files(src_files=["mock.cpp", "test.cpp"],
                         flags=flags + ' -DDISABLE_MOCKS')
test = link(exe_name="test", dependencies=[test_objs, prod_objs])
build = Build(test)
