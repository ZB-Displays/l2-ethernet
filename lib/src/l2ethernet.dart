import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;
import './eth_bindings.dart' as pr;
import 'package:ffi/ffi.dart';

const IF_NAMESIZE = 16;

class SocketStruct {
  int socket;
  int ifrindex;
  int srcMACAddress;
  String ifName;

  SocketStruct(ifName) {
    this.socket = 0;
    this.ifrindex = 0;
    this.srcMACAddress = 0;
    this.ifName = ifName;
  }
}

class L2Ethernet {
  final libraryPath =
      path.join(Directory.current.path, 'eth_library', 'libeth.so');
  late ethlib;
  late SocketStruct myFD;

  L2Ethernet(String interfaceName) {
    this.myFD = SocketStruct(interfaceName);
    this.ethlib = pr.NativeLibrary(DynamicLibrary.open(libraryPath));
  }

  int getMACAddress() {
    return srcMACAddress;
  }

  int open() {
    // if (Platform.isMacOS) {
    //   libraryPath =
    //       path.join(Directory.current.path, 'eth_library', 'libeth.dylib');
    // }
    // if (Platform.isWindows) {
    //   libraryPath =
    //       path.join(Directory.current.path, 'eth_library', 'Debug', 'eth.dll');
    // }
    final ifname = calloc<Uint8>(IF_NAMESIZE);

    for (int i = 0; i < myFD.ifName.length && i < IF_NAMESIZE; ++i) {
      ifname[i] = myFD.ifName.codeUnitAt(i);
    }
    myFD.socket = ethlib.socket_open(ifname);
    calloc.free(ifname);
    return myFD.socket;
  }

  int close() {
    int res = ethlib.socket_close(myFD.socket);
    myFD.socket = 0;
    return res;
  }

  int send() {
    print("Sending stuff here...");
    return 0;
  }
}
