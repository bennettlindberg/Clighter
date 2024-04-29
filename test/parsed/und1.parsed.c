extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

int x[2] = {12, 34, };

int y[1] = {56, };

int main(void)
{
  int i;
  i = 65536 * 65536 + 2;
  printf("i = %d\n", i);
  printf("x[i] = %d\n", x[i]);
  return 0;
  return 0;
}


