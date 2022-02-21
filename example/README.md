# Examples

I added two examples:

* send_packet.dart which shows a simple example to send a raw Ethernet frame. Use `tcpdump -i $nic 'ether proto 0xbeef` to see it being sent out.
* colorlight.dart sends several frames for a Colorlight card. Used to test this package.

## Notes

0. Both examples need an environment variable `nic` to contain the network interface name to use.
0. Both need to run either as root or the binary has to have the needed capabilities to use a raw socket: `setcap 'cap_net_admin,cap_net_raw+ep' BINARY`
0. Because of the requirement to run as root, I highly recommend to compile stand-alone executables (via `dart compile exe`) which can get above capabilities added. This avoids having to run dart as root.