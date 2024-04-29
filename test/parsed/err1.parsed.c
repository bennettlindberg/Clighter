extern void __builtin_debug(int kind, ...);

struct a;

struct a {
  int b;
  int c;
  int d;
  int e;
  int f;
};

struct a g;

struct a h = {1, 0, 0, 0, 0, };

struct a * i;

int j(struct a k)
{
  struct a * l;
  l = &g;
  if (k.b) {
    l = i = &k;
  }
  if (l != &k) {
    return 233;
  }
  return 0;
}

int main(void)
{
  return j(h);
  return 0;
}


