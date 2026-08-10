{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWE140_205WK1TIFBRG";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWE140_205VK3HCFBRG";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
      disk3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWE140_205XK358FBRG";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
      disk4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWE140_205XK35CFBRG";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        mode = "raidz1";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          data = {
            type = "zfs_fs";
            mountpoint = "/mnt/disks";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
  boot = {
    kernelModules = [ "zfs" ];
    supportedFilesystems = {
      zfs = true;
    };
  };
}
