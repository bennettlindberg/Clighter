#include <stdio.h>

void f1(void) {
  for (int i = 2147483640; i >= 0; i++) {
    // Undefined Behavior      
  }
}

void f2(void) {
    puts("Formatting /dev/sda1...");
    // system("mkfs -t btrfs -f /dev/sda1");
}

// Prevents inlining
void (*volatile p1)(void) = f1;
void (*volatile p2)(void) = f2;

int main(void) {
    p1();
    return 0;
}

