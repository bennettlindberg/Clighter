// https://github.com/llvm/llvm-project/issues/76017

#include <stdio.h>

typedef struct {
  float a;
  float b;
} my_struct_1;

typedef struct {
  float x;
  double y;
} my_struct_2;

typedef union {
  my_struct_1 s1;
  my_struct_2 s2;
} my_union;

my_union my_func() {
  my_union u;
  u.s1.a = 100.f;
  u.s1.b = 200.f;
  return u;
}

int main() {
  my_union u = my_func();

  if (u.s1.a != 100.f)
    printf("a oops\n");

  if (u.s1.b != 200.f)
    printf("b oops\n");

  return 0;
}
