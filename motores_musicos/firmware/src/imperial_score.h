#ifndef IMPERIAL_SCORE_H
#define IMPERIAL_SCORE_H

#include <stddef.h>

#include "motor_map.h"

// Marcha Imperial (short choreography) - 100 BPM => 600 ms per beat
// Events list: dt_ms is absolute time from start
extern const Event IMPERIAL_SCORE[];
extern const size_t IMPERIAL_N;

#endif
