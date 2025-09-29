// Minimal Stream.h shim
#ifndef STREAM_SHIM_H
#define STREAM_SHIM_H

#include "Arduino.h"

class Stream : public Print {
public:
  virtual int available() { return 0; }
  virtual int read() { return -1; }
  virtual size_t write(const uint8_t *buffer, size_t size) { return size; }
};

#endif
