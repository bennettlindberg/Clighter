extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

int main(void)
{
  int a;
  a = 0;
  printf("%d\n", a++ + a);
  return 0;
  return 0;
}


