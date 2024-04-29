#include <stdio.h>

int main() {
  int a = 100;
  int b = 200;
  printf("%d\n", b+++a);  // an undefined behavior
  return 0;
}
