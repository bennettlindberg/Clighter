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
extern int puts(signed char *);
void f1(void);
void f2(void);
int main(void);
signed char const __stringlit_1[24] = "Formatting /dev/sda1...";

void f1(void)
{
  int i;
  i = 2147483640;
  for (; 1; i = i + 1) {
    if (! (i >= 0)) {
      break;
    }
  }
}

void f2(void)
{
  puts(__stringlit_1);
}

void (* volatile p1)(void) = &f1;

void (* volatile p2)(void) = &f2;

int main(void)
{
  register void (* volatile $92)(void);
  $92 = builtin volatile load int64(&p1);
  $92();
  return 0;
  return 0;
}


