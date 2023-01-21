{
  lib
, pkgs
, ...
}:
with lib; let
  bashScript = name: scriptDependencies: (
    pkgs.resholve.writeScriptBin
      "${name}"
      {
        interpreter = "${pkgs.bash}/bin/bash";
        inputs = scriptDependencies;
        fake.external = [ "sudo" "ping" "mount" "umount" ];
        execer = [
          "cannot:${pkgs.git}/bin/git"
          "cannot:${pkgs.gzip}/bin/uncompress"
          "cannot:${pkgs.networkmanager}/bin/nmcli"
          "cannot:${pkgs.nixos-install-tools}/bin/nixos-generate-config"
          "cannot:${pkgs.nixos-install-tools}/bin/nixos-install"
          "cannot:${pkgs.nixos-rebuild}/bin/nixos-rebuild"
          "cannot:${pkgs.nix}/bin/nix"
          "cannot:${pkgs.nix}/bin/nix-collect-garbage"
          "cannot:${pkgs.openssh}/bin/ssh"
          "cannot:${pkgs.p7zip}/bin/7z"
          "cannot:${pkgs.p7zip}/bin/7za"
          "cannot:${pkgs.procps}/bin/pkill"
          "cannot:${pkgs.rsync}/bin/rsync"
          "cannot:${pkgs.sway}/bin/swaymsg"
          "cannot:${pkgs.systemd}/bin/systemctl"
          "cannot:${pkgs.util-linux}/bin/swapon"
          "cannot:${pkgs.wl-clipboard}/bin/wl-copy"
          "cannot:${pkgs.wpa_supplicant}/bin/wpa_passphrase"
        ];
      }
      (builtins.readFile ./scripts/${
      name}.sh)
  );

  s-setup-nixos-native-encrypted-zfs-boot = bashScript "setup-nixos-native-encrypted-zfs-boot" (with pkgs; [
    coreutils
    util-linux
    gnused
    gawk
    gnugrep
    git
    networkmanager
    wpa_supplicant
    systemd
    findutils
    gptfdisk
    zfs
    dosfstools
    nixpkgs-fmt
    nixos-install-tools
  ]);
in
{
  environment.systemPackages = with pkgs; [
    s-setup-nixos-native-encrypted-zfs-boot
  ];
}
