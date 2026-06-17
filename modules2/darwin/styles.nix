{
  flake.modules.darwin.styles =
    { pkgs, ... }:
    {
      stylix = {
        enable = true;
        autoEnable = false;
        polarity = "light";
        # This option must be set, but it doesn't seem
        # to actually do anything on darwin, and it's
        # overridden in the home-manager module.
        image = ./../../wallpapers/grayscale-desert.jpg;
      };
    };
}
