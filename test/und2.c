#include <stdio.h>

int main() {
  _Bool p; // uninitialized local variable
  if (p)
      printf("p is true\n");
  if (!p)
      printf("p is false\n");
}
