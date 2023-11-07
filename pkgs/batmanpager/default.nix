{ bat
, coreutils-full
, util-linux
, writeShellApplication
}:
writeShellApplication {
  name = "batmanpager";
  runtimeInputs = [ bat coreutils-full util-linux.bin ];
  text = ''
    # shellcheck disable=SC2002
    cat "$1" | col -bx | bat --language man --style plain
  '';
}
