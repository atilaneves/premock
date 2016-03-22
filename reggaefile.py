from reggae import *


common_flags = '-Wall -Werror -g'
c_flags = common_flags
cpp_flags = common_flags + ' -std=c++14'
prod_objs = object_files(src_files=["prod.c"],
                         flags=c_flags + ' -include mock.h')
test_objs = object_files(src_files=["mock.cpp", "test.cpp"],
                         flags=cpp_flags + ' -DDISABLE_MOCKS')
test = link(exe_name="test", dependencies=[test_objs, prod_objs])
build = Build(test)
