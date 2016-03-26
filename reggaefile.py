from reggae import object_files, link, Build, user_vars, scriptlike, Target, static_library


san_opts = ""
if 'production' in user_vars:
    san_opts = '-fsanitize=address'

includes = [".", "example_cpp/test", "example_cpp/src", "example_cpp/deps"]
common_flags = san_opts + " -Wall -Werror -Wextra -g"
c_flags = common_flags
prod_flags = c_flags + " -include mocks.h"
cpp_flags = common_flags + " -std=c++14"
linker_flags = san_opts

# production code we want to test
prod_objs = object_files(src_dirs=["example_cpp/src"],
                         includes=includes,
                         flags=prod_flags)

# C dependencies of the production code
dep_objs = object_files(src_dirs=["example_cpp/deps"],
                        flags=c_flags)

# Test code where the mock implementations live
test_objs = object_files(src_dirs=["example_cpp/test"],
                         includes=includes,
                         flags=cpp_flags)

# The example_cpp binary
example_cpp_test = link(exe_name="example_cpp_test",
                        dependencies=[test_objs, prod_objs, dep_objs],
                        flags=linker_flags)

# Unit tests for premock itself
ut_cpp_objs = object_files(src_dirs=["tests"],
                           flags=cpp_flags,
                           includes=[".", "tests"])
ut_cpp = link(exe_name="ut_cpp", dependencies=ut_cpp_objs, flags=linker_flags)


d_objs = object_files(src_dirs=["example_d"],
                      src_files=["premock.d"],
                      flags='-g -unittest',
                      includes=[".", "example_d"])
ut_d = link(exe_name="ut_d",
            dependencies=[d_objs, prod_objs])


build = Build(example_cpp_test, ut_cpp, ut_d)
