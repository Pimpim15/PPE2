// Minimal Arduino.h shim for IntelliSense only
#ifndef ARDUINO_SHIM_H
#define ARDUINO_SHIM_H

#include <stdint.h>
#include "Print.h"

typedef uint8_t byte;
extern unsigned long millis(void);
extern void pinMode(int pin, int mode);
extern void digitalWrite(int pin, int val);
extern int digitalRead(int pin);
extern void delay(unsigned long ms);

#define INPUT 0
#define OUTPUT 1

// Forward declare Stream to satisfy declarations
class Stream;

extern Print Serial;

#endif
