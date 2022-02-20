# package:l2ethernet

Sending raw Ethernet frames in Dart

## What is this?

This is a small Dart package to make it possible to send raw Ethernet frames out. My use-case was to send data to a [Colorlight 5A receiver card](https://www.colorlight-led.com/product/colorlight-5a-75b-led-display-receiving-card.html) which expect Ethernet frames and I found no way to do that with Dart. The miss-leadingly named [RawSocket class](https://api.dart.dev/stable/2.16.1/dart-io/RawSocket-class.html) used TCP.

Thus this package was born: via [FFI](https://dart.dev/guides/libraries/c-interop) it uses the Linux [socket()](https://man7.org/linux/man-pages/man2/socket.2.html) interface to send out raw Ethernet frames. Can be used to send arbitrary Ethernet packets. WOL packets, ARP spoofing, custom protocols come into mind.

## Testing

[Tests](https://github.com/haraldkubota/l2-ethernet/tree/main/test) contain two parts: one which can be run as non-root and one which requires root (or similar permissions) as it actually opens a raw socket. I do run tcpdump in the background to capture the sent Ethernet packet and verify it's what I expect it to be.

## Compiling the shared library

This is actually simple as the C layer is very short. I added a [buildme.sh](https://github.com/haraldkubota/l2-ethernet/blob/main/lib/src/eth_library/buildme.sh) script. It's that simple.

## macOS, Windows, Android, iOS

Sorry, no support from my side for those.

## Limitations

* Receiving frames is not currently implemented.
* This is nor performance optimized: A single frame is sent out synchronously. If performance is required, [sendmmsg()](https://man7.org/linux/man-pages/man2/sendmmsg.2.html) should be used.
* Only Linux supported and the shared library is only available for x86_64 and aarch64. It's very simple to compile the library though (see [buildme.sh](https://github.com/haraldkubota/l2-ethernet/blob/main/lib/src/eth_library/buildme.sh)).
* The package depends on finding the shared library. I have not yet mastered the method.
