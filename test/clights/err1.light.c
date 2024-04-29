struct a;
struct a {
  int b;
  int c;
  int d;
  int e;
  int f;
};

extern unsigned int __compcert_va_int32(void *);
extern unsigned long long __compcert_va_int64(void *);
extern double __compcert_va_float64(void *);
extern void *__compcert_va_composite(void *, unsigned long long);
extern long long __compcert_i64_dtos(double);
extern unsigned long long __compcert_i64_dtou(double);
extern double __compcert_i64_stod(long long);
extern double __compcert_i64_utod(unsigned long long);
extern float __compcert_i64_stof(long long);
extern float __compcert_i64_utof(unsigned long long);
extern long long __compcert_i64_sdiv(long long, long long);
extern unsigned long long __compcert_i64_udiv(unsigned long long, unsigned long long);
extern long long __compcert_i64_smod(long long, long long);
extern unsigned long long __compcert_i64_umod(unsigned long long, unsigned long long);
extern long long __compcert_i64_shl(long long, int);
extern unsigned long long __compcert_i64_shr(unsigned long long, int);
extern long long __compcert_i64_sar(long long, int);
extern long long __compcert_i64_smulh(long long, long long);
extern unsigned long long __compcert_i64_umulh(unsigned long long, unsigned long long);
extern void __builtin_debug(int, ...);
int j(struct a);
int main(void);
struct a g;

struct a h = { 1, 0, 0, 0, 0, };

struct a *i;

int j(struct a k)
{
  struct a *l;
  register struct a *$70;
  l = &g;
  if (k.b) {
    $70 = (struct a *) &k;
    i = $70;
    l = $70;
  }
  if (l != &k) {
    return 233;
  }
  return 0;
}

int main(void)
{
  register int $70;
  $70 = j(h);
  return $70;
  return 0;
}


