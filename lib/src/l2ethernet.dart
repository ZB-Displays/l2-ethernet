import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;
import './eth_bindings.dart' as pr;
import 'package:ffi/ffi.dart';

const IF_NAMESIZE = 16;

class L2Ethernet {
  String interfaceName;
  int srcMACAddress = 0;
  var libraryPath =
      path.join(Directory.current.path, 'eth_library', 'libeth.so');
  var ethlib;

  int socket = 0;

  L2Ethernet(String this.interfaceName) {
    ethlib = pr.NativeLibrary(DynamicLibrary.open(libraryPath));
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

    for (int i = 0; i < interfaceName.length && i < IF_NAMESIZE; ++i) {
      ifname[i] = interfaceName.codeUnitAt(i);
    }
    socket = ethlib.socket_open(ifname);
    return socket;
  }

  int close() {
    int res = ethlib.socket_close(socket);
    socket = 0;
    return res;
  }

  int send() {
    return 0;
  }
}
