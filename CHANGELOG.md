# 0.3.0

* To setup the L2Ethernet object, use L2Ethernet.setup(String nicname). It's an async function since loading the module is an async operation.

# 0.2.2

* Make the path of libeth.so relative to the module (i.e. don't use the CWD)

# 0.2.1

* Fix small issues the analyzer at pub.dev found
* Updated examples to use a package directly (since now a package exists)

# 0.2.0

* Works on ARM64 and x86_64 on Linux
* Send-only
* Add example program
