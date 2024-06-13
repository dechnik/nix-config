{ disks ? [ "/dev/nvme0n1" ], ... }: {
  disk = {
    disk1 = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            priority = 1;
            start = "0";
            end = "1M";
            type = "EF02"; # for grub MBR
          };
          ESP = {
            priority = 2;
            type = "EF00";
            start = "1M";
            end = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            priority = 3;
            start = "1G";
            end = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
              # if you want to use the key for interactive login be sure there is no trailing newline
              # for example use `echo -n "password" > /tmp/secret.key`
              settings.keyFile = "/tmp/secret.key";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                # mountOptions = [ "compress=zstd" ];
              };
            };
          };
        };
      };
    };
  };
}
