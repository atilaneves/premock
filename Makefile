test: test.cpp prod.cpp prod.hpp
	clang++ -Wall -Werror -std=c++14 -o $@ *.cpp
