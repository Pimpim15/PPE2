// Minimal Arduino String shim for IntelliSense
#ifndef ARDUINO_STRING_H
#define ARDUINO_STRING_H

#include <string>
#include <algorithm>
#include <cctype>
#include <cstdlib>

class String {
  std::string s;
public:
  String() = default;
  String(const char* c) : s(c ? c : "") {}
  String(const std::string &ss) : s(ss) {}
  void trim() {
    // trim left
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch){ return !std::isspace(ch); }));
    // trim right
    s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch){ return !std::isspace(ch); }).base(), s.end());
  }
  void toUpperCase() {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c){ return std::toupper(c); });
  }
  int toInt() const {
    if (s.empty()) return 0;
    try { return std::stoi(s); } catch(...) { return 0; }
  }
  bool startsWith(const char* pref) const {
    std::string p = pref ? pref : "";
    if (p.size() > s.size()) return false;
    return std::equal(p.begin(), p.end(), s.begin());
  }
  String substring(int from) const {
    if (from < 0) from = 0;
    if ((size_t)from >= s.size()) return String("");
    return String(s.substr((size_t)from));
  }
  String substring(int from, int to) const {
    if (from < 0) from = 0;
    if (to <= from) return String("");
    size_t f = (size_t)from;
    size_t t = (size_t)to;
    if (f >= s.size()) return String("");
    if (t > s.size()) t = s.size();
    return String(s.substr(f, t - f));
  }
  bool operator==(const char* o) const { return s == std::string(o ? o : ""); }
  bool operator==(const String& o) const { return s == o.s; }
  String& operator=(const char* o) { s = o ? o : ""; return *this; }
  int length() const { return (int)s.size(); }
  const char* c_str() const { return s.c_str(); }
  String toUpperCaseCopy() const { String r(*this); r.toUpperCase(); return r; }
  String toLowerCaseCopy() const { String r(*this); std::transform(r.s.begin(), r.s.end(), r.s.begin(), [](unsigned char c){ return std::tolower(c); }); return r; }
};

#endif
