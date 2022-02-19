#!/bin/bash

cmake .
make
march=$(uname -m)
mkdir ../../$march
cp libeth* ../../$march/
