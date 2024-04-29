extern void __builtin_debug(int kind, ...);

extern int puts(char const * __s);

void f1(void)
{
  int i;
  i = 2147483640;
  for (/*nothing*/; i >= 0; i++) {
    /*skip*/;
  }
}

void f2(void)
{
  puts("Formatting /dev/sda1...");
}

void (* volatile p1)(void) = f1;

void (* volatile p2)(void) = f2;

int main(void)
{
  p1();
  return 0;
  return 0;
}


