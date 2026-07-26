#!/usr/bin/env bash
# Prints: macos | linux | windows | unknown
u="$(uname -s 2>/dev/null || echo unknown)"
case "$u" in
  Darwin) echo macos ;;
  Linux) echo linux ;;
  MINGW*|MSYS*|CYGWIN*) echo windows ;;
  *) echo unknown ;;
esac
