// Minimal SoftwareSerial shim for IntelliSense
#ifndef SOFTWARESERIAL_SHIM_H
#define SOFTWARESERIAL_SHIM_H

#include "Stream.h"

class SoftwareSerial : public Stream {
public:
  SoftwareSerial(int rx, int tx) {}
  void begin(long baud) {}
  int available() { return 0; }
  int read() { return -1; }
  size_t write(uint8_t b) { return 1; }
};

#endif
