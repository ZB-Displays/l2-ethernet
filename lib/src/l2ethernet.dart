import 'dart:ffi';
import 'dart:io' show Directory;
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
  var libraryPath;
  //  if (Platform.isMacOS) {
  //   libraryPath =
  //       path.join(Directory.current.path, 'eth_library', 'libeth.dylib');
  // }
  // if (Platform.isWindows) {
  //   libraryPath =
  //       path.join(Directory.current.path, 'eth_library', 'Debug', 'eth.dll');
  // }

  var _ethlib;
  SocketStruct myFD;

  L2Ethernet._constructor(String interfaceName, dynamic this._ethlib)
      : myFD = SocketStruct(interfaceName);

  factory L2Ethernet(String interfaceName, String libraryPath) {
    return L2Ethernet._constructor(
        interfaceName, pr.NativeLibrary(DynamicLibrary.open(libraryPath)));
  }

  int getMACAddress() {
    return myFD.srcMACAddress;
  }

  int open() {
    final ifnamePtr = calloc<Uint8>(IF_NAMESIZE);

    for (int i = 0; i < myFD.ifName.length && i < IF_NAMESIZE; ++i) {
      ifnamePtr[i] = myFD.ifName.codeUnitAt(i);
    }
    myFD.socket = _ethlib.socket_open(ifnamePtr);
    myFD.ifrindex = _ethlib.get_ifrindex();
    myFD.srcMACAddress = _ethlib.get_mac_addr();
    calloc.free(ifnamePtr);
    return myFD.socket;
  }

  int close() {
    return _ethlib.socket_close(myFD.socket);
  }

  int send(int src_mac, int dest_mac, int ether_type, Pointer<Uint8> data,
      int len, int flags) {
    var res;
    if (src_mac == 0) src_mac = myFD.srcMACAddress;
    res = _ethlib.socket_send(
        this.myFD.socket, src_mac, dest_mac, ether_type, data, len, flags);
    return res;
  }
}
