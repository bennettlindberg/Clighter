#include <stdio.h>
#include <stdlib.h>

int main(void) {
  int *p = (int *)malloc(sizeof(int));
  free(p);
  int *q = (int *)malloc(sizeof(int));
  *p = 1; // UB access to a pointer that was freed
  *q = 2;
  if (p == q) // UB access to a pointer that was freed
    printf("%d%d\n", *p, *q);
}
