#include <stdio.h>

int x[2] = {12, 34};
int y[1] = {56};

int main(void) {
  int i = 65536 * 65536 + 2;
  printf("i = %d\n", i);
  printf("x[i] = %d\n", x[i]);
  return 0;
}
