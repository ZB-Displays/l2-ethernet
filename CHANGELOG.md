# 0.3.1

- Find the libeth.so, first in the packages (when run via "dart run") or in
  ./lib/$march/ when compiled to exe or aot (. is the directory where the binary
  executable file is, thus this only works for exe as for aot the executable is
  dartaotruntime)

# 0.3.0

- To setup the L2Ethernet object, use L2Ethernet.setup(String nicname). It's an
  async function since loading the module is an async operation.

# 0.2.2

- Make the path of libeth.so relative to the module (i.e. don't use the CWD)

# 0.2.1

- Fix small issues the analyzer at pub.dev found
- Updated examples to use a package directly (since now a package exists)

# 0.2.0

- Works on ARM64 and x86_64 on Linux
- Send-only
- Add example program
