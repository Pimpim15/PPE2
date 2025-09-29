// Minimal AccelStepper shim for IntelliSense only
#ifndef ACCELSTEPPER_SHIM_H
#define ACCELSTEPPER_SHIM_H

class AccelStepper {
public:
  enum MotorInterfaceType { DRIVER };
  AccelStepper(MotorInterfaceType, int stepPin, int dirPin) {}
  void setMaxSpeed(float s) {}
  void setAcceleration(float a) {}
  void moveTo(long pos) {}
  void stop() {}
  bool run() { return true; }
  long distanceToGo() { return 0; }
};

#endif
