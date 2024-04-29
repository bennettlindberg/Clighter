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
extern void *malloc(unsigned long long);
extern void free(void *);
int main(void);
signed char const __stringlit_1[6] = "%d%d\012";

int main(void)
{
  int *p;
  int *q;
  register void *$97;
  register void *$96;
  $96 = malloc(sizeof(int));
  p = (int *) $96;
  free(p);
  $97 = malloc(sizeof(int));
  q = (int *) $97;
  *p = 1;
  *q = 2;
  if (p == q) {
    printf(__stringlit_1, *p, *q);
  }
  return 0;
}


