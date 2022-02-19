import 'package:test/test.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import './l2ethernet.dart';

void main() {
  var ethName = Platform.environment["nic"] ?? "";
  group('Library Basics', () {
    test('Found nic env variable', () {
      expect(ethName, isNot(equals("")));
    });
    test('Can load library', () {
      var myl2eth = L2Ethernet(ethName);
      expect(myl2eth.socketData.toString(),
          equals("Socket=0, ifrindex=0, srcMACAddress=0, ifname=$ethName"));
      expect(myl2eth, isNot(equals(0)));
    });
  });
}
