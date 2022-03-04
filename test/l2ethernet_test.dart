import 'package:test/test.dart';
import 'dart:io';
import 'package:l2ethernet/l2ethernet.dart';

void main() {
  var ethName = Platform.environment["nic"] ?? "";
  group('Library Basics', () {
    test('Found nic env variable', () {
      expect(ethName, isNot(equals("")));
    });
    test('Can load library', () async {
      var myl2eth = await L2Ethernet.setup(ethName);
      expect(myl2eth.socketData.toString(),
          equals("Socket=0, ifrindex=0, srcMACAddress=0, ifname=$ethName"));
      expect(myl2eth, isNot(equals(0)));
    });
  });
}
