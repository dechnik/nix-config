{ disks ? [ "/dev/nvme0n1" ], ... }: {
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
            name = "root";
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
              };
            };
          }
        ];
      };
    };
  };
}
