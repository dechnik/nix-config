{ config
, lib
, pkgs
, ...
}:{
  boot = {
    initrd.supportedFilesystems = [ "zfs" ]; # boot from zfs
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "nohibernate" ]; # ZFS misses support for freeze/thaw operations.This means that using ZFS together with hibernation (suspend to disk) may cause filesystem corruption.See https://github.com/openzfs/zfs/issues/260.
    supportedFilesystems = [ "zfs" ];
    zfs.enableUnstable = false;
    # initrd.postDeviceCommands = mkAfter ''
    #   zfs rollback -r ${cfg.rootDataset}@blank
    # '';
  };

  services.udev.extraRules = ''
        ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
      ''; # zfs already has its own scheduler. without this (@Artturin)'s computer froze for a second when he nix builds something.
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
