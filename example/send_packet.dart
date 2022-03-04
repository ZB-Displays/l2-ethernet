// Simple example of how to send one raw Ethernet frame
// Requires "nic" environment variable to have the NIC name (e.g. eth0)

// You can watch the traffic by running tcpdump in another window:
//
// $ tcpdump -i $nic 'ether proto 0xbeef'
// tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
// listening on enp3s0f0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
// 23:12:50.672028 22:22:33:44:55:66 (oui Unknown) > 11:22:33:44:55:66 (oui Unknown), ethertype Unknown (0xbeef), length 114:
//         0x0000:  2021 2223 2425 2627 2829 2a2b 2c2d 2e2f  .!"#$%&'()*+,-./
//         0x0010:  3031 3233 3435 3637 3839 3a3b 3c3d 3e3f  0123456789:;<=>?
//         0x0020:  4041 4243 4445 4647 4849 4a4b 4c4d 4e4f  @ABCDEFGHIJKLMNO
//         0x0030:  5051 5253 5455 5657 5859 5a5b 5c5d 5e5f  PQRSTUVWXYZ[\]^_
//         0x0040:  6061 6263 6465 6667 6869 6a6b 6c6d 6e6f  `abcdefghijklmno
//         0x0050:  7071 7273 7475 7677 7879 7a7b 7c7d 7e7f  pqrstuvwxyz{|}~.
//         0x0060:  8081 8283                                ....
// 1 packet captured
// 1 packet received by filter
// 0 packets dropped by kernel

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:l2ethernet/l2ethernet.dart';

void main() async {
  final ethName = Platform.environment["nic"] ?? "eth0";
  const src_mac = 0x222233445566;
  const dest_mac = 0x112233445566;
  const len = 100;
  var res;
  final data = calloc<Uint8>(len);

  print("Preparing buffer of $len bytes");

  final myl2eth = await L2Ethernet.setup(ethName);
  for (var i = 0; i < len; ++i) data[i] = i + 32;

  print("Opening the socket");

  res = myl2eth.open();
  if (res == 0) {
    print("Problems opening $ethName. Aborting.");
    exit(20);
  }
  print("FYI: open() returned $res");

  res = myl2eth.send(src_mac, dest_mac, 0xbeef, data, len, 0);
  print("$res (should be 114) bytes sent");

  print("Closing socket now");
  res = myl2eth.close();
  if (res != 0) {
    print("Closing the socket returned $res (should have been 0)");
  }
  calloc.free(data);
}
