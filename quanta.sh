#!/bin/bash

egrep '<<< Q [0-9]+ at [0-9]+' $1 | awk '{print ""$5 ", " $7}'