// https://github.com/llvm/llvm-project/issues/59679

#include <stdio.h>

int x = 0;

int test(int* restrict ptr) {
  *ptr = 1;
  if (ptr == &x)
    *ptr = 2;
  return *ptr;
}

int main() {
  #ifndef __COMPCERT_VERSION__
  printf(__VERSION__);
  #else
  printf("%d", __COMPCERT_VERSION__);
  #endif
  printf("test(&x) = %d\n", test(&x));
}
