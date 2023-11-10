{
  config,
  options,
  inputs,
  pkgs,
  ...
}:

{
  users.users.zmitchell = {
    name = "zmitchell";
    isNormalUser = true;
    initialPassword = "let-me-in";
    shell = pkgs.zsh;
    # Gives the user sudo permissions
    extraGroups = ["wheel"];

    packages = with pkgs; [
      # put stuff here
    ];
  };
}
