{
  device,
  user,
  ...
}:
{
  disko.devices.main = {
    disk = {
      type = "disk";
      device = device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1GiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          zfs = {
            size = "100%";
            pool = "zroot";
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mountpoint = "/";
        # Create a snapshot of the root filesystem as soon as it's created.
        postCreateHook = "zfs snapshot zroot@blank";
        rootFsOptions = {
          # Enable additional access control features as they're intended to be used
          # in ZFS.
          acltype = "posixacl";
          xattr = "sa";
          # Enable compression by default.
          compression = "zstd";
        };
        datasets = {
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              # Disable atime updates to reduce IO.
              atime = "off";
              # NixOS requires mountpoint=legacy for all datasets
              options.mountpoint = "legacy";
            };
          };
          "system/var" = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              # NixOS requires mountpoint=legacy for all datasets
              options.mountpoint = "legacy";
            };
          };
          "system/root" = {
            type = "zfs_fs";
            mountpoint = "/root";
            options = {
              # NixOS requires mountpoint=legacy for all datasets
              options.mountpoint = "legacy";
            };
          };
          user = {
            type = "zfs_fs";
            mountpoint = "/home/${user}";
            options = {
              # NixOS requires mountpoint=legacy for all datasets
              options.mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
