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
int a(void);
int b(void);
int c(void);
int main(void);
signed char const __stringlit_4[4] = "%d\012";

signed char const __stringlit_3[3] = "c ";

signed char const __stringlit_2[3] = "b ";

signed char const __stringlit_1[3] = "a ";

int a(void)
{
  printf(__stringlit_1);
  return 1;
}

int b(void)
{
  printf(__stringlit_2);
  return 2;
}

int c(void)
{
  printf(__stringlit_3);
  return 3;
}

int main(void)
{
  register int $89;
  register int $88;
  register int $87;
  $87 = a();
  $88 = b();
  $89 = c();
  printf(__stringlit_4, $87 + ($88 + $89));
  return 0;
  return 0;
}


