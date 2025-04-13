let
  getTemplate = (name: import ./templates/${name}.nix);
  names = [ "gtk" "btop" "discord" "firefox" "ghostty" "tmTheme" ];
in
builtins.listToAttrs (builtins.map (tname: {name = tname; value = getTemplate tname;}) names)
