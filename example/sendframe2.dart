// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// export nic=eth0 or whatever NIC you use
// Needs to run as root or via
// sudo setcap 'cap_net_admin,cap_net_raw+ep' sendeth_detect.exe
// Note that the Colorlight card send back a frame (from 11:22:33:44:55:66 to ff:ff:ff:ff:ff:ff)
// and you need a network sniffer to see it

// It's also possible to run via JIT:
// sudo ~/dart/bin/dart sendrow.dart

import 'dart:ffi';
import 'dart:io';
// import 'dart:typed_data';
// import 'dart:convert';
import 'package:ffi/ffi.dart';
import '../lib/l2ethernet.dart';

const columnCount = 128;
const rowCount = 64;

const IF_NAMESIZE = 16;

// void printArray(Pointer<Uint8> ptr, count) {
//   for (var i = 0; i < count; ++i) {
//     stdout.write('ptr[${i}]=${ptr[i]} ');
//   }
//   stdout.write('\n');
// }

const frame0107DataLength = 98;
const frame0affDataLength = 63;
const frame5500DataLength = columnCount * 3 + 7;
final frameData0107 = calloc<Uint8>(frame0107DataLength);
final frameData0aff = calloc<Uint8>(frame0affDataLength);
final frameData5500 = calloc<Uint8>(frame5500DataLength);

// Brightness in 2 variations. Max 255 for both
const brightness = 0x28;
const brightnessPercent = 3;

void initFrames() {
  frameData0107[11] = brightnessPercent;
  frameData0107[12] = 5;
  frameData0107[14] = brightnessPercent;
  frameData0107[15] = brightnessPercent;
  frameData0107[16] = brightnessPercent;

  frameData0aff[0] = brightness;
  frameData0aff[1] = brightness;
  frameData0aff[2] = 255;

  frameData5500[0] = 0;
  frameData5500[1] = 0;
  frameData5500[2] = 0;
  frameData5500[3] = 0;
  frameData5500[4] = columnCount;
  frameData5500[5] = 0x08;
  frameData5500[6] = 0x88;
}

void calculateFrame5500Row(int t, int y) {
  for (int i = 0; i < columnCount; ++i) {
    if (i == t || t == y || y == 2 * rowCount - t) {
      frameData5500[7 + 3 * i] = 127;
      frameData5500[7 + 3 * i + 1] = 127;
      frameData5500[7 + 3 * i + 2] = 127;
    } else {
      frameData5500[7 + 3 * i] = 0;
      frameData5500[7 + 3 * i + 1] = t;
      frameData5500[7 + 3 * i + 2] = 0;
    }
  }
}

void deleteFrames() {
  calloc.free(frameData0107);
  calloc.free(frameData0aff);
  calloc.free(frameData5500);
}

void main() async {
  var ethName = Platform.environment["nic"];
  if (ethName == null) {
    print("Set nic environment variable first");
    exit(20);
  } else {
    int n = 0;
    var myl2eth = L2Ethernet(ethName);
    myl2eth.open();
    const src_mac = 0x222233445566;
    const dest_mac = 0x112233445566;
    const flags = 0;

    initFrames();

    // Draw 128 frames, one vertical black line from left to right
    // to see tearing or lack of smoothness
    for (int k = 0; k < 10; ++k) {
      await sweep(n, myl2eth, src_mac, dest_mac, flags);
    }
    deleteFrames();
  }
}

const wait = true;
const waitTime = 19;

Future<void> sweep(
    int n, L2Ethernet l2, int src_mac, int dest_mac, int flags) async {
  for (int t = 0; t < 128; ++t) {
    // Send a brightness packet

    n = l2.send(src_mac, dest_mac, 0x0a00 + brightness, frameData0aff,
        frame0affDataLength, flags);

    // Send one complete frame

    for (int y = 0; y < rowCount; ++y) {
      calculateFrame5500Row(t, y);
      frameData5500[0] = y;
      n = l2.send(
          src_mac, dest_mac, 0x5500, frameData5500, frame5500DataLength, flags);
    }

    // Without the following delay the end of the bottom row module flickers in the last line

    if (wait) await Future.delayed(Duration(milliseconds: 1));

    // Display frame

    n = l2.send(
        src_mac, dest_mac, 0x0107, frameData0107, frame0107DataLength, flags);

    // 20 fps, wait 50ms but subtract the 1ms from above
    if (wait) await Future.delayed(Duration(milliseconds: waitTime));
  }
  for (int t = 127; t >= 0; --t) {
    // Send a brightness packet

    n = l2.send(src_mac, dest_mac, 0x0a00 + brightness, frameData0aff,
        frame0affDataLength, flags);

    // Send one complete frame

    for (int y = 0; y < rowCount; ++y) {
      calculateFrame5500Row(t, y);
      frameData5500[0] = y;
      n = l2.send(
          src_mac, dest_mac, 0x5500, frameData5500, frame5500DataLength, flags);
    }

    // Without the following delay the end of the bottom row module flickers in the last line

    if (wait) await Future.delayed(Duration(milliseconds: 1));

    // Display frame

    n = l2.send(
        src_mac, dest_mac, 0x0107, frameData0107, frame0107DataLength, flags);

    // 20 fps, wait 50ms but subtract the 1ms from above

    if (wait) await Future.delayed(Duration(milliseconds: waitTime));
  }
}
