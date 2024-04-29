extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

int main(void)
{
  int a;
  int b;
  a = 100;
  b = 200;
  printf("%d\n", b++ + a);
  return 0;
  return 0;
}


