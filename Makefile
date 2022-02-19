all:	send_packet.exe

send_packet.exe:	example/send_packet.dart
	dart compile exe -o $@ $<
	sudo setcap 'cap_net_admin,cap_net_raw+ep' $@

colorlight.exe:	example/colorlight.dart
	dart compile exe -o $@ $<
	sudo setcap 'cap_net_admin,cap_net_raw+ep' $@
