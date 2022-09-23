# package:l2ethernet

Sending raw Ethernet frames in Dart

## What is this?

This is a small Dart package to make it possible to send raw Ethernet frames
out. My use-case was to send data to a
[Colorlight 5A receiver card](https://www.colorlight-led.com/product/colorlight-5a-75b-led-display-receiving-card.html)
which expect Ethernet frames and I found no way to do that with Dart. The
miss-leadingly named
[RawSocket class](https://api.dart.dev/stable/2.16.1/dart-io/RawSocket-class.html)
used TCP.

Thus this package was born: via
[FFI](https://dart.dev/guides/libraries/c-interop) it uses the Linux
[socket()](https://man7.org/linux/man-pages/man2/socket.2.html) interface to
send out raw Ethernet frames. Can be used to send arbitrary Ethernet packets.
WOL packets, ARP spoofing, custom protocols come into mind.

## Testing

[Tests](https://github.com/haraldkubota/l2-ethernet/tree/main/test) contain two
parts: one which can be run as non-root and one which requires root (or similar
permissions) as it actually opens a raw socket. I do run tcpdump in the
background to capture the sent Ethernet packet and verify it's what I expect it
to be.

## Compiling the shared library

This is actually simple as the C layer is very short. I added a
[buildme.sh](https://github.com/haraldkubota/l2-ethernet/blob/main/lib/src/eth_library/buildme.sh)
script. It's that simple:
```
❯ cd lib/src/eth_library
❯ ./buildme.sh
-- The C compiler identification is GNU 11.2.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: /home/harald/git/l2-ethernet/lib/src/eth_library
[ 25%] Building C object CMakeFiles/eth_library.dir/sendeth.c.o
[ 50%] Linking C shared library libeth.so
[ 50%] Built target eth_library
[ 75%] Building C object CMakeFiles/sendeth_test.dir/sendeth.c.o
[100%] Linking C executable sendeth_test
[100%] Built target sendeth_test
```
and the result is in ./lib/x86\_64/ (if compiled on x86\_64)

Now you can run the test program:
```
❯ dart pub get
❯ make
dart compile exe -o send_packet.exe example/send_packet.dart
Info: Compiling with sound null safety
Generated: /home/harald/git/l2-ethernet/send_packet.exe
sudo setcap 'cap_net_admin,cap_net_raw+ep' send_packet.exe
```

## macOS, Windows, Android, iOS

Sorry, no support from my side for those.

## Limitations

- Receiving frames is not currently implemented.
- This is nor performance optimized: A single frame is sent out synchronously.
  If performance is required,
  [sendmmsg()](https://man7.org/linux/man-pages/man2/sendmmsg.2.html) should be
  used.
- Only Linux supported and the shared library is only available for x86_64 and
  aarch64. It's very simple to compile the library though (see
  [buildme.sh](https://github.com/haraldkubota/l2-ethernet/blob/main/lib/src/eth_library/buildme.sh)).
- 32 bit ARM seems to not work (see [here](https://github.com/haraldkubota/l2-ethernet/issues/1)

## Note on libeth.so for Dart exe and aot

Dart can use packages (pulled in by dart pub get), but when compiled to exe or
aot, it does not look at packages and thus libeth.so will not be found. While it
would be nice to statically link it to the executable file (or aot file), this
does not work as of Dart 2.16.1 The workaround is to have the needed libeth.so
file in ./lib/$march/libeth.so where . is the path of the binary (e.g.
sendframe.exe) See also https://github.com/dart-lang/sdk/issues/47718
