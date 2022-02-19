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
  });
  group('Raw socket ops (needs root)', () {
    test('Open and close socket', () {
      var myl2eth = L2Ethernet(ethName);
      var res;
      res = myl2eth.open();
      print("srcMACAddress=${myl2eth.socketData.srcMACAddress}");
      expect(res, greaterThan(0));
      res = myl2eth.close();
      expect(res, equals(0));
    });
    test('Send frame 0xbeef 100 data byte on socket', () async {
      const src_mac = 0x222233445566;
      const dest_mac = 0x112233445566;
      const len = 100;
      var data = calloc<Uint8>(len);

      var myl2eth = L2Ethernet(ethName);
      var res;
      for (var i = 0; i < len; ++i) data[i] = i + 32;

      List<String> output = [];

      final futProcess = Process.run(
          'timeout',
          [
            '10s',
            'tcpdump',
            '-c',
            '1',
            '-n',
            '-e',
            '-i',
            ethName,
            'ether proto 0xbeef'
          ],
          runInShell: true,
          stdoutEncoding: utf8);

      // Run tcpdump to listen to the packet we'll send, but wait a second after starting it
      // as otherwise tcpdump is not yet listening.

      await Future.delayed(Duration(seconds: 1));

      res = myl2eth.open();
      res = myl2eth.send(src_mac, dest_mac, 0xbeef, data, len, 0);
      // 14 Byte L2 Header: src MAC (6), dest MAC (6), type (2)
      expect(res, equals(len + 14));
      res = myl2eth.close();

      // await Future.delayed(Duration(seconds: 1));
      final process = await futProcess;

      // print("stdout=${process.stdout}, stderr=${process.stderr}");
      expect(process.stdout, contains("22:22:33:44:55:66 > 11:22:33:44:55:66"));
      expect(process.stdout, contains("ethertype Unknown (0xbeef)"));
      expect(process.stdout, contains("length 114:"));
      expect(process.stdout, contains("0x0060:  8081 8283"));
    });
  });
}
