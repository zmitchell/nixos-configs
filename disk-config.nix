{...}:
let
  device = "/dev/sda";
  user = "zmitchell";
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = device;
      content = {
        type = "gpt";
        partitions = {
          {
            name = "MBR";
            type = "EF02"; # for grub MBR
            size = "1M";
            priority = 1; # Needs to be first partition
          }
          {
            name = "ESP";
            size = "500M";
            type = "EF00";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          }
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
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
          # Don't allow the pool itself to be mounted
          canmount = "off";
        };
        datasets = {
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              # Disable atime updates to reduce IO.
              atime = "off";
              # NixOS requires mountpoint=legacy for all datasets
              mountpoint = "legacy";
            };
          };
          "system/var" = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              # NixOS requires mountpoint=legacy for all datasets
              mountpoint = "legacy";
            };
          };
          "system/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              # NixOS requires mountpoint=legacy for all datasets
              mountpoint = "legacy";
            };
          };
          user = {
            type = "zfs_fs";
            mountpoint = "/home/${user}";
            options = {
              # NixOS requires mountpoint=legacy for all datasets
              mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
