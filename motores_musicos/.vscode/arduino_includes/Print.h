// Minimal Print.h for IntelliSense
#ifndef PRINT_H
#define PRINT_H

#include <stddef.h>

class Print {
public:
  size_t write(uint8_t) { return 1; }
  size_t write(const char *s) { return 0; }
  void print(const char*) {}
  void println(const char*) {}
};

#endif
