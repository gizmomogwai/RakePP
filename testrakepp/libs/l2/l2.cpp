#include "l2.h"

#include "l1.h"
#include <iostream>

void l2() {
  l1();
  std::cout << "l2" << std::endl;
}
