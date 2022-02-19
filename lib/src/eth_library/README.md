# Send Ethernet Frames for Dart

This started as an example how to use FFI in Dart.

## Build

```
$ cmake .
$ make
$ march=$(uname -m)
$ mkdir ../../$march
$ cp libeth* ../../$march
```
