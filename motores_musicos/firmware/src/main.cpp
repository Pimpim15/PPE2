#include <Arduino.h>
#include <HardwareSerial.h>
#include <SoftwareSerial.h>
#include <AccelStepper.h>
#include <cstddef>
#include <stddef.h>
#include "motor_map.h"
#include "protocol.h"
#include "demo_score.h"
#include "imperial_score.h"

extern HardwareSerial Serial;

// ---------- Global Declarations ----------

// SoftwareSerial para HM-10 (RX, TX)
SoftwareSerial bleSerial(HM10_RX_PIN, HM10_TX_PIN);
Stream* bleStream = nullptr;

// Instâncias do AccelStepper (modo DRIVER: step, dir)
AccelStepper stepX(AccelStepper::DRIVER, X_STEP, X_DIR);
AccelStepper stepY(AccelStepper::DRIVER, Y_STEP, Y_DIR);
AccelStepper stepZ(AccelStepper::DRIVER, Z_STEP, Z_DIR);
AccelStepper stepA(AccelStepper::DRIVER, A_STEP, A_DIR);

AccelStepper* motors[4] = { &stepX, &stepY, &stepZ, &stepA };

// Estado do player
bool playing = false;
bool paused = false;
size_t score_idx = 0;
unsigned long score_start_ms = 0;
unsigned long last_tick_ms = 0;
const unsigned long TICK_MS = 10;

// Buffer do parser
char lineBuf[64];
size_t linePos = 0;

// ---------- Function Definitions ----------

void motorsEnable(bool on) {
  digitalWrite(EN_PIN, on ? LOW : HIGH);
}

void setSpeeds(float v01) {
  if (v01 < 0) v01 = 0;
  if (v01 > 1) v01 = 1;
  float maxSpeed = 200.0 + 1200.0 * v01;
  float acc = 500.0 + 2000.0 * v01;
  for (int i = 0; i < 4; i++) {
    motors[i]->setMaxSpeed(maxSpeed);
    motors[i]->setAcceleration(acc);
  }
  replyOK("SPD SET");
}

void applyTarget(long tx, long ty, long tz, long ta) {
  motors[0]->moveTo(tx);
  motors[1]->moveTo(ty);
  motors[2]->moveTo(tz);
  motors[3]->moveTo(ta);
  char buf[128];
  snprintf(buf, sizeof(buf), "EVENT_APPLY t=%lu x=%ld y=%ld z=%ld a=%ld", millis(), tx, ty, tz, ta);
  Serial.println(buf);
  if (bleStream) {
    bleStream->println(buf);
  }
}

void resetScore() {
  score_idx = 0;
  score_start_ms = millis();
}

void stopPlayback() {
  playing = false;
  paused = false;
  motorsEnable(false);
  for (int i = 0; i < 4; i++) {
    motors[i]->stop();
  }
  replyOK("STOP");
}

void setPlayerStateLog(const char* s) {
  Serial.print("PLAYER_STATE ");
  Serial.println(s);
  if (bleStream) {
    bleStream->print("PLAYER_STATE ");
    bleStream->println(s);
  }
}

void startPlayback(const Event* score, size_t n) {
  motorsEnable(true);
  playing = true;
  paused = false;
  score_idx = 0;
  score_start_ms = millis();
  last_tick_ms = millis();
  if (n > 0) {
    applyTarget(score[0].x, score[0].y, score[0].z, score[0].a);
  }
  replyOK("PLAY");
  setPlayerStateLog("PLAY");
}

void tickPlayer(const Event* score, size_t n) {
  if (!playing || paused || n == 0) return;
  unsigned long now = millis();
  // Atualiza os motores
  for (int i = 0; i < 4; i++) {
    motors[i]->run();
  }
  // Processa eventos do score
  while (score_idx + 1 < n) {
    unsigned long targetTime = score_start_ms + score[score_idx+1].dt_ms;
    if (now >= targetTime) {
      score_idx++;
      applyTarget(score[score_idx].x, score[score_idx].y, score[score_idx].z, score[score_idx].a);
    } else
      break;
  }
  // Finaliza se os eventos terminarem e os motores pararam
  if (score_idx + 1 >= n) {
    bool busy = false;
    for (int i = 0; i < 4; i++) {
      if (motors[i]->distanceToGo() != 0)
        busy = true;
    }
    if (!busy) {
      playing = false;
      replyOK("DONE");
      setPlayerStateLog("DONE");
    }
  }
}

void handleCmd(const char* cmd) {
  String s = String(cmd);
  s.trim();
  s.toUpperCase();
  if (s == "PING") {
    replyOK("PONG");
    return;
  }
  if (s == "DEMO") {
    startPlayback(DEMO_SCORE, DEMO_N);
    return;
  }
  if (s == "PLAY IMP") {
    startPlayback(IMPERIAL_SCORE, IMPERIAL_N);
    return;
  }
  if (s == "PAUSE") {
    if (playing) {
      paused = true;
      replyOK("PAUSED");
      setPlayerStateLog("PAUSED");
    } else
      replyErr("NOT_PLAYING");
    return;
  }
  if (s == "RESUME") {
    if (playing && paused) {
      paused = false;
      replyOK("RESUMED");
      setPlayerStateLog("RESUMED");
    } else
      replyErr("NOT_PAUSED");
    return;
  }
  if (s == "STOP") {
    stopPlayback();
    setPlayerStateLog("STOP");
    return;
  }
  if (s.startsWith("SPD ")) {
    String arg = s.substring(4);
    int v = arg.toInt();
    if (v < 0 || v > 100) {
      replyErr("SPD_RANGE");
      return;
    }
    setSpeeds(v/100.0);
    char buf[64];
    snprintf(buf, sizeof(buf), "SPD=%d", v);
    Serial.println(buf);
    if (bleStream) bleStream->println(buf);
    return;
  }
  replyErr("UNKNOWN_CMD");
}

void processLine() {
  lineBuf[linePos] = '\0';
  handleCmd(lineBuf);
  linePos = 0;
}

void setup() {
  Serial.begin(115200);
  bleSerial.begin(9600);
  bleStream = &bleSerial;
  pinMode(HM10_STATE_PIN, INPUT);
  pinMode(EN_PIN, OUTPUT);
  motorsEnable(false);
  for (int i = 0; i < 4; i++) {
    motors[i]->setMaxSpeed(1400);
    motors[i]->setAcceleration(1000);
  }
  setSpeeds(1.0);
  Serial.println("READY");
  replyOK("READY");
}

void loop() {
  while (bleSerial.available()) {
    char c = bleSerial.read();
    if (c == '\r') continue;
    if (c == '\n') {
      processLine();
    } else {
      if (linePos < sizeof(lineBuf) - 1)
        lineBuf[linePos++] = c;
    }
  }

  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\r') continue;
    if (c == '\n') {
      if (linePos > 0)
        processLine();
    } else {
      if (linePos < sizeof(lineBuf)-1)
        lineBuf[linePos++] = c;
    }
  }

  tickPlayer(IMPERIAL_SCORE, IMPERIAL_N);
}
