{
  flake.modules.generic.system_fonts =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.system_fonts = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          input-fonts
          ubuntu-classic
          nerd-fonts.hack
          nerd-fonts.fira-code
          nerd-fonts.inconsolata
          nerd-fonts.symbols-only
          atkinson-hyperlegible-mono
          atkinson-hyperlegible-next
        ];
        description = "Basic system-wide fonts to include";
      };

      config = {
        nixpkgs.config.input-fonts.acceptLicense = true;
        fonts.packages = config.system_fonts;
      };
    };
}
