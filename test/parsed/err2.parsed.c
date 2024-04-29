extern void __builtin_debug(int kind, ...);

extern int printf(char const * restrict __format, ...);

struct _363;

struct _363 {
  float a;
  float b;
};

typedef struct _363 my_struct_1;

struct _365;

struct _365 {
  float x;
  double y;
};

typedef struct _365 my_struct_2;

union _367;

union _367 {
  my_struct_1 s1;
  my_struct_2 s2;
};

typedef union _367 my_union;

void __attribute__((__structreturn)) my_func(my_union * _res)
{
  my_union u;
  u.s1.a = 100.0E0F;
  u.s1.b = 200.0E0F;
  *_res = u;
  return;
}

int main(void)
{
  my_union u;
  my_union _res;
  my_func(&_res), u = _res;
  if (u.s1.a != 100.0E0F) {
    printf("a ooops");
  }
  if (u.s1.b != 200.0E0F) {
    printf("b ooops");
  }
  return 0;
  return 0;
}


