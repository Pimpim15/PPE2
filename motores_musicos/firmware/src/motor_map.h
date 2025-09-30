#ifndef MOTOR_MAP_H
#define MOTOR_MAP_H

#include <stdint.h>

// HM-10 pins (SoftwareSerial)
#define HM10_RX_PIN 10 // UNO receives from HM-10 TX
#define HM10_TX_PIN 11 // UNO transmits to HM-10 RX
// STATE moved to D9 to avoid conflict with A STEP on some CNC shields
#define HM10_STATE_PIN 9

// Motor pins
#define X_STEP 2
#define X_DIR 5
#define Y_STEP 3
#define Y_DIR 6
#define Z_STEP 4
#define Z_DIR 7
#define A_STEP 12
#define A_DIR 13

#define EN_PIN 8 // LOW to enable

typedef struct {
  uint16_t dt_ms; // time offset from start
  long x;
  long y;
  long z;
  long a;
} Event;

#endif
