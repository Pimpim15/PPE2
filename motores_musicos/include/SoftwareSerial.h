// Minimal SoftwareSerial.h shim
#ifndef SOFTWARESERIAL_H
#define SOFTWARESERIAL_H

#include <stddef.h>
#include "Stream.h"

class SoftwareSerial : public Stream {
public:
  SoftwareSerial(int rxPin, int txPin) {}
  bool begin(long) { return true; }
  int available() override { return 0; }
  int read() override { return -1; }
  int peek() override { return -1; }
  size_t write(uint8_t) override { return 1; }
  void flush() override {}
  int availableForWrite() override { return 0; }
};

#endif
