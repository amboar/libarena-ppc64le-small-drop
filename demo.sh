#!/bin/bash

read -p "Show opt pass set 15 fail then pass? (Enter)"
./compile-command.sh 15-broken
read -p "Continue? (Enter) "
./compile-command.sh 15
read -p "Show opt pass set 1 fail then pass? (Enter)"
./compile-command.sh 01-broken
read -p "Continue? (Enter) "
./compile-command.sh 01
