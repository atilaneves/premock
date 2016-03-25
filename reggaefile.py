from reggae import object_files, link, Build


includes = [".", "example/test", "example/src", "example/deps"]
common_flags = "-Wall -Werror -Wextra -g -fsanitize=address"
c_flags = common_flags
prod_flags = c_flags + " -include mocks.h"
cpp_flags = common_flags + " -std=c++14"
linker_flags = '-fsanitize=address'

# production code we want to test
prod_objs = object_files(src_dirs=["example/src"],
                         includes=includes,
                         flags=prod_flags)

# C dependencies of the production code
dep_objs = object_files(src_dirs=["example/deps"],
                        flags=c_flags)

# Test code where the mock implementations live
test_objs = object_files(src_dirs=["example/test"],
                         includes=includes,
                         flags=cpp_flags)

# The example binary
example_test = link(exe_name="example_test",
                    dependencies=[test_objs, prod_objs, dep_objs],
                    flags=linker_flags)

# Unit tests for premock itself
ut_objs = object_files(src_dirs=["tests"],
                       flags=cpp_flags,
                       includes=[".", "tests"])
ut = link(exe_name="ut", dependencies=ut_objs, flags=linker_flags)

build = Build(example_test, ut)
