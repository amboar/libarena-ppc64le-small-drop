#!/bin/bash

read -p "Show test fail then pass with opt pass-set 15 ? (Enter) "
./compile-command.sh 15-broken
read -p "Continue? (Enter) "
./compile-command.sh 15
read -p "Show test fail then pass with opt pass-set 1 ? (Enter) "
./compile-command.sh 01-broken
read -p "Continue? (Enter) "
./compile-command.sh 01
read -p "Show test fail then pass by dropping the instcombine subsequent to the inline pass? (Enter) "
./opt-link.sh $(./print-pass.sh p1.upper-broken)
./arena
read -p "Continue? (Enter) "
./opt-link.sh $(./print-pass.sh p1.pre-upper-broken)
./arena
read -p "Show test fail then pass by removing inline when instcombine immediately follows inline pass? (Enter) "
./opt-link.sh $(./print-pass.sh p1.lower-broken)
./arena
read -p "Continue? (Enter) "
./opt-link.sh $(./print-pass.sh p1.lower)
./arena
read -p "Show simplifycfg is required for test to fail: '$(./print-pass.sh p1.reduced-broken)' ? (Enter) "
./opt-link.sh $(./print-pass.sh p1.reduced-broken)
./arena
read -p "Continue with '$(./print-pass.sh p1.reduced)' ? (Enter) "
./opt-link.sh $(./print-pass.sh p1.reduced)
./arena
read -p "Show '$(./print-pass.sh po.reduced-broken)' is the fully reduced optimisation pipeline ? (Enter) "
./opt-once-link.sh $(./print-pass.sh po.reduced-broken)
./arena
read -p "Continue with '$(./print-pass.sh po.reduced)' ? (Enter) "
./opt-once-link.sh $(./print-pass.sh po.reduced)
./arena
