#!/bin/bash

read -p "Show test fail then pass with opt pass-set 15 ? (Enter)"
./compile-command.sh 15-broken
read -p "Continue? (Enter) "
./compile-command.sh 15
read -p "Show test fail then pass with opt pass-set 1 ? (Enter)"
./compile-command.sh 01-broken
read -p "Continue? (Enter) "
./compile-command.sh 01
read -p "Show test fail then pass by dropping the instcombine subsequent to the inline pass? (Enter)"
./opt-link.sh $(cat p1.upper-broken | grep -v '^#' | tr "$'\012'" " ")
./arena
read -p "Continue? (Enter) "
./opt-link.sh $(cat p1.pre-upper-broken | grep -v '^#' | tr "$'\012'" " ")
./arena
read -p "Show test fail then pass by removing inline when instcombine immediately follows inline pass (Enter)"
./opt-link.sh $(cat p1.lower-broken | grep -v '^#' | tr "$'\012'" " ")
./arena
read -p "Continue? (Enter) "
./opt-link.sh $(cat p1.lower | grep -v '^#' | tr "$'\012'" " ")
./arena
