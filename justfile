default:
    just --list

system-init attr:
    nixos-generate-config --root /tmp/config --no-filesystems
    sudo nix run 'github:nix-community/disko/latest#disko-install' -- --flake ".#{{attr}}" --disk "{{disk-name}}" "{{disk-device}}"
