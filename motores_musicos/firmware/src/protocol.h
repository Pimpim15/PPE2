#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <Arduino.h>

// firmware will forward responses to Serial and, if available, to bleStream
extern Stream* bleStream; // set in main.ino to &bleSerial

inline void replyOK(const char* msg) {
  Serial.print("OK "); Serial.println(msg);
  if (bleStream) {
    bleStream->print("OK "); bleStream->println(msg);
  }
}

inline void replyErr(const char* msg) {
  Serial.print("ERR "); Serial.println(msg);
  if (bleStream) {
    bleStream->print("ERR "); bleStream->println(msg);
  }
}

#endif
