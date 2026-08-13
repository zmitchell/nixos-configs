{
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          # Fork of upstream Proton with extra patches not yet upstreamed
          proton-ge-bin
        ];
      };
      # Allow Steam to detect hardware changes i.e. controllers being added
      hardware.steam-hardware.enable = true;
      programs.gamemode.enable = true;
    };
}
