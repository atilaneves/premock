from reggae import *

objs = object_files(src_dirs=["."], flags='-Wall -Werror -std=c++14 -g')
test = link(exe_name="test", dependencies=objs)
build = Build(test)
