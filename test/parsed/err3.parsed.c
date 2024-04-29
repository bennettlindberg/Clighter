extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

int x = 0;

int test(int * restrict ptr)
{
  *ptr = 1;
  if (ptr == &x) {
    *ptr = 2;
  }
  return *ptr;
}

int main(void)
{
  printf("%d", 314);
  printf("test(&x) = %d\n", test(&x));
  return 0;
}


