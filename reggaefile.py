from reggae import *


includes = [".", "example/test", "example/src", "example/deps"]
common_flags = '-Wall -Werror -Wextra -g'
c_flags = common_flags
cpp_flags = common_flags + ' -std=c++14'
prod_objs = object_files(src_dirs=["example/src"],
                         includes=includes,
                         flags=c_flags + ' -DPREMOCK_ENABLE -include mocks.h')
test_objs = object_files(src_dirs=["example/test"],
                         includes=includes,
                         flags=cpp_flags)
dep_objs = object_files(src_dirs=["example/deps"],
                        flags=c_flags)
test = link(exe_name="test_example",
            dependencies=[test_objs, prod_objs, dep_objs])
build = Build(test)
