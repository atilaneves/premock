#include "prod.hpp"
#include <iostream>
#include <string>
#include <stdexcept>


using namespace std;



int main() {
    // if(argc != 2) throw runtime_error("Must pass in int");
    // const auto i = stoi(argv[1]);
    const auto res = func(42);
    if(res != 7) throw runtime_error("Must be 7!!!!!");
    cout << "Result was " << res << endl;
}
