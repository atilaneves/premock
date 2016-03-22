from reggae import *


flags = '-Wall -Werror -std=c++14 -g'
prod_files = ['prod.cpp']
objs = object_files(src_dirs=["."], flags=flags, exclude_files=prod_files)
prod_objs = object_files(src_files=prod_files,
                         flags=flags + ' -include mock.hpp')
test = link(exe_name="test", dependencies=[objs, prod_objs])
build = Build(test)
