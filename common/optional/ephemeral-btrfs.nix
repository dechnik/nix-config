# This file contains an ephemeral btrfs root configuration
# TODO: perhaps partition using disko in the future
{ lib, config, ... }:
let
  hostname = config.networking.hostName;
  rootfsDevice = "/dev/disk/by-label/${hostname}";
  wipeScript = ''
    counter=0

    # systemd initrd offers no way to hook in between
    # 'root device is ready' and 'mount the root device at /sysroot'.
    # Instead, lets poll for the root device.
    # https://github.com/systemd/systemd/issues/24904

    echo "wipe: Waiting for ${rootfsDevice}"
    while [ ! -e ${rootfsDevice} ]; do
      sleep 0.1
      counter=$((counter + 1))
      if [ $counter -ge 300 ]; then
          echo "wipe: Timed out waiting for ${rootfsDevice}"
          exit
      fi
    done
    echo "wipe: Found ${rootfsDevice}. Wiping ephemeral."
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ ${rootfsDevice} "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "wipe: Creating needed directories"
      mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}

      echo "wipe: Cleaning root subvolume"
      btrfs subvolume list -o "$MNTPOINT/root" | cut -f9 -d ' ' |
      while read -r subvolume; do
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done && btrfs subvolume delete "$MNTPOINT/root"

      echo "wipe: Restoring blank subvolume"
      btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;
in
{
  boot.initrd = {
    supportedFilesystems = [ "btrfs" ];
    postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
    systemd.services.restore-root = lib.mkIf phase1Systemd {
      description = "Rollback btrfs rootfs";
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-cryptsetup@${hostname}.service" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = wipeScript;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
    };

    "/persist" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" ];
      neededForBoot = true;
    };

    "/swap" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" ];
    };
  };

  environment.persistence."/persist" = {
    users.lukasz = {
      directories = [
        { directory = ".gnupg"; mode = "0700"; }
      ];
    };
  };

}
