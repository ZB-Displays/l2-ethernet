sendframes.exe:	sendframes.dart
	dart compile exe $<
	sudo setcap 'cap_net_admin,cap_net_raw+ep' $@
