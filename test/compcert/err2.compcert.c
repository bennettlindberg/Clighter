struct _350;
struct _352;
union _354;
struct _350 {
  float a;
  float b;
};

struct _352 {
  float x;
  double y;
};

union _354 {
  struct _350 s1;
  struct _352 s2;
};

static signed char const __stringlit_2[8];

static signed char const __stringlit_1[8];

extern void my_func(union _354 *);

extern int main(void);

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

signed char const __stringlit_2[8] = "b ooops";

signed char const __stringlit_1[8] = "a ooops";

extern void __builtin_debug(int, ...);

extern int printf(signed char *, ...);

void my_func(union _354 *_res)
{
  union _354 u;
  u.s1.a = 100.f;
  u.s1.b = 200.f;
  *_res = u;
  return;
}

int main(void)
{
  union _354 u;
  union _354 _res;
  my_func(&_res), u = _res;
  if (u.s1.a != 100.f) {
    printf(__stringlit_1);
  }
  if (u.s1.b != 200.f) {
    printf(__stringlit_2);
  }
  return 0;
  return 0;
}


