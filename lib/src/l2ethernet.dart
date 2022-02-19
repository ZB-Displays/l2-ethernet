import 'dart:ffi';
import 'dart:io' show Directory, Process;
import 'package:path/path.dart' as path;
import './eth_bindings.dart' as pr;
import 'package:ffi/ffi.dart';

const IF_NAMESIZE = 16;

class SocketStruct {
  int socket = 0;
  int ifrindex = 0;
  int srcMACAddress = 0;
  String ifName;

  SocketStruct(this.ifName);

  String toString() {
    return "Socket=${this.socket}, ifrindex=${this.ifrindex}, srcMACAddress=${this.srcMACAddress}, ifname=${this.ifName}";
  }
}

class L2Ethernet {
  var _ethlib;
  SocketStruct socketData;

  L2Ethernet._constructor(String interfaceName, dynamic this._ethlib)
      : socketData = SocketStruct(interfaceName);

  factory L2Ethernet(String interfaceName) {
    var march = Process.runSync("uname", ["-m"]).stdout.trim();
    var libraryPath =
        path.join(Directory.current.path, 'lib/$march', 'libeth.so');

    return L2Ethernet._constructor(
        interfaceName, pr.NativeLibrary(DynamicLibrary.open(libraryPath)));
  }

  int getMACAddress() {
    return socketData.srcMACAddress;
  }

  int open() {
    final ifnamePtr = calloc<Uint8>(IF_NAMESIZE);

    for (int i = 0; i < socketData.ifName.length && i < IF_NAMESIZE; ++i) {
      ifnamePtr[i] = socketData.ifName.codeUnitAt(i);
    }
    socketData.socket = _ethlib.socket_open(ifnamePtr);
    socketData.ifrindex = _ethlib.get_ifrindex();
    socketData.srcMACAddress = _ethlib.get_mac_addr();
    calloc.free(ifnamePtr);
    return socketData.socket;
  }

  int close() {
    return _ethlib.socket_close(socketData.socket);
  }

  int send(int src_mac, int dest_mac, int ether_type, Pointer<Uint8> data,
      int len, int flags) {
    var res;
    if (src_mac == 0) src_mac = socketData.srcMACAddress;
    res = _ethlib.socket_send(
        socketData.socket, src_mac, dest_mac, ether_type, data, len, flags);
    return res;
  }
}
