#!/bin/bash


cd src

make clean

time caffeinate make

say "I'm finished building Postgres app!"
