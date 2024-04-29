#include <stdio.h>
int a() { printf("a "); return 1; }
int b() { printf("b "); return 2; }
int c() { printf("c "); return 3; }
int main () {
  printf("%d\n", a() + (b() + c()));
  return 0;
}
