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

  group('Raw socket ops (needs root)', () {
    test('Open and close socket', () {
      var myl2eth = L2Ethernet(ethName, libraryPath);
      var res;
      res = myl2eth.open();
      print("srcMACAddress=${myl2eth.myFD.srcMACAddress}");
      expect(res, greaterThan(0));
      res = myl2eth.close();
      expect(res, equals(0));
    }, skip: "Needs root");
    test('Send frame 0xbeef 100 data byte on socket', () async {
      const src_mac = 0x222233445566;
      const dest_mac = 0x112233445566;
      const len = 100;
      var data = calloc<Uint8>(len);

      var myl2eth = L2Ethernet(ethName, libraryPath);
      var res;
      for (var i = 0; i < len; ++i) data[i] = i + 32;

      List<String> output = [];

      final process = Process.run('tcpdump',
          ['-c', '1', '-n', '-e', '-i', ethName, '"ether proto 0xbeef"'],
          runInShell: true);

      // Run tcpdump to listen to the packet we'll send

      sleep(Duration(seconds: 3));

      res = myl2eth.open();
      res = myl2eth.send(src_mac, dest_mac, 0xbeef, data, len, 0);
      // 14 Byte L2 Header: src MAC (6), dest MAC (6), type (2)
      expect(res, equals(len + 14));
      res = myl2eth.close();

      sleep(Duration(seconds: 3));
      final proc = await process;

      print(proc.stdout);
    });
  });
}
