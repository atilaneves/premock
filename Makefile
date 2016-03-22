all: test

FLAGS=-Wall -Werror -std=c++14 -g

test.o: test.cpp prod.hpp Makefile
	clang++ $(FLAGS) -o $@ -c $<

prod.o: prod.cpp prod.hpp Makefile
	clang++ $(FLAGS) -include mock.hpp -o $@ -c $<

mock.o: mock.cpp prod.hpp Makefile
	clang++ $(FLAGS) -o $@ -c $<

test: test.o prod.o mock.o
	clang++ $(FLAGS) -o $@ $^
