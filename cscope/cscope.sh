#!/usr/bin/env bash
find . \( -name "*.[ch]" -or -name "*.[ch]pp" -or -name "*.cc" -or -name "*.hh" \) -exec echo \"{}\" \; > cscope.files
cscope -Rb
