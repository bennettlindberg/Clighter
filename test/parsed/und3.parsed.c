extern void __builtin_debug(int kind, ...);

typedef unsigned long size_t;

extern int printf(char const * restrict __format, ...);

extern void * malloc(size_t __size);

extern void free(void * __ptr);

int main(void)
{
  int * p;
  int * q;
  p = (int *) malloc(sizeof(int));
  free(p);
  q = (int *) malloc(sizeof(int));
  *p = 1;
  *q = 2;
  if (p == q) {
    printf("%d%d\n", *p, *q);
  }
  return 0;
}


