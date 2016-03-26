from reggae import object_files, link, Build, user_vars


san_opts = ""
if 'production' in user_vars:
    san_opts = '-fsanitize=address'

includes = [".", "example/cpp/test", "example/src",
            "example/deps", "example/cpp/mocks"]
common_flags = san_opts + " -Wall -Werror -Wextra -g"
c_flags = common_flags
prod_flags = c_flags + " -include mocks.h"
cpp_flags = common_flags + " -std=c++14"
linker_flags = san_opts

# production code we want to test
prod_objs = object_files(src_dirs=["example/src"],
                         includes=includes,
                         flags=prod_flags)

# C dependencies of the production code
dep_objs = object_files(src_dirs=["example/deps"],
                        flags=c_flags)

# Test code where the mock implementations live
mock_objs = object_files(src_dirs=["example/cpp/mocks"],
                         includes=includes,
                         flags=cpp_flags)

# The unit tests themselves
test_objs = object_files(src_dirs=["example/cpp/test"],
                         includes=includes,
                         flags=cpp_flags)

# The example_cpp binary
example_cpp = link(exe_name="example_cpp",
                   dependencies=[test_objs, prod_objs,
                                 dep_objs, mock_objs],
                   flags=linker_flags)

# Unit tests for premock itself
ut_cpp_objs = object_files(src_dirs=["tests"],
                           flags=cpp_flags,
                           includes=[".", "tests"])
ut_cpp = link(exe_name="ut_cpp", dependencies=ut_cpp_objs, flags=linker_flags)


d_objs = object_files(src_dirs=["example/d"],
                      src_files=["premock.d"],
                      flags='-g -unittest',
                      includes=[".", "example/d"])
ut_d = link(exe_name="example_d",
            dependencies=[d_objs, prod_objs, dep_objs],
            flags="-L-lstdc++")


build = Build(example_cpp, ut_cpp, ut_d)
