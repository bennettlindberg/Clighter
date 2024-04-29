extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

int a(void)
{
  printf("a ");
  return 1;
}

int b(void)
{
  printf("b ");
  return 2;
}

int c(void)
{
  printf("c ");
  return 3;
}

int main(void)
{
  printf("%d\n", a() + (b() + c()));
  return 0;
  return 0;
}


