#ifndef DEMO_SCORE_H
#define DEMO_SCORE_H

// Simple demo: small oscillation on X/Y/Z/A over ~10s
const Event DEMO_SCORE[] = {
  {0, 0, 0, 0, 0},
  {500, 200, -200, 0, 0},
  {1000, -200, 200, 50, -50},
  {1500, 0, 0, -100, 100},
  {2000, 300, -300, 0, 0},
  {2500, -300, 300, 0, 0},
  {3000, 0, 0, 0, 0},
  {3500, 100, 100, 100, -100},
  {4000, -100, -100, -100, 100},
  {4500, 0, 0, 0, 0}
};
const size_t DEMO_N = sizeof(DEMO_SCORE)/sizeof(DEMO_SCORE[0]);

#endif
