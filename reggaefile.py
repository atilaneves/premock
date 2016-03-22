from reggae import *


common_flags = '-Wall -Werror -g'
c_flags = common_flags
cpp_flags = common_flags + ' -std=c++14'
prod_objs = object_files(src_files=["prod.c"],
                         flags=c_flags + ' -include mocks.h')
test_objs = object_files(src_files=["mock_network.cpp",
                                    "mock_other.cpp",
                                    "test.cpp"],
                         flags=cpp_flags + ' -DDISABLE_MOCKS')
dep_objs = object_files(src_files=["other.c"],
                        flags=c_flags + ' -DDISABLE_MOCKS')
test = link(exe_name="test", dependencies=[test_objs, prod_objs, dep_objs])
build = Build(test)
