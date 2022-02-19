import 'package:test/test.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import './l2ethernet.dart';

const ethName = "eth0";

void main() {
  String libraryPath =
      path.join(Directory.current.path, 'eth_library', 'libeth.so');

  group('Library Basics', () {
    test('Can load library', () {
      var myl2eth = L2Ethernet(ethName, libraryPath);
      expect(myl2eth.myFD.toString(),
          equals("Socket=0, ifrindex=0, srcMACAddress=0, ifname=$ethName"));
      expect(myl2eth, isNot(equals(0)));
    });
  });
}
