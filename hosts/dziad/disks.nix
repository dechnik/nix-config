{ disks ? [ "/dev/vda" ], ... }: {
  disk = {
    disk1 = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "0";
            end = "1M";
            part-type = "primary";
            flags = [ "bios_grub" ];
          }
          {
            name = "ESP";
            start = "1M";
            end = "1G";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "zfsroot";
            start = "1G";
            end = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          }
        ];
      };
    };
  };
  zpool = {
    rpool = {
      type = "zpool";
      rootFsOptions = {
        acltype = "posixacl";
        compression = "zstd";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
      };
      options = {
        ashift = "12";
        autotrim = "on";
      };

      datasets = {
        "root" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
          };
          mountpoint = "/";
        };
        "nix" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/nix";
        };
        "var" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/var";
        };
        "persist" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/persist";
        };
        "home" = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
