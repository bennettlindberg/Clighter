extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

int main(void)
{
  _Bool p;
  if (p) {
    printf("p is true\n");
  }
  if (!p) {
    printf("p is false\n");
  }
  return 0;
}


