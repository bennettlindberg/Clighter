// https://github.com/llvm/llvm-project/issues/87534

struct a {
  int b;
  int c;
  int d;
  int e;
  int f;
} g, h = {1,0,0,0,0}, *i;

int j(struct a k) {
  struct a *l = &g;
  if (k.b)
    l = i = &k;
  if (l != &k)
    return 233;
  return 0;
}

int main() {
  return j(h);
}
