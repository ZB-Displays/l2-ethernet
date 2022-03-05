# Examples

I added two examples:

- send_packet.dart which shows a simple example to send a raw Ethernet frame.
  Use `tcpdump -i $nic 'ether proto 0xbeef` to see it being sent out.
- colorlight.dart sends several frames for a Colorlight card. Used to test this
  package.

## Note on libeth.so for Dart exe and aot

Dart can use packages (pulled in by dart pub get), but when compiled to exe or
aot, it does not look at packages and thus libeth.so will not be found. While it
would be nice to statically link it to the executable file (or aot file), this
does not work as of Dart 2.16.1 The workaround is to have the needed libeth.so
file in ./lib/$march/libeth.so where . is the path of the binary (e.g.
sendframe.exe)

## More Notes

0. Both examples need an environment variable `nic` to contain the network
   interface name to use.
1. Both need to run either as root or the binary has to have the needed
   capabilities to use a raw socket:
   `setcap 'cap_net_admin,cap_net_raw+ep' BINARY`
2. Because of the requirement to run as root, I highly recommend to compile
   stand-alone executables (via `dart compile exe`) which can get above
   capabilities added. This avoids having to run dart as root.
