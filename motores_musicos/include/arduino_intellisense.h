#ifndef ARDUINO_INTELLISENSE_H
#define ARDUINO_INTELLISENSE_H

// Minimal, editor-only definitions to help VS Code IntelliSense.
// These are intentionally small and defensive so they don't conflict with
// the real Arduino/toolchain headers used at build time.

// Provide size_t if the IntelliSense parser doesn't pick up the standard headers.
// This fallback is intentionally simple and only used by the editor.
#ifndef _INTELLISENSE_SIZE_T_DEFINED
	#ifdef __SIZE_TYPE__
		typedef __SIZE_TYPE__ size_t;
	#else
		typedef unsigned long size_t;
	#endif
	#define _INTELLISENSE_SIZE_T_DEFINED
#endif

// Minimal Stream-like class so references to Serial resolve in the editor.
class Stream {
public:
	virtual void begin(unsigned long /*baud*/) {}
	virtual int available() { return 0; }
	virtual int read() { return -1; }
	virtual size_t write(unsigned char) { return 0; }
	virtual void println(const char*) {}
	virtual void println(unsigned long) {}
	virtual void println() {}
	virtual void print(const char*) {}
	virtual void print(unsigned long) {}
};

// Loose declaration for the global Serial object used in Arduino sketches.
extern Stream Serial;

#endif // ARDUINO_INTELLISENSE_H
