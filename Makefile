FLAGS=-Wall -Werror -std=c++14

test.o: test.cpp prod.hpp
	clang++ $(FLAGS) -o $@ -c $<

prod.o: prod.cpp prod.hpp
	clang++ $(FLAGS) -o $@ -c $<

test: test.o prod.o
	clang++ $(FLAGS) -o $@ $^
