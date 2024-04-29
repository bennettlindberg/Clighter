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
extern int printf(signed char *, ...);
int test(int *);
int main(void);
signed char const __stringlit_2[15] = "test(&x) = %d\012";

signed char const __stringlit_1[3] = "%d";

int x = 0;

int test(int *ptr)
{
  *ptr = 1;
  if (ptr == &x) {
    *ptr = 2;
  }
  return *ptr;
}

int main(void)
{
  register int $85;
  printf(__stringlit_1, 314);
  $85 = test(&x);
  printf(__stringlit_2, $85);
  return 0;
}


